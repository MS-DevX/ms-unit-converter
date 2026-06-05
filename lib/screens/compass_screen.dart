/// Compass screen — live device heading with manual angle entry.
///
/// On open: sensors activate, arrow follows device direction in real-time.
/// User taps rose / types angle / taps chip: pauses live mode, locks to manual.
/// "↺ Live" button resumes sensor tracking.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../services/compass_service.dart';
import '../widgets/compass_rose.dart';

/// Full-screen compass showing live heading with manual override.
class CompassScreen extends StatefulWidget {
  const CompassScreen({super.key});

  @override
  State<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends State<CompassScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  StreamSubscription<double>? _headingSub;
  StreamSubscription<bool>? _liveSub;

  double? _liveHeading;
  double? _manualHeading;
  bool _isLive = true;
  String _selectedLabel = 'N';

  @override
  void initState() {
    super.initState();
    _startSensors();
  }

  @override
  void dispose() {
    _headingSub?.cancel();
    _liveSub?.cancel();
    CompassService.instance.stop();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _startSensors() {
    final compass = CompassService.instance;
    compass.start();

    _headingSub = compass.headingStream.listen((heading) {
      if (_isLive && mounted) {
        setState(() {
          _liveHeading = heading;
          _selectedLabel = nearestCompassPoint(heading).label;
        });
      }
    });

    _liveSub = compass.liveStatusStream.listen((_) {});
  }

  void _setManualDirection(double bearingDeg, {bool updateInput = true}) {
    var bearing = bearingDeg % 360;
    if (bearing < 0) bearing += 360;

    setState(() {
      _isLive = false;
      _manualHeading = bearing;
      _liveHeading = bearing;
      _selectedLabel = nearestCompassPoint(bearing).label;
    });

    if (updateInput) {
      final intStr = bearing.roundToDouble() == bearing
          ? bearing.toInt().toString()
          : bearing.toStringAsFixed(1);
      _inputController.text = intStr;
      _inputFocusNode.unfocus();
    }

    HapticFeedback.selectionClick();
  }

  void _onInputChanged(String value) {
    if (value.isEmpty) {
      setState(() {
        _isLive = false;
        _manualHeading = null;
        _liveHeading = null;
        _selectedLabel = 'N';
      });
      return;
    }

    final parsed = double.tryParse(value);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) return;
    if (parsed < 0 || parsed > 360) return;

    _setManualDirection(parsed, updateInput: false);
  }

  Future<void> _resumeLive() async {
    setState(() {
      _isLive = true;
      _manualHeading = null;
    });
    _inputController.clear();
    _inputFocusNode.unfocus();
    HapticFeedback.lightImpact();
    // Small settle delay for sensors to stabiliSe after pause.
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void _onTapChip(String label) {
    final point = compassPoints.firstWhere((p) => p.label == label);
    _setManualDirection(point.bearing);
  }

  Future<void> _onRefresh() async {
    await _resumeLive();
    // Give sensors a moment to produce a fresh reading.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayHeading = _isLive
        ? _liveHeading
        : _manualHeading;

    final displayLabel = displayHeading != null
        ? '$_selectedLabel · ${displayHeading.roundToDouble() == displayHeading ? displayHeading.toInt().toString() : displayHeading.toStringAsFixed(1)}°'
        : 'N · 0°';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compass',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
        actions: [
          if (!_isLive && _manualHeading != null)
            TextButton.icon(
              onPressed: _resumeLive,
              icon: const Icon(Icons.my_location_rounded, size: 18),
              label: const Text('Live'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        displacement: 60,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.85,
                    colors: isDark
                        ? [
                            const Color(0xFF0F1A2E),
                            const Color(0xFF080E14),
                          ]
                        : [
                            const Color(0xFFF0F4FF),
                            const Color(0xFFE8ECF1),
                          ],
                    stops: const [0.3, 1.0],
                  ),
                ),
                child: Column(
                  children: [
                    // ── Compass rose ─────────────────────────────────
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: CompassRose(
                          heading: displayHeading,
                          selectedLabel: _isLive || _manualHeading != null
                              ? _selectedLabel
                              : null,
                          isLive: _isLive,
                          onBearingSelected: (bearing) =>
                              _setManualDirection(bearing),
                        ),
                      ),
                    ),

                    // ── Direction display ────────────────────────────
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: Column(
                        key: ValueKey(displayLabel),
                        children: [
                          Text(
                            _selectedLabel,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: _isLive
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary),
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _roundBearing(displayHeading ?? 0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Angle input ──────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: TextField(
                        controller: _inputController,
                        focusNode: _inputFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        onChanged: _onInputChanged,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter bearing (0–360)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary)
                                .withValues(alpha: 0.4),
                          ),
                          suffixText: '°',
                          suffixStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary)
                                .withValues(alpha: 0.5),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Quick direction chips ────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          _Chip('N', isDark, _selectedLabel, () => _onTapChip('N')),
                          _Chip('NE', isDark, _selectedLabel, () => _onTapChip('NE')),
                          _Chip('E', isDark, _selectedLabel, () => _onTapChip('E')),
                          _Chip('SE', isDark, _selectedLabel, () => _onTapChip('SE')),
                          _Chip('S', isDark, _selectedLabel, () => _onTapChip('S')),
                          _Chip('SW', isDark, _selectedLabel, () => _onTapChip('SW')),
                          _Chip('W', isDark, _selectedLabel, () => _onTapChip('W')),
                          _Chip('NW', isDark, _selectedLabel, () => _onTapChip('NW')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roundBearing(double bearing) {
    final rounded = bearing.roundToDouble() == bearing
        ? bearing.toInt()
        : bearing.toStringAsFixed(1);
    return '$rounded°';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isDark;
  final String selected;
  final VoidCallback onTap;

  const _Chip(this.label, this.isDark, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = label == selected;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
