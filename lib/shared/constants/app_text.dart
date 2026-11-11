import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale. Every piece of text in the app should come from here so that
/// size, weight, tracking and line-height stay on one system.
abstract final class AppText {
  static TextStyle _base(
    double size,
    FontWeight weight, {
    double tracking = 0,
    double height = 1.4,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: tracking,
        height: height,
        color: color,
      );

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Screen titles on top-level tabs.
  static TextStyle get display =>
      _base(30, FontWeight.w700, tracking: -0.9, height: 1.15);

  /// Hero numerals (progress %, score). Tabular so digits do not jitter.
  static TextStyle get numeral =>
      _base(44, FontWeight.w700, tracking: -1.8, height: 1.0)
          .copyWith(fontFeatures: _tabular);

  static TextStyle get title =>
      _base(20, FontWeight.w700, tracking: -0.45, height: 1.25);

  static TextStyle get headline =>
      _base(16, FontWeight.w600, tracking: -0.25, height: 1.3);

  static TextStyle get body =>
      _base(15, FontWeight.w400, tracking: -0.15, height: 1.5);

  static TextStyle get bodyStrong =>
      _base(15, FontWeight.w500, tracking: -0.2, height: 1.4);

  static TextStyle get callout =>
      _base(14, FontWeight.w500, tracking: -0.15, height: 1.4);

  static TextStyle get caption => _base(12.5, FontWeight.w400,
      tracking: -0.05, height: 1.35, color: AppColors.textSecondary);

  static TextStyle get captionStrong => _base(12.5, FontWeight.w500,
      tracking: -0.05, height: 1.35, color: AppColors.textSecondary);

  static TextStyle get micro => _base(11, FontWeight.w500,
      tracking: 0.1, height: 1.3, color: AppColors.textTertiary);

  /// Numbers inside stat rows.
  static TextStyle get stat =>
      _base(22, FontWeight.w700, tracking: -0.6, height: 1.1)
          .copyWith(fontFeatures: _tabular);

  static TextStyle get button =>
      _base(15.5, FontWeight.w600, tracking: -0.2, height: 1.2);
}
