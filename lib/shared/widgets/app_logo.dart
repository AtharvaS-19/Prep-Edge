import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';

/// The brand mark for the app.
///
/// [size] controls the icon container size (applied to both width and height).
/// [showLabel] adds the "PrepEdge" wordmark text below the icon.
/// [showTagline] adds the tagline below the name (only when [showLabel] is true).
///
/// Uses the real `assets/branding/logo_icon.png` asset.
/// Every screen that renders AppLogo automatically inherits the real brand.
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
        // Real brand icon — swapped from placeholder Container
        Image.asset(
          'assets/branding/logo_icon.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          // Graceful fallback while asset loads or if path is wrong in a test
          errorBuilder: (_, __, ___) => _LogoMarkFallback(size: size),
        ),
        if (showLabel) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.appName,
            style: TextStyle(
              fontSize: size * 0.45,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          if (showTagline) ...[
            const SizedBox(height: AppSpacing.xxs),
            const Text(
              AppStrings.appTagline,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ],
    );
  }
}

/// Fallback rendered only when the image asset cannot be loaded
/// (e.g. in unit-test environments without asset bundles).
/// Matches the original placeholder visual so tests don't break.
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
        borderRadius: BorderRadius.circular(size * 0.214), // ≈ radiusMd ratio
      ),
      child: Center(
        child: Text(
          'P',
          style: TextStyle(
            fontSize: size * 0.50,
            fontWeight: FontWeight.w800,
            color: AppColors.textOnPrimary,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }
}
