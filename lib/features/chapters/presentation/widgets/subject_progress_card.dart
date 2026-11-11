import 'package:flutter/material.dart';
import '../../../learning/models/subject_progress.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';

/// Overall progress summary for a subject, driven by live [SubjectProgress].
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({
    super.key,
    required this.subjectProgress,
    required this.accentColor,
    required this.totalChapters,
  });

  final SubjectProgress subjectProgress;
  final Color accentColor;

  /// Total number of chapters in this subject.
  final int totalChapters;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.radiusXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  text: '${subjectProgress.completionPercent}',
                  style: AppText.numeral.copyWith(fontSize: 40),
                  children: [
                    TextSpan(
                      text: '%',
                      style: AppText.title.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('complete', style: AppText.caption),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppProgressBar(
            value: subjectProgress.completionPercentage,
            color: accentColor,
            height: 6,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _Stat(
                value:
                    '${subjectProgress.attemptedQuestions}/${subjectProgress.totalQuestions}',
                label: 'Questions',
              ),
              const SizedBox(width: AppSpacing.xxl),
              _Stat(value: '$totalChapters', label: 'Chapters'),
              if (subjectProgress.hasActivity) ...[
                const SizedBox(width: AppSpacing.xxl),
                _Stat(
                  value: '${subjectProgress.accuracyPercent}%',
                  label: 'Accuracy',
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.callout.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(label, style: AppText.micro),
      ],
    );
  }
}
