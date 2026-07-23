/// Compass Screen — Pixel-perfect implementation of Google Stitch Material Design 3 export.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../widgets/stitch_card.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen>
    with SingleTickerProviderStateMixin {
  double _heading = 180.0;
  String _cardinal = 'S';
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _getCardinal(double heading) {
    if (heading >= 337.5 || heading < 22.5) return 'N';
    if (heading >= 22.5 && heading < 67.5) return 'NE';
    if (heading >= 67.5 && heading < 112.5) return 'E';
    if (heading >= 112.5 && heading < 157.5) return 'SE';
    if (heading >= 157.5 && heading < 202.5) return 'S';
    if (heading >= 202.5 && heading < 247.5) return 'SW';
    if (heading >= 247.5 && heading < 292.5) return 'W';
    return 'NW';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        title: const Text(
          'Compass',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // ROTATING COMPASS RING CONTAINER
            Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Fixed Heading Indicator Top Pin
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 4,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.primary,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Rotating Compass Ring
                    AnimatedRotation(
                      turns: -_heading / 360.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: CustomPaint(
                        size: const Size(280, 280),
                        painter: _CompassPainter(),
                      ),
                    ),

                    // Central Readout Box
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_heading.round()}°',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          _cardinal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // MANUAL ADJUSTMENT SLIDER FOR TESTING / CONVERTING
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Manual Angle',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${_heading.round()}° (${(_heading * math.pi / 180).toStringAsFixed(2)} rad)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _heading,
                    min: 0,
                    max: 360,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceContainerHighest,
                    onChanged: (val) {
                      setState(() {
                        _heading = val;
                        _cardinal = _getCardinal(val);
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // METRIC DETAILS PANEL (ACCURACY & MAGNETIC FIELD)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Row(
                children: [
                  Expanded(
                    child: StitchCard(
                      backgroundColor: AppColors.surfaceContainerLow,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Column(
                        children: [
                          const Text(
                            'ACCURACY',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'High',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StitchCard(
                      backgroundColor: AppColors.surfaceContainerLow,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      child: Column(
                        children: const [
                          Text(
                            'MAGNETIC FIELD',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '48.2 μT',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final outerPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius, outerPaint);

    final tickPaint = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 1;

    for (int i = 0; i < 360; i += 15) {
      final angle = i * math.pi / 180;
      final isMajor = i % 90 == 0;
      final tickLength = isMajor ? 14.0 : 8.0;

      final start = Offset(
        center.dx + (radius - tickLength) * math.cos(angle),
        center.dy + (radius - tickLength) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      tickPaint.color = isMajor
          ? AppColors.primary
          : AppColors.outlineVariant.withValues(alpha: 0.4);
      tickPaint.strokeWidth = isMajor ? 2.0 : 1.0;
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
