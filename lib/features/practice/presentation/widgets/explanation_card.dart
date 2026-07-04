import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _isCorrect ? AppColors.successLight : AppColors.errorLight,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: _isCorrect
              ? AppColors.success.withValues(alpha: 0.25)
              : AppColors.error.withValues(alpha: 0.25),
          width: 0.75,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Result header
          Row(
            children: [
              Icon(
                _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                size: 18,
                color: _isCorrect ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                _isCorrect ? 'Correct!' : 'Incorrect',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _isCorrect ? AppColors.success : AppColors.error,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          if (!_isCorrect) ...[
            const SizedBox(height: AppSpacing.sm),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Correct answer: ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: question.correctOptionText,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Explanation',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
