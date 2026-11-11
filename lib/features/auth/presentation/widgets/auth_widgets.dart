import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/constants/app_radius.dart';
import '../../../../shared/constants/app_spacing.dart';
import '../../../../shared/constants/app_text.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/reveal.dart';

/// Shared frame for login and signup: left-aligned brand, headline and form
/// sitting directly on the page (no card-in-a-card), centred on wide screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.footer,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget form;
  final Widget footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 44,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: onBack == null
                          ? const AppLogo(size: 40, showLabel: false)
                          : Pressable(
                              onTap: onBack,
                              child: const SizedBox(
                                width: 44,
                                height: 44,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 24,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Reveal(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.display),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppText.body
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Reveal(index: 1, child: form),
                  const SizedBox(height: AppSpacing.xl),
                  Reveal(index: 2, child: Center(child: footer)),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline error shown above the primary action.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline_rounded,
                size: 17, color: AppColors.error),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppText.callout
                  .copyWith(color: AppColors.error, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Prompt  Action" line under the form.
class AuthSecondaryAction extends StatelessWidget {
  const AuthSecondaryAction({
    super.key,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          prompt,
          style: AppText.callout.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w400),
        ),
        const SizedBox(width: 6),
        Pressable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              actionLabel,
              style: AppText.callout.copyWith(
                  color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
