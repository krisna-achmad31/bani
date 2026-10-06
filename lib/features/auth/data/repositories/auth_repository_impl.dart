import 'package:bani/l10n/l10n.dart';
import 'package:bani/core/constants/app_constants.dart';
import 'package:bani/core/errors/app_failure.dart';
import 'package:bani/features/auth/domain/entities/app_user.dart';
import 'package:bani/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  AuthRepositoryImpl — Google Sign-In (google_sign_in 7) + Firebase Auth
// ─────────────────────────────────────────────────────────────────────────────

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;
  Future<void>? _init;

  Future<void> _ensureInitialized() => _init ??= GoogleSignIn.instance
      .initialize(serverClientId: AppConstants.googleServerClientId);

  @override
  Stream<AppUser?> get authStateChanges => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw AppFailure(tr.loginNoToken);
      }
      final result = await _auth
          .signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
      return _map(result.user)!;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AppFailure(tr.loginCancelled);
      }
      throw AppFailure(tr.loginFailed(e.description ?? e.code.name));
    } on FirebaseAuthException catch (e) {
      throw AppFailure(tr.loginFailed(e.message ?? e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
  }

  AppUser? _map(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );
}
