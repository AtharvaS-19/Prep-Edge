import 'package:flutter/material.dart';
import '../../models/chapter.dart';
import '../../../learning/models/chapter_progress.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/pressable.dart';

/// One chapter row, designed to sit inside an `AppGroup`.
///
/// [progress] is the live [ChapterProgress] derived from the Learning Engine.
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

  static String _questions(int n) => '$n question${n == 1 ? '' : 's'}';

  @override
  Widget build(BuildContext context) {
    final bool isStarted = progress.hasActivity;
    final bool isCompleted = progress.isCompleted;

    final String meta;
    if (isCompleted) {
      meta = 'Completed · ${progress.accuracyPercent}% accuracy';
    } else if (isStarted) {
      meta =
          '${progress.attemptedQuestions} of ${progress.totalQuestions} attempted · ${progress.accuracyPercent}% accuracy';
    } else {
      meta = _questions(progress.totalQuestions);
    }

    return Pressable(
      onTap: onTap,
      scale: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: isCompleted
                    ? const Icon(Icons.check_circle_rounded,
                        size: 18, color: AppColors.success)
                    : Text(
                        index.toString().padLeft(2, '0'),
                        style: AppText.callout.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w500,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chapter.title, style: AppText.bodyStrong),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: AppText.caption.copyWith(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (isStarted && !isCompleted) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppProgressBar(
                      value: progress.completionPercentage,
                      color: accentColor,
                      height: 4,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(Icons.chevron_right_rounded,
                  size: 20, color: AppColors.iconSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
