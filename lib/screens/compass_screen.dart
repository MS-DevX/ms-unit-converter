/// Compass screen — live magnetic compass with optional GPS coordinates.
///
/// Starts in pure magnetic mode **without** requesting location permission.
/// GPS / true north is only activated after the user taps the
/// *Enable True North / GPS Coordinates* button. Permission responses follow the
/// session-level denial rule: the system dialog is shown at most once per
/// session; subsequent taps produce an in-app message.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../services/compass_service.dart';
import '../widgets/compass_rose.dart';
import '../widgets/bubble_level_widget.dart';

/// Full-screen live compass.
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  StreamSubscription<double>? _headingSub;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<CompassState>? _stateSub;

  double _trueHeading = 0;
  String _directionLabel = 'North';
  String _latDMS = '--';
  String _lngDMS = '--';
  CompassState _compassState = CompassState.initializing;
  bool _gpsActive = false;
  bool _isBusy = false;
  bool _levelMode = false;

  @override
  void initState() {
    super.initState();
    _startMagneticCompass();
  }

  @override
  void dispose() {
    _cancelScreenSubs();
    CompassService.instance.stop();
    super.dispose();
  }

  /// Cancels all screen-level subscriptions to prevent duplicates.
  void _cancelScreenSubs() {
    _headingSub?.cancel();
    _headingSub = null;
    _positionSub?.cancel();
    _positionSub = null;
    _stateSub?.cancel();
    _stateSub = null;
  }

  /// Starts only the magnetic compass (accelerometer + magnetometer).
  /// Does **not** request location permission.
  void _startMagneticCompass() {
    final compass = CompassService.instance;

    // Cancel any previous screen subscriptions before re-subscribing
    _cancelScreenSubs();

    compass.start();

    _headingSub = compass.trueHeadingStream.listen((heading) {
      if (mounted) {
        setState(() {
          _trueHeading = heading;
          _directionLabel = directionLabel(heading);
        });
      }
    });

    _positionSub = compass.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _latDMS = toDMS(position.latitude, true);
          _lngDMS = toDMS(position.longitude, false);
        });
      }
    });

    _stateSub = compass.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _compassState = state;
          if (state == CompassState.trueNorthActive) {
            _gpsActive = true;
          } else if (state == CompassState.magneticNorthActive && _gpsActive) {
            // GPS was active but something stopped it (e.g. stopLocation)
            _gpsActive = false;
          }
        });
      }
    });
  }

  /// Called when the user taps *Enable True North / GPS Coordinates*.
  Future<void> _onEnableGps() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    final result = await CompassService.instance.enableTrueNorth();
    if (!mounted) return;

    setState(() => _isBusy = false);

    switch (result.state) {
      case LocationPermissionState.granted:
      // State stream handles _gpsActive update
      case LocationPermissionState.deniedForever:
        await Geolocator.openAppSettings();
      case LocationPermissionState.serviceDisabled:
        await Geolocator.openLocationSettings();
      default:
        break;
    }
  }

  /// Shows a calibration help bottom sheet.
  void _showCalibrationHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C2433),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.explore, color: Color(0xFF3B82F6)),
                    const SizedBox(width: 12),
                    Text(
                      'Calibration Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[100],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _calibrationTip(
                  Icons.rotate_right,
                  'Move your phone in a figure-eight motion — this helps the sensors recalibrate.',
                ),
                const SizedBox(height: 14),
                _calibrationTip(
                  Icons.sensors,
                  'Keep away from magnets, metal objects, and electronics.',
                ),
                const SizedBox(height: 14),
                _calibrationTip(
                  Icons.phone_iphone,
                  'Hold the phone flat and steady while using the compass.',
                ),
                const SizedBox(height: 14),
                _calibrationTip(
                  Icons.slow_motion_video,
                  'Rotate slowly — rapid movements may cause inaccurate readings.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Got it'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _calibrationTip(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF60A5FA)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[300],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _toggleMode() {
    HapticFeedback.lightImpact();
    if (_levelMode) {
      // Switching back to compass
      setState(() => _levelMode = false);
      _startMagneticCompass();
    } else {
      // Switching to level mode – stop compass to save battery
      _cancelScreenSubs();
      CompassService.instance.stop();
      setState(() => _levelMode = true);
    }
  }

  Future<void> _onRefresh() async {
    if (_levelMode) return;
    final compass = CompassService.instance;
    compass.stop();
    _gpsActive = false;
    _latDMS = '--';
    _lngDMS = '--';
    await Future.delayed(const Duration(milliseconds: 200));
    _startMagneticCompass();
  }

  /// Returns the button label for the current compass state.
  String _gpsButtonLabel() {
    if (_isBusy) return 'Requesting…';
    return switch (_compassState) {
      CompassState.locationDeniedForever => 'Open Settings',
      CompassState.locationServiceDisabled => 'Enable Location',
      _ => 'Enable True North / GPS Coordinates',
    };
  }

  @override
  Widget build(BuildContext context) {
    final showGpsButton = !_gpsActive;
    final showRetryButton =
        _compassState == CompassState.sensorsUnavailable ||
        _compassState == CompassState.error;

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          displacement: 60,
          color: const Color(0xFF3B82F6),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // ── Mode toggle ─────────────────────────────────
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _toggleMode,
                      icon: Icon(
                        _levelMode ? Icons.explore : Icons.straighten,
                        size: 18,
                      ),
                      label: Text(_levelMode ? 'Compass' : 'Level'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6B7280),
                        textStyle: const TextStyle(fontSize: 13),
                      ),
                    ),

                    if (_levelMode) ...[
                      // ── Bubble level takes remaining space ────────
                      Expanded(child: BubbleLevelWidget()),
                    ] else ...[
                      const Spacer(flex: 1),

                      // ── Direction name ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 4),
                        child: Text(
                          _directionLabel,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      // ── Status text ─────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          compassStateLabel(_compassState),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _statusColor(_compassState),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── Compass rose ────────────────────────────────
                      Expanded(
                        flex: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: CompassRose(
                            heading: _trueHeading,
                            isDark: true,
                          ),
                        ),
                      ),

                      const Spacer(flex: 1),

                      // ── GPS coordinates ─────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                          left: 32,
                          right: 32,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _CoordinateColumn(
                                label: 'Latitude',
                                value: _latDMS,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _CoordinateColumn(
                                label: 'Longitude',
                                value: _lngDMS,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ── Action buttons ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 12,
                          left: 32,
                          right: 32,
                        ),
                        child: Column(
                          children: [
                            // GPS enable / True North button
                            if (showGpsButton)
                              _actionButton(
                                onPressed: _isBusy ? null : _onEnableGps,
                                icon: _isBusy
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF3B82F6),
                                        ),
                                      )
                                    : const Icon(Icons.my_location, size: 20),
                                label: _gpsButtonLabel(),
                              ),

                            // Retry sensors button
                            if (showRetryButton)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _actionButton(
                                  onPressed: () {
                                    CompassService.instance.retrySensors();
                                  },
                                  icon: const Icon(Icons.refresh, size: 20),
                                  label: 'Retry sensors',
                                ),
                              ),

                            // Calibration help button
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _actionButton(
                                onPressed: _showCalibrationHelp,
                                icon: const Icon(Icons.info_outline, size: 20),
                                label: 'Calibration Help',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  Color _statusColor(CompassState state) {
    return switch (state) {
      CompassState.initializing => const Color(0xFF9CA3AF),
      CompassState.magneticNorthActive => const Color(0xFF10B981),
      CompassState.trueNorthActive => const Color(0xFF3B82F6),
      CompassState.sensorsUnavailable => const Color(0xFFEF4444),
      CompassState.locationPermissionNeeded => const Color(0xFFF59E0B),
      CompassState.locationDenied => const Color(0xFFEF4444),
      CompassState.locationDeniedThisSession => const Color(0xFFF59E0B),
      CompassState.locationDeniedForever => const Color(0xFFEF4444),
      CompassState.locationServiceDisabled => const Color(0xFFF59E0B),
      CompassState.calibrationRecommended => const Color(0xFFF59E0B),
      CompassState.error => const Color(0xFFEF4444),
    };
  }
}

class _CoordinateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _CoordinateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
