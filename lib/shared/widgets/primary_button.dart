import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_motion.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text.dart';
import 'pressable.dart';

/// The primary call-to-action button used throughout the app.
///
/// - [label]: the button text
/// - [onPressed]: tap callback; pass null to disable
/// - [isLoading]: shows a spinner and disables interaction
/// - [isFullWidth]: stretches to fill available width (default true)
/// - [icon]: optional trailing icon
/// - [outlined]: renders the secondary, bordered variant
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final Color fg = outlined ? AppColors.textPrimary : Colors.white;
    final Color bg = outlined
        ? AppColors.cardBackground
        : (disabled
            ? AppColors.primary.withValues(alpha: 0.45)
            : AppColors.primary);

    final Widget content = AnimatedSwitcher(
      duration: AppMotion.fast,
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loading'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(fg),
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: AppText.button.copyWith(color: fg)),
                if (icon != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Icon(icon, size: 18, color: fg),
                ],
              ],
            ),
    );

    return Pressable(
      onTap: disabled ? null : onPressed,
      haptic: true,
      scale: 0.985,
      child: AnimatedContainer(
        duration: AppMotion.base,
        height: AppSpacing.buttonHeight,
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.radiusLg,
          border: outlined ? Border.all(color: AppColors.border) : null,
        ),
        child: content,
      ),
    );
  }
}
