import 'package:flutter/material.dart';

/// Border radius tokens used consistently across the app.
abstract final class AppRadius {
  static const double xs = 6.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 14.0;
  static const double xl = 16.0;
  static const double xxl = 20.0;
  static const double full = 999.0;

  // ── BorderRadius shortcuts ─────────────────────────────────────────────────
  static const BorderRadius radiusXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXxl = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusFull =
      BorderRadius.all(Radius.circular(full));

  // Prevent instantiation
  AppRadius._();
}
