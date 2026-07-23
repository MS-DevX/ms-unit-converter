/// Reusable Stitch Material 3 Card with micro-interaction scale press effect.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/colors.dart';

class StitchCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final double borderRadius;
  final Border? border;
  final Color? leftBorderColor;
  final double leftBorderWidth;

  const StitchCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor,
    this.borderRadius = 16,
    this.border,
    this.leftBorderColor,
    this.leftBorderWidth = 4.0,
  });

  @override
  State<StitchCard> createState() => _StitchCardState();
}

class _StitchCardState extends State<StitchCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.customCard;

    Widget cardContent = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border ??
            (widget.leftBorderColor != null
                ? null
                : Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.2),
                    width: 1,
                  )),
      ),
      child: widget.child,
    );

    if (widget.leftBorderColor != null) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: Border(
              left: BorderSide(
                color: widget.leftBorderColor!,
                width: widget.leftBorderWidth,
              ),
            ),
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(18),
            child: widget.child,
          ),
        ),
      );
    }

    if (widget.onTap == null) return cardContent;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: cardContent,
      ),
    );
  }
}
