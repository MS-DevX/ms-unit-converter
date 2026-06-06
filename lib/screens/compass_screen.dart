/// Compass screen — pure live GPS-based true heading compass.
///
/// Displays a rotating dial compass with degree ticks, cardinal markers,
/// fixed red heading needle, centre heading value, and GPS coordinates
/// in DMS format. Pure live mode — no manual entry, no toggles.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/compass_service.dart';
import '../widgets/compass_rose.dart';

/// Full-screen live compass with GPS coordinates.
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  StreamSubscription<double>? _headingSub;
  StreamSubscription<Position>? _positionSub;

  double _trueHeading = 0;
  String _directionLabel = 'North';
  String _latDMS = '--';
  String _lngDMS = '--';

  @override
  void initState() {
    super.initState();
    _startServices();
  }

  @override
  void dispose() {
    _headingSub?.cancel();
    _positionSub?.cancel();
    CompassService.instance.stop();
    super.dispose();
  }

  void _startServices() {
    final compass = CompassService.instance;
    compass.start();

    _headingSub = compass.trueHeadingStream.listen((heading) {
      if (mounted) {
        setState(() {
          _trueHeading = heading;
          _directionLabel = _directionFromHeading(heading);
        });
      }
    });

    _positionSub = compass.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _latDMS = _toDMS(position.latitude, true);
          _lngDMS = _toDMS(position.longitude, false);
        });
      }
    });
  }

  /// Returns the 8-point compass label for a given heading (0–360).
  String _directionFromHeading(double h) {
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
  String _toDMS(double decimal, bool isLat) {
    final dir = isLat
        ? (decimal >= 0 ? 'N' : 'S')
        : (decimal >= 0 ? 'E' : 'W');
    decimal = decimal.abs();
    final d = decimal.floor();
    final m = ((decimal - d) * 60).floor();
    final s = (decimal - d - m / 60.0) * 3600;
    return '$d°$m\'${s.toStringAsFixed(1)}" $dir';
  }

  Future<void> _onRefresh() async {
    final compass = CompassService.instance;
    compass.stop();
    await Future.delayed(const Duration(milliseconds: 200));
    _startServices();
  }

  @override
  Widget build(BuildContext context) {
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
                    const Spacer(flex: 1),

                    // ── Direction name ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 8),
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
                        bottom: 40,
                        left: 32,
                        right: 32,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _CoordinateColumn(
                              label: 'North latitude',
                              value: _latDMS,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: _CoordinateColumn(
                              label: 'East longitude',
                              value: _lngDMS,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
