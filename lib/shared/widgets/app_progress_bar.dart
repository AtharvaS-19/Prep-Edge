import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_motion.dart';

/// Rounded progress bar that animates to its value.
class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    super.key,
    required this.value,
    this.color = AppColors.primary,
    this.trackColor = AppColors.progressTrack,
    this.height = 6,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN ? 0.0 : value.clamp(0.0, 1.0);
    return LayoutBuilder(builder: (context, c) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(height),
        ),
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: v),
          duration: AppMotion.slow,
          curve: AppMotion.emphasized,
          builder: (_, t, __) => Container(
            width: c.maxWidth * t,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(height),
            ),
          ),
        ),
      );
    });
  }
}
