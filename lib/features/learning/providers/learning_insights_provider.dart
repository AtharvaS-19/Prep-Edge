import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_prep_app/features/learning/models/question_attempt.dart';
import 'package:exam_prep_app/features/learning/providers/learning_provider.dart';
import 'package:exam_prep_app/features/learning/providers/progress_stats_provider.dart';

// ── Continue learning ─────────────────────────────────────────────────────────

/// The most appropriate [QuestionAttempt] for resuming a learning session.
///
/// Currently delegates to [latestAttemptProvider] (last question submitted).
/// Future phases may factor in spaced repetition, weak chapters, or
/// user-configured goals — all without changing this provider's type signature.
///
/// Returns null when no attempts have been recorded yet.
final continueLearningProvider = Provider<QuestionAttempt?>((ref) {
  return ref.watch(latestAttemptProvider);
});

// ── Chapter insight providers ─────────────────────────────────────────────────

/// The chapter ID with the **lowest** accuracy among chapters attempted at
/// least once.
///
/// Accuracy is computed as `correctQuestions / attemptedQuestions` where
/// correct/incorrect is based on the latest attempt per question.
///
/// Returns null when no attempts exist.
final weakestChapterProvider = Provider<String?>((ref) {
  final attempts = ref.watch(learningProvider);
  if (attempts.isEmpty) return null;

  // Build accuracy per chapter from the latest attempt per question.
  final chapterIds = attempts.map((a) => a.chapterId).toSet();
  String? weakest;
  double lowestAccuracy = double.infinity;

  for (final chapterId in chapterIds) {
    final chapterAttempts =
        attempts.where((a) => a.chapterId == chapterId).toList();
    final accuracy = _latestAccuracy(chapterAttempts);
    if (accuracy < lowestAccuracy) {
      lowestAccuracy = accuracy;
      weakest = chapterId;
    }
  }

  return weakest;
});

/// The chapter ID with the **highest** accuracy among chapters attempted at
/// least once.
///
/// Returns null when no attempts exist.
final strongestChapterProvider = Provider<String?>((ref) {
  final attempts = ref.watch(learningProvider);
  if (attempts.isEmpty) return null;

  final chapterIds = attempts.map((a) => a.chapterId).toSet();
  String? strongest;
  double highestAccuracy = -1;

  for (final chapterId in chapterIds) {
    final chapterAttempts =
        attempts.where((a) => a.chapterId == chapterId).toList();
    final accuracy = _latestAccuracy(chapterAttempts);
    if (accuracy > highestAccuracy) {
      highestAccuracy = accuracy;
      strongest = chapterId;
    }
  }

  return strongest;
});

/// The chapter ID with the **most raw submission events** (total attempts,
/// not distinct questions). Rewards sustained practice sessions.
///
/// Returns null when no attempts exist.
final mostPracticedChapterProvider = Provider<String?>((ref) {
  final attempts = ref.watch(learningProvider);
  if (attempts.isEmpty) return null;

  // Tally raw attempt count per chapter.
  final counts = <String, int>{};
  for (final a in attempts) {
    counts[a.chapterId] = (counts[a.chapterId] ?? 0) + 1;
  }

  return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
});

// ── Recently completed questions ──────────────────────────────────────────────

/// Question IDs sorted by most-recently-attempted first.
///
/// Each question ID appears exactly once — the ordering reflects the time of
/// the student's **latest** attempt on that question, not the first.
///
/// "Completed" means the question has been submitted at least once.
/// Use this provider to drive recency-based UIs (e.g. recently solved list).
final recentlyCompletedQuestionsProvider = Provider<List<String>>((ref) {
  final attempts = ref.watch(learningProvider);
  if (attempts.isEmpty) return const [];

  // Keep the latest attempt per question ID.
  // Iterate in reverse so the first occurrence we see is the most recent.
  final seen = <String>{};
  final ordered = <String>[];

  for (final attempt in attempts.reversed) {
    if (seen.add(attempt.questionId)) {
      ordered.add(attempt.questionId);
    }
  }

  // `ordered` is already newest-first because we iterated in reverse.
  return List.unmodifiable(ordered);
});

// ── Private helpers ───────────────────────────────────────────────────────────

/// Computes accuracy (0.0–1.0) for a pre-filtered list of attempts
/// using the latest attempt per question as the authoritative result.
///
/// Returns 0.0 when [attempts] is empty (safe default for comparisons).
double _latestAccuracy(List<QuestionAttempt> attempts) {
  if (attempts.isEmpty) return 0.0;

  final latestByQuestion = <String, QuestionAttempt>{};
  for (final a in attempts) {
    latestByQuestion[a.questionId] = a;
  }

  final correct = latestByQuestion.values.where((a) => a.isCorrect).length;
  return correct / latestByQuestion.length;
}
