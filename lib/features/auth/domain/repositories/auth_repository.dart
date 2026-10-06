import 'package:bani/features/auth/domain/entities/app_user.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AuthRepository (abstract interface)
// ─────────────────────────────────────────────────────────────────────────────

abstract interface class AuthRepository {
  /// Stream of the current authenticated user, null when signed out.
  Stream<AppUser?> get authStateChanges;

  /// Returns the current user or null.
  AppUser? get currentUser;

  /// Signs in with Google. Returns the [AppUser] on success.
  Future<AppUser> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();
}
