import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/widgets/primary_button.dart';

/// Shown at the end of a practice session.
///
/// Receives result data via GoRouter's `extra` parameter.
/// Displays score, accuracy, and offers navigation back to chapters
/// or to practice again.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        title: const Text('Session complete'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.xl,
            AppSpacing.screenHorizontal,
            AppSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter label
              Text(
                chapterTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'Here\'s how you did',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Score card
              _ScoreCard(
                correct: correct,
                wrong: _wrong,
                total: total,
                accuracyPercent: _accuracyPercent,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Stat row
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Correct',
                      value: '$correct',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Wrong',
                      value: '$_wrong',
                      color: AppColors.error,
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.cardGap),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Accuracy',
                      value: '$_accuracyPercent%',
                      color: AppColors.primary,
                      icon: Icons.track_changes_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Actions
              PrimaryButton(
                label: 'Back to chapters',
                onPressed: () => context.go('/subjects/$subjectId'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () => context.pushReplacement(
                  '/subjects/$subjectId/chapters/$chapterId/practice',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize:
                      const Size(double.infinity, AppSpacing.buttonHeight),
                  side: const BorderSide(color: AppColors.border),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                  ),
                ),
                child: const Text(
                  'Practice again',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Score card ────────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.correct,
    required this.wrong,
    required this.total,
    required this.accuracyPercent,
  });

  final int correct;
  final int wrong;
  final int total;
  final int accuracyPercent;

  Color get _accuracyColor {
    if (accuracyPercent >= 80) return AppColors.success;
    if (accuracyPercent >= 50) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
        ],
      ),
      child: Column(
        children: [
          // Big accuracy number
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$accuracyPercent',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: _accuracyColor,
                    letterSpacing: -3,
                    height: 1.0,
                  ),
                ),
                TextSpan(
                  text: '%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: _accuracyColor.withValues(alpha: 0.7),
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$correct out of $total correct',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : correct / total,
              minHeight: 7,
              backgroundColor: AppColors.progressTrack,
              valueColor: AlwaysStoppedAnimation<Color>(_accuracyColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
