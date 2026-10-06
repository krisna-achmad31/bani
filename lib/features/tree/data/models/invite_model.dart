import 'package:bani/features/tree/data/models/family_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  InviteModel — invites/{token} (top-level so a link only needs the token)
// ─────────────────────────────────────────────────────────────────────────────

class InviteModel {
  const InviteModel({
    required this.token,
    required this.familyId,
    required this.familyName,
    required this.memberId,
    required this.memberName,
    required this.memberGeneration,
    required this.role,
    required this.maxDepth,
    required this.createdByUid,
    required this.createdByName,
    required this.expiresAt,
    this.usedBy,
  });

  final String token;
  final String familyId;
  final String familyName;
  final String memberId;
  final String memberName;
  final int memberGeneration;
  final FamilyRole role;

  /// Generations below the anchor the contributor may add (null = unlimited).
  final int? maxDepth;
  final String createdByUid;
  final String createdByName;
  final DateTime expiresAt;
  final String? usedBy;

  bool get isUsed => usedBy != null;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isUsed && !isExpired;
  int? get maxGeneration => maxDepth == null ? null : memberGeneration + maxDepth!;

  factory InviteModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return InviteModel(
      token: s.id,
      familyId: d['familyId'] as String? ?? '',
      familyName: d['familyName'] as String? ?? '',
      memberId: d['memberId'] as String? ?? '',
      memberName: d['memberName'] as String? ?? '',
      memberGeneration: (d['memberGeneration'] as num?)?.toInt() ?? 1,
      role: FamilyRoleX.from(d['role'] as String?) ?? FamilyRole.viewer,
      maxDepth: (d['maxDepth'] as num?)?.toInt(),
      createdByUid: d['createdByUid'] as String? ?? '',
      createdByName: d['createdByName'] as String? ?? '',
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
      usedBy: d['usedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'familyId': familyId,
        'familyName': familyName,
        'memberId': memberId,
        'memberName': memberName,
        'memberGeneration': memberGeneration,
        'role': role.name,
        'maxDepth': maxDepth,
        'createdByUid': createdByUid,
        'createdByName': createdByName,
        'expiresAt': Timestamp.fromDate(expiresAt),
        'usedBy': null,
        'createdAt': FieldValue.serverTimestamp(),
      };
}
