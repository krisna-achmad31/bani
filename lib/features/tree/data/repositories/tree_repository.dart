import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/core/utils/tree_utils.dart';
import 'package:bani/features/auth/domain/entities/app_user.dart';
import 'package:bani/features/auth/domain/entities/user_profile.dart';
import 'package:bani/features/tree/data/models/app_config.dart';
import 'package:bani/features/tree/data/models/album_photo.dart';
import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:bani/features/tree/data/models/feedback_model.dart';
import 'package:bani/features/tree/data/models/invite_model.dart';
import 'package:bani/features/tree/data/models/member_model.dart';
import 'package:bani/features/tree/data/repositories/storage_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:collection/collection.dart';

/// 8-character invite code without look-alike characters (0/O, 1/I/L).
/// 30^8 ≈ 6.5e11 combinations; codes expire after 7 days and are single-use.
String inviteCode() {
  const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ2345679';
  final rnd = Random.secure();
  return List.generate(8, (_) => alphabet[rnd.nextInt(alphabet.length)]).join();
}

/// Someone else saved the member after this form was opened.
class MemberConflict extends AppFailure {
  MemberConflict(this.latest)
      : super(tr.errConflict((latest.updatedByName ?? '').isEmpty
            ? tr.someoneElse
            : latest.updatedByName!));
  final MemberModel latest;
}

/// Editable fields whose value differs between [before] and [after].
Map<String, dynamic> diffMember(MemberModel before, MemberModel after) {
  const eq = DeepCollectionEquality();
  final a = before.toEditableMap(), b = after.toEditableMap();
  return {
    for (final k in b.keys)
      if (k != 'photoThumb' && k != 'hasPhoto' && !eq.equals(a[k], b[k])) k: b[k],
  };
}

/// "KDRT7XQM" → "KDRT-7XQM" for display.
String formatInviteCode(String code) =>
    code.length == 8 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

/// Accepts a code ("kdrt-7xqm"), a full invite link, or a legacy long token.
String? parseInviteInput(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final uri = Uri.tryParse(text);
  final t = uri?.queryParameters['t'];
  if (t != null && t.isNotEmpty) return t;
  final compact = text.replaceAll(RegExp(r'[\s-]'), '');
  return compact.length <= 10 ? compact.toUpperCase() : compact;
}

// ─────────────────────────────────────────────────────────────────────────────
//  TreeRepository — every Firestore read/write of the app.
//
//  Writes that add or remove a member always update families/{id}.memberCount
//  and lastMemberOp in the same batch; firestore.rules checks that pairing to
//  enforce the member quota (see docs/PRD).
// ─────────────────────────────────────────────────────────────────────────────

class TreeRepository {
  TreeRepository({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  // ── Paths ─────────────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection(AppConstants.usersCollection).doc(uid);
  DocumentReference<Map<String, dynamic>> _family(String fid) =>
      _db.collection(AppConstants.familiesCollection).doc(fid);
  CollectionReference<Map<String, dynamic>> _members(String fid) =>
      _family(fid).collection(AppConstants.membersCollection);
  DocumentReference<Map<String, dynamic>> _photo(String fid, String mid) =>
      _members(fid).doc(mid).collection(AppConstants.mediaCollection).doc(AppConstants.photoDoc);
  DocumentReference<Map<String, dynamic>> _contact(String fid, String mid) =>
      _members(fid).doc(mid).collection(AppConstants.privateCollection).doc(AppConstants.contactDoc);
  DocumentReference<Map<String, dynamic>> _grant(String fid, String uid) =>
      _family(fid).collection(AppConstants.grantsCollection).doc(uid);
  CollectionReference<Map<String, dynamic>> get _invites =>
      _db.collection(AppConstants.invitesCollection);

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } catch (e) {
      throw AppFailure.from(e);
    }
  }

  // ── Config / account ──────────────────────────────────────────────────────

  Stream<AppConfig> watchConfig() => _db
      .collection(AppConstants.configCollection)
      .doc(AppConstants.configAppDoc)
      .snapshots()
      .map((s) => AppConfig.fromMap(s.data()))
      .handleError((_) {});

  Stream<UserProfile?> watchUserProfile(String uid) => _user(uid)
      .snapshots()
      .map((s) => s.exists ? UserProfile.fromSnapshot(s) : null);

  Stream<bool> watchIsSuperAdmin(String uid) => _db
      .collection(AppConstants.adminsCollection)
      .doc(uid)
      .snapshots()
      .map((s) => s.exists)
      .handleError((_) {});

  /// Creates users/{uid} on first login with the quota from config/app.
  Future<void> ensureUserProfile(AppUser user) => _guard(() async {
        final ref = _user(user.uid);
        final snap = await ref.get();
        if (snap.exists) {
          await ref.update({
            'displayName': user.displayName ?? '',
            'photoUrl': user.photoUrl,
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
          return;
        }
        final configSnap = await _db
            .collection(AppConstants.configCollection)
            .doc(AppConstants.configAppDoc)
            .get();
        final config = AppConfig.fromMap(configSnap.data());
        await ref.set({
          'displayName': user.displayName ?? '',
          'email': user.email,
          'photoUrl': user.photoUrl,
          'memberLimit': config.defaultMemberLimit,
          'plan': 'free',
          'planUntil': null,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      });

  /// Registers the app owner as Super Admin and seeds config/app once.
  Future<void> ensureOwnerAdmin(AppUser user) => _guard(() async {
        if (user.email.toLowerCase() != AppConstants.ownerEmail) return;
        final adminRef =
            _db.collection(AppConstants.adminsCollection).doc(user.uid);
        if (!(await adminRef.get()).exists) {
          await adminRef.set({
            'role': 'owner',
            'email': user.email,
            'since': FieldValue.serverTimestamp(),
          });
        }
        final configRef = _db
            .collection(AppConstants.configCollection)
            .doc(AppConstants.configAppDoc);
        final configSnap = await configRef.get();
        final plans = {
          for (final e in AppConfig.defaultPlans.entries) e.key: e.value.toMap(),
        };
        final packages = [
          for (final p in AppConfig.defaultPackages)
            {
              'id': p.id,
              'name': p.name,
              'description': p.description,
              'price': p.price,
              'period': p.period,
              'tag': p.tag,
            },
        ];
        if (configSnap.exists) {
          final data = configSnap.data() ?? const {};
          final oldPackages = (data['packages'] as List? ?? const [])
              .whereType<Map>()
              .map((p) => p['id'])
              .toSet();
          final patch = <String, Object>{
            if (!data.containsKey('plans')) 'plans': plans,
            if (!data.containsKey('minMembersForAlbum')) 'minMembersForAlbum': 5,
            // Replace the old package list (premium / members50) once.
            if (!oldPackages.contains('keluarga')) 'packages': packages,
            for (final old in ['albumLimitPerTree', 'albumFreePerTree', 'albumPremiumPerTree'])
              if (data.containsKey(old)) old: FieldValue.delete(),
          };
          if (patch.isNotEmpty) await configRef.update(patch);
        } else {
          await configRef.set({
            'defaultMemberLimit': AppConstants.defaultMemberLimit,
            'defaultBranchDepth': AppConstants.defaultBranchDepth,
            'minMembersForAlbum': 5,
            'plans': plans,
            'showPricing': true,
            'adminWhatsapp': '',
            'packages': packages,
          });
        }
      });

  /// Mirrors the owner's plan on each tree they own so contributors' apps can
  /// show the right limits (the rules always check the real plan).
  Future<void> syncOwnerPlan(String uid, String plan) => _guard(() async {
        // Single array-contains query (no composite index); filter owner here.
        final mine = await _db
            .collection(AppConstants.familiesCollection)
            .where('memberUids', arrayContains: uid)
            .get();
        for (final d in mine.docs) {
          if (d.data()['ownerId'] == uid && d.data()['ownerPlan'] != plan) {
            await d.reference.update({'ownerPlan': plan});
          }
        }
      });

  /// One free tree per phone: devices/{hash} is claimed by the first account
  /// that creates a free tree on it. Returns false if another account did.
  Future<bool> claimDevice(String hash, String uid) => _guard(() async {
        final ref = _db.collection('devices').doc(hash);
        final snap = await ref.get();
        if (snap.exists) return snap.data()?['uid'] == uid;
        await ref.set({'uid': uid, 'createdAt': FieldValue.serverTimestamp()});
        return true;
      });

  // ── Families ──────────────────────────────────────────────────────────────

  Stream<List<FamilyModel>> watchUserFamilies(String uid) => _db
      .collection(AppConstants.familiesCollection)
      .where('memberUids', arrayContains: uid)
      .snapshots()
      .map((q) => q.docs.map(FamilyModel.fromSnapshot).toList()
        ..sort((a, b) => a.name.compareTo(b.name)));

  Stream<FamilyModel?> watchFamily(String fid) => _family(fid)
      .snapshots()
      .map((s) => s.exists ? FamilyModel.fromSnapshot(s) : null);

  /// Tree ids are deterministic: the first tree is `uid`, a Keluarga Besar
  /// owner's second is `uid_2` (the rules only allow these). A free tree also
  /// carries [deviceHash], which must be claimed by the same account.
  Future<String> createFamily({
    String? familyId,
    required String name,
    required AppUser owner,
    required String rootName,
    bool rootIsOwner = false,
    String? deviceHash,
    String ownerPlan = 'free',
  }) =>
      _guard(() async {
        final famRef = familyId == null
            ? _db.collection(AppConstants.familiesCollection).doc()
            : _family(familyId);
        final rootRef = _members(famRef.id).doc();
        final batch = _db.batch()
          ..set(famRef, {
            'name': name.trim(),
            'ownerId': owner.uid,
            'ownerPlan': ownerPlan,
            'deviceHash': deviceHash,
            'memberCount': 1,
            'lastMemberOp': rootRef.id,
            'roles': {owner.uid: FamilyRole.owner.name},
            'memberUids': [owner.uid],
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..set(rootRef, {
            ...MemberModel(memberId: rootRef.id, fullName: rootName).toEditableMap(),
            'parentId': null,
            'generation': 1,
            'ancestors': <String>[],
            'claimedByUid': rootIsOwner ? owner.uid : null,
            'createdBy': owner.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..set(_grant(famRef.id, owner.uid), {
            'role': FamilyRole.owner.name,
            'anchorMemberId': rootRef.id,
            'maxGeneration': null,
            'createdAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
        return famRef.id;
      });

  Future<void> renameFamily(String fid, String name) => _guard(() =>
      _family(fid).update({'name': name.trim(), 'updatedAt': FieldValue.serverTimestamp()}));

  // ── Grants / access ───────────────────────────────────────────────────────

  Stream<GrantModel?> watchGrant(String fid, String uid) => _grant(fid, uid)
      .snapshots()
      .map((s) => s.exists ? GrantModel.fromSnapshot(s) : null);

  Stream<List<GrantModel>> watchGrants(String fid) => _family(fid)
      .collection(AppConstants.grantsCollection)
      .snapshots()
      .map((q) => q.docs.map(GrantModel.fromSnapshot).toList());

  Future<void> setRole(String fid, String uid, FamilyRole role) => _guard(() async {
        final batch = _db.batch()
          ..update(_grant(fid, uid), {'role': role.name})
          ..update(_family(fid), {
            'roles.$uid': role.name,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  Future<void> revokeAccess(String fid, String uid) => _guard(() async {
        final batch = _db.batch()
          ..delete(_grant(fid, uid))
          ..update(_family(fid), {
            'roles.$uid': FieldValue.delete(),
            'memberUids': FieldValue.arrayRemove([uid]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  // ── Members ───────────────────────────────────────────────────────────────

  Stream<List<MemberModel>> watchMembers(String fid) => _members(fid)
      .snapshots()
      .map((q) => q.docs.map(MemberModel.fromSnapshot).toList());

  /// Fetches the family and its members from the server (bypassing the local
  /// cache); open snapshot listeners pick the fresh data up automatically.
  Future<void> refreshFamily(String fid) => _guard(() async {
        await Future.wait([
          _family(fid).get(const GetOptions(source: Source.server)),
          _members(fid).get(const GetOptions(source: Source.server)),
        ]);
      });

  Future<String?> getPhoto(String fid, String mid) => _guard(() async {
        final s = await _photo(fid, mid).get();
        return s.data()?['data'] as String?;
      });

  /// Emits null when the contact is hidden from this user or empty.
  Stream<MemberContact?> watchContact(String fid, String mid) =>
      _contact(fid, mid)
          .snapshots()
          .map<MemberContact?>((s) => s.exists ? MemberContact.fromMap(s.data()) : null)
          .handleError((_) {});

  Future<String> addMember({
    required String familyId,
    required MemberModel parent,
    required MemberModel member,
    required String uid,
    PickedPhoto? photo,
    MemberContact? contact,
  }) =>
      _guard(() async {
        final ref = _members(familyId).doc();
        final withPhoto = photo == null
            ? member
            : member.copyWith(photoThumb: photo.thumbBase64, hasPhoto: true);
        final batch = _db.batch()
          ..set(ref, {
            ...withPhoto.toEditableMap(),
            'parentId': parent.memberId,
            'generation': parent.generation + 1,
            'ancestors': [...parent.ancestors, parent.memberId],
            'claimedByUid': null,
            'createdBy': uid,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..update(_family(familyId), {
            'memberCount': FieldValue.increment(1),
            'lastMemberOp': ref.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        if (photo != null) {
          batch.set(_photo(familyId, ref.id), {'data': photo.fullBase64});
        }
        if (contact != null && !contact.isEmpty) {
          batch.set(_contact(familyId, ref.id), contact.toMap());
        }
        await batch.commit();
        return ref.id;
      });

  /// Saves only [changes] (see [diffMember]) on top of [baseVersion].
  /// Throws [MemberConflict] when someone else saved since [baseVersion].
  Future<void> updateMember({
    required String familyId,
    required String memberId,
    required int baseVersion,
    required Map<String, dynamic> changes,
    required AppUser editor,
    PickedPhoto? newPhoto,
    bool removePhoto = false,
    MemberContact? contact,
  }) async {
    final fields = {...changes};
    if (newPhoto != null) {
      fields['photoThumb'] = newPhoto.thumbBase64;
      fields['hasPhoto'] = true;
    } else if (removePhoto) {
      fields['photoThumb'] = null;
      fields['hasPhoto'] = false;
    }
    if (fields.isEmpty && contact == null) return;

    final ref = _members(familyId).doc(memberId);
    final batch = _db.batch()
      ..update(ref, {
        ...fields,
        'version': baseVersion + 1,
        'updatedBy': editor.uid,
        'updatedByName': editor.displayName ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      })
      ..update(_family(familyId), {'updatedAt': FieldValue.serverTimestamp()});
    if (newPhoto != null) {
      batch.set(_photo(familyId, memberId), {'data': newPhoto.fullBase64});
    } else if (removePhoto) {
      batch.delete(_photo(familyId, memberId));
    }
    if (contact != null) batch.set(_contact(familyId, memberId), contact.toMap());

    try {
      await batch.commit();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        final latest = await ref.get(const GetOptions(source: Source.server));
        if (latest.exists && (latest.data()?['version'] as num? ?? 0) != baseVersion) {
          throw MemberConflict(MemberModel.fromSnapshot(latest));
        }
        throw AppFailure(tr.errEditDenied, isPermission: true);
      }
      throw AppFailure.from(e);
    }
  }

  /// Moves [member] and its whole subtree under [newParent] (Owner/Admin).
  /// Writes go parent-first in small batches: the rules validate each node
  /// against its parent's post-write state and allow ~20 document reads per
  /// batch. Contributor grants anchored inside the subtree keep their depth.
  Future<void> moveMember({
    required String familyId,
    required MemberModel member,
    required MemberModel newParent,
    required FamilyIndex index,
  }) =>
      _guard(() async {
        if (member.isRoot) throw AppFailure(tr.moveRootNotAllowed);
        if (newParent.memberId == member.memberId ||
            newParent.ancestors.contains(member.memberId)) {
          throw AppFailure(tr.moveIntoOwnSubtree);
        }
        final delta = newParent.generation + 1 - member.generation;
        final baseAncestors = [...newParent.ancestors, newParent.memberId];
        final subtree = index.dfs(member.memberId);
        final moved = {for (final m in subtree) m.memberId};

        final updates = <(DocumentReference<Map<String, dynamic>>, Map<String, dynamic>)>[];
        for (final m in subtree) {
          final at = m.ancestors.indexOf(member.memberId);
          final ancestors = m.memberId == member.memberId
              ? baseAncestors
              : [...baseAncestors, ...m.ancestors.sublist(at)];
          updates.add((_members(familyId).doc(m.memberId), {
            if (m.memberId == member.memberId) 'parentId': newParent.memberId,
            if (m.memberId == member.memberId)
              'birthOrder': index.childrenOf(newParent.memberId).length + 1,
            'generation': m.generation + delta,
            'ancestors': ancestors,
            'updatedAt': FieldValue.serverTimestamp(),
          }));
        }

        for (var i = 0; i < updates.length; i += 12) {
          final batch = _db.batch();
          for (final (ref, data) in updates.skip(i).take(12)) {
            batch.update(ref, data);
          }
          await batch.commit();
        }

        if (delta != 0) {
          final grants = await _family(familyId).collection(AppConstants.grantsCollection).get();
          final batch = _db.batch();
          var any = false;
          for (final g in grants.docs.map(GrantModel.fromSnapshot)) {
            if (g.maxGeneration != null && moved.contains(g.anchorMemberId)) {
              batch.update(_grant(familyId, g.uid), {'maxGeneration': g.maxGeneration! + delta});
              any = true;
            }
          }
          if (any) await batch.commit();
        }
        await _family(familyId).update({'updatedAt': FieldValue.serverTimestamp()});
      });

  /// Only leaf members can be deleted (the UI checks for children first).
  Future<void> deleteMember(String familyId, String memberId) => _guard(() async {
        final batch = _db.batch()
          ..delete(_photo(familyId, memberId))
          ..delete(_contact(familyId, memberId))
          ..delete(_members(familyId).doc(memberId))
          ..update(_family(familyId), {
            'memberCount': FieldValue.increment(-1),
            'lastMemberOp': memberId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  // ── Album (foto kenangan) ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _album(String fid, String mid) =>
      _members(fid).doc(mid).collection('album');
  DocumentReference<Map<String, dynamic>> _albumFull(String fid, String mid, String pid) =>
      _album(fid, mid).doc(pid).collection('full').doc('data');

  Stream<List<AlbumPhoto>> watchAlbum(String fid, String mid) =>
      _album(fid, mid).snapshots().map((q) => q.docs.map(AlbumPhoto.fromSnapshot).toList()
        ..sort((a, b) {
          final y = (a.year ?? 9999).compareTo(b.year ?? 9999);
          if (y != 0) return y;
          return (a.createdAt ?? DateTime(2100)).compareTo(b.createdAt ?? DateTime(2100));
        }));

  Future<String?> getAlbumFull(String fid, String mid, String pid) => _guard(() async {
        final s = await _albumFull(fid, mid, pid).get();
        return s.data()?['data'] as String?;
      });

  /// One photo per batch: the rules check that albumCount moves by one,
  /// paired with the photo it counts (same pattern as memberCount).
  Future<void> addAlbumPhoto({
    required String familyId,
    required String memberId,
    required PickedPhoto photo,
    required AppUser user,
    String? caption,
    int? year,
  }) =>
      _guard(() async {
        final ref = _album(familyId, memberId).doc();
        // Per-day upload counter on the uploader's users doc (checked by rules).
        final now = DateTime.now().toUtc();
        final today = DateTime.utc(now.year, now.month, now.day);
        final me = await _user(user.uid).get(const GetOptions(source: Source.server));
        final lastDay = (me.data()?['uploadDay'] as Timestamp?)?.toDate().toUtc();
        final sameDay = lastDay != null && lastDay.isAtSameMomentAs(today);
        final count = sameDay ? ((me.data()?['uploadCount'] as num?)?.toInt() ?? 0) + 1 : 1;
        final batch = _db.batch()
          ..update(_user(user.uid), {
            'uploadDay': Timestamp.fromDate(today),
            'uploadCount': count,
          })
          ..set(ref, {
            'thumb': photo.thumbBase64,
            'caption': (caption == null || caption.trim().isEmpty) ? null : caption.trim(),
            'year': year,
            'uploadedBy': user.uid,
            'uploadedByName': user.displayName ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(_albumFull(familyId, memberId, ref.id), {'data': photo.fullBase64})
          ..update(_family(familyId), {
            'albumCount': FieldValue.increment(1),
            'lastAlbumOp': '$memberId/album/${ref.id}',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  Future<void> updateAlbumCaption(
          String fid, String mid, String pid, String? caption, int? year) =>
      _guard(() => _album(fid, mid).doc(pid).update({
            'caption': (caption == null || caption.trim().isEmpty) ? null : caption.trim(),
            'year': year,
          }));

  Future<void> deleteAlbumPhoto(String fid, String mid, String pid) => _guard(() async {
        final batch = _db.batch()
          ..delete(_albumFull(fid, mid, pid))
          ..delete(_album(fid, mid).doc(pid))
          ..update(_family(fid), {
            'albumCount': FieldValue.increment(-1),
            'lastAlbumOp': '$mid/album/$pid',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });

  // ── Feedback ──────────────────────────────────────────────────────────────

  Future<void> sendFeedback({
    required AppUser user,
    required FeedbackType type,
    required String message,
    String? appVersion,
  }) =>
      _guard(() => _db.collection('feedback').add({
            'uid': user.uid,
            'userName': user.displayName ?? '',
            'userEmail': user.email,
            'type': type.name,
            'message': message.trim(),
            'appVersion': appVersion,
            'language': currentLocale.languageCode,
            'status': 'new',
            'createdAt': FieldValue.serverTimestamp(),
          }));

  /// Super Admin only.
  Stream<List<FeedbackModel>> watchFeedback() => _db
      .collection('feedback')
      .orderBy('createdAt', descending: true)
      .limit(200)
      .snapshots()
      .map((q) => q.docs.map(FeedbackModel.fromSnapshot).toList());

  Future<void> setFeedbackDone(String id, bool done) => _guard(() => _db
      .collection('feedback')
      .doc(id)
      .update({'status': done ? 'done' : 'new'}));

  // ── Invites / claim ───────────────────────────────────────────────────────

  Stream<List<InviteModel>> watchInvites(String fid) => _invites
      .where('familyId', isEqualTo: fid)
      .snapshots()
      .map((q) => q.docs.map(InviteModel.fromSnapshot).toList())
      .handleError((_) {});

  Future<InviteModel> createInvite({
    required FamilyModel family,
    required MemberModel member,
    required FamilyRole role,
    required int? maxDepth,
    required AppUser creator,
  }) =>
      _guard(() async {
        var token = inviteCode();
        while ((await _invites.doc(token).get()).exists) {
          token = inviteCode();
        }
        final invite = InviteModel(
          token: token,
          familyId: family.familyId,
          familyName: family.name,
          memberId: member.memberId,
          memberName: member.fullName,
          memberGeneration: member.generation,
          role: role,
          maxDepth: role == FamilyRole.contributor ? maxDepth : null,
          createdByUid: creator.uid,
          createdByName: creator.displayName ?? '',
          expiresAt: DateTime.now()
              .add(const Duration(days: AppConstants.inviteExpiryDays)),
        );
        await _invites.doc(token).set(invite.toMap());
        return invite;
      });

  Future<void> cancelInvite(String token) =>
      _guard(() => _invites.doc(token).delete());

  Future<InviteModel?> getInvite(String token) => _guard(() async {
        final s = await _invites.doc(token).get();
        return s.exists ? InviteModel.fromSnapshot(s) : null;
      });

  /// Links the invited member to [uid] and grants the invite's role.
  Future<void> claimInvite(InviteModel invite, String uid) => _guard(() async {
        if (!invite.isValid) {
          throw AppFailure(tr.inviteAlreadyUsed);
        }
        if ((await _grant(invite.familyId, uid).get()).exists) {
          throw AppFailure(tr.inviteAlreadyJoined);
        }
        final batch = _db.batch()
          ..update(_invites.doc(invite.token), {
            'usedBy': uid,
            'usedAt': FieldValue.serverTimestamp(),
          })
          ..set(_grant(invite.familyId, uid), {
            'role': invite.role.name,
            'anchorMemberId': invite.memberId,
            'maxGeneration': invite.maxGeneration,
            'inviteToken': invite.token,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..update(_members(invite.familyId).doc(invite.memberId), {
            'claimedByUid': uid,
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..update(_family(invite.familyId), {
            'roles.$uid': invite.role.name,
            'memberUids': FieldValue.arrayUnion([uid]),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        await batch.commit();
      });
}
