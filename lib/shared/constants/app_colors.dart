import 'package:flutter/material.dart';

/// Single source of truth for every color token in the app.
/// Never use raw Color() values outside this file.
abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFEFF6FF);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // ── Surface ───────────────────────────────────────────────────────────────
  /// Main scaffold background — calm off-white, avoids harsh pure white.
  static const Color background = Color(0xFFF7F8FA);

  /// Secondary surface for elevated elements (modal sheets, overlays).
  static const Color surface = Color(0xFFFCFCFD);

  /// Card background — slightly warmer to lift off the background.
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Alternative card background for subtle visual grouping.
  static const Color cardBackgroundAlt = Color(0xFFF4F6F9);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Border ────────────────────────────────────────────────────────────────
  /// Default subtle border — softer than before for a more premium feel.
  static const Color border = Color(0xFFE8ECF0);

  /// Focused input border.
  static const Color borderFocused = Color(0xFF2563EB);

  // ── Status ────────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);

  // ── Progress ──────────────────────────────────────────────────────────────
  static const Color progressTrack = Color(0xFFEDF0F3);

  // ── Divider ───────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFF0F2F5);

  // ── Icon ──────────────────────────────────────────────────────────────────
  static const Color iconPrimary = Color(0xFF374151);
  static const Color iconSecondary = Color(0xFF9CA3AF);

  // ── Navigation bar ────────────────────────────────────────────────────────
  /// Floating nav bar surface — white with very slight warmth.
  static const Color navBarSurface = Color(0xFFFFFFFF);

  // ── Subject accent colors (for cards) ────────────────────────────────────
  static const Color physicsAccent = Color(0xFF2563EB);
  static const Color chemistryAccent = Color(0xFF16A34A);
  static const Color mathAccent = Color(0xFFD97706);
  static const Color biologyAccent = Color(0xFF9333EA);

  // Prevent instantiation
  AppColors._();
}
