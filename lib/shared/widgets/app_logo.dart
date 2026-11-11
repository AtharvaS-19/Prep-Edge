import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text.dart';

/// The brand mark for the app.
///
/// [size] controls the icon size, [showLabel] adds the wordmark text below
/// and [showTagline] adds the tagline (only when [showLabel] is true).
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 56,
    this.showLabel = true,
    this.showTagline = false,
  });

  final double size;
  final bool showLabel;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/branding/logo_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _LogoMarkFallback(size: size),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.appName,
            style: AppText.title.copyWith(fontSize: size * 0.4),
          ),
          if (showTagline) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              AppStrings.appTagline,
              textAlign: TextAlign.center,
              style: AppText.callout.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Fallback rendered only when the image asset cannot be loaded.
class _LogoMarkFallback extends StatelessWidget {
  const _LogoMarkFallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      alignment: Alignment.center,
      child: Text(
        'P',
        style: AppText.title
            .copyWith(fontSize: size * 0.5, color: AppColors.textOnPrimary),
      ),
    );
  }
}
