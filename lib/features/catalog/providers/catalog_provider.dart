import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/catalog_repository.dart';
import '../../subjects/models/subject_model.dart';
import '../../chapters/models/chapter.dart';
import '../../practice/models/question.dart';

// ── Repository provider ────────────────────────────────────────────────────────

/// Provides the singleton [CatalogRepository] for the lifetime of the app.
///
/// Currently backed by local static data. Sprint 10.6 swaps the repository
/// implementation — no provider or consumer changes required.
final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return const CatalogRepository();
});

// ── Subject providers ──────────────────────────────────────────────────────────

/// All subjects across both exam streams.
///
/// Replaces direct calls to `SubjectsData.all`.
final allSubjectsProvider = Provider<List<SubjectModel>>((ref) {
  return ref.watch(catalogRepositoryProvider).allSubjects();
});

/// Subjects filtered to [ExamStream].
///
/// Replaces direct calls to `SubjectsData.forStream(stream)`.
final subjectsForStreamProvider =
    Provider.family<List<SubjectModel>, ExamStream>((ref, stream) {
  return ref.watch(catalogRepositoryProvider).subjectsForStream(stream);
});

/// Finds a single subject by its stable [id].
///
/// Replaces direct calls to `SubjectsData.findById(id)`.
final subjectByIdProvider =
    Provider.family<SubjectModel?, String>((ref, id) {
  return ref.watch(catalogRepositoryProvider).findSubjectById(id);
});

// ── Chapter provider ───────────────────────────────────────────────────────────

/// Chapters for a single subject, identified by [subjectId].
///
/// Replaces direct calls to `DummyChapters.forSubject(subjectId)`.
final chaptersForSubjectProvider =
    Provider.family<List<Chapter>, String>((ref, subjectId) {
  return ref.watch(catalogRepositoryProvider).chaptersForSubject(subjectId);
});

// ── Question provider ──────────────────────────────────────────────────────────

/// Questions for a single chapter, identified by [chapterId].
///
/// Replaces direct calls to `DummyQuestions.forChapter(chapterId)`.
final questionsForChapterProvider =
    Provider.family<List<Question>, String>((ref, chapterId) {
  return ref.watch(catalogRepositoryProvider).questionsForChapter(chapterId);
});
