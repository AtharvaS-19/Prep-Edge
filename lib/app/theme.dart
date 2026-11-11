import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../shared/constants/app_colors.dart';
import '../shared/constants/app_radius.dart';
import '../shared/constants/app_spacing.dart';
import '../shared/constants/app_text.dart';

/// The app's single source-of-truth [ThemeData].
///
/// All styling decisions live here. Screens should never define inline
/// TextStyles, button styles, or decoration that duplicates what is here.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      visualDensity: VisualDensity.standard,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppText.callout.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      }),
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dividerTheme: _dividerTheme,
      progressIndicatorTheme: _progressIndicatorTheme,
    );
  }

  // ── Color scheme ───────────────────────────────────────────────────────────
  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryLight,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.textSecondary,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.cardBackground,
    onSecondaryContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
  );

  // ── Text theme (Inter) ─────────────────────────────────────────────────────
  static TextTheme get _textTheme {
    final inter = GoogleFonts.interTextTheme();
    return inter.copyWith(
      displayLarge: inter.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
        color: AppColors.textPrimary,
      ),
      displayMedium: inter.displayMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: AppColors.textPrimary,
      ),
      headlineLarge: inter.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
      headlineMedium: inter.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
        height: 1.25,
      ),
      headlineSmall: inter.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      titleLarge: inter.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
        height: 1.3,
      ),
      titleMedium: inter.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      titleSmall: inter.titleSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
      bodyLarge: inter.bodyLarge?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.55,
      ),
      bodyMedium: inter.bodyMedium?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
      bodySmall: inter.bodySmall?.copyWith(
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
        height: 1.45,
      ),
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      ),
      labelMedium: inter.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      labelSmall: inter.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textTertiary,
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  static AppBarTheme get _appBarTheme => AppBarTheme(
    backgroundColor: AppColors.background,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    titleTextStyle: AppText.headline,
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 22,
    ),
  );

  // ── Elevated button ────────────────────────────────────────────────────────
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor:
              AppColors.textOnPrimary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.radiusLg,
          ),
          textStyle: AppText.button,
        ),
      );

  // ── Outlined button ────────────────────────────────────────────────────────
  static OutlinedButtonThemeData get _outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1),
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.radiusLg,
          ),
          textStyle: AppText.button.copyWith(fontWeight: FontWeight.w500),
        ),
      );

  // ── Text button ────────────────────────────────────────────────────────────
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: AppText.callout.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  // ── Input decoration ───────────────────────────────────────────────────────
  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg, // Was radiusMd
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide:
              BorderSide(color: AppColors.borderFocused, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
        labelStyle: AppText.callout,
      );

  // ── Card ───────────────────────────────────────────────────────────────────
  /// Cards float gently above the background using a soft shadow and border.
  /// Elevation is intentionally kept at 0 — shadow is applied via BoxDecoration
  /// in the card widgets themselves for finer control.
  static const CardThemeData _cardTheme = CardThemeData(
    color: AppColors.cardBackground,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.radiusXl, // Was radiusLg
    ),
  );

  // ── Divider ───────────────────────────────────────────────────────────────
  static const DividerThemeData _dividerTheme = DividerThemeData(
    color: AppColors.divider,
    thickness: 1,
    space: 0,
  );

  // ── Progress indicator ─────────────────────────────────────────────────────
  static const ProgressIndicatorThemeData _progressIndicatorTheme =
      ProgressIndicatorThemeData(
    color: AppColors.primary,
    linearTrackColor: AppColors.progressTrack,
    linearMinHeight: 5,
  );

  // Prevent instantiation
  AppTheme._();
}
