import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';

/// Top progress bar shown on the practice screen.
///
/// Displays "Q 3 of 20", a linear progress indicator,
/// and the exam source tag on the right.
class QuestionProgressBar extends StatelessWidget {
  const QuestionProgressBar({
    super.key,
    required this.currentIndex,
    required this.total,
    required this.sourceLabel,
    required this.year,
  });

  final int currentIndex; // 0-based
  final int total;
  final String sourceLabel;
  final int year;

  double get _progress => total == 0 ? 0 : (currentIndex + 1) / total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Q ${currentIndex + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            Text(
              ' of $total',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textTertiary,
              ),
            ),
            const Spacer(),
            _SourceTag(label: sourceLabel, year: year),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 4,
            backgroundColor: AppColors.progressTrack,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _SourceTag extends StatelessWidget {
  const _SourceTag({required this.label, required this.year});
  final String label;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        '$label · $year',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
