/// Custom-painted compass rose with rotating dial, tick marks, degree labels,
/// cardinal markers, fixed red heading needle, and centre heading display.
///
/// The entire dial (ticks, numbers, cardinals, triangle) rotates so that the
/// current heading aligns with the top of the screen. A fixed red needle
/// at the top acts as the lubber line / heading indicator.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom-painted compass rose widget.
class CompassRose extends StatelessWidget {
  /// Current true heading in degrees (0–360).
  final double heading;

  /// Whether the device is using dark theme.
  final bool isDark;

  const CompassRose({super.key, required this.heading, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _CompassRosePainter(heading: heading, isDark: isDark),
    );
  }
}

class _CompassRosePainter extends CustomPainter {
  final double heading;
  final bool isDark;

  _CompassRosePainter({required this.heading, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    // Pure black background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF000000),
    );

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    if (radius <= 0) return;

    // ── Save & rotate so heading° moves to top ─────────────────────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    // ── Outer ring ─────────────────────────────────────────────────
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.grey.withValues(alpha: 0.4);
    canvas.drawCircle(Offset.zero, radius, ringPaint);

    // ── Tick marks: 1°/5°/10° intervals ────────────────────────────
    for (int i = 0; i < 360; i++) {
      final angle = (i - 90) * math.pi / 180;
      final isEvery10 = i % 10 == 0;
      final isEvery5 = i % 5 == 0;

      double innerR, strokeWidth;
      Color color;

      if (isEvery10) {
        innerR = radius - radius * 0.14;
        strokeWidth = 2.0;
        color = Colors.white.withValues(alpha: 0.7);
      } else if (isEvery5) {
        innerR = radius - radius * 0.08;
        strokeWidth = 1.2;
        color = Colors.white.withValues(alpha: 0.4);
      } else {
        innerR = radius - radius * 0.04;
        strokeWidth = 0.8;
        color = Colors.grey.withValues(alpha: 0.25);
      }

      final inner = Offset(innerR * math.cos(angle), innerR * math.sin(angle));
      final outer = Offset(radius * math.cos(angle), radius * math.sin(angle));

      final tickPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawLine(inner, outer, tickPaint);
    }

    // ── Degree labels at 30° intervals (outside ring) ──────────────
    final labelR = radius + 22;
    for (int i = 0; i < 360; i += 30) {
      final angle = (i - 90) * math.pi / 180;
      final x = labelR * math.cos(angle);
      final y = labelR * math.sin(angle);
      final tp = TextPainter(
        text: TextSpan(
          text: '$i',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.6),
            fontWeight: FontWeight.w400,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
    }

    // ── Cardinal labels N / E / S / W ──────────────────────────────
    final cardR = radius * 0.68;
    _drawCardinal(canvas, 0, -cardR, 'N');
    _drawCardinal(canvas, cardR, 0, 'E');
    _drawCardinal(canvas, 0, cardR, 'S');
    _drawCardinal(canvas, -cardR, 0, 'W');

    // ── Red triangle at N (rotates with dial), tip pointing outward ──────────
    final triY = -(radius * 0.78);
    final triSize = radius * 0.05;
    final triPath = Path()
      ..moveTo(0, triY - triSize * 1.2) // tip toward ring (outward)
      ..lineTo(-triSize * 0.7, triY + triSize) // left base toward centre
      ..lineTo(triSize * 0.7, triY + triSize); // right base toward centre
    final triPaint = Paint()
      ..color = const Color(0xFFFF3333)
      ..style = PaintingStyle.fill;
    canvas.drawPath(triPath, triPaint);

    // ── Restore (everything drawn after this is fixed) ─────────────
    canvas.restore();

    // ── Fixed red vertical needle (lubber line) at top ─────────────
    final needlePaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, center.dy - radius * 0.80),
      needlePaint,
    );

    // Small filled red dot at needle tip
    final dotPaint = Paint()
      ..color = const Color(0xFFFF0000)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx, center.dy - radius * 0.80),
      3,
      dotPaint,
    );

    // ── Centre heading text ────────────────────────────────────────
    final headingText = '${heading.round()}°';
    final headingTp = TextPainter(
      text: TextSpan(
        text: headingText,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    headingTp.paint(
      canvas,
      center - Offset(headingTp.width / 2, headingTp.height / 2),
    );
  }

  void _drawCardinal(Canvas canvas, double x, double y, String label) {
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(_CompassRosePainter oldDelegate) {
    return oldDelegate.heading != heading || oldDelegate.isDark != isDark;
  }
}
