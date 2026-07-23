/// Compass service — streams tilt-compensated magnetic heading from device sensors.
///
/// Location / GPS / true north features require an explicit [enableTrueNorth] call;
/// the compass starts in pure magnetic mode without requesting any permissions.
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

// ── Compass state model ──────────────────────────────────────────

/// Represents the current state of the compass.
enum CompassState {
  /// Sensors are being initialized.
  initializing,

  /// Magnetic compass (accelerometer + magnetometer) is active.
  magneticNorthActive,

  /// True north (magnetic + GPS declination) is active.
  trueNorthActive,

  /// Required sensors (accelerometer / magnetometer) are unavailable.
  sensorsUnavailable,

  /// Location permission has not been requested yet.
  locationPermissionNeeded,

  /// Location permission was denied by the user.
  locationDenied,

  /// Location permission denied in this session (will not re-ask).
  locationDeniedThisSession,

  /// Location permission is permanently denied (deniedForever).
  locationDeniedForever,

  /// Location services (GPS) are disabled on the device.
  locationServiceDisabled,

  /// Sensor calibration is recommended (noisy heading).
  calibrationRecommended,

  /// An unexpected error occurred.
  error,
}

// ── Permission helpers (keep existing API) ───────────────────────

/// Outcomes of an [enableTrueNorth] attempt.
enum LocationPermissionState {
  /// Permission was granted / already granted — location features start.
  granted,

  /// The user denied the prompt in this session. Do not prompt again.
  deniedThisSession,

  /// The user denied and ticked "Don't ask again" (OS-level permanent deny).
  deniedForever,

  /// Location services (GPS) are switched off on the device.
  serviceDisabled,

  /// No permission check has been attempted yet.
  notRequested,

  /// An unexpected error occurred during the permission flow.
  error,
}

/// Holds the result of an [enableTrueNorth] attempt.
class PermissionResult {
  const PermissionResult({required this.state, this.message});

  final LocationPermissionState state;
  final String? message;
}

// ── Location permission adapter (keep existing) ──────────────────

/// Abstract interface for location permission operations.
///
/// Inject a fake in tests to avoid depending on [Geolocator].
abstract class LocationPermissionAdapter {
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Future<bool> isLocationServiceEnabled();
  Stream<Position> getPositionStream(LocationSettings settings);
  Future<Position> getCurrentPosition(LocationSettings settings);
}

/// Default adapter that delegates to the real [Geolocator] APIs.
class DefaultLocationPermissionAdapter implements LocationPermissionAdapter {
  const DefaultLocationPermissionAdapter();

  @override
  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  @override
  Future<bool> isLocationServiceEnabled() =>
      Geolocator.isLocationServiceEnabled();

  @override
  Stream<Position> getPositionStream(LocationSettings settings) =>
      Geolocator.getPositionStream(locationSettings: settings);

  @override
  Future<Position> getCurrentPosition(LocationSettings settings) =>
      Geolocator.getCurrentPosition(locationSettings: settings);
}

// ── Pure helper functions (package-visible for testing) ──────────

/// Returns the 8-point compass label for a heading in degrees (0–360).
String directionLabel(double h) {
  if (h >= 337.5 || h < 22.5) return 'North';
  if (h >= 22.5 && h < 67.5) return 'North East';
  if (h >= 67.5 && h < 112.5) return 'East';
  if (h >= 112.5 && h < 157.5) return 'South East';
  if (h >= 157.5 && h < 202.5) return 'South';
  if (h >= 202.5 && h < 247.5) return 'South West';
  if (h >= 247.5 && h < 292.5) return 'West';
  if (h >= 292.5 && h < 337.5) return 'North West';
  return 'North';
}

/// Converts decimal degrees to DMS string (e.g. `31°29'23.4" N`).
String toDMS(double decimal, bool isLat) {
  final dir = isLat ? (decimal >= 0 ? 'N' : 'S') : (decimal >= 0 ? 'E' : 'W');
  decimal = decimal.abs();
  final d = decimal.floor();
  final m = ((decimal - d) * 60).floor();
  final s = (decimal - d - m / 60.0) * 3600;
  return '$d°$m\'${s.toStringAsFixed(1)}" $dir';
}

/// Human-readable label for [CompassState].
String compassStateLabel(CompassState state) {
  return switch (state) {
    CompassState.initializing => 'Initializing…',
    CompassState.magneticNorthActive => 'Magnetic North',
    CompassState.trueNorthActive => 'True North',
    CompassState.sensorsUnavailable => 'Sensor unavailable',
    CompassState.locationPermissionNeeded => 'Location permission needed',
    CompassState.locationDenied => 'Location unavailable',
    CompassState.locationDeniedThisSession => 'Location denied this session',
    CompassState.locationDeniedForever =>
      'Location permanently denied — change in settings',
    CompassState.locationServiceDisabled => 'Location services are off',
    CompassState.calibrationRecommended => 'Calibration recommended',
    CompassState.error => 'Error',
  };
}

/// Human-readable label for [LocationPermissionState].
String locationPermissionLabel(LocationPermissionState state) {
  return switch (state) {
    LocationPermissionState.notRequested => 'GPS not requested',
    LocationPermissionState.granted => 'GPS enabled',
    LocationPermissionState.deniedThisSession =>
      'Denied this session — magnetic compass still works',
    LocationPermissionState.deniedForever =>
      'Permanently denied — enable in settings',
    LocationPermissionState.serviceDisabled =>
      'Location services are off — enable in settings',
    LocationPermissionState.error => 'Permission error',
  };
}

// ── Service ──────────────────────────────────────────────────────

/// Service that streams the device's magnetic (and optionally true) heading
/// (0–360°) and GPS position.
///
/// The compass starts in **magnetic-only** mode when [start] is called.
/// Location / GPS / true north are only activated after an explicit
/// [enableTrueNorth] call from the UI.
class CompassService {
  CompassService._();

  static final CompassService _instance = CompassService._();

  /// Singleton accessor.
  static CompassService get instance => _instance;

  /// The permission adapter used for all [Geolocator] interactions.
  /// Override in tests with a fake to avoid real permission dialogs.
  LocationPermissionAdapter permissionAdapter =
      const DefaultLocationPermissionAdapter();

  // ── Subscriptions ──────────────────────────────────────────────

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<Position>? _locationSub;
  Timer? _positionTimer;
  Timer? _sensorTimeout;

  // ── Stream controllers ─────────────────────────────────────────

  final StreamController<double> _trueHeadingController =
      StreamController<double>.broadcast();
  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  final StreamController<bool> _liveOverrideController =
      StreamController<bool>.broadcast();
  final StreamController<PermissionResult> _permissionResultController =
      StreamController<PermissionResult>.broadcast();
  final StreamController<CompassState> _stateController =
      StreamController<CompassState>.broadcast();

  // ── Sensor state ───────────────────────────────────────────────

  double _ax = 0, _ay = 0, _az = 0;
  double _mx = 0, _my = 0, _mz = 0;
  double _filteredHeading = 0;
  double? _currentDeclination;

  static const double _smoothing = 0.1;
  static const double _filterConstant = 0.1;

  bool _isListening = false;

  CompassState _currentState = CompassState.initializing;

  /// In-memory flag: reset on app process restart.
  bool _locationDeniedThisSession = false;
  bool _requestInProgress = false;

  // ── Streams / getters ──────────────────────────────────────────

  /// Magnetic or true heading corrected for declination (0–360°).
  Stream<double> get trueHeadingStream => _trueHeadingController.stream;

  /// GPS position updates.
  Stream<Position> get positionStream => _positionController.stream;

  /// Always emits `true` while sensors are active.
  Stream<bool> get liveStatusStream => _liveOverrideController.stream;

  /// Emits the result of each [enableTrueNorth] attempt.
  Stream<PermissionResult> get permissionResultStream =>
      _permissionResultController.stream;

  /// Emits compass state changes.
  Stream<CompassState> get stateStream => _stateController.stream;

  /// Current compass state.
  CompassState get currentState => _currentState;

  /// Whether the sensor streams (at least magnetic compass) are active.
  bool get isListening => _isListening;

  /// Whether a location permission request is currently in flight.
  bool get isRequestInProgress => _requestInProgress;

  // ── Control ────────────────────────────────────────────────────

  /// Starts the magnetic compass (accelerometer + magnetometer).
  ///
  /// Does **not** request location permission or start GPS.
  /// Call [enableTrueNorth] separately for GPS features.
  void start() {
    if (_isListening) return;
    _isListening = true;
    _updateState(CompassState.initializing);
    _initSensors();
  }

  Future<void> _initSensors() async {
    // Set a timeout: if no events arrive within 3s, mark sensors unavailable.
    _sensorTimeout?.cancel();
    _sensorTimeout = Timer(const Duration(seconds: 3), () {
      if (_currentState == CompassState.initializing) {
        _updateState(CompassState.sensorsUnavailable);
        _isListening = false;
      }
    });

    _accelSub =
        accelerometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen(
          (event) {
            _sensorTimeout?.cancel();
            _ax = _lowPassFilter(_ax, event.x, _filterConstant);
            _ay = _lowPassFilter(_ay, event.y, _filterConstant);
            _az = _lowPassFilter(_az, event.z, _filterConstant);
            _computeHeading();
          },
          onError: (_) {
            _sensorTimeout?.cancel();
            _updateState(CompassState.sensorsUnavailable);
            _isListening = false;
          },
          cancelOnError: false,
        );

    _magSub =
        magnetometerEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen(
          (event) {
            _sensorTimeout?.cancel();
            _mx = _lowPassFilter(_mx, event.x, _filterConstant);
            _my = _lowPassFilter(_my, event.y, _filterConstant);
            _mz = _lowPassFilter(_mz, _mz * 0 + event.z, _filterConstant);
            _computeHeading();
          },
          onError: (_) {
            _sensorTimeout?.cancel();
            _updateState(CompassState.sensorsUnavailable);
            _isListening = false;
          },
          cancelOnError: false,
        );

    // If either stream has already emitted an event (not initializing anymore),
    // the timeout will be cancelled by the event handlers above.
    // The magneticNorthActive state is set by _computeHeading when both
    // sensor streams have started producing data.
  }

  /// Retry initializing sensors after an error or unavailable state.
  void retrySensors() {
    if (_isListening) {
      // Already listening — nothing to retry
      return;
    }
    _updateState(CompassState.initializing);
    _isListening = true;
    _initSensors();
  }

  /// Requests location permission and, if granted, starts GPS streams.
  ///
  /// Returns a [PermissionResult] describing the outcome.
  /// If the user denied already in this session, returns
  /// [LocationPermissionState.deniedThisSession] without showing the
  /// system dialog.
  Future<PermissionResult> enableTrueNorth() async {
    if (_requestInProgress) {
      return const PermissionResult(
        state: LocationPermissionState.error,
        message: 'A permission request is already in progress.',
      );
    }

    _requestInProgress = true;

    try {
      final result = await _requestLocationPermission();
      final pr = PermissionResult(
        state: result,
        message: locationPermissionLabel(result),
      );
      _permissionResultController.add(pr);
      if (result == LocationPermissionState.granted) {
        _updateState(CompassState.trueNorthActive);
      }
      return pr;
    } finally {
      _requestInProgress = false;
    }
  }

  Future<LocationPermissionState> _requestLocationPermission() async {
    // ── Session denial guard (re-check in case user changed via settings) ─
    if (_locationDeniedThisSession) {
      final permission = await permissionAdapter.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _locationDeniedThisSession = false;
        _startLocationSubscription();
        _updateState(CompassState.trueNorthActive);
        return LocationPermissionState.granted;
      }
      _updateState(CompassState.locationDeniedThisSession);
      return LocationPermissionState.deniedThisSession;
    }

    // ── Check if location services are on ────────────────────────
    final serviceEnabled = await permissionAdapter.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _updateState(CompassState.locationServiceDisabled);
      return LocationPermissionState.serviceDisabled;
    }

    // ── Check current permission ─────────────────────────────────
    var permission = await permissionAdapter.checkPermission();

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _startLocationSubscription();
      _updateState(CompassState.trueNorthActive);
      return LocationPermissionState.granted;
    }

    if (permission == LocationPermission.deniedForever) {
      _updateState(CompassState.locationDeniedForever);
      return LocationPermissionState.deniedForever;
    }

    // ── denied — request once ─────────────────────────────────────
    if (permission == LocationPermission.denied) {
      permission = await permissionAdapter.requestPermission();

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _startLocationSubscription();
        _updateState(CompassState.trueNorthActive);
        return LocationPermissionState.granted;
      }

      if (permission == LocationPermission.deniedForever) {
        _updateState(CompassState.locationDeniedForever);
        return LocationPermissionState.deniedForever;
      }

      // User tapped Deny (not "Deny & don't ask again")
      _locationDeniedThisSession = true;
      _updateState(CompassState.locationDeniedThisSession);
      return LocationPermissionState.deniedThisSession;
    }

    _updateState(CompassState.error);
    return LocationPermissionState.error;
  }

  void _startLocationSubscription() {
    // Cancel any existing subscription first (anti-duplication)
    _locationSub?.cancel();
    _positionTimer?.cancel();

    _locationSub = permissionAdapter
        .getPositionStream(
          const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 0,
          ),
        )
        .listen(_onPositionUpdate);

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
      final pos = await permissionAdapter.getCurrentPosition(
        const LocationSettings(accuracy: LocationAccuracy.high),
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

  void _updateState(CompassState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// Stops GPS location streams without stopping the magnetic compass.
  void stopLocation() {
    _locationSub?.cancel();
    _locationSub = null;
    _positionTimer?.cancel();
    _positionTimer = null;
    _currentDeclination = null;
    if (_currentState == CompassState.trueNorthActive) {
      _updateState(CompassState.magneticNorthActive);
    }
  }

  /// Stops all sensor subscriptions and clears state.
  void stop() {
    _isListening = false;
    _sensorTimeout?.cancel();
    _sensorTimeout = null;
    _accelSub?.cancel();
    _accelSub = null;
    _magSub?.cancel();
    _magSub = null;
    stopLocation();
    _ax = _ay = _az = 0;
    _mx = _my = _mz = 0;
    _currentDeclination = null;
    _filteredHeading = 0;
    _updateState(CompassState.initializing);
  }

  /// Disposes all resources. The service cannot be restarted after this.
  void dispose() {
    stop();
    _trueHeadingController.close();
    _positionController.close();
    _liveOverrideController.close();
    _permissionResultController.close();
    _stateController.close();
  }

  @visibleForTesting
  void resetTestState() {
    _locationDeniedThisSession = false;
    _requestInProgress = false;
    _currentState = CompassState.initializing;
  }

  // ── Heading computation ────────────────────────────────────────

  void _computeHeading() {
    final accelNorm = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
    if (accelNorm < 0.01) return;

    // First successful heading → magnetic north active
    if (_currentState == CompassState.initializing) {
      _updateState(CompassState.magneticNorthActive);
    }
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

    if (_filteredHeading == 0) {
      _filteredHeading = heading;
    } else {
      var diff = heading - _filteredHeading;
      if (diff > 180) {
        diff -= 360;
      } else if (diff < -180) {
        diff += 360;
      }
      _filteredHeading += diff * _smoothing;
      if (_filteredHeading < 0) _filteredHeading += 360;
      if (_filteredHeading >= 360) _filteredHeading -= 360;
    }

    var trueHeading = _filteredHeading;
    if (_currentDeclination != null) {
      trueHeading += _currentDeclination!;
      if (trueHeading < 0) trueHeading += 360;
      if (trueHeading >= 360) trueHeading -= 360;
    }
    _trueHeadingController.add(trueHeading);
    _liveOverrideController.add(true);
  }

  static double _lowPassFilter(double previous, double current, double alpha) {
    return previous + alpha * (current - previous);
  }
}
