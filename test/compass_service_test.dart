import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unit_converter/services/compass_service.dart';

/// Fake [LocationPermissionAdapter] that returns controlled values.
class FakeLocationPermissionAdapter implements LocationPermissionAdapter {
  LocationPermission _checkResult = LocationPermission.denied;
  LocationPermission _requestResult = LocationPermission.whileInUse;
  bool _serviceEnabled = true;

  int checkCallCount = 0;
  int requestCallCount = 0;
  int enabledCallCount = 0;

  void setCheck(LocationPermission p) => _checkResult = p;
  void setRequest(LocationPermission p) => _requestResult = p;
  void setServiceEnabled(bool v) => _serviceEnabled = v;

  @override
  Future<LocationPermission> checkPermission() async {
    checkCallCount++;
    return _checkResult;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    requestCallCount++;
    return _requestResult;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    enabledCallCount++;
    return _serviceEnabled;
  }

  @override
  Stream<Position> getPositionStream(LocationSettings settings) =>
      const Stream.empty();

  @override
  Future<Position> getCurrentPosition(LocationSettings settings) async =>
      throw UnimplementedError('not used in these tests');
}

void main() {
  // ── Pure helper functions ────────────────────────────────────────

  group('directionLabel', () {
    test('heading 0 returns North', () {
      expect(directionLabel(0), 'North');
    });

    test('heading 360 returns North', () {
      expect(directionLabel(360), 'North');
    });

    test('heading 90 returns East', () {
      expect(directionLabel(90), 'East');
    });

    test('heading 180 returns South', () {
      expect(directionLabel(180), 'South');
    });

    test('heading 270 returns West', () {
      expect(directionLabel(270), 'West');
    });

    test('heading 45 returns North East', () {
      expect(directionLabel(45), 'North East');
    });

    test('heading 337.5 returns North', () {
      expect(directionLabel(337.5), 'North');
    });

    test('heading 22.5 returns North East', () {
      expect(directionLabel(22.5), 'North East');
    });
  });

  group('toDMS', () {
    test('positive latitude formats correctly', () {
      expect(toDMS(31.4898, true), '31°29\'23.3" N');
    });

    test('negative latitude shows S', () {
      expect(toDMS(-33.8568, true), '33°51\'24.5" S');
    });

    test('positive longitude shows E', () {
      expect(toDMS(151.2153, false), '151°12\'55.1" E');
    });

    test('negative longitude shows W', () {
      expect(toDMS(-74.0060, false), '74°0\'21.6" W');
    });

    test('zero is N/E', () {
      expect(toDMS(0, true), '0°0\'0.0" N');
    });
  });

  group('compassStateLabel', () {
    test('initializing label', () {
      expect(compassStateLabel(CompassState.initializing), 'Initializing…');
    });

    test('magneticNorthActive label', () {
      expect(
        compassStateLabel(CompassState.magneticNorthActive),
        'Magnetic North',
      );
    });

    test('trueNorthActive label', () {
      expect(compassStateLabel(CompassState.trueNorthActive), 'True North');
    });

    test('sensorsUnavailable label', () {
      expect(
        compassStateLabel(CompassState.sensorsUnavailable),
        'Sensor unavailable',
      );
    });

    test('locationDeniedThisSession label', () {
      expect(
        compassStateLabel(CompassState.locationDeniedThisSession),
        'Location denied this session',
      );
    });
  });

  group('locationPermissionLabel', () {
    test('granted label', () {
      expect(
        locationPermissionLabel(LocationPermissionState.granted),
        'GPS enabled',
      );
    });

    test('notRequested label', () {
      expect(
        locationPermissionLabel(LocationPermissionState.notRequested),
        'GPS not requested',
      );
    });
  });

  // ── Permission flow tests ────────────────────────────────────

  group('enableTrueNorth()', () {
    late FakeLocationPermissionAdapter fakeAdapter;

    setUp(() {
      final compass = CompassService.instance;
      compass.resetTestState();
      fakeAdapter = FakeLocationPermissionAdapter();
      compass.permissionAdapter = fakeAdapter;
    });

    test('returns granted when permission already granted', () async {
      fakeAdapter.setCheck(LocationPermission.whileInUse);
      fakeAdapter.setServiceEnabled(true);

      final result = await CompassService.instance.enableTrueNorth();

      expect(result.state, LocationPermissionState.granted);
      expect(fakeAdapter.requestCallCount, 0);
    });

    test('returns granted when user grants after prompt', () async {
      fakeAdapter.setCheck(LocationPermission.denied);
      fakeAdapter.setRequest(LocationPermission.whileInUse);
      fakeAdapter.setServiceEnabled(true);

      final result = await CompassService.instance.enableTrueNorth();

      expect(result.state, LocationPermissionState.granted);
      expect(fakeAdapter.requestCallCount, 1);
    });

    test('returns deniedThisSession when user denies and does not '
        're-prompt on second call', () async {
      fakeAdapter.setCheck(LocationPermission.denied);
      fakeAdapter.setRequest(LocationPermission.denied);
      fakeAdapter.setServiceEnabled(true);

      final first = await CompassService.instance.enableTrueNorth();
      expect(first.state, LocationPermissionState.deniedThisSession);
      expect(fakeAdapter.requestCallCount, 1);

      final second = await CompassService.instance.enableTrueNorth();
      expect(second.state, LocationPermissionState.deniedThisSession);
      expect(fakeAdapter.requestCallCount, 1);
    });

    test('returns deniedForever without calling requestPermission', () async {
      fakeAdapter.setCheck(LocationPermission.deniedForever);
      fakeAdapter.setServiceEnabled(true);

      final result = await CompassService.instance.enableTrueNorth();

      expect(result.state, LocationPermissionState.deniedForever);
      expect(fakeAdapter.requestCallCount, 0);
    });

    test('returns serviceDisabled when location services are off', () async {
      fakeAdapter.setServiceEnabled(false);

      final result = await CompassService.instance.enableTrueNorth();

      expect(result.state, LocationPermissionState.serviceDisabled);
      expect(fakeAdapter.checkCallCount, 0);
      expect(fakeAdapter.requestCallCount, 0);
    });

    test('returns granted after deniedForever when user changes permission '
        'via settings', () async {
      fakeAdapter.setCheck(LocationPermission.deniedForever);
      fakeAdapter.setServiceEnabled(true);

      final first = await CompassService.instance.enableTrueNorth();
      expect(first.state, LocationPermissionState.deniedForever);

      fakeAdapter.setCheck(LocationPermission.whileInUse);

      final second = await CompassService.instance.enableTrueNorth();
      expect(second.state, LocationPermissionState.granted);
    });

    test(
      'returns granted via settings after session denial (re-check)',
      () async {
        fakeAdapter.setCheck(LocationPermission.denied);
        fakeAdapter.setRequest(LocationPermission.denied);
        fakeAdapter.setServiceEnabled(true);

        final first = await CompassService.instance.enableTrueNorth();
        expect(first.state, LocationPermissionState.deniedThisSession);

        fakeAdapter.setCheck(LocationPermission.whileInUse);

        final second = await CompassService.instance.enableTrueNorth();
        expect(second.state, LocationPermissionState.granted);
      },
    );
  });

  // ── State transitions (without real sensors) ─────────────────────

  group('compass state', () {
    late FakeLocationPermissionAdapter fakeAdapter;

    setUp(() {
      final compass = CompassService.instance;
      compass.resetTestState();
      fakeAdapter = FakeLocationPermissionAdapter();
      compass.permissionAdapter = fakeAdapter;
    });

    test('initial state is initializing', () {
      expect(CompassService.instance.currentState, CompassState.initializing);
    });

    test(
      'enableTrueNorth with granted transitions to trueNorthActive',
      () async {
        fakeAdapter.setCheck(LocationPermission.whileInUse);
        fakeAdapter.setServiceEnabled(true);

        await CompassService.instance.enableTrueNorth();

        expect(
          CompassService.instance.currentState,
          CompassState.trueNorthActive,
        );
      },
    );

    test('enableTrueNorth with deniedThisSession transitions to '
        'locationDeniedThisSession', () async {
      fakeAdapter.setCheck(LocationPermission.denied);
      fakeAdapter.setRequest(LocationPermission.denied);
      fakeAdapter.setServiceEnabled(true);

      await CompassService.instance.enableTrueNorth();

      expect(
        CompassService.instance.currentState,
        CompassState.locationDeniedThisSession,
      );
    });

    test('enableTrueNorth with deniedForever transitions to '
        'locationDeniedForever', () async {
      fakeAdapter.setCheck(LocationPermission.deniedForever);
      fakeAdapter.setServiceEnabled(true);

      await CompassService.instance.enableTrueNorth();

      expect(
        CompassService.instance.currentState,
        CompassState.locationDeniedForever,
      );
    });

    test('enableTrueNorth with service disabled transitions to '
        'locationServiceDisabled', () async {
      fakeAdapter.setServiceEnabled(false);

      await CompassService.instance.enableTrueNorth();

      expect(
        CompassService.instance.currentState,
        CompassState.locationServiceDisabled,
      );
    });

    test(
      'stopLocation reverts trueNorthActive to magneticNorthActive',
      () async {
        fakeAdapter.setCheck(LocationPermission.whileInUse);
        fakeAdapter.setServiceEnabled(true);
        await CompassService.instance.enableTrueNorth();

        expect(
          CompassService.instance.currentState,
          CompassState.trueNorthActive,
        );

        CompassService.instance.stopLocation();

        expect(
          CompassService.instance.currentState,
          CompassState.magneticNorthActive,
        );
      },
    );

    test('stop resets state to initializing', () async {
      fakeAdapter.setCheck(LocationPermission.whileInUse);
      fakeAdapter.setServiceEnabled(true);
      await CompassService.instance.enableTrueNorth();

      expect(
        CompassService.instance.currentState,
        CompassState.trueNorthActive,
      );

      CompassService.instance.stop();

      expect(CompassService.instance.currentState, CompassState.initializing);
    });
  });
}
