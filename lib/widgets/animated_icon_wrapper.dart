/// Wrapper widget supplying 3D floating and subtle pulse animations to category icons.
library;

import 'package:flutter/material.dart';

/// Wraps icons with a continuous subtle vertical floating float motion.
class AnimatedIconWrapper extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;

  const AnimatedIconWrapper({
    super.key,
    required this.child,
    this.isActive = false,
    this.duration = const Duration(milliseconds: 2400),
  });

  @override
  State<AnimatedIconWrapper> createState() => _AnimatedIconWrapperState();
}

class _AnimatedIconWrapperState extends State<AnimatedIconWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -3.0, end: 3.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    if (disableAnimations) return widget.child;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        final floatOffset = _floatAnimation.value;
        final scale = widget.isActive ? 1.15 : 1.0;

        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Transform.scale(
            scale: scale,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
