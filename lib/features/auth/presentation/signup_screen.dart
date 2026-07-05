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

/// The Signup screen.
///
/// Presentation-layer only. Auth logic lives in [AuthNotifier] / [AuthRepository].
/// The screen reads [authNotifierProvider] for loading state and error messages,
/// and delegates account creation to [AuthNotifier.signUp].
///
/// Navigation on success is handled by the router's redirect — no manual
/// context.go() is needed.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onCreate() async {
    // Client-side password confirmation check.
    if (_passwordController.text != _confirmPasswordController.text) {
      // We surface this as if it were a provider error for consistent UX.
      // No Firebase call is made — we short-circuit here.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    ref.read(authNotifierProvider.notifier).clearError();
    await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
    // Navigation to /home is handled automatically by the router redirect.
  }

  void _onLogin() => context.pop();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Subtle gradient background ────────────────────────────────────
          const _BackgroundGradient(),

          // ── Back button overlay ───────────────────────────────────────────
          // Signup is always pushed from Login, so the stack is valid.
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.screenHorizontal,
                  top: AppSpacing.md,
                ),
                child: _BackButton(onTap: () => context.pop()),
              ),
            ),
          ),

          // ── Main scrollable content ───────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  // ── Top — logo + brand name as unified group ──────────────
                  const SizedBox(height: AppSpacing.xxxxl),
                  const _LogoLockup(),

                  // 22dp between brand name and headline — intentional gap
                  const SizedBox(height: 22),

                  // ── Headline ──────────────────────────────────────────────
                  const _AuthHeadline(
                    title: 'Create Your\nPrepEdge Account',
                    subtitle: 'Build consistency. Improve every day.',
                  ),

                  // More breathing room before the card
                  const SizedBox(height: AppSpacing.xxxl),

                  // ── Auth card ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenHorizontal,
                    ),
                    child: _AuthCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Full name',
                            hintText: 'Arjun Sharma',
                            keyboardType: TextInputType.name,
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.fieldGap),
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
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.fieldGap),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm password',
                            hintText: '••••••••',
                            obscureText: true,
                            prefixIcon: Icons.lock_outline_rounded,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _onCreate(),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // ── Error message ─────────────────────────────────
                          if (authState.errorMessage != null)
                            _ErrorBanner(message: authState.errorMessage!),

                          const SizedBox(height: AppSpacing.md),
                          PrimaryButton(
                            label: 'Create Account',
                            onPressed: authState.isLoading ? null : _onCreate,
                            isLoading: authState.isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Secondary action ──────────────────────────────────────
                  const SizedBox(height: AppSpacing.xxl),
                  _SecondaryAction(
                    prompt: 'Already have an account?',
                    actionLabel: 'Log in',
                    onTap: _onLogin,
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
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

// ── Back button ───────────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: AppColors.border, width: 0.75),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          size: 18,
          color: AppColors.textPrimary,
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
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.7,
              height: 1.2,
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
