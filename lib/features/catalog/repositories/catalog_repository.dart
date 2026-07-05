import 'package:flutter/material.dart';
import '../../subjects/models/subject_model.dart';
import '../../subjects/data/subjects_data.dart';
import '../../chapters/models/chapter.dart';
import '../../chapters/data/dummy_chapters.dart';
import '../../practice/models/question.dart';
import '../../practice/data/dummy_questions.dart';

/// Data-layer contract for the PrepEdge question catalog.
///
/// Currently backed by local static data ([SubjectsData], [DummyChapters],
/// [DummyQuestions]). In Sprint 10.6 the method bodies are replaced by
/// Firestore reads — the public API and all callers remain unchanged.
///
/// ## Firestore paths (future)
/// - `catalog/subjects/{subjectId}`
/// - `catalog/chapters/{chapterId}`
/// - `catalog/questions/{questionId}`
///
/// Note: [SubjectModel] contains Flutter-specific types ([IconData], [Color]).
/// These will continue to be resolved locally from a mapping table even after
/// Firestore integration, since those types cannot be stored in Firestore.
class CatalogRepository {
  const CatalogRepository();

  // ── Subjects ───────────────────────────────────────────────────────────────

  /// Returns all subjects across both exam streams.
  ///
  /// Sprint 10.6: replace body with Firestore read of `catalog/subjects`.
  List<SubjectModel> allSubjects() => SubjectsData.all;

  /// Returns subjects filtered by [stream].
  List<SubjectModel> subjectsForStream(ExamStream stream) =>
      SubjectsData.forStream(stream);

  /// Finds a subject by its [id]. Returns null if not found.
  SubjectModel? findSubjectById(String id) => SubjectsData.findById(id);

  // ── Chapters ───────────────────────────────────────────────────────────────

  /// Returns all chapters for [subjectId], or an empty list.
  ///
  /// Sprint 10.6: replace body with Firestore query on `catalog/chapters`
  /// where `subjectId == subjectId`.
  List<Chapter> chaptersForSubject(String subjectId) =>
      DummyChapters.forSubject(subjectId);

  // ── Questions ──────────────────────────────────────────────────────────────

  /// Returns all questions for [chapterId].
  ///
  /// Falls back to a generic placeholder when the chapter has no specific
  /// questions — preserving the existing [DummyQuestions] behaviour.
  ///
  /// Sprint 10.6: replace body with Firestore query on `catalog/questions`
  /// where `chapterId == chapterId`.
  List<Question> questionsForChapter(String chapterId) =>
      DummyQuestions.forChapter(chapterId);
}
