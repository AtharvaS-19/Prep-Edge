import 'package:flutter/material.dart';
import '../../models/question.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_motion.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/pressable.dart';

/// Renders a single MCQ question with its selectable options.
///
/// State is managed externally — this widget is purely presentational.
/// [selectedIndex] = null means no answer chosen yet.
/// [isSubmitted] locks the options and reveals correct/incorrect colours.
/// [isBookmarked] is accepted for API completeness — the bookmark toggle lives
/// in the AppBar, not inside this card.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.selectedIndex,
    required this.isSubmitted,
    required this.onOptionSelected,
    this.isBookmarked = false,
  });

  final Question question;
  final int? selectedIndex;
  final bool isSubmitted;
  final ValueChanged<int> onOptionSelected;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: AppText.headline.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.55,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ...List.generate(question.options.length, (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom:
                  index < question.options.length - 1 ? AppSpacing.sm : 0,
            ),
            child: _OptionTile(
              index: index,
              text: question.options[index],
              selectedIndex: selectedIndex,
              correctIndex: question.correctOptionIndex,
              isSubmitted: isSubmitted,
              onTap: isSubmitted ? null : () => onOptionSelected(index),
            ),
          );
        }),
      ],
    );
  }
}

// ── Option tile ───────────────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selectedIndex,
    required this.correctIndex,
    required this.isSubmitted,
    required this.onTap,
  });

  final int index;
  final String text;
  final int? selectedIndex;
  final int correctIndex;
  final bool isSubmitted;
  final VoidCallback? onTap;

  static const List<String> _labels = ['A', 'B', 'C', 'D'];

  _OptionStyle get _style {
    if (!isSubmitted) {
      final bool isSelected = selectedIndex == index;
      return _OptionStyle(
        background:
            isSelected ? AppColors.primaryLight : AppColors.cardBackground,
        border: isSelected ? AppColors.primary : AppColors.border,
        labelBackground:
            isSelected ? AppColors.primary : AppColors.cardBackgroundAlt,
        labelColor: isSelected ? Colors.white : AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        borderWidth: isSelected ? 1.5 : 1.0,
      );
    }

    final bool isCorrect = index == correctIndex;
    final bool isWrongSelected = selectedIndex == index && !isCorrect;

    if (isCorrect) {
      return const _OptionStyle(
        background: AppColors.successLight,
        border: AppColors.success,
        labelBackground: AppColors.success,
        labelColor: Colors.white,
        textColor: AppColors.textPrimary,
        borderWidth: 1.5,
      );
    }
    if (isWrongSelected) {
      return const _OptionStyle(
        background: AppColors.errorLight,
        border: AppColors.error,
        labelBackground: AppColors.error,
        labelColor: Colors.white,
        textColor: AppColors.textPrimary,
        borderWidth: 1.5,
      );
    }
    return const _OptionStyle(
      background: AppColors.cardBackground,
      border: AppColors.border,
      labelBackground: AppColors.cardBackgroundAlt,
      labelColor: AppColors.textTertiary,
      textColor: AppColors.textTertiary,
      borderWidth: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;

    return Pressable(
      onTap: onTap,
      scale: 0.99,
      child: AnimatedContainer(
        duration: AppMotion.base,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: style.border, width: style.borderWidth),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.base,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: style.labelBackground,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _labels[index],
                style: AppText.captionStrong.copyWith(
                  color: style.labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppText.body
                    .copyWith(color: style.textColor, height: 1.4),
              ),
            ),
            if (isSubmitted && index == correctIndex)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(Icons.check_circle_rounded,
                    size: 20, color: AppColors.success),
              ),
            if (isSubmitted && selectedIndex == index && index != correctIndex)
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Icon(Icons.cancel_rounded,
                    size: 20, color: AppColors.error),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionStyle {
  const _OptionStyle({
    required this.background,
    required this.border,
    required this.labelBackground,
    required this.labelColor,
    required this.textColor,
    required this.borderWidth,
  });

  final Color background;
  final Color border;
  final Color labelBackground;
  final Color labelColor;
  final Color textColor;
  final double borderWidth;
}
