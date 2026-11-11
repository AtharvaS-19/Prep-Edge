import 'package:flutter/material.dart';

/// Single source of truth for every color token in the app.
/// Never use raw Color() values outside this file.
abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF3652D9);
  static const Color primaryLight = Color(0xFFEEF1FD);
  static const Color primaryDark = Color(0xFF2B42B3);

  // ── Surface ───────────────────────────────────────────────────────────────
  /// Main scaffold background — calm off-white, avoids harsh pure white.
  static const Color background = Color(0xFFF6F7FA);

  /// Secondary surface for elevated elements (modal sheets, overlays).
  static const Color surface = Color(0xFFFFFFFF);

  /// Card background — slightly warmer to lift off the background.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Alternative card background for subtle visual grouping.
  static const Color cardBackgroundAlt = Color(0xFFF1F2F6);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0E1224);
  static const Color textSecondary = Color(0xFF5A6076);
  static const Color textTertiary = Color(0xFF8A8FA3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Border ────────────────────────────────────────────────────────────────
  /// Default subtle border — softer than before for a more premium feel.
  static const Color border = Color(0xFFE6E8F0);

  /// Focused input border.
  static const Color borderFocused = Color(0xFF3652D9);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1E9B62);
  static const Color successLight = Color(0xFFEDF8F2);
  static const Color error = Color(0xFFD13F3A);
  static const Color errorLight = Color(0xFFFCF0EF);
  static const Color warning = Color(0xFFB7791F);
  static const Color warningLight = Color(0xFFFBF5E8);

  // ── Progress ──────────────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFEAECF3);

  // ── Divider ───────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFEDEEF4);

  // ── Icon ──────────────────────────────────────────────────────────────────
  static const Color iconPrimary = Color(0xFF30364B);
  static const Color iconSecondary = Color(0xFF8A8FA3);

  // ── Navigation bar ────────────────────────────────────────────────────────
  /// Floating nav bar surface — white with very slight warmth.
  static const Color navBarSurface = Color(0xFFFFFFFF);

  // ── Subject accent colors (for cards) ────────────────────────────────────
  static const Color physicsAccent = Color(0xFF3652D9);
  static const Color chemistryAccent = Color(0xFF0E9384);
  static const Color mathAccent = Color(0xFFC2701B);
  static const Color biologyAccent = Color(0xFF7A4FD6);

  // Prevent instantiation
  AppColors._();
}
