/// A single chapter within a subject.
///
/// Immutable. All chapter data is sourced from [DummyChapters].
/// When Firestore is introduced, this model stays unchanged —
/// only the data source swaps.
class Chapter {
  const Chapter({
    required this.id,
    required this.title,
    required this.totalQuestions,
    required this.completedQuestions,
    this.isBookmarked = false,
  });

  final String id;
  final String title;
  final int totalQuestions;
  final int completedQuestions;

  /// Future-ready: bookmark support in Phase 5.
  final bool isBookmarked;

  /// Progress as a fraction between 0.0 and 1.0.
  double get progress =>
      totalQuestions == 0 ? 0.0 : completedQuestions / totalQuestions;

  /// Progress as a rounded percentage integer (0–100).
  int get progressPercent => (progress * 100).round();

  /// Whether the student has started this chapter.
  bool get isStarted => completedQuestions > 0;

  /// Whether the student has fully completed this chapter.
  bool get isCompleted => completedQuestions >= totalQuestions;

  /// The label shown on the chapter card CTA.
  String get ctaLabel {
    if (isCompleted) return 'Review';
    if (isStarted) return 'Continue';
    return 'Start';
  }

  /// Formatted remaining count for display.
  String get remainingLabel {
    final remaining = totalQuestions - completedQuestions;
    if (isCompleted) return 'Completed';
    if (!isStarted) return '$totalQuestions questions';
    return '$remaining remaining';
  }
}
