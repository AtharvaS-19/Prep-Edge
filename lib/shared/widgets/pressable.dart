import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_motion.dart';

/// Tap target with a subtle scale + dim on press. Replaces bare
/// GestureDetectors so every tappable surface gives tactile feedback.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.98,
    this.haptic = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (widget.onTap == null || _down == v) return;
    setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: AnimatedOpacity(
          opacity: _down ? 0.88 : 1,
          duration: AppMotion.fast,
          child: widget.child,
        ),
      ),
    );
  }
}
