import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_prep_app/features/chapters/data/dummy_chapters.dart';
import 'package:exam_prep_app/features/learning/models/chapter_progress.dart';
import 'package:exam_prep_app/features/learning/models/subject_progress.dart';
import 'package:exam_prep_app/features/learning/providers/learning_provider.dart';
import 'package:exam_prep_app/features/practice/data/dummy_questions.dart';

// ── Chapter progress ──────────────────────────────────────────────────────────

/// Derived [ChapterProgress] for a single chapter, identified by [chapterId].
///
/// Automatically rebuilds whenever [learningProvider] state changes — no
/// manual refresh is ever required.
///
/// [totalQuestions] is resolved from [DummyQuestions] (static data layer)
/// and will be replaced by a repository call when Firestore is introduced.
///
/// Usage: `ref.watch(chapterProgressProvider('ep_01'))`
final chapterProgressProvider =
    Provider.family<ChapterProgress, String>((ref, chapterId) {
  final attempts = ref
      .watch(learningProvider)
      .where((a) => a.chapterId == chapterId)
      .toList();

  final totalQuestions = DummyQuestions.forChapter(chapterId).length;

  return ChapterProgress.fromAttempts(
    chapterId: chapterId,
    totalQuestions: totalQuestions,
    attempts: attempts,
  );
});

// ── Subject progress ──────────────────────────────────────────────────────────

/// Derived [SubjectProgress] for a single subject, identified by [subjectId].
///
/// Aggregates [ChapterProgress] across all chapters in the subject.
/// [totalQuestions] is the sum of all question counts across every chapter
/// belonging to the subject.
///
/// Automatically rebuilds whenever [learningProvider] state changes.
///
/// Usage: `ref.watch(subjectProgressProvider('eng_physics'))`
final subjectProgressProvider =
    Provider.family<SubjectProgress, String>((ref, subjectId) {
  final attempts = ref
      .watch(learningProvider)
      .where((a) => a.subjectId == subjectId)
      .toList();

  // Sum question counts across every chapter in this subject.
  // DummyChapters.forSubject returns [] for unrecognised IDs — safe default.
  final totalQuestions =
      DummyChapters.forSubject(subjectId).fold<int>(0, (sum, chapter) {
    return sum + DummyQuestions.forChapter(chapter.id).length;
  });

  return SubjectProgress.fromAttempts(
    subjectId: subjectId,
    totalQuestions: totalQuestions,
    attempts: attempts,
  );
});
