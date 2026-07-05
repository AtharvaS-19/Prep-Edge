import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/constants/app_colors.dart';
import '../../shared/widgets/app_logo.dart';

/// The splash screen.
///
/// Shows the brand mark and tagline for a fixed delay, then navigates to
/// `/login`. The router's `redirect` intercepts that and sends authenticated
/// users directly to `/home` instead — so this screen never needs to know
/// about auth state.
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
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: _SplashBody(),
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLogo(
            size: 72,
            showLabel: true,
            showTagline: true,
          ),
        ],
      ),
    );
  }
}
