import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text.dart';
import 'pressable.dart';

/// Sentence-case section title with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(title, style: AppText.headline)),
          if (action != null)
            Pressable(
              onTap: onAction,
              child: Text(
                action!,
                style: AppText.callout.copyWith(color: AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// Large title block for top-level tab screens.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
        AppSpacing.screenHorizontal,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.display),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!,
                style: AppText.body.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}
