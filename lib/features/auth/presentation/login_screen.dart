import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_radius.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';

/// The Login screen.
///
/// Presentation-layer only. Auth logic lives in [AuthNotifier] / [AuthRepository].
/// The screen reads [authNotifierProvider] for loading state and error messages,
/// and delegates all Firebase calls to [AuthNotifier.signIn].
///
/// Navigation is handled entirely by the router's redirect:
/// when sign-in succeeds, [authStateProvider] emits a non-null [User] and
/// the router automatically redirects to `/home`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    // Clear any previous error before a new attempt.
    ref.read(authNotifierProvider.notifier).clearError();
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
    // Navigation is handled by the router redirect — no context.go() needed.
  }

  void _onSignUp() => context.push('/signup');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Subtle gradient background ────────────────────────────────────
          const _BackgroundGradient(),

          // ── Main scrollable content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ── Top — logo + brand name as unified group ──────────
                      const SizedBox(height: AppSpacing.xxxxl),
                      const _LogoLockup(),

                      // 22dp between brand name and headline — intentional gap
                      const SizedBox(height: 22),

                      // ── Headline ──────────────────────────────────────────
                      const _AuthHeadline(
                        title: 'Welcome Back',
                        subtitle: 'Pick up where you left off.',
                      ),

                      // More breathing room before the card
                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Auth card ─────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                        ),
                        child: _AuthCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                labelText: 'Email',
                                hintText: 'you@example.com',
                                keyboardType: TextInputType.emailAddress,
                                prefixIcon: Icons.mail_outline_rounded,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppSpacing.fieldGap),
                              CustomTextField(
                                controller: _passwordController,
                                labelText: 'Password',
                                hintText: '••••••••',
                                obscureText: true,
                                prefixIcon: Icons.lock_outline_rounded,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _onLogin(),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              // Forgot password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot password?',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),

                              // ── Error message ─────────────────────────────
                              if (authState.errorMessage != null)
                                _ErrorBanner(message: authState.errorMessage!),

                              const SizedBox(height: AppSpacing.md),
                              PrimaryButton(
                                label: 'Log in',
                                onPressed:
                                    authState.isLoading ? null : _onLogin,
                                isLoading: authState.isLoading,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Secondary action ──────────────────────────────────
                      const SizedBox(height: AppSpacing.xxl),
                      _SecondaryAction(
                        prompt: "Don't have an account?",
                        actionLabel: 'Sign up',
                        onTap: _onSignUp,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Background gradient ───────────────────────────────────────────────────────

class _BackgroundGradient extends StatelessWidget {
  const _BackgroundGradient();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F4FF), // barely-blue tint at top
              Color(0xFFF7F8FA), // base background at bottom
            ],
            stops: [0.0, 0.45],
          ),
        ),
      ),
    );
  }
}

// ── Logo lockup ───────────────────────────────────────────────────────────────
//
// Logo icon and brand name rendered as a single visual group.
// 8dp gap between icon and name — tighter than the default AppLogo label gap —
// so the two elements read as one connected unit.

class _LogoLockup extends StatelessWidget {
  const _LogoLockup();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Size 74 — ~15% larger than the 64dp Sprint 2 baseline.
        // showLabel: false so we control the gap and name rendering below.
        const AppLogo(size: 74, showLabel: false, showTagline: false),
        const SizedBox(height: 8), // tight icon→name connection
        Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 74 * 0.30, // proportional to icon size ≈ 22px
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

// ── Auth headline ─────────────────────────────────────────────────────────────

class _AuthHeadline extends StatelessWidget {
  const _AuthHeadline({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.7,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Auth card ─────────────────────────────────────────────────────────────────

class _AuthCard extends StatelessWidget {
  const _AuthCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXxl,
        border: Border.all(color: AppColors.border, width: 0.75),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E000000),
            blurRadius: 24,
            offset: Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.error.withAlpha(51)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Secondary action ──────────────────────────────────────────────────────────

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          prompt,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
