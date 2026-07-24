/// Compass Screen — Real-time live sensor integration with pixel-perfect Google Stitch M3 UI.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../core/colors.dart';
import '../widgets/stitch_card.dart';

class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  double _heading = 0.0;
  String _cardinal = 'N';
  double _accuracy = 15.0; // In degrees
  double _magneticField = 48.2; // In μT
  bool _hasSensors = true;
  bool _isLoading = true;

  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  @override
  void initState() {
    super.initState();
    _initSensors();
  }

  void _initSensors() {
    _compassSub = FlutterCompass.events?.listen(
      (event) {
        if (!mounted) return;
        final heading = event.heading;
        if (heading != null) {
          setState(() {
            _hasSensors = true;
            _isLoading = false;
            // Normalize heading to 0..359
            final normalized = (heading % 360 + 360) % 360;
            _heading = normalized;
            _cardinal = _getCardinal(normalized);
            if (event.accuracy != null) {
              _accuracy = event.accuracy!;
            }
          });
        }
      },
      onError: (err) {
        if (!mounted) return;
        setState(() {
          _hasSensors = false;
          _isLoading = false;
        });
      },
    );

    if (_compassSub == null) {
      setState(() {
        _hasSensors = false;
        _isLoading = false;
      });
    }

    _magSub = magnetometerEventStream().listen(
      (event) {
        if (!mounted) return;
        final field = math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
        if (field > 0) {
          setState(() {
            _magneticField = field;
          });
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _magSub?.cancel();
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

  String _getAccuracyText(double accuracy) {
    if (accuracy <= 15) return 'High';
    if (accuracy <= 30) return 'Medium';
    return 'Low';
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 15) return AppColors.success;
    if (accuracy <= 30) return AppColors.tertiary;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : !_hasSensors
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: StitchCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.explore_off_rounded,
                              size: 48,
                              color: AppColors.tertiary,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Compass Sensor Unavailable',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Your device hardware does not support magnetometer or compass orientation sensors.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Column(
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

                              // Live Rotating Compass Ring
                              AnimatedRotation(
                                turns: -_heading / 360.0,
                                duration: const Duration(milliseconds: 150),
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
                                          decoration: BoxDecoration(
                                            color: _getAccuracyColor(_accuracy),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _getAccuracyText(_accuracy),
                                          style: const TextStyle(
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
                                  children: [
                                    const Text(
                                      'MAGNETIC FIELD',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurfaceVariant,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${_magneticField.toStringAsFixed(1)} μT',
                                      style: const TextStyle(
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
