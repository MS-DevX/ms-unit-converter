/// Live bubble level / inclinometer widget using the device accelerometer.
///
/// Displays a circular spirit-level gauge with a blue bubble that moves
/// in response to pitch and roll.  Includes numeric readouts, a "Level"
/// indicator when both angles are near zero, and Set-zero / Reset
/// calibration buttons.
///
/// Stop sensor listeners on [dispose] and shows a fallback message when
/// the accelerometer is unavailable.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/bubble_level_service.dart';

/// Full bubble-level widget with gauge, readouts and calibration controls.
class BubbleLevelWidget extends StatefulWidget {
  const BubbleLevelWidget({super.key});

  @override
  State<BubbleLevelWidget> createState() => _BubbleLevelWidgetState();
}

class _BubbleLevelWidgetState extends State<BubbleLevelWidget> {
  final BubbleLevelService _service = BubbleLevelService();
  StreamSubscription<BubbleLevelData>? _sub;

  BubbleLevelData _data = const BubbleLevelData(
    pitch: 0,
    roll: 0,
    hasSensor: false,
  );
  double _rawPitch = 0;
  double _rawRoll = 0;

  @override
  void initState() {
    super.initState();
    _service.start();
    _sub = _service.dataStream.listen((data) {
      if (mounted) {
        setState(() {
          _rawPitch = data.pitch + _service.pitchOffset;
          _rawRoll = data.roll + _service.rollOffset;
          _data = data;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _service.dispose();
    super.dispose();
  }

  void _onCalibrate() {
    HapticFeedback.lightImpact();
    setState(() {
      _service.calibrate(_rawPitch, _rawRoll);
    });
  }

  void _onResetCalibration() {
    HapticFeedback.lightImpact();
    setState(() {
      _service.resetCalibration();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_data.hasSensor) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sensors_off, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 12),
            Text(
              'Accelerometer not available',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Spacer(flex: 1),

        // ── Bubble gauge ──────────────────────────────────────────
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _BubbleLevelPainter(
                    pitch: _data.pitch,
                    roll: _data.roll,
                  ),
                ),
              ),
            ),
          ),
        ),

        const Spacer(flex: 1),

        // ── Pitch / Roll readouts ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              _ReadoutCard(label: 'Pitch', value: formatDegrees(_data.pitch)),
              const SizedBox(width: 24),
              _ReadoutCard(label: 'Roll', value: formatDegrees(_data.roll)),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── "Level" indicator ─────────────────────────────────────
        if (_data.pitch.abs() < 0.5 && _data.roll.abs() < 0.5)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
                Text(
                  'Level',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // ── Calibration buttons ───────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 32, right: 32, bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: _actionButton(
                  onPressed: _onCalibrate,
                  icon: const Icon(Icons.my_location, size: 20),
                  label: 'Set zero',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _actionButton(
                  onPressed:
                      _service.pitchOffset != 0 || _service.rollOffset != 0
                      ? _onResetCalibration
                      : null,
                  icon: const Icon(Icons.refresh, size: 20),
                  label: 'Reset',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  Widget _actionButton({
    required VoidCallback? onPressed,
    required Widget icon,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF3B82F6),
          side: const BorderSide(color: Color(0xFF3B82F6)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

// ── Readout card ──────────────────────────────────────────────────

class _ReadoutCard extends StatelessWidget {
  final String label;
  final String value;

  const _ReadoutCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2433),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Custom painter for the bubble gauge ───────────────────────────

class _BubbleLevelPainter extends CustomPainter {
  final double pitch;
  final double roll;

  _BubbleLevelPainter({required this.pitch, required this.roll});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    if (radius <= 0) return;

    // Outer ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.grey.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, ringPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius * 0.7, innerRingPaint);

    // Crosshairs
    final crosshairPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.grey.withValues(alpha: 0.3);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      crosshairPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      crosshairPaint,
    );

    // Centre dot
    final centerDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.withValues(alpha: 0.5);
    canvas.drawCircle(center, 3, centerDotPaint);

    // Bubble position
    final maxDisplacement = radius * 0.6;
    const maxAngle = 15.0;
    double clamp(double v) => v.clamp(-1.0, 1.0);
    final dx = clamp(roll / maxAngle) * maxDisplacement;
    final dy = clamp(-pitch / maxAngle) * maxDisplacement;
    final bubbleCenter = Offset(center.dx + dx, center.dy + dy);
    final bubbleRadius = radius * 0.18;

    // Glow
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              const Color(0xFF3B82F6).withValues(alpha: 0.3),
              const Color(0xFF3B82F6).withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(center: bubbleCenter, radius: bubbleRadius * 2.5),
          );
    canvas.drawCircle(bubbleCenter, bubbleRadius * 2.5, glowPaint);

    // Bubble fill
    final bubblePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF3B82F6);
    canvas.drawCircle(bubbleCenter, bubbleRadius, bubblePaint);

    // Highlight
    final highlightPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(
        bubbleCenter.dx - bubbleRadius * 0.25,
        bubbleCenter.dy - bubbleRadius * 0.25,
      ),
      bubbleRadius * 0.4,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(_BubbleLevelPainter oldDelegate) {
    return oldDelegate.pitch != pitch || oldDelegate.roll != roll;
  }
}
