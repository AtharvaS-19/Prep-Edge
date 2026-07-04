import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_prep_app/features/learning/models/progress_stats.dart';
import 'package:exam_prep_app/features/learning/models/question_attempt.dart';
import 'package:exam_prep_app/features/learning/providers/learning_provider.dart';

// ── Overall stats ─────────────────────────────────────────────────────────────

/// Overall [ProgressStats] derived from the complete learning history.
///
/// Reacts to every new [QuestionAttempt] recorded by [learningProvider].
/// Consumed by: ProgressScreen, HomeScreen "Continue Learning" card (future).
final progressStatsProvider = Provider<ProgressStats>((ref) {
  final attempts = ref.watch(learningProvider);
  return ProgressStats.fromAttempts(attempts);
});

// ── Scoped stats ──────────────────────────────────────────────────────────────

/// [ProgressStats] for a single chapter, identified by [chapterId].
///
/// Usage: `ref.watch(chapterStatsProvider('ep_01'))`
final chapterStatsProvider =
    Provider.family<ProgressStats, String>((ref, chapterId) {
  final attempts = ref.watch(learningProvider);
  final filtered = attempts.where((a) => a.chapterId == chapterId).toList();
  return ProgressStats.fromAttempts(filtered);
});

/// [ProgressStats] for a single subject, identified by [subjectId].
///
/// Usage: `ref.watch(subjectStatsProvider('eng_physics'))`
final subjectStatsProvider =
    Provider.family<ProgressStats, String>((ref, subjectId) {
  final attempts = ref.watch(learningProvider);
  final filtered = attempts.where((a) => a.subjectId == subjectId).toList();
  return ProgressStats.fromAttempts(filtered);
});

// ── Convenience providers ─────────────────────────────────────────────────────

/// The set of question IDs that have been attempted at least once, globally.
///
/// Derived from [progressStatsProvider] — no separate computation.
final completedQuestionsProvider = Provider<Set<String>>((ref) {
  return ref.watch(progressStatsProvider).completedQuestionIds;
});

/// The single most recent [QuestionAttempt] across all questions, or null.
///
/// Useful for the "Continue Learning" card on HomeScreen (future phase).
final latestAttemptProvider = Provider<QuestionAttempt?>((ref) {
  return ref.watch(progressStatsProvider).latestAttempt;
});
