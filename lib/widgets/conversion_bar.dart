/// Floating glassmorphic quick-conversion bar with animated light trails and glowing arrows.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../core/ui_constants.dart';
import '../data/units_data.dart';

/// Single item model for the quick conversion bar.
class QuickConversionItem {
  final UnitCategory category;
  final String fromSymbol;
  final String toSymbol;
  final double sampleValue;
  final String fromUnitName;
  final String toUnitName;

  const QuickConversionItem({
    required this.category,
    required this.fromSymbol,
    required this.toSymbol,
    required this.sampleValue,
    required this.fromUnitName,
    required this.toUnitName,
  });
}

/// Floating horizontal scrollable list of quick conversions with light trail animation.
class QuickConversionBar extends StatefulWidget {
  final List<QuickConversionItem> items;
  final void Function(QuickConversionItem item) onItemTap;

  const QuickConversionBar({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  State<QuickConversionBar> createState() => _QuickConversionBarState();
}

class _QuickConversionBarState extends State<QuickConversionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lightTrailController;

  @override
  void initState() {
    super.initState();
    _lightTrailController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _lightTrailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: CosmicUIConstants.glassBlur,
            sigmaY: CosmicUIConstants.glassBlur,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                  .withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: CosmicUIConstants.cosmicBorder,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: CosmicUIConstants.cosmicCyanGlow.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              scrollDirection: Axis.horizontal,
              itemCount: widget.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _QuickConversionCard(
                  item: item,
                  lightTrailProgress: _lightTrailController,
                  onTap: () => widget.onItemTap(item),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Single conversion card item with animated gradient light trail stroke and glowing arrow.
class _QuickConversionCard extends StatelessWidget {
  final QuickConversionItem item;
  final Animation<double> lightTrailProgress;
  final VoidCallback onTap;

  const _QuickConversionCard({
    required this.item,
    required this.lightTrailProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = CosmicUIConstants.categoryGradients[item.category] ??
        [AppColors.primary, AppColors.primaryDark];

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              gradients.first.withValues(alpha: 0.25),
              gradients.last.withValues(alpha: 0.15),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: gradients.first.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // CustomPaint animated light trail line connecting from -> to
            Positioned.fill(
              child: AnimatedBuilder(
                animation: lightTrailProgress,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _LightTrailPainter(
                      progress: lightTrailProgress.value,
                      glowColor: gradients.first,
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.category.icon, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  '${item.fromSymbol} ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // Glowing arrow indicator (↔)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: gradients.first.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: gradients.first.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                Text(
                  ' ${item.toSymbol}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter rendering horizontal animated light trail gradient stroke across the bar.
class _LightTrailPainter extends CustomPainter {
  final double progress;
  final Color glowColor;

  _LightTrailPainter({
    required this.progress,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - 3.0;
    final startX = 0.0;
    final endX = size.width;

    final paint = Paint()
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..shader = LinearGradient(
        colors: [
          glowColor.withValues(alpha: 0.0),
          glowColor.withValues(alpha: 0.9),
          glowColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: GradientRotation(progress * 3.14159 * 2),
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
  }

  @override
  bool shouldRepaint(covariant _LightTrailPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.glowColor != glowColor;
  }
}
