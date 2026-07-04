import 'package:exam_prep_app/features/learning/models/question_attempt.dart';

/// Derived progress snapshot for a single subject (aggregated across all its chapters).
///
/// Constructed via [SubjectProgress.fromAttempts]. All fields are computed
/// from [QuestionAttempt] records — no state is duplicated from [LearningNotifier].
///
/// [correctQuestions] and [incorrectQuestions] are based on the **latest**
/// attempt per question, reflecting the student's current mastery.
class SubjectProgress {
  const SubjectProgress({
    required this.subjectId,
    required this.totalQuestions,
    required this.attemptedQuestions,
    required this.correctQuestions,
    required this.incorrectQuestions,
    required this.completionPercentage,
    required this.accuracyPercentage,
  });

  /// Derives subject progress from a filtered list of [QuestionAttempt]s.
  ///
  /// [attempts] must already be filtered to this [subjectId].
  /// [totalQuestions] is supplied by the caller as the sum of all question
  /// counts across all chapters in the subject.
  factory SubjectProgress.fromAttempts({
    required String subjectId,
    required int totalQuestions,
    required List<QuestionAttempt> attempts,
  }) {
    if (attempts.isEmpty || totalQuestions == 0) {
      return SubjectProgress(
        subjectId: subjectId,
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

    return SubjectProgress(
      subjectId: subjectId,
      totalQuestions: totalQuestions,
      attemptedQuestions: attempted,
      correctQuestions: correct,
      incorrectQuestions: attempted - correct,
      completionPercentage:
          totalQuestions > 0 ? attempted / totalQuestions : 0.0,
      accuracyPercentage: attempted > 0 ? correct / attempted : 0.0,
    );
  }

  final String subjectId;

  /// Total questions available across all chapters in this subject.
  final int totalQuestions;

  /// Distinct questions attempted at least once across all chapters.
  final int attemptedQuestions;

  /// Questions whose most recent attempt was correct.
  final int correctQuestions;

  /// Questions whose most recent attempt was incorrect.
  final int incorrectQuestions;

  /// Fraction of total subject questions attempted (0.0–1.0).
  final double completionPercentage;

  /// Fraction of attempted subject questions answered correctly (0.0–1.0).
  final double accuracyPercentage;

  /// Completion as an integer percentage (0–100).
  int get completionPercent => (completionPercentage * 100).round();

  /// Accuracy as an integer percentage (0–100).
  int get accuracyPercent => (accuracyPercentage * 100).round();

  /// True when the student has attempted at least one question in this subject.
  bool get hasActivity => attemptedQuestions > 0;
}
