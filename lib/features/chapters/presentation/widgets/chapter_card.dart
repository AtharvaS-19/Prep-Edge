import 'package:flutter/material.dart';
import '../../models/chapter.dart';
import '../../../learning/models/chapter_progress.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_radius.dart';
import '../../../../../shared/constants/app_spacing.dart';

/// A card widget displaying individual chapter details, progress, and a CTA.
///
/// [progress] is the live [ChapterProgress] derived from the Learning Engine.
/// When provided, all progress values are sourced from [progress]; when null
/// (defensive default), the card falls back to the static [chapter] fields.
class ChapterCard extends StatelessWidget {
  const ChapterCard({
    super.key,
    required this.chapter,
    required this.accentColor,
    required this.index,
    required this.onTap,
    required this.progress,
  });

  final Chapter chapter;
  final ChapterProgress progress;
  final Color accentColor;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String formattedIndex = index.toString().padLeft(2, '0');

    // Derive display values from live ChapterProgress.
    final bool isStarted = progress.hasActivity;
    final bool isCompleted = progress.isCompleted;
    final String ctaLabel = isCompleted
        ? 'Review'
        : isStarted
            ? 'Continue'
            : 'Start';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXxl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000), // ~5% black — very soft lift
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x06000000), // ~2.5% black — subtle ambient
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXxl,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Index / status indicator
                      _StatusIndicator(
                        formattedIndex: formattedIndex,
                        isCompleted: isCompleted,
                        accentColor: accentColor,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Title & sub-label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            _SubLabel(
                              progress: progress,
                              isStarted: isStarted,
                              isCompleted: isCompleted,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // CTA chip
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctaLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: accentColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Progress bar — only shown when the student has started
                  if (isStarted) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ProgressRow(
                      progress: progress,
                      accentColor: accentColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status indicator ──────────────────────────────────────────────────────────

/// Shows a green check for completed chapters, the numbered index otherwise.
class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({
    required this.formattedIndex,
    required this.isCompleted,
    required this.accentColor,
  });

  final String formattedIndex;
  final bool isCompleted;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.1)
            : accentColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check_rounded,
                size: 15,
                color: AppColors.success,
              )
            : Text(
                formattedIndex,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
      ),
    );
  }
}

// ── Sub-label ─────────────────────────────────────────────────────────────────

/// Displays a contextual description beneath the chapter title.
///
/// - Not started: total question count
/// - In progress: remaining questions
/// - Completed: "Completed · N% accuracy"
class _SubLabel extends StatelessWidget {
  const _SubLabel({
    required this.progress,
    required this.isStarted,
    required this.isCompleted,
  });

  final ChapterProgress progress;
  final bool isStarted;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final String label;

    if (isCompleted) {
      label = 'Completed · ${progress.accuracyPercent}% accuracy';
    } else if (isStarted) {
      final remaining = progress.totalQuestions - progress.attemptedQuestions;
      label = '$remaining remaining';
    } else {
      label = '${progress.totalQuestions} questions';
    }

    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isCompleted ? AppColors.success : AppColors.textSecondary,
      ),
    );
  }
}

// ── Progress row ──────────────────────────────────────────────────────────────

/// Linear progress bar + completion% + accuracy pill shown for started chapters.
class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.progress,
    required this.accentColor,
  });

  final ChapterProgress progress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: AppRadius.radiusFull,
                child: LinearProgressIndicator(
                  value: progress.completionPercentage,
                  minHeight: 5,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${progress.completionPercent}%',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        if (progress.hasActivity) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${progress.attemptedQuestions} of ${progress.totalQuestions} attempted · '
            '${progress.accuracyPercent}% accuracy',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}
