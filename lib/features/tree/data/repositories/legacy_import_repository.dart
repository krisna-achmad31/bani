import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/core/utils/formatters.dart';
import 'package:bani/features/auth/domain/entities/app_user.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  LegacyImportRepository — copies the old nested `mungin` data (children in
//  `anak[]` arrays and/or `anak` subcollections) into families/{id}/members.
//  Super Admin only (rules). The legacy collection is never modified.
// ─────────────────────────────────────────────────────────────────────────────

class LegacyNode {
  LegacyNode(this.data) : name = (data['nama'] as String? ?? '').trim();

  final Map<String, dynamic> data;
  final String name;
  final children = <LegacyNode>[];

  /// Adds [child], merging with an existing sibling of the same name
  /// (the same person can appear in both the array and the subcollection).
  void addChild(LegacyNode child) {
    final key = child.name.toLowerCase();
    final same = children.where((c) => key.isNotEmpty && c.name.toLowerCase() == key).firstOrNull;
    if (same == null) {
      children.add(child);
    } else {
      for (final e in child.data.entries) {
        same.data.putIfAbsent(e.key, () => e.value);
      }
      child.children.forEach(same.addChild);
    }
  }
}

class LegacyPreview {
  LegacyPreview({required this.root, required this.alreadyImported});

  final LegacyNode root;
  final bool alreadyImported;

  int get total {
    int count(LegacyNode n) => 1 + n.children.fold(0, (a, c) => a + count(c));
    return count(root);
  }

  Map<int, int> get perGeneration {
    final out = <int, int>{};
    void walk(LegacyNode n, int g) {
      out[g] = (out[g] ?? 0) + 1;
      for (final c in n.children) {
        walk(c, g + 1);
      }
    }

    walk(root, 1);
    return out;
  }
}

class LegacyImportRepository {
  LegacyImportRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<LegacyPreview> preview() async {
    try {
      final snap = await _db.collection(AppConstants.legacyCollection).get();
      if (snap.docs.isEmpty) {
        throw AppFailure(tr.importEmpty);
      }
      final rootName = AppConstants.legacyFamilyName.replaceFirst('Bani ', '');
      final root = LegacyNode({'nama': rootName});

      for (final doc in snap.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        final name = (data['nama'] as String? ?? '').trim();
        // A document without a name (or named after the ancestor) IS the
        // ancestor; otherwise it is one of the ancestor's children.
        final isRoot = name.isEmpty || name.toLowerCase() == rootName.toLowerCase();
        final target = isRoot ? root : LegacyNode(data);
        if (isRoot) {
          for (final e in data.entries) {
            if (e.key != 'anak') root.data.putIfAbsent(e.key, () => e.value);
          }
        }
        _addArrayChildren(target, data['anak']);
        await _addSubcollectionChildren(target, doc.reference);
        if (!isRoot) root.addChild(target);
      }

      final exists = (await _db
              .collection(AppConstants.familiesCollection)
              .doc(AppConstants.legacyFamilyId)
              .get())
          .exists;
      return LegacyPreview(root: root, alreadyImported: exists);
    } catch (e) {
      throw AppFailure.from(e);
    }
  }

  void _addArrayChildren(LegacyNode parent, Object? list) {
    if (list is! List) return;
    for (final item in list.whereType<Map>()) {
      final node = LegacyNode(Map<String, dynamic>.from(item));
      _addArrayChildren(node, item['anak']);
      parent.addChild(node);
    }
  }

  Future<void> _addSubcollectionChildren(
      LegacyNode parent, DocumentReference<Map<String, dynamic>> ref) async {
    final sub = await ref.collection('anak').get();
    for (final d in sub.docs) {
      final node = LegacyNode(Map<String, dynamic>.from(d.data()));
      _addArrayChildren(node, d.data()['anak']);
      await _addSubcollectionChildren(node, d.reference);
      parent.addChild(node);
    }
  }

  /// Writes the preview as a new tree owned by [owner]. Returns the family id.
  Future<String> commit(LegacyPreview preview, AppUser owner) async {
    if (preview.alreadyImported) {
      throw AppFailure(tr.importAlready);
    }
    try {
      final famRef = _db
          .collection(AppConstants.familiesCollection)
          .doc(AppConstants.legacyFamilyId);
      final members = famRef.collection(AppConstants.membersCollection);
      final writes = <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
      String? rootId;

      void walk(LegacyNode n, String? parentId, int generation, List<String> ancestors,
          int order) {
        final ref = members.doc();
        rootId ??= ref.id;
        writes.add((ref, _memberData(n, parentId, generation, ancestors, order, owner.uid)));
        var i = 0;
        for (final c in n.children) {
          walk(c, ref.id, generation + 1, [...ancestors, ref.id], ++i);
        }
      }

      walk(preview.root, null, 1, const [], 1);

      final all = [
        (famRef, <String, dynamic>{
          'name': AppConstants.legacyFamilyName,
          'ownerId': owner.uid,
          'memberCount': writes.length,
          'lastMemberOp': writes.last.$1.id,
          'roles': {owner.uid: FamilyRole.owner.name},
          'memberUids': [owner.uid],
          'importedFrom': AppConstants.legacyCollection,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }),
        (famRef.collection(AppConstants.grantsCollection).doc(owner.uid), <String, dynamic>{
          'role': FamilyRole.owner.name,
          'anchorMemberId': rootId,
          'maxGeneration': null,
          'createdAt': FieldValue.serverTimestamp(),
        }),
        ...writes,
      ];
      for (var i = 0; i < all.length; i += 400) {
        final batch = _db.batch();
        for (final (ref, data) in all.skip(i).take(400)) {
          batch.set(ref, data);
        }
        await batch.commit();
      }
      return famRef.id;
    } catch (e) {
      throw AppFailure.from(e);
    }
  }

  Map<String, dynamic> _memberData(LegacyNode n, String? parentId, int generation,
      List<String> ancestors, int order, String uid) {
    final d = n.data;
    final dob = parseLegacyDob((d['dob'] ?? d['ttl'] ?? d['tanggal_lahir'])?.toString());
    final member = MemberModel(
      memberId: '',
      fullName: n.name.isEmpty ? tr.importNoName : n.name,
      birthOrder: int.tryParse('${d['anak_ke'] ?? ''}') ?? order,
      gender: _gender(d['gender'] ?? d['jenis_kelamin']),
      birthPlace: dob.place,
      birthDate: dob.date,
      birthYearOnly: dob.yearOnly,
      isDeceased: _isDead(d['status']),
      spouses: _spouses(d['pasangan']),
      occupation: d['pekerjaan'] as String?,
    );
    return {
      ...member.toEditableMap(),
      'parentId': parentId,
      'generation': generation,
      'ancestors': ancestors,
      'claimedByUid': null,
      'createdBy': uid,
      'legacySource': AppConstants.legacyCollection,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  static Gender _gender(Object? v) {
    final s = '${v ?? ''}'.toLowerCase().trim();
    if (s.startsWith('p') || s.contains('wanita')) return Gender.female;
    if (s.startsWith('l') || s.contains('pria')) return Gender.male;
    return Gender.unknown;
  }

  static bool _isDead(Object? v) {
    final s = '${v ?? ''}'.toLowerCase();
    return ['meninggal', 'wafat', 'alm'].any(s.contains);
  }

  static List<Spouse> _spouses(Object? p) {
    final list = p is List ? p : (p == null ? const [] : [p]);
    return [
      for (final s in list)
        if (s is Map && '${s['nama'] ?? ''}'.trim().isNotEmpty)
          Spouse(
            name: '${s['nama']}'.trim(),
            status: _isDead(s['status'])
                ? SpouseStatus.deceased
                : '${s['status'] ?? ''}'.toLowerCase().contains('cerai')
                    ? SpouseStatus.divorced
                    : SpouseStatus.married,
          )
        else if (s is String && s.trim().isNotEmpty)
          Spouse(name: s.trim()),
    ];
  }
}
