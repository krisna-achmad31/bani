import 'package:bani/l10n/l10n.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FamilyRole
// ─────────────────────────────────────────────────────────────────────────────

enum FamilyRole { owner, admin, contributor, viewer }

extension FamilyRoleX on FamilyRole {
  static FamilyRole? from(String? s) =>
      FamilyRole.values.where((r) => r.name == s).firstOrNull;

  bool get canManage => this == FamilyRole.owner || this == FamilyRole.admin;
  bool get canEdit => this != FamilyRole.viewer;

  String get label => switch (this) {
        FamilyRole.owner => tr.roleOwner,
        FamilyRole.admin => tr.roleAdmin,
        FamilyRole.contributor => tr.roleContributor,
        FamilyRole.viewer => tr.roleViewer,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
//  FamilyModel — families/{familyId}
//  A user's first (free) tree always has familyId == their uid, which lets the
//  security rules limit free accounts to one tree without a counter.
// ─────────────────────────────────────────────────────────────────────────────

class FamilyModel {
  const FamilyModel({
    required this.familyId,
    required this.name,
    required this.ownerId,
    this.memberCount = 0,
    this.albumCount = 0,
    this.ownerPlan = 'free',
    this.roles = const {},
    this.updatedAt,
  });

  final String familyId;
  final String name;
  final String ownerId;
  final int memberCount;

  /// Album photos across the whole tree (quota: see AppConfig.plans).
  final int albumCount;

  /// Owner's plan mirrored by the owner's app ('free' | 'keluarga' |
  /// 'keluarga_besar' | 'admin'). Display only — the rules read the real plan.
  final String ownerPlan;
  bool get ownerPaid => ownerPlan != 'free';

  /// { uid → role name } — also mirrored in `memberUids` for array-contains queries.
  final Map<String, String> roles;
  final DateTime? updatedAt;

  FamilyRole? roleOf(String uid) => FamilyRoleX.from(roles[uid]);

  factory FamilyModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return FamilyModel(
      familyId: s.id,
      name: d['name'] as String? ?? '',
      ownerId: d['ownerId'] as String? ?? '',
      memberCount: (d['memberCount'] as num?)?.toInt() ?? 0,
      albumCount: (d['albumCount'] as num?)?.toInt() ?? 0,
      ownerPlan: d['ownerPlan'] as String? ?? 'free',
      roles: Map<String, String>.from(d['roles'] as Map? ?? const {}),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FamilyModel &&
      other.familyId == familyId &&
      other.memberCount == memberCount &&
      other.albumCount == albumCount &&
      other.ownerPlan == ownerPlan &&
      other.name == name &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(familyId, memberCount, albumCount, name, updatedAt);
}

// ─────────────────────────────────────────────────────────────────────────────
//  GrantModel — families/{familyId}/grants/{uid}
//  maxGeneration is absolute: a contributor at generation 3 with depth 2 can
//  add members up to generation 5, whichever account does the writing.
// ─────────────────────────────────────────────────────────────────────────────

class GrantModel {
  const GrantModel({
    required this.uid,
    required this.role,
    this.anchorMemberId,
    this.maxGeneration,
  });

  final String uid;
  final FamilyRole role;
  final String? anchorMemberId;

  /// null = unlimited.
  final int? maxGeneration;

  factory GrantModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return GrantModel(
      uid: s.id,
      role: FamilyRoleX.from(d['role'] as String?) ?? FamilyRole.viewer,
      anchorMemberId: d['anchorMemberId'] as String?,
      maxGeneration: (d['maxGeneration'] as num?)?.toInt(),
    );
  }
}
