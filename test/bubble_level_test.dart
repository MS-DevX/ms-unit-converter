import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/services/bubble_level_service.dart';

void main() {
  // ── calcPitch ──────────────────────────────────────────────────────

  group('calcPitch', () {
    test('flat on back (screen up) → 0°', () {
      // ax=0, ay=0, az=9.8
      final pitch = calcPitch(0, 0, 9.8);
      expect(pitch, closeTo(0, 0.1));
    });

    test('tilted 30° forward (top edge down) → ~30°', () {
      // ax = -g*sin(30°) ≈ -4.9, ay=0, az = g*cos(30°) ≈ 8.49
      final pitch = calcPitch(-4.9, 0, 8.49);
      expect(pitch, closeTo(30, 1.0));
    });

    test('tilted 30° backward (top edge up) → ~-30°', () {
      // ax = g*sin(30°) ≈ 4.9, ay=0, az = g*cos(30°) ≈ 8.49
      final pitch = calcPitch(4.9, 0, 8.49);
      expect(pitch, closeTo(-30, 1.0));
    });

    test(
      'tilted 90° forward (screen facing down, top toward floor) → ~-90°',
      () {
        // ax = g = 9.8, ay=0, az≈0 (small epsilon to avoid zero in sqrt)
        final pitch = calcPitch(9.8, 0, 0.01);
        expect(pitch, closeTo(-90, 0.1));
      },
    );
  });

  // ── calcRoll ───────────────────────────────────────────────────────

  group('calcRoll', () {
    test('flat on back → 0°', () {
      final roll = calcRoll(0, 9.8);
      expect(roll, closeTo(0, 0.1));
    });

    test('tilted 20° right (right edge up) → ~-20°', () {
      // ay = -g*sin(20°) ≈ -3.35, az = g*cos(20°) ≈ 9.21
      final roll = calcRoll(-3.35, 9.21);
      expect(roll, closeTo(-20, 1.0));
    });

    test('tilted 20° left (left edge up) → ~20°', () {
      // ay = g*sin(20°) ≈ 3.35, az = g*cos(20°) ≈ 9.21
      final roll = calcRoll(3.35, 9.21);
      expect(roll, closeTo(20, 1.0));
    });

    test('90° roll (phone on its right edge) → ~-90°', () {
      // ay ≈ -g, az ≈ 0
      final roll = calcRoll(-9.8, 0.01);
      expect(roll, closeTo(-90, 0.1));
    });
  });

  // ── applyOffset ────────────────────────────────────────────────────

  group('applyOffset', () {
    test('returns value minus offset', () {
      expect(applyOffset(10, 3), 7);
    });

    test('zero offset returns value unchanged', () {
      expect(applyOffset(5.5, 0), 5.5);
    });

    test('negative offset increases value', () {
      expect(applyOffset(2, -3), 5);
    });

    test('value equal to offset returns zero', () {
      expect(applyOffset(15, 15), 0);
    });

    test('works with floating point', () {
      expect(applyOffset(0.5, 0.3), closeTo(0.2, 1e-10));
    });
  });

  // ── formatDegrees ──────────────────────────────────────────────────

  group('formatDegrees', () {
    test('zero degrees', () {
      expect(formatDegrees(0), '0.0°');
    });

    test('positive degrees', () {
      expect(formatDegrees(42.5), '42.5°');
    });

    test('negative degrees', () {
      expect(formatDegrees(-15.3), '-15.3°');
    });

    test('rounds to one decimal', () {
      expect(formatDegrees(3.14159), '3.1°');
    });

    test('negative rounds to one decimal', () {
      expect(formatDegrees(-2.718), '-2.7°');
    });

    test('NaN returns --', () {
      expect(formatDegrees(double.nan), '--');
    });

    test('infinity returns --', () {
      expect(formatDegrees(double.infinity), '--');
    });

    test('negative infinity returns --', () {
      expect(formatDegrees(double.negativeInfinity), '--');
    });
  });

  // ── BubbleLevelService calibrate / resetCalibration ────────────────

  group('BubbleLevelService calibration', () {
    test('initial offsets are zero', () {
      final service = BubbleLevelService();
      expect(service.pitchOffset, 0);
      expect(service.rollOffset, 0);
      service.dispose();
    });

    test('calibrate sets the offsets', () {
      final service = BubbleLevelService();
      service.calibrate(12.5, -3.2);
      expect(service.pitchOffset, 12.5);
      expect(service.rollOffset, -3.2);
      service.dispose();
    });

    test('resetCalibration clears offsets', () {
      final service = BubbleLevelService();
      service.calibrate(5, 10);
      expect(service.pitchOffset, 5);
      expect(service.rollOffset, 10);
      service.resetCalibration();
      expect(service.pitchOffset, 0);
      expect(service.rollOffset, 0);
      service.dispose();
    });

    test('applyOffset after calibrate produces centre at calibrated angle', () {
      const rawPitch = 12.5;
      const rawRoll = -3.2;

      // After calibrate, offset = raw value
      final offsetPitch = applyOffset(rawPitch, rawPitch);
      final offsetRoll = applyOffset(rawRoll, rawRoll);
      expect(offsetPitch, closeTo(0, 1e-10));
      expect(offsetRoll, closeTo(0, 1e-10));
    });
  });

  // ── Edge cases ─────────────────────────────────────────────────────

  group('edge cases', () {
    test('zero acceleration produces pitch 0', () {
      // When the device is in free-fall, all axes are 0
      final pitch = calcPitch(0, 0, 0);
      // atan2(0, 0) = 0
      expect(pitch, 0);
    });

    test('very small acceleration produces finite pitch', () {
      final pitch = calcPitch(0.01, 0.01, 9.8);
      expect(pitch.isFinite, isTrue);
      expect(pitch, closeTo(0, 0.1));
    });

    test('calcRoll with zero az produces ±90°', () {
      // ay = 1, az = 0 → atan2(1, 0) = π/2 → 90°
      final roll = calcRoll(1, 0);
      expect(roll, closeTo(90, 0.1));
    });

    test('calcRoll with negative az and zero ay produces ±180°', () {
      // ay = 0, az = -1 → atan2(0, -1) = π → 180°
      final roll = calcRoll(0, -1);
      expect(roll, closeTo(180, 0.1));
    });

    test('calcPitch and calcRoll on realistic flat reading', () {
      // Phone flat on table: ax≈0, ay≈0, az≈9.81
      final pitch = calcPitch(0.02, -0.01, 9.81);
      final roll = calcRoll(-0.01, 9.81);
      expect(pitch, closeTo(0, 0.2));
      expect(roll, closeTo(0, 0.2));
    });
  });
}
