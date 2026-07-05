import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data-layer contract for the bookmarks subcollection.
///
/// Manages `users/{uid}/bookmarks/{questionId}` documents in Firestore.
/// The repository is the *only* place in the app that reads or writes bookmarks
/// from Firestore — no UI or provider touches Firestore directly.
///
/// ## Firestore path
/// `users/{uid}/bookmarks/{questionId}`
///
/// ## Document ID
/// `questionId` — the stable [Question.id]. No auto-generated IDs.
/// This makes toggle operations a known-path `set` / `delete` with no query needed.
///
/// ## Fields written
/// | Field          | Type        |
/// |----------------|-------------|
/// | `questionId`   | `String`    |
/// | `subjectId`    | `String`    |
/// | `chapterId`    | `String`    |
/// | `bookmarkedAt` | `Timestamp` |
///
/// See `docs/firestore_schema.md` for the full field reference.
class BookmarkRepository {
  BookmarkRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the `users/{uid}/bookmarks` [CollectionReference].
  /// Throws a [StateError] if no user is authenticated.
  // ignore: unused_element
  CollectionReference<Map<String, dynamic>> get _bookmarksCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('BookmarkRepository: no authenticated user.');
    }
    return _firestore.collection('users').doc(uid).collection('bookmarks');
  }

  // ── Add ────────────────────────────────────────────────────────────────────

  /// Adds a bookmark for [questionId].
  ///
  /// [subjectId] and [chapterId] are stored as denormalised fields so the
  /// BookmarksScreen can display and navigate without a secondary lookup.
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> add({
    required String questionId,
    required String subjectId,
    required String chapterId,
  }) async {
    // Sprint 10.5: replace with actual Firestore write.
    // await _bookmarksCol.doc(questionId).set({
    //   'questionId': questionId,
    //   'subjectId': subjectId,
    //   'chapterId': chapterId,
    //   'bookmarkedAt': FieldValue.serverTimestamp(),
    // });
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  /// Removes the bookmark for [questionId].
  ///
  /// No-op if the document does not exist (Firestore delete is idempotent).
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> remove(String questionId) async {
    // Sprint 10.5: replace with actual Firestore write.
    // await _bookmarksCol.doc(questionId).delete();
  }

  // ── Watch ──────────────────────────────────────────────────────────────────

  /// Returns a stream of all bookmarked question IDs, ordered by [bookmarkedAt].
  ///
  /// The stream is always live — changes in Firestore appear immediately.
  /// Emits an empty list when the user has no bookmarks.
  ///
  /// This method does **not** read from Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Stream<List<String>> watchAll() {
    // Sprint 10.5: replace with actual Firestore stream.
    // return _bookmarksCol
    //     .orderBy('bookmarkedAt')
    //     .snapshots()
    //     .map((snap) => snap.docs.map((d) => d.id).toList());
    return const Stream.empty();
  }
}
