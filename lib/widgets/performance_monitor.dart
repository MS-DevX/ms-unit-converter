/// Performance monitor widget for tracking FPS and frame rendering times (<16ms target).
library;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/colors.dart';

/// Overlay widget that monitors live frame rendering times and calculates FPS.
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final List<Duration> _frameTimes = [];
  double _fps = 60.0;
  double _lastFrameMs = 16.6;
  int _frameCount = 0;
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      SchedulerBinding.instance.addTimingsCallback(_onReportTimings);
    }
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onReportTimings);
    super.dispose();
  }

  void _onReportTimings(List<FrameTiming> timings) {
    if (!mounted || !widget.enabled) return;

    for (final timing in timings) {
      final totalDuration = timing.totalSpan;
      _frameTimes.add(totalDuration);
      _frameCount++;
    }

    // Retain last 30 frames
    if (_frameTimes.length > 30) {
      _frameTimes.removeRange(0, _frameTimes.length - 30);
    }

    final now = DateTime.now();
    final elapsed = now.difference(_lastTime).inMilliseconds;

    if (elapsed >= 500 && _frameCount > 0) {
      final avgMs = _frameTimes.map((d) => d.inMicroseconds / 1000.0).reduce((a, b) => a + b) / _frameTimes.length;
      final calculatedFps = (_frameCount * 1000.0) / elapsed;

      setState(() {
        _lastFrameMs = avgMs;
        _fps = calculatedFps.clamp(0.0, 120.0);
        _frameCount = 0;
        _lastTime = now;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final isOptimal = _fps >= 55.0 && _lastFrameMs <= 16.6;

    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isOptimal ? AppColors.success : AppColors.error,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isOptimal ? AppColors.success : AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_fps.toStringAsFixed(0)} FPS (${_lastFrameMs.toStringAsFixed(1)}ms)',
                      style: TextStyle(
                        color: isOptimal ? AppColors.success : AppColors.error,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
