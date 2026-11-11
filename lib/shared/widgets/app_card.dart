import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import 'pressable.dart';

/// The one surface used for grouped content.
///
/// Flat white with a hairline border, no stacked shadows. Pass [onTap] to
/// make the whole surface pressable.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.color = AppColors.cardBackground,
    this.radius = AppRadius.radiusXl,
    this.borderColor = AppColors.border,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final BorderRadius radius;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return Pressable(onTap: onTap, child: card);
  }
}

/// A set of rows inside a single card, separated by inset hairlines.
/// Used instead of one card per row so lists read as one group.
class AppGroup extends StatelessWidget {
  const AppGroup({super.key, required this.children, this.dividerInset = 16});

  final List<Widget> children;
  final double dividerInset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.radiusXl,
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: EdgeInsets.only(left: dividerInset),
                  child: const Divider(height: 1, color: AppColors.divider),
                ),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}
