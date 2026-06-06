/// Compass service — streams tilt-compensated true heading from device sensors + GPS.
///
/// Uses [sensors_plus] accelerometer + magnetometer for magnetic heading,
/// [geolocator] for GPS position, and [GeoMag] for WMM magnetic declination
/// correction to produce a true north heading.
library;

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geomag/geomag.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Service that streams the device's true heading (0–360°) and GPS position.
class CompassService {
  CompassService._();

  static final CompassService _instance = CompassService._();

  /// Singleton accessor.
  static CompassService get instance => _instance;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<Position>? _locationSub;
  Timer? _positionTimer;

  final StreamController<double> _trueHeadingController =
      StreamController<double>.broadcast();
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  final StreamController<bool> _liveOverrideController =
      StreamController<bool>.broadcast();

  double _ax = 0, _ay = 0, _az = 0;
  double _mx = 0, _my = 0, _mz = 0;
  double _filteredHeading = 0;
  double? _currentDeclination;

  /// Low-pass smoothing factor (lower = smoother but more lag).
  static const double _smoothing = 0.1;
  static const double _filterConstant = 0.1;

  bool _isListening = false;

  /// True heading corrected for magnetic declination (0–360°).
  Stream<double> get trueHeadingStream => _trueHeadingController.stream;

  /// GPS position updates from [Geolocator].
  Stream<Position> get positionStream => _positionController.stream;

  /// Always emits `true` while sensors are active.
  Stream<bool> get liveStatusStream => _liveOverrideController.stream;

  /// Whether the sensor streams are active.
  bool get isListening => _isListening;

  /// Starts sensor listeners and GPS location updates.
  void start() {
    if (_isListening) return;
    _isListening = true;

    _accelSub = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _ax = _lowPassFilter(_ax, event.x, _filterConstant);
      _ay = _lowPassFilter(_ay, event.y, _filterConstant);
      _az = _lowPassFilter(_az, event.z, _filterConstant);
      _computeHeading();
    });

    _magSub = magnetometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100),
    ).listen((event) {
      _mx = _lowPassFilter(_mx, event.x, _filterConstant);
      _my = _lowPassFilter(_my, event.y, _filterConstant);
      _mz = _lowPassFilter(_mz, event.z, _filterConstant);
      _computeHeading();
    });

    _startLocationUpdates();
  }

  /// Requests location permission and subscribes to GPS position stream.
  Future<void> _startLocationUpdates() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('Compass: location permission denied');
      return;
    }

    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
      ),
    ).listen(_onPositionUpdate);

    _positionTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchCurrentPosition(),
    );
  }

  void _onPositionUpdate(Position position) {
    _positionController.add(position);
    _updateDeclination(position);
  }

  Future<void> _fetchCurrentPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _positionController.add(pos);
      _updateDeclination(pos);
    } catch (_) {
      // stream covers updates; timer is a fallback
    }
  }

  void _updateDeclination(Position position) {
    try {
      final geoMag = GeoMag();
      final heightFeet = position.altitude * 3.28084;
      final result = geoMag.calculate(
        position.latitude,
        position.longitude,
        heightFeet,
        DateTime.now(),
      );
      _currentDeclination = result.dec;
    } catch (e) {
      debugPrint('Compass: geomag error: $e');
    }
  }

  /// Stops all sensor subscriptions and clears state.
  void stop() {
    _isListening = false;
    _accelSub?.cancel();
    _accelSub = null;
    _magSub?.cancel();
    _magSub = null;
    _locationSub?.cancel();
    _locationSub = null;
    _positionTimer?.cancel();
    _positionTimer = null;
    _ax = _ay = _az = 0;
    _mx = _my = _mz = 0;
    _currentDeclination = null;
  }

  /// Disposes all resources. The service cannot be restarted after this.
  void dispose() {
    stop();
    _positionTimer?.cancel();
    _trueHeadingController.close();
    _positionController.close();
    _liveOverrideController.close();
  }

  /// Computes tilt-compensated magnetic heading, then applies declination
  /// to produce a true north heading.
  void _computeHeading() {
    final accelNorm = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (accelNorm < 0.01) return;
    final ax = _ax / accelNorm;
    final ay = _ay / accelNorm;
    final az = _az / accelNorm;

    final roll = math.atan2(ay, az);
    final pitch = math.atan2(ax, math.sqrt(ay * ay + az * az));

    final cosRoll = math.cos(roll);
    final sinRoll = math.sin(roll);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);

    final magX = _mx * cosPitch + _mz * sinPitch;
    final magY =
        _mx * sinRoll * sinPitch + _my * cosRoll - _mz * sinRoll * cosPitch;

    var heading = math.atan2(-magX, magY) * 180.0 / math.pi;
    if (heading < 0) heading += 360;
    if (heading >= 360) heading -= 360;

    // Smooth magnetic heading — wrap-aware low-pass filter.
    if (_filteredHeading == 0) {
      _filteredHeading = heading;
    } else {
      var diff = heading - _filteredHeading;
      // Normalise diff into the [-180, 180] range first, then apply it.
      if (diff > 180) {
        diff -= 360;
      } else if (diff < -180) {
        diff += 360;
      }
      _filteredHeading += diff * _smoothing;
      if (_filteredHeading < 0) _filteredHeading += 360;
      if (_filteredHeading >= 360) _filteredHeading -= 360;
    }

    // Apply declination for true heading
    var trueHeading = _filteredHeading;
    if (_currentDeclination != null) {
      trueHeading += _currentDeclination!;
      if (trueHeading < 0) trueHeading += 360;
      if (trueHeading >= 360) trueHeading -= 360;
    }
    _trueHeadingController.add(trueHeading);
    _liveOverrideController.add(true);
  }

  /// Exponential low-pass filter.
  static double _lowPassFilter(double previous, double current, double alpha) {
    return previous + alpha * (current - previous);
  }
}
