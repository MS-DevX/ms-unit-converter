import 'package:flutter/material.dart';

/// Screen size classes following Android Material 3 adaptive layout guidance.
enum ScreenSizeClass {
  /// Standard phones (< 600dp width).
  compact,

  /// Foldables open / small tablets (600dp – 840dp width).
  medium,

  /// Large tablets / desktops (>= 840dp width).
  expanded,
}

/// Helper class for responsive screen size detection and layout adaptation.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Returns the [ScreenSizeClass] for the given [BuildContext].
  static ScreenSizeClass sizeClassOf(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return ScreenSizeClass.compact;
    if (width < 840) return ScreenSizeClass.medium;
    return ScreenSizeClass.expanded;
  }

  /// Returns `true` if the current layout is Compact (phones in portrait).
  static bool isCompact(BuildContext context) {
    return sizeClassOf(context) == ScreenSizeClass.compact;
  }

  /// Returns `true` if the current layout is Medium or Expanded (foldables/tablets).
  static bool isExpanded(BuildContext context) {
    return sizeClassOf(context) != ScreenSizeClass.compact;
  }

  /// Returns optimal grid column count based on screen width.
  static int gridColumnCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }
}
