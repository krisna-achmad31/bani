import 'package:bani/l10n/l10n.dart';
import 'package:firebase_core/firebase_core.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  App Failures — user-facing error messages (Bahasa Indonesia)
// ─────────────────────────────────────────────────────────────────────────────

class AppFailure implements Exception {
  const AppFailure(this.message, {this.isPermission = false});
  final String message;

  /// True when Firestore rules rejected the write — usually a quota/branch limit.
  final bool isPermission;

  @override
  String toString() => message;

  static AppFailure from(Object error) {
    if (error is AppFailure) return error;
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => AppFailure(tr.errPermission, isPermission: true),
        'unavailable' => AppFailure(tr.errOffline),
        'not-found' => AppFailure(tr.errNotFound),
        _ => AppFailure(error.message ?? tr.errGeneric(error.code)),
      };
    }
    return AppFailure(error.toString());
  }
}
