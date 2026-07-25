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

class _CompassScreenState extends State<CompassScreen> with AutomaticKeepAliveClientMixin {
  double _heading = 0.0;
  String _cardinal = 'N';
  double _accuracy = 15.0;
  double _magneticField = 48.2;
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
        if (mounted) {
          setState(() {
            _hasSensors = false;
            _isLoading = false;
          });
        }
      },
    );

    _magSub = magnetometerEventStream().listen(
      (event) {
        if (!mounted) return;
        final magnitude = math.sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        setState(() {
          _magneticField = magnitude;
        });
      },
      onError: (_) {},
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compass'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : !_hasSensors
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.explore_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            'Compass Sensors Unavailable',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your device does not support magnetometer hardware.',
                            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      children: [
                        // PROMINENT DEGREE HEADING DISPLAY
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '${_heading.round()}',
                                  style: TextStyle(
                                    fontSize: 72,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.primary,
                                    height: 1.0,
                                    letterSpacing: -2,
                                  ),
                                ),
                                Text(
                                  '°',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w400,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _cardinal,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Heading relative to Magnetic North',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // COMPASS DIAL DIAL WITH NEEDLE
                        Center(
                          child: SizedBox(
                            width: 260,
                            height: 260,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // DIAL RIM
                                Container(
                                  width: 260,
                                  height: 260,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.surfaceContainerLow,
                                    border: Border.all(
                                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                                      width: 4,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x15000000),
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                ),

                                // ROTATING COMPASS DIAL MARKS
                                Transform.rotate(
                                  angle: -_heading * (math.pi / 180),
                                  child: CustomPaint(
                                    size: const Size(240, 240),
                                    painter: _CompassDialPainter(colorScheme: colorScheme),
                                  ),
                                ),

                                // STATIC CENTER NORTH NEEDLE POINTER
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),

                        // METRICS GRID (MAGNETIC FIELD & ACCURACY)
                        Row(
                          children: [
                            Expanded(
                              child: StitchCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.waves_rounded,
                                          color: colorScheme.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Magnetic Field',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_magneticField.toStringAsFixed(1)} μT',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StitchCard(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          color: _getAccuracyColor(_accuracy),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Accuracy',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _getAccuracyText(_accuracy),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: _getAccuracyColor(_accuracy),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // CALIBRATION ADVICE FOOTER
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Move your device in a figure-8 motion to calibrate magnetic sensors.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final ColorScheme colorScheme;

  _CompassDialPainter({required this.colorScheme});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    final northPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 3;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final cardinals = {'N': 0, 'E': 90, 'S': 180, 'W': 270};

    for (int i = 0; i < 360; i += 15) {
      final angle = i * (math.pi / 180);
      final isCardinal = i % 90 == 0;
      final tickLength = isCardinal ? 14.0 : 8.0;

      final start = Offset(
        center.dx + (radius - tickLength) * math.sin(angle),
        center.dy - (radius - tickLength) * math.cos(angle),
      );

      final end = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      canvas.drawLine(start, end, i == 0 ? northPaint : paint);
    }

    cardinals.forEach((label, deg) {
      final angle = deg * (math.pi / 180);
      final offset = Offset(
        center.dx + (radius - 28) * math.sin(angle),
        center.dy - (radius - 28) * math.cos(angle),
      );

      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: label == 'N' ? colorScheme.primary : colorScheme.onSurface,
        ),
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
      );
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
