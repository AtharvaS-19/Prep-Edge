import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/constants/app_strings.dart';
import '../../shared/constants/app_text.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/reveal.dart';

/// The splash screen.
///
/// Shows the brand mark for a fixed delay, then navigates to `/login`. The
/// router's `redirect` intercepts that and sends authenticated users directly
/// to `/home` instead, so this screen never needs to know about auth state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 84, showLabel: false),
              const SizedBox(height: 20),
              Text(AppStrings.appName, style: AppText.title.copyWith(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                AppStrings.splashTagline,
                style: AppText.callout.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
