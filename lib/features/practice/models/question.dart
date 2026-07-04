/// The exam a question originates from.
enum ExamSource { jeeMain, jeeAdvanced, neet }

extension ExamSourceLabel on ExamSource {
  String get label => switch (this) {
        ExamSource.jeeMain => 'JEE Main',
        ExamSource.jeeAdvanced => 'JEE Adv',
        ExamSource.neet => 'NEET',
      };
}

/// A single multiple-choice question.
///
/// Immutable. All question data lives in [DummyQuestions].
/// When Firestore is added, this model stays unchanged.
class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.source,
    required this.year,
    this.isBookmarked = false,
  });

  final String id;

  /// The question text. May contain simple inline notation (e.g. "v²").
  final String text;

  /// Exactly 4 answer options, in display order.
  final List<String> options;

  /// 0-based index of the correct option within [options].
  final int correctOptionIndex;

  /// Explanation shown after the student submits an answer.
  final String explanation;

  final ExamSource source;
  final int year;

  /// Future-ready for Phase 5 bookmark system.
  final bool isBookmarked;

  /// The text of the correct option.
  String get correctOptionText => options[correctOptionIndex];

  /// Whether [selectedIndex] is the correct answer.
  bool isCorrect(int selectedIndex) => selectedIndex == correctOptionIndex;
}
