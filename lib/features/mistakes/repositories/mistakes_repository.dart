import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/mistakes_provider.dart';

/// Data-layer contract for the mistakes subcollection.
///
/// Manages `users/{uid}/mistakes/{questionId}` documents in Firestore.
/// The repository is the *only* place in the app that reads or writes mistakes
/// from Firestore — no UI or provider touches Firestore directly.
///
/// ## Firestore path
/// `users/{uid}/mistakes/{questionId}`
///
/// ## Document ID
/// `questionId` — the stable [Question.id]. Matches the [WrongAnswer.questionId]
/// identity rule already enforced by [MistakesNotifier].
///
/// ## Document lifecycle
/// A document is **set** when [record] is called and **deleted** when [remove]
/// is called — mirroring [MistakesNotifier.record] and [MistakesNotifier.remove].
///
/// ## Fields written
/// | Field          | Type        |
/// |----------------|-------------|
/// | `questionId`   | `String`    |
/// | `subjectId`    | `String`    |
/// | `chapterId`    | `String`    |
/// | `chapterTitle` | `String`    |
/// | `attemptedAt`  | `Timestamp` |
///
/// See `docs/firestore_schema.md` for the full field reference.
class MistakesRepository {
  MistakesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the `users/{uid}/mistakes` [CollectionReference].
  /// Throws a [StateError] if no user is authenticated.
  CollectionReference<Map<String, dynamic>> get _mistakesCol {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('MistakesRepository: no authenticated user.');
    }
    return _firestore.collection('users').doc(uid).collection('mistakes');
  }

  // ── Record ─────────────────────────────────────────────────────────────────

  /// Persists a wrong answer event for [answer.questionId].
  ///
  /// Overwrites any existing document for the same [questionId] so that
  /// `attemptedAt` always reflects the most recent incorrect attempt.
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> record(WrongAnswer answer) async {
    // Sprint 10.5: replace with actual Firestore write.
    // await _mistakesCol.doc(answer.questionId).set({
    //   'questionId': answer.questionId,
    //   'subjectId': answer.subjectId,
    //   'chapterId': answer.chapterId,
    //   'chapterTitle': answer.chapterTitle,
    //   'attemptedAt': FieldValue.serverTimestamp(),
    // });
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  /// Deletes the wrong-answer document for [questionId].
  ///
  /// Called when the student later answers the same question correctly.
  /// No-op if the document does not exist.
  ///
  /// This method does **not** write to Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Future<void> remove(String questionId) async {
    // Sprint 10.5: replace with actual Firestore write.
    // await _mistakesCol.doc(questionId).delete();
  }

  // ── Watch ──────────────────────────────────────────────────────────────────

  /// Returns a live stream of all current wrong answers.
  ///
  /// Ordered by [attemptedAt] descending so the most recent mistake appears
  /// first in [MistakesScreen].
  ///
  /// This method does **not** read from Firestore yet.
  /// Wire it to `FirebaseFirestore` in Sprint 10.5.
  Stream<List<WrongAnswer>> watchAll() {
    // Sprint 10.5: replace with actual Firestore stream.
    // return _mistakesCol
    //     .orderBy('attemptedAt', descending: true)
    //     .snapshots()
    //     .map((snap) => snap.docs.map(_fromDoc).toList());
    return const Stream.empty();
  }

  // ── Serialisation ──────────────────────────────────────────────────────────

  // Sprint 10.5: uncomment when Firestore reads are wired in.
  // WrongAnswer _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
  //   final data = doc.data();
  //   return WrongAnswer(
  //     questionId: data['questionId'] as String,
  //     subjectId: data['subjectId'] as String,
  //     chapterId: data['chapterId'] as String,
  //     chapterTitle: data['chapterTitle'] as String,
  //     attemptedAt: (data['attemptedAt'] as Timestamp).toDate(),
  //   );
  // }
}
