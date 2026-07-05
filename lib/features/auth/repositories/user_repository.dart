import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data-layer contract for user profile documents.
///
/// Manages the `users/{uid}` document in Firestore.
/// The repository is the *only* place in the app that reads or writes the
/// user profile collection — no UI or provider touches Firestore directly.
///
/// ## Firestore path
/// `users/{uid}`
///
/// ## Fields written
/// | Field          | Type        |
/// |----------------|-------------|
/// | `uid`          | `String`    |
/// | `displayName`  | `String?`   |
/// | `email`        | `String`    |
/// | `createdAt`    | `Timestamp` |
/// | `lastActiveAt` | `Timestamp` |
/// | `examStream`   | `String`    |
///
/// See `docs/firestore_schema.md` for the full field reference.
class UserRepository {
  UserRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the `users/{uid}` [DocumentReference] for the currently signed-in
  /// user, or throws a [StateError] if no user is authenticated.
  DocumentReference<Map<String, dynamic>> get _userDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('UserRepository: no authenticated user.');
    return _firestore.collection('users').doc(uid);
  }

  // ── Profile creation ───────────────────────────────────────────────────────

  /// Creates the `users/{uid}` document on the user's first sign-in.
  ///
  /// Uses `SetOptions(merge: true)` so that a repeated call (e.g. on re-install)
  /// does not overwrite `createdAt` with a newer timestamp.
  ///
  /// [displayName] is optional — populated from the signup form when provided.
  /// [examStream] defaults to `'engineering'`.
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> createProfile({
    String? displayName,
    String examStream = 'engineering',
  }) async {
    // Sprint 10.5: replace with actual Firestore write.
    // final uid = _auth.currentUser!.uid;
    // final email = _auth.currentUser!.email ?? '';
    // await _userDoc.set(
    //   {
    //     'uid': uid,
    //     'displayName': displayName,
    //     'email': email,
    //     'createdAt': FieldValue.serverTimestamp(),
    //     'lastActiveAt': FieldValue.serverTimestamp(),
    //     'examStream': examStream,
    //   },
    //   SetOptions(merge: true),
    // );
  }

  // ── Last-active stamp ──────────────────────────────────────────────────────

  /// Updates `lastActiveAt` to the current server timestamp.
  ///
  /// Called on every app launch after the user is confirmed authenticated.
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> updateLastActive() async {
    // Sprint 10.5: replace with actual Firestore write.
    // await _userDoc.update({'lastActiveAt': FieldValue.serverTimestamp()});
  }
}
