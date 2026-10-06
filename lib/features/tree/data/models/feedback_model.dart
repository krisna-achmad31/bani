import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  FeedbackModel — feedback/{id}. Anyone signed in can send; only the
//  Super Admin can read and mark as done (see firestore.rules).
// ─────────────────────────────────────────────────────────────────────────────

enum FeedbackType { idea, bug, other }

class FeedbackModel {
  const FeedbackModel({
    required this.id,
    required this.type,
    required this.message,
    required this.userName,
    required this.userEmail,
    this.appVersion,
    this.createdAt,
    this.done = false,
  });

  final String id;
  final FeedbackType type;
  final String message;
  final String userName;
  final String userEmail;
  final String? appVersion;
  final DateTime? createdAt;
  final bool done;

  factory FeedbackModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> s) {
    final d = s.data() ?? const {};
    return FeedbackModel(
      id: s.id,
      type: FeedbackType.values.where((t) => t.name == d['type']).firstOrNull ??
          FeedbackType.other,
      message: d['message'] as String? ?? '',
      userName: d['userName'] as String? ?? '',
      userEmail: d['userEmail'] as String? ?? '',
      appVersion: d['appVersion'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      done: d['status'] == 'done',
    );
  }
}
