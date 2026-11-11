import 'package:flutter/animation.dart';

/// Shared durations and curves so motion feels uniform everywhere.
abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 140);
  static const Duration base = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 420);
  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
}
