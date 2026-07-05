import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_prep_app/features/catalog/providers/catalog_provider.dart';
import 'package:exam_prep_app/features/learning/models/chapter_progress.dart';
import 'package:exam_prep_app/features/learning/models/subject_progress.dart';
import 'package:exam_prep_app/features/learning/providers/learning_provider.dart';

// ── Chapter progress ──────────────────────────────────────────────────────────

/// Derived [ChapterProgress] for a single chapter, identified by [chapterId].
///
/// Automatically rebuilds whenever [learningProvider] or the catalog changes.
///
/// [totalQuestions] is resolved from [questionsForChapterProvider] (catalog
/// layer) — backed by local data now, Firestore in Sprint 10.6.
///
/// Usage: `ref.watch(chapterProgressProvider('ep_01'))`
final chapterProgressProvider =
    Provider.family<ChapterProgress, String>((ref, chapterId) {
  final attempts = ref
      .watch(learningProvider)
      .where((a) => a.chapterId == chapterId)
      .toList();

  final totalQuestions =
      ref.watch(questionsForChapterProvider(chapterId)).length;

  return ChapterProgress.fromAttempts(
    chapterId: chapterId,
    totalQuestions: totalQuestions,
    attempts: attempts,
  );
});

// ── Subject progress ──────────────────────────────────────────────────────────

/// Derived [SubjectProgress] for a single subject, identified by [subjectId].
///
/// Aggregates question counts across all chapters in the subject.
/// [totalQuestions] is the sum of all question counts from [chaptersForSubjectProvider].
///
/// Automatically rebuilds whenever [learningProvider] or the catalog changes.
///
/// Usage: `ref.watch(subjectProgressProvider('eng_physics'))`
final subjectProgressProvider =
    Provider.family<SubjectProgress, String>((ref, subjectId) {
  final attempts = ref
      .watch(learningProvider)
      .where((a) => a.subjectId == subjectId)
      .toList();

  final chapters = ref.watch(chaptersForSubjectProvider(subjectId));
  final totalQuestions = chapters.fold<int>(0, (sum, chapter) {
    return sum + ref.watch(questionsForChapterProvider(chapter.id)).length;
  });

  return SubjectProgress.fromAttempts(
    subjectId: subjectId,
    totalQuestions: totalQuestions,
    attempts: attempts,
  );
});
