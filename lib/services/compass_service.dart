/// Compass service — streams tilt-compensated heading from device sensors.
///
/// Uses [sensors_plus] accelerometer + magnetometer to compute a heading
/// that works whether the phone is flat, tilted, or held upright.
/// Applies a low-pass filter for smooth readings.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:sensors_plus/sensors_plus.dart';

/// Service that streams the device's heading (0–360°) using sensor fusion.
class CompassService {
  CompassService._();

  static final CompassService _instance = CompassService._();

  /// Singleton accessor.
  static CompassService get instance => _instance;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;

  final StreamController<double> _headingController =
      StreamController<double>.broadcast();

  /// Raw acceleration vector (gravity + motion).
  double _ax = 0, _ay = 0, _az = 0;

  /// Raw magnetic field vector.
  double _mx = 0, _my = 0, _mz = 0;

  /// Low-pass filtered heading (smooth).
  double _filteredHeading = 0;

  /// Smoothing factor (0–1). Lower = smoother but laggier.
  static const double _smoothing = 0.25;
  static const double _filterConstant = 0.15;

  /// Whether the service has been started.
  bool _isListening = false;

  /// Fired when the user's manual entry should be overridden by live heading.
  final StreamController<bool> _liveOverrideController =
      StreamController<bool>.broadcast();

  /// Stream of live heading values (0–360°).
  Stream<double> get headingStream => _headingController.stream;

  /// Stream that emits `true` when live mode is active, `false` when paused.
  Stream<bool> get liveStatusStream => _liveOverrideController.stream;

  /// Whether the sensor stream is currently active.
  bool get isListening => _isListening;

  /// Starts listening to sensors and computing heading.
  void start() {
    if (_isListening) return;
    _isListening = true;

    // Accelerometer (gravity + motion).
    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _ax = _lowPassFilter(_ax, event.x, _filterConstant);
      _ay = _lowPassFilter(_ay, event.y, _filterConstant);
      _az = _lowPassFilter(_az, event.z, _filterConstant);
      _computeHeading();
    });

    // Magnetometer (magnetic field).
    _magSub = magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _mx = _lowPassFilter(_mx, event.x, _filterConstant);
      _my = _lowPassFilter(_my, event.y, _filterConstant);
      _mz = _lowPassFilter(_mz, event.z, _filterConstant);
      _computeHeading();
    });
  }

  /// Stops all sensor subscriptions and clears state.
  void stop() {
    _isListening = false;
    _accelSub?.cancel();
    _accelSub = null;
    _magSub?.cancel();
    _magSub = null;
    _ax = _ay = _az = 0;
    _mx = _my = _mz = 0;
  }

  /// Disposes all resources.
  void dispose() {
    stop();
    _headingController.close();
    _liveOverrideController.close();
  }

  /// Computes a tilt-compensated heading using accelerometer and
  /// magnetometer readings.
  ///
  /// Algorithm: uses the gravity vector from the accelerometer to
  /// determine device orientation (roll/pitch), then projects the
  /// magnetic field onto the horizontal plane to get a heading that
  /// works regardless of tilt.
  void _computeHeading() {
    // Normalise accelerometer vector.
    final accelNorm =
        math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (accelNorm < 0.01) return;
    final ax = _ax / accelNorm;
    final ay = _ay / accelNorm;
    final az = _az / accelNorm;

    // Tilt-compensated magnetometer projection onto horizontal plane.
    // Using the standard Tilt Compensation formula:
    //   Mx' = Mx * cos(pitch) + Mz * sin(pitch)
    //   My' = Mx * sin(roll) * sin(pitch) + My * cos(roll) - Mz * sin(roll) * cos(pitch)
    // Where roll and pitch are derived from accelerometer.

    final roll = math.atan2(-ay, -az);
    final pitch = math.atan2(
        ax, math.sqrt(ay * ay + az * az));

    final cosRoll = math.cos(roll);
    final sinRoll = math.sin(roll);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);

    // Tilt-compensated magnetic components.
    final magX = _mx * cosPitch + _mz * sinPitch;
    final magY = _mx * sinRoll * sinPitch +
        _my * cosRoll -
        _mz * sinRoll * cosPitch;

    // Heading in degrees.
    var heading =
        math.atan2(-magY, magX) * 180.0 / math.pi;
    if (heading < 0) heading += 360;
    if (heading >= 360) heading -= 360;

    // Apply smoothing.
    if (_filteredHeading == 0) {
      _filteredHeading = heading;
    } else {
      // Handle wrap-around for averaging (e.g., 359 → 1 should go to 0, not 180).
      var diff = heading - _filteredHeading;
      if (diff > 180) {
        _filteredHeading += 360;
      } else if (diff < -180) {
        _filteredHeading -= 360;
      }
      _filteredHeading += (heading - _filteredHeading) * _smoothing;
      if (_filteredHeading < 0) _filteredHeading += 360;
      if (_filteredHeading >= 360) _filteredHeading -= 360;
    }

    _headingController.add(_filteredHeading);
    _liveOverrideController.add(true);
  }

  /// Simple exponential low-pass filter.
  static double _lowPassFilter(
      double previous, double current, double alpha) {
    return previous + alpha * (current - previous);
  }
}
