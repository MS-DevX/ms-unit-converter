library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConverterConnectorBar extends StatefulWidget {
  final List<Color> gradientColors;
  final VoidCallback onSwap;

  const ConverterConnectorBar({
    super.key,
    required this.gradientColors,
    required this.onSwap,
  });

  @override
  State<ConverterConnectorBar> createState() => _ConverterConnectorBarState();
}

class _ConverterConnectorBarState extends State<ConverterConnectorBar>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final AnimationController _swapController;
  late final Animation<double> _swapRotation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _swapRotation = Tween<double>(begin: 0, end: 3.14159).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  Future<void> _handleSwap() async {
    if (_swapController.isAnimating) return;
    HapticFeedback.mediumImpact();
    await _swapController.forward();
    widget.onSwap();
    _swapController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.gradientColors;
    final endColor = colors.length > 1 ? colors[1] : colors[0];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: endColor.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white70,
                    size: 20,
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'All conversions',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: _swapRotation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _swapRotation.value,
                  child: child,
                );
              },
              child: Semantics(
                label: 'Swap units',
                button: true,
                child: GestureDetector(
                  onTap: _handleSwap,
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.swap_vert_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
