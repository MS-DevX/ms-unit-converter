/// Custom-painted compass rose with rotating arrow, 16 tick marks,
/// and bold cardinal labels (N/E/S/W). No intermediate labels on the arrow.
///
/// Always shows:
/// - Outer circle with thin rim
/// - 16 tick marks at 22.5° intervals
/// - 4 cardinal labels (N, E, S, W) — large, bold, theme-aware black/white
/// - Arrow/needle rotating to the current heading
/// - Highlighted arc (22.5°) on the rim showing the active segment
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Compass data for a single 16-point direction.
class CompassPoint {
  final String label;
  final double bearing;

  const CompassPoint(this.label, this.bearing);
}

/// All 16 principal compass points with their bearings in degrees.
const List<CompassPoint> compassPoints = [
  CompassPoint('N', 0),
  CompassPoint('NNE', 22.5),
  CompassPoint('NE', 45),
  CompassPoint('ENE', 67.5),
  CompassPoint('E', 90),
  CompassPoint('ESE', 112.5),
  CompassPoint('SE', 135),
  CompassPoint('SSE', 157.5),
  CompassPoint('S', 180),
  CompassPoint('SSW', 202.5),
  CompassPoint('SW', 225),
  CompassPoint('WSW', 247.5),
  CompassPoint('W', 270),
  CompassPoint('WNW', 292.5),
  CompassPoint('NW', 315),
  CompassPoint('NNW', 337.5),
];

/// Returns the nearest compass point for a given [bearing] (0–360).
CompassPoint nearestCompassPoint(double bearing) {
  var best = compassPoints[0];
  var minDiff = 360.0;
  for (final p in compassPoints) {
    var diff = (p.bearing - bearing).abs();
    if (diff > 180) diff = 360 - diff;
    if (diff < minDiff) {
      minDiff = diff;
      best = p;
    }
  }
  return best;
}

/// Custom-painted compass rose widget.
class CompassRose extends StatelessWidget {
  /// The current heading the arrow points at (0–360). Set to `null` to
  /// show the arrow pointing North with no selection label.
  final double? heading;

  /// When non-null, the 16-point label that appears near the rim.
  final String? selectedLabel;

  /// Whether the compass is in live sensor mode.
  final bool isLive;

  /// Called when the user taps a point on the compass face.
  final ValueChanged<double>? onBearingSelected;

  const CompassRose({
    super.key,
    this.heading,
    this.selectedLabel,
    this.isLive = false,
    this.onBearingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        if (onBearingSelected == null) return;
        final size = context.size;
        if (size == null) return;
        final center = Offset(size.width / 2, size.height / 2);
        final dx = details.localPosition.dx - center.dx;
        final dy = details.localPosition.dy - center.dy;
        var angle =
            math.atan2(-dx, -dy) * 180.0 / math.pi;
        if (angle < 0) angle += 360;
        onBearingSelected!(angle);
      },
      child: CustomPaint(
        size: Size.infinite,
        painter: _CompassRosePainter(
          heading: heading,
          selectedLabel: selectedLabel,
          isLive: isLive,
        ),
      ),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  final double? heading;
  final String? selectedLabel;
  final bool isLive;

  _CompassRosePainter({
    this.heading,
    this.selectedLabel,
    this.isLive = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    if (radius <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // ── Outer circle ──────────────────────────────────────────────
    paint.color = Colors.grey.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius, paint);

    // ── Inner circle (subtle) ──────────────────────────────────────
    paint.color = Colors.grey.withValues(alpha: 0.12);
    paint.strokeWidth = 0.5;
    canvas.drawCircle(center, radius * 0.92, paint);

    // ── Tick marks at 22.5° intervals ─────────────────────────────
    for (int i = 0; i < 16; i++) {
      final angle = (i * 22.5 - 90) * math.pi / 180;
      final isCardinal = i % 4 == 0;
      final innerR = isCardinal ? radius * 0.88 : radius * 0.90;
      final outerR = radius * 0.96;
      final inner = Offset(
        center.dx + innerR * math.cos(angle),
        center.dy + innerR * math.sin(angle),
      );
      final outer = Offset(
        center.dx + outerR * math.cos(angle),
        center.dy + outerR * math.sin(angle),
      );
      paint.color = Colors.grey.withValues(alpha: isCardinal ? 0.6 : 0.25);
      paint.strokeWidth = isCardinal ? 2.5 : 1.0;
      canvas.drawLine(inner, outer, paint);
    }

    // ── Cardinal labels: N, E, S, W (bold, theme-aware) ────────────
    final labelStyle = TextStyle(
      fontSize: radius * 0.16,
      fontWeight: FontWeight.w900,
      color: Colors.black.withValues(alpha: 0.85),
    );
    final labelOffset = radius * 0.75;
    _drawLabel(canvas, center, labelOffset, -90, 'N', labelStyle);
    _drawLabel(canvas, center, labelOffset, 0, 'E', labelStyle);
    _drawLabel(canvas, center, labelOffset, 90, 'S', labelStyle);
    _drawLabel(canvas, center, labelOffset, 180, 'W', labelStyle);

    // ── Highlighted arc for selected direction ────────────────────
    if (heading != null) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      final startAngle = (heading! - 90 - 11.25) * math.pi / 180;
      final sweepAngle = 22.5 * math.pi / 180;

      arcPaint.color = isLive
          ? const Color(0xFF10B981).withValues(alpha: 0.7)
          : const Color(0xFF3B82F6).withValues(alpha: 0.7);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.97),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }

    // ── Arrow / Needle ────────────────────────────────────────────
    if (heading != null) {
      _drawArrow(canvas, center, radius * 0.70, heading!, isLive);
    } else {
      _drawArrow(canvas, center, radius * 0.70, 0, false);
    }

    // ── Centre dot ────────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.035, dotPaint);
  }

  void _drawArrow(Canvas canvas, Offset center, double length,
      double headingDeg, bool isLive) {
    final radians = (headingDeg - 90) * math.pi / 180;
    final tip = Offset(
      center.dx + length * math.cos(radians),
      center.dy + length * math.sin(radians),
    );

    final shaftPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    shaftPaint.color = isLive
        ? const Color(0xFF10B981).withValues(alpha: 0.9)
        : const Color(0xFF3B82F6).withValues(alpha: 0.9);
    canvas.drawLine(center, tip, shaftPaint);

    // Arrow head (triangle).
    final headLength = length * 0.12;
    final headAngle = 25.0 * math.pi / 180;
    final leftWing = Offset(
      tip.dx - headLength * math.cos(radians - headAngle),
      tip.dy - headLength * math.sin(radians - headAngle),
    );
    final rightWing = Offset(
      tip.dx - headLength * math.cos(radians + headAngle),
      tip.dy - headLength * math.sin(radians + headAngle),
    );
    final headPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isLive
          ? const Color(0xFF10B981)
          : const Color(0xFF3B82F6);
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(leftWing.dx, leftWing.dy)
      ..lineTo(rightWing.dx, rightWing.dy)
      ..close();
    canvas.drawPath(path, headPaint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double distance,
    double angleDeg,
    String label,
    TextStyle style,
  ) {
    final radians = angleDeg * math.pi / 180;
    final pos = Offset(
      center.dx + distance * math.cos(radians),
      center.dy + distance * math.sin(radians),
    );
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      pos - Offset(tp.width / 2, tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(_CompassRosePainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.selectedLabel != selectedLabel ||
        oldDelegate.isLive != isLive;
  }
}
