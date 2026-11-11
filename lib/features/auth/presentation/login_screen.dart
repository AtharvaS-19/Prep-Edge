import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_colors.dart';
import '../../../shared/constants/app_spacing.dart';
import '../../../shared/constants/app_text.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_widgets.dart';

/// The Login screen.
///
/// Presentation-layer only. Auth logic lives in [AuthNotifier] / [AuthRepository].
/// Navigation is handled entirely by the router's redirect: when sign-in
/// succeeds, [authStateProvider] emits a non-null user and the router sends
/// the user to `/home`.
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

    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Pick up where you left off.',
      form: Column(
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
            hintText: 'Enter your password',
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onLogin(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Pressable(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  'Forgot password?',
                  style: AppText.callout.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            AuthErrorBanner(message: authState.errorMessage!),
          ],
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Log in',
            onPressed: authState.isLoading ? null : _onLogin,
            isLoading: authState.isLoading,
          ),
        ],
      ),
      footer: AuthSecondaryAction(
        prompt: "Don't have an account?",
        actionLabel: 'Sign up',
        onTap: _onSignUp,
      ),
    );
  }
}
