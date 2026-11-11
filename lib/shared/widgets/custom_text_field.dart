import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text.dart';

/// A reusable, styled text field that wraps [TextFormField].
///
/// Supports password fields ([obscureText]), keyboard types, leading and
/// trailing icons, and an optional label above the field.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: AppText.captionStrong.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          cursorColor: AppColors.primary,
          style: AppText.body,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppText.body.copyWith(color: AppColors.textTertiary),
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(
                        left: AppSpacing.md, right: AppSpacing.sm),
                    child: Icon(widget.prefixIcon,
                        size: 19, color: AppColors.iconSecondary),
                  )
                : null,
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: widget.obscureText
                ? _PasswordToggle(
                    isObscured: _obscured,
                    onToggle: () => setState(() => _obscured = !_obscured),
                  )
                : widget.suffixIcon,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 15,
            ),
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.borderFocused, width: 1.5),
            errorBorder: _border(AppColors.error),
            focusedErrorBorder: _border(AppColors.error, width: 1.5),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _border(Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.radiusLg,
        borderSide: BorderSide(color: c, width: width),
      );
}

class _PasswordToggle extends StatelessWidget {
  const _PasswordToggle({required this.isObscured, required this.onToggle});

  final bool isObscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Icon(
          isObscured
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 19,
          color: AppColors.iconSecondary,
        ),
      ),
    );
  }
}
