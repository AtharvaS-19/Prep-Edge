import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/app_progress_bar.dart';

/// Top progress strip shown on the practice screen: "Question 3 of 20", the
/// exam source on the right and a slim progress bar beneath.
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
    const tabular = [FontFeature.tabularFigures()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text.rich(
              TextSpan(
                text: 'Question ${currentIndex + 1}',
                style: AppText.callout
                    .copyWith(fontWeight: FontWeight.w600, fontFeatures: tabular),
                children: [
                  TextSpan(
                    text: ' of $total',
                    style: AppText.callout.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                      fontFeatures: tabular,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text('$sourceLabel · $year', style: AppText.caption),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppProgressBar(value: _progress, height: 4),
      ],
    );
  }
}
