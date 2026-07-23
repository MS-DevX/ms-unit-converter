/// Cosmic background particle system with twinkling stars and parallax depth.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/ui_constants.dart';

/// Single particle model for the starfield background.
class _StarParticle {
  final double x; // Normalized 0.0 - 1.0
  final double y; // Normalized 0.0 - 1.0
  final double size; // 1.0 - 3.0 px
  final double baseOpacity; // 0.3 - 0.8
  final double twinkleSpeed; // Twinkle cycle multiplier (5 - 8s)
  final double twinklePhase; // Random phase offset
  final double depth; // 0.2 - 1.0 for parallax depth

  const _StarParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinklePhase,
    required this.depth,
  });
}

/// Particle starfield background widget featuring twinkling animations and parallax depth.
class CosmicBackground extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;
  final double opacity;

  const CosmicBackground({
    super.key,
    required this.child,
    this.scrollController,
    this.opacity = 0.08,
  });

  @override
  State<CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  final List<_StarParticle> _stars = [];
  final math.Random _random = math.Random(42);
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _generateStarfield(120);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    _animController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (mounted && widget.scrollController != null) {
      setState(() {
        _scrollOffset = widget.scrollController!.offset;
      });
    }
  }

  void _generateStarfield(int count) {
    _stars.clear();
    for (int i = 0; i < count; i++) {
      _stars.add(
        _StarParticle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: 1.0 + _random.nextDouble() * 2.0, // 1 - 3px
          baseOpacity: 0.3 + _random.nextDouble() * 0.5, // 0.3 - 0.8
          twinkleSpeed: 0.8 + _random.nextDouble() * 0.6,
          twinklePhase: _random.nextDouble() * math.pi * 2,
          depth: 0.2 + _random.nextDouble() * 0.8, // 0.2 - 1.0
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    return Stack(
      children: [
        // Deep space dark gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.3),
              radius: 1.2,
              colors: [
                Color(0xFF0F172A),
                CosmicUIConstants.cosmicBackground,
                Color(0xFF02040A),
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Starfield CustomPaint layer
        AnimatedBuilder(
          animation: _animController,
          builder: (context, _) {
            final progress = disableAnimations ? 0.5 : _animController.value;
            return RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _StarfieldPainter(
                  stars: _stars,
                  animProgress: progress,
                  scrollOffset: _scrollOffset,
                  backgroundOpacity: widget.opacity,
                ),
              ),
            );
          },
        ),

        // Child overlay content
        widget.child,
      ],
    );
  }
}

/// CustomPainter rendering twinkling starfield particles with parallax offset.
class _StarfieldPainter extends CustomPainter {
  final List<_StarParticle> stars;
  final double animProgress;
  final double scrollOffset;
  final double backgroundOpacity;

  _StarfieldPainter({
    required this.stars,
    required this.animProgress,
    required this.scrollOffset,
    required this.backgroundOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final paint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      // Calculate twinkling opacity
      final twinkle = math.sin((animProgress * math.pi * 2 * star.twinkleSpeed) + star.twinklePhase);
      final currentOpacity = (star.baseOpacity + twinkle * 0.25).clamp(0.1, 1.0);

      // Apply subtle background opacity scale for content contrast
      final effectiveOpacity = currentOpacity * (backgroundOpacity * 5.0).clamp(0.2, 1.0);

      // Parallax position calculation
      final parallaxY = (star.y * size.height - scrollOffset * star.depth) % size.height;
      final adjustedY = parallaxY < 0 ? parallaxY + size.height : parallaxY;
      final x = star.x * size.width;

      paint.color = Colors.white.withValues(alpha: effectiveOpacity);

      // Draw star particle
      canvas.drawCircle(Offset(x, adjustedY), star.size, paint);

      // Subtle glow for larger stars (>= 2.5px)
      if (star.size >= 2.5) {
        paint.color = CosmicUIConstants.cosmicCyanGlow.withValues(alpha: effectiveOpacity * 0.3);
        canvas.drawCircle(Offset(x, adjustedY), star.size * 2.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.backgroundOpacity != backgroundOpacity;
  }
}
