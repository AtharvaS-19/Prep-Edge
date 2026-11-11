import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/constants/app_spacing.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_widgets.dart';

/// The Signup screen.
///
/// Presentation-layer only. Auth logic lives in [AuthNotifier] / [AuthRepository].
/// Navigation on success is handled by the router's redirect.
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

    return AuthScaffold(
      title: 'Create your account',
      subtitle: 'Build consistency. Improve every day.',
      onBack: () => context.pop(),
      form: Column(
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
            hintText: 'Create a password',
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: AppSpacing.fieldGap),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'Confirm password',
            hintText: 'Re-enter your password',
            obscureText: true,
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _onCreate(),
          ),
          if (authState.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            AuthErrorBanner(message: authState.errorMessage!),
          ],
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: 'Create account',
            onPressed: authState.isLoading ? null : _onCreate,
            isLoading: authState.isLoading,
          ),
        ],
      ),
      footer: AuthSecondaryAction(
        prompt: 'Already have an account?',
        actionLabel: 'Log in',
        onTap: _onLogin,
      ),
    );
  }
}
