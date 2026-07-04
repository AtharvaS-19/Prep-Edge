import 'package:exam_prep_app/features/learning/models/question_attempt.dart';

/// Derived progress snapshot for a single chapter.
///
/// Constructed via [ChapterProgress.fromAttempts]. All fields are computed
/// from [QuestionAttempt] records — no state is duplicated from [LearningNotifier].
///
/// [correctQuestions] and [incorrectQuestions] are based on the **latest**
/// attempt per question, reflecting the student's current mastery rather than
/// their full attempt history.
class ChapterProgress {
  const ChapterProgress({
    required this.chapterId,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctQuestions,
    required this.incorrectQuestions,
    required this.completionPercentage,
    required this.accuracyPercentage,
  });

  /// Derives chapter progress from a filtered list of [QuestionAttempt]s.
  ///
  /// [attempts] must already be filtered to this [chapterId].
  /// [totalQuestions] is supplied by the caller from the question data source
  /// (e.g. DummyQuestions) so this model has no data-layer dependency.
  factory ChapterProgress.fromAttempts({
    required String chapterId,
    required int totalQuestions,
    required List<QuestionAttempt> attempts,
  }) {
    if (attempts.isEmpty || totalQuestions == 0) {
      return ChapterProgress(
        chapterId: chapterId,
        totalQuestions: totalQuestions,
        attemptedQuestions: 0,
        correctQuestions: 0,
        incorrectQuestions: 0,
        completionPercentage: 0.0,
        accuracyPercentage: 0.0,
      );
    }

    // One entry per question ID — last write wins (attempts are appended
    // chronologically, so the last entry is the most recent attempt).
    final latestByQuestion = <String, QuestionAttempt>{};
    for (final attempt in attempts) {
      latestByQuestion[attempt.questionId] = attempt;
    }

    final attempted = latestByQuestion.length;
    final correct = latestByQuestion.values.where((a) => a.isCorrect).length;

    return ChapterProgress(
      chapterId: chapterId,
      totalQuestions: totalQuestions,
      attemptedQuestions: attempted,
      correctQuestions: correct,
      incorrectQuestions: attempted - correct,
      completionPercentage:
          totalQuestions > 0 ? attempted / totalQuestions : 0.0,
      accuracyPercentage: attempted > 0 ? correct / attempted : 0.0,
    );
  }

  final String chapterId;

  /// Total questions available in this chapter (from the data layer).
  final int totalQuestions;

  /// Distinct questions attempted at least once.
  final int attemptedQuestions;

  /// Questions whose most recent attempt was correct.
  final int correctQuestions;

  /// Questions whose most recent attempt was incorrect.
  final int incorrectQuestions;

  /// Fraction of total questions attempted (0.0–1.0).
  final double completionPercentage;

  /// Fraction of attempted questions answered correctly (0.0–1.0).
  final double accuracyPercentage;

  /// Completion as an integer percentage (0–100).
  int get completionPercent => (completionPercentage * 100).round();

  /// Accuracy as an integer percentage (0–100).
  int get accuracyPercent => (accuracyPercentage * 100).round();

  /// True when the student has attempted at least one question.
  bool get hasActivity => attemptedQuestions > 0;

  /// True when every question has been attempted at least once.
  bool get isCompleted =>
      totalQuestions > 0 && attemptedQuestions >= totalQuestions;
}
