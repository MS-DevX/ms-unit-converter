/// Bubble level / inclinometer service using the device accelerometer.
///
/// Streams pitch and roll angles in degrees. Supports zero-offset
/// calibration so the user can set any orientation as the reference.
///
/// Uses [sensors_plus] for accelerometer access — no GPS or location
/// permission required.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// A single reading from the bubble level.
class BubbleLevelData {
  /// Pitch angle in degrees (rotation around Y axis).
  /// Positive = top edge raised above horizontal.
  final double pitch;

  /// Roll angle in degrees (rotation around X axis).
  /// Positive = right edge raised above horizontal.
  final double roll;

  /// Whether the accelerometer sensor is available.
  final bool hasSensor;

  const BubbleLevelData({
    required this.pitch,
    required this.roll,
    this.hasSensor = true,
  });
}

// ── Pure calculation helpers (exported for testing) ────────────────

/// Calculates pitch in degrees from raw accelerometer values.
///
/// Pitch is rotation around the Y axis (phone tilts forward/backward).
/// Returns a value in the range [-90, 90].
double calcPitch(double ax, double ay, double az) {
  return math.atan2(-ax, math.sqrt(ay * ay + az * az)) * 180 / math.pi;
}

/// Calculates roll in degrees from raw accelerometer values.
///
/// Roll is rotation around the X axis (phone tilts left/right).
/// Returns a value in the range [-90, 90].
double calcRoll(double ay, double az) {
  return math.atan2(ay, az) * 180 / math.pi;
}

/// Applies a calibration offset, returning `value - offset`.
double applyOffset(double value, double offset) {
  return value - offset;
}

/// Formats an angle in degrees with one decimal place and a degree symbol.
///
/// Returns `'--'` for NaN or infinite values.
String formatDegrees(double degrees) {
  if (degrees.isNaN || degrees.isInfinite) return '--';
  final abs = degrees.abs();
  final str = abs.toStringAsFixed(1);
  return '${degrees < 0 ? '-' : ''}$str\u00B0';
}

// ── Service ────────────────────────────────────────────────────────

/// Listens to the device accelerometer and streams pitch / roll angles.
class BubbleLevelService {
  StreamSubscription<AccelerometerEvent>? _accelSub;
  final StreamController<BubbleLevelData> _dataController =
      StreamController<BubbleLevelData>.broadcast();

  double _pitchOffset = 0;
  double _rollOffset = 0;
  bool _isListening = false;

  /// Whether the accelerometer subscription is active.
  bool get isListening => _isListening;

  /// Broadcast stream of [BubbleLevelData] readings.
  /// Emits at roughly 10 Hz (100 ms sampling period).
  Stream<BubbleLevelData> get dataStream => _dataController.stream;

  /// Current pitch calibration offset in degrees.
  double get pitchOffset => _pitchOffset;

  /// Current roll calibration offset in degrees.
  double get rollOffset => _rollOffset;

  /// Starts the accelerometer listener.
  ///
  /// If no sensor event arrives within 2 seconds, emits a reading with
  /// `hasSensor = false`.
  void start() {
    if (_isListening) return;
    _isListening = true;

    Timer? timeout;
    timeout = Timer(const Duration(seconds: 2), () {
      if (_isListening) {
        _dataController.add(
          const BubbleLevelData(pitch: 0, roll: 0, hasSensor: false),
        );
      }
    });

    _accelSub =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen(
          (event) {
            timeout?.cancel();
            final rawPitch = calcPitch(event.x, event.y, event.z);
            final rawRoll = calcRoll(event.y, event.z);
            _dataController.add(
              BubbleLevelData(
                pitch: applyOffset(rawPitch, _pitchOffset),
                roll: applyOffset(rawRoll, _rollOffset),
                hasSensor: true,
              ),
            );
          },
          onError: (_) {
            timeout?.cancel();
            _dataController.add(
              const BubbleLevelData(pitch: 0, roll: 0, hasSensor: false),
            );
          },
          cancelOnError: false,
        );
  }

  /// Stops the accelerometer listener.
  void stop() {
    _isListening = false;
    _accelSub?.cancel();
    _accelSub = null;
  }

  /// Records the current raw angles as the calibration zero point.
  ///
  /// After calling this, the stream will emit `pitch - rawPitch` and
  /// `roll - rawRoll`, so the bubble centres at the calibrated orientation.
  void calibrate(double rawPitch, double rawRoll) {
    _pitchOffset = rawPitch;
    _rollOffset = rawRoll;
  }

  /// Clears the calibration offset back to zero.
  void resetCalibration() {
    _pitchOffset = 0;
    _rollOffset = 0;
  }

  /// Disposes of the stream controller and stops listening.
  void dispose() {
    stop();
    _dataController.close();
  }
}
