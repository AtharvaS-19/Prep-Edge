import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_progress_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/reveal.dart';

/// Shown at the end of a practice session.
///
/// Receives result data via GoRouter's `extra` parameter. Displays score and
/// accuracy, and offers navigation back to chapters or to practice again.
class PracticeResultScreen extends StatelessWidget {
  const PracticeResultScreen({
    super.key,
    required this.chapterTitle,
    required this.total,
    required this.correct,
    required this.subjectId,
    required this.chapterId,
  });

  final String chapterTitle;
  final int total;
  final int correct;
  final String subjectId;
  final String chapterId;

  int get _wrong => total - correct;
  int get _accuracyPercent =>
      total == 0 ? 0 : ((correct / total) * 100).round();

  Color get _tone {
    if (_accuracyPercent >= 80) return AppColors.success;
    if (_accuracyPercent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  String get _verdict {
    if (_accuracyPercent >= 80) return 'Strong session';
    if (_accuracyPercent >= 50) return 'Good progress';
    return 'Room to grow';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      AppSpacing.xxl,
                      AppSpacing.screenHorizontal,
                      AppSpacing.xl,
                    ),
                    child: Reveal(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Session complete', style: AppText.caption),
                          const SizedBox(height: 4),
                          Text(chapterTitle, style: AppText.display.copyWith(fontSize: 26)),
                          const SizedBox(height: AppSpacing.xl),
                          AppCard(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_verdict,
                                    style: AppText.captionStrong
                                        .copyWith(color: _tone)),
                                const SizedBox(height: AppSpacing.xs),
                                Text.rich(
                                  TextSpan(
                                    text: '$_accuracyPercent',
                                    style: AppText.numeral
                                        .copyWith(fontSize: 64, color: _tone),
                                    children: [
                                      TextSpan(
                                        text: '%',
                                        style: AppText.title.copyWith(
                                          fontSize: 26,
                                          color: AppColors.textTertiary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text('$correct of $total answered correctly',
                                    style: AppText.callout.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w400)),
                                const SizedBox(height: AppSpacing.lg),
                                AppProgressBar(
                                  value: total == 0 ? 0 : correct / total,
                                  color: _tone,
                                  height: 6,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                const Divider(height: 1),
                                const SizedBox(height: AppSpacing.lg),
                                Row(
                                  children: [
                                    _Stat(
                                        label: 'Correct',
                                        value: '$correct',
                                        color: AppColors.success),
                                    _Stat(
                                        label: 'Wrong',
                                        value: '$_wrong',
                                        color: AppColors.error),
                                    _Stat(
                                        label: 'Total',
                                        value: '$total',
                                        color: AppColors.textPrimary),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    0,
                    AppSpacing.screenHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    children: [
                      PrimaryButton(
                        label: 'Back to chapters',
                        onPressed: () => context.go('/subjects/$subjectId'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      PrimaryButton(
                        label: 'Practice again',
                        outlined: true,
                        onPressed: () => context.pushReplacement(
                          '/subjects/$subjectId/chapters/$chapterId/practice',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.stat.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(label, style: AppText.micro),
        ],
      ),
    );
  }
}
