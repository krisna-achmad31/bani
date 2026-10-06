import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  UserProfile — users/{uid}. Quota fields are written only by the app on
//  first login (from config/app) and afterwards by the Super Admin in Console.
//
//  plan: 'free' | 'keluarga' | 'keluarga_besar' (legacy 'premium' counts as
//  keluarga_besar) with planUntil. memberLimit = members for a free owner
//  (raised by purchases); albumBonus = extra album photos (Paket Foto +30).
// ─────────────────────────────────────────────────────────────────────────────

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.memberLimit,
    this.albumBonus = 0,
    this.plan = 'free',
    this.planUntil,
    this.uploadDay,
    this.uploadCount = 0,
  });

  /// Album uploads today (UTC day), for the per-day limit in the rules.
  final DateTime? uploadDay;
  final int uploadCount;

  int uploadsToday() {
    final now = DateTime.now().toUtc();
    final d = uploadDay?.toUtc();
    return (d != null && d.year == now.year && d.month == now.month && d.day == now.day)
        ? uploadCount
        : 0;
  }

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int memberLimit;
  final int albumBonus;
  final String plan;
  final DateTime? planUntil;

  bool get _active => planUntil == null || planUntil!.isAfter(DateTime.now());

  /// The plan key whose limits apply right now.
  String get effectivePlan {
    if (!_active) return 'free';
    return switch (plan) {
      'keluarga' => 'keluarga',
      'keluarga_besar' || 'premium' => 'keluarga_besar',
      _ => 'free',
    };
  }

  bool get isPaid => effectivePlan != 'free';

  factory UserProfile.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return UserProfile(
      uid: s.id,
      displayName: d['displayName'] as String? ?? '',
      email: d['email'] as String? ?? '',
      photoUrl: d['photoUrl'] as String?,
      memberLimit: (d['memberLimit'] as num?)?.toInt() ?? 0,
      albumBonus: (d['albumBonus'] as num?)?.toInt() ?? 0,
      plan: d['plan'] as String? ?? 'free',
      planUntil: (d['planUntil'] as Timestamp?)?.toDate(),
      uploadDay: (d['uploadDay'] as Timestamp?)?.toDate(),
      uploadCount: (d['uploadCount'] as num?)?.toInt() ?? 0,
    );
  }
}
