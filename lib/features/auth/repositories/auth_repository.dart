import 'package:firebase_auth/firebase_auth.dart';

/// Data-layer contract for Firebase Authentication.
///
/// The repository is the *only* place in the app that imports FirebaseAuth.
/// All callers (providers) receive either a [User] or a plain [String] error
/// message — never a raw [FirebaseAuthException].
class AuthRepository {
  AuthRepository({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  // ── Auth state stream ──────────────────────────────────────────────────────

  /// Emits the current [User] whenever auth state changes.
  /// Emits `null` when the user is signed out or on cold start if unauthenticated.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The currently authenticated [User], or `null` if unauthenticated.
  User? get currentUser => _auth.currentUser;

  // ── Sign in ────────────────────────────────────────────────────────────────

  /// Signs in with [email] and [password].
  ///
  /// Returns `null` on success. Returns a user-friendly error message on
  /// failure so that the presentation layer never handles [FirebaseAuthException].
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  // ── Sign up ────────────────────────────────────────────────────────────────

  /// Creates a new account with [email] and [password].
  ///
  /// Returns `null` on success. Returns a user-friendly error message on
  /// failure.
  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapError(e.code);
    }
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  /// Signs the current user out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Error mapping ──────────────────────────────────────────────────────────

  /// Converts a [FirebaseAuthException] error code into a user-friendly string.
  String _mapError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'user-not-found':
        return 'No account found for that email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for that email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'network-request-failed':
        return 'Check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
