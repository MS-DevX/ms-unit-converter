/// Glassmorphic category tile widget featuring 3D matrix transformations,
/// backdrop blur, glowing shadows, and micro-interaction animations.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/ui_constants.dart';
import '../data/units_data.dart';

/// A 3D glassmorphic card tile with glowing shadows and tap/hover micro-animations.
class GlassmorphicCategoryTile extends StatefulWidget {
  final UnitCategory category;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;

  const GlassmorphicCategoryTile({
    super.key,
    required this.category,
    required this.onTap,
    this.onLongPress,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  State<GlassmorphicCategoryTile> createState() => _GlassmorphicCategoryTileState();
}

class _GlassmorphicCategoryTileState extends State<GlassmorphicCategoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.035).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = CosmicUIConstants.categoryGradients[widget.category] ??
        [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)];

    final primaryGlow = gradients.first;
    final secondaryGlow = gradients.last;

    final bool disableAnimations = MediaQuery.of(context).disableAnimations;

    return Semantics(
      label: '${widget.category.displayName} category converter. Double tap to open.',
      button: true,
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          if (!disableAnimations) _animController.forward();
        },
        onExit: (_) {
          setState(() => _isHovered = false);
          if (!disableAnimations) _animController.reverse();
        },
        child: GestureDetector(
          onTapDown: disableAnimations ? null : _onTapDown,
          onTapUp: disableAnimations ? null : _onTapUp,
          onTapCancel: disableAnimations ? null : _onTapCancel,
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap();
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            widget.onLongPress?.call();
          },
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final scale = disableAnimations ? 1.0 : _scaleAnimation.value;
              final rotation = disableAnimations ? 0.0 : _rotationAnimation.value;

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // 3D perspective
                  ..scaleByDouble(scale, scale, 1.0, 1.0)
                  ..rotateZ(_isHovered ? rotation : 0.0),
                alignment: Alignment.center,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CosmicUIConstants.cardBorderRadius),
                    boxShadow: [
                      // Vibrant glowing outer shadow
                      BoxShadow(
                        color: primaryGlow.withValues(
                          alpha: (_isPressed || _isHovered) ? 0.55 : 0.30,
                        ),
                        blurRadius: (_isPressed || _isHovered) ? 28.0 : 18.0,
                        spreadRadius: (_isPressed || _isHovered) ? 4.0 : 1.0,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: secondaryGlow.withValues(alpha: 0.20),
                        blurRadius: 14.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(CosmicUIConstants.cardBorderRadius),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: CosmicUIConstants.glassBlur,
                        sigmaY: CosmicUIConstants.glassBlur,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              gradients.first.withValues(alpha: 0.85),
                              gradients.last.withValues(alpha: 0.70),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(CosmicUIConstants.cardBorderRadius),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: (_isPressed || _isHovered) ? 0.45 : 0.25,
                            ),
                            width: CosmicUIConstants.glassBorderWidth,
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Ambient top-left highlight streak
                            Positioned(
                              top: -20,
                              left: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                            ),

                            // Card contents
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.category.icon,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const Spacer(),
                                      if (widget.onFavoriteToggle != null)
                                        GestureDetector(
                                          onTap: () {
                                            HapticFeedback.selectionClick();
                                            widget.onFavoriteToggle!(
                                              !widget.isFavorite,
                                            );
                                          },
                                          child: Icon(
                                            widget.isFavorite
                                                ? Icons.star_rounded
                                                : Icons.star_outline_rounded,
                                            color: widget.isFavorite
                                                ? Colors.amber
                                                : Colors.white.withValues(alpha: 0.5),
                                            size: 18,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Text(
                                    widget.category.displayName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 4,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    widget.category.description,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      height: 1.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 3,
                                    runSpacing: 2,
                                    children: [
                                      ...widget.category.unitSymbols.take(4).map(
                                            (s) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 5,
                                                vertical: 1,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.22),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                s,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      if (widget.category.unitSymbols.length > 4)
                                        Text(
                                          '+${widget.category.unitSymbols.length - 4}',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.75),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
