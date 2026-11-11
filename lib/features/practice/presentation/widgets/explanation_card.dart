import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/reveal.dart';

/// Displayed below the question after the student submits an answer.
///
/// Shows whether the answer was correct, the correct option text,
/// and a plain-language explanation.
class ExplanationCard extends StatelessWidget {
  const ExplanationCard({
    super.key,
    required this.question,
    required this.selectedIndex,
  });

  final Question question;
  final int selectedIndex;

  bool get _isCorrect => question.isCorrect(selectedIndex);

  @override
  Widget build(BuildContext context) {
    final Color tone = _isCorrect ? AppColors.success : AppColors.error;

    return Reveal(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 20,
                  color: tone,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _isCorrect ? 'Correct' : 'Incorrect',
                  style: AppText.headline.copyWith(color: tone),
                ),
              ],
            ),
            if (!_isCorrect) ...[
              const SizedBox(height: AppSpacing.sm),
              Text.rich(
                TextSpan(
                  text: 'Correct answer  ',
                  style: AppText.callout.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: question.correctOptionText,
                      style: AppText.callout
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            Text('Explanation', style: AppText.captionStrong),
            const SizedBox(height: 6),
            Text(
              question.explanation,
              style: AppText.body.copyWith(fontSize: 14.5, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
