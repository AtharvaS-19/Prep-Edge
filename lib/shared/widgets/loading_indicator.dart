import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A simple, centred circular loading indicator.
///
/// Use this instead of raw [CircularProgressIndicator] so the brand colour
/// is automatically applied.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 24.0});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}
