import 'package:flutter/material.dart';
import '../../../learning/models/subject_progress.dart';
import '../../../../../shared/constants/app_colors.dart';
import '../../../../../shared/constants/app_radius.dart';
import '../../../../../shared/constants/app_spacing.dart';

/// Displays the overall progress summary for a subject.
///
/// Receives a live [SubjectProgress] derived from the Learning Engine.
/// All values are computed from actual attempt history — not static dummy data.
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({
    super.key,
    required this.subjectProgress,
    required this.accentColor,
    required this.totalChapters,
  });

  final SubjectProgress subjectProgress;
  final Color accentColor;

  /// Total number of chapters in this subject, used for the "N chapters done"
  /// stat. Passed from the caller which owns the chapter list.
  final int totalChapters;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXxl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 16,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: completion % + stat badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall progress',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${subjectProgress.completionPercent}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: -1.5,
                              height: 1.0,
                            ),
                          ),
                          const TextSpan(
                            text: '%',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textTertiary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Stat column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatBadge(
                    value:
                        '${subjectProgress.attemptedQuestions} / ${subjectProgress.totalQuestions}',
                    label: 'questions',
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Accuracy badge — only meaningful when there's activity
                  if (subjectProgress.hasActivity)
                    _StatBadge(
                      value: '${subjectProgress.accuracyPercent}%',
                      label: 'accuracy',
                    )
                  else
                    _StatBadge(
                      value: '$totalChapters',
                      label: 'chapters',
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: subjectProgress.completionPercentage,
              minHeight: 7,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }
}
