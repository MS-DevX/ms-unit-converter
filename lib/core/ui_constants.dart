/// UI constants and cosmic design system tokens for MS Unit Converter.
library;

import 'package:flutter/material.dart';
import '../data/converter_config.dart';
import '../data/units_data.dart';

/// Central design tokens for Cosmic Theme & Glassmorphic styling.
class CosmicUIConstants {
  CosmicUIConstants._();

  /// Storage key for cosmic theme preference.
  static const String cosmicThemeStorageKey = 'is_cosmic_theme_enabled';

  /// Glassmorphic backdrop blur strength in pixels.
  static const double glassBlur = 10.0;

  /// Glass container border width.
  static const double glassBorderWidth = 1.2;

  /// Standard card border radius.
  static const double cardBorderRadius = 18.0;

  /// Returns exact gradient color pairs per category from [converterRegistry].
  static List<Color> getGradient(UnitCategory category) {
    return configFor(category).gradient;
  }

  /// Backward-compatible map accessor for category gradients.
  static Map<UnitCategory, List<Color>> get categoryGradients =>
      converterRegistry.map((key, config) => MapEntry(key, config.gradient));

  /// Deep cosmic dark background.
  static const Color cosmicBackground = Color(0xFF070B14);

  /// Cosmic card surface color with high glass transparency.
  static const Color cosmicCardSurface = Color(0x1F1E293B);

  /// Cosmic border color with translucent cyan glow.
  static const Color cosmicBorder = Color(0x3360A5FA);

  /// Glowing cyan accent color.
  static const Color cosmicCyanGlow = Color(0xFF38BDF8);

  /// Glowing purple accent color.
  static const Color cosmicPurpleGlow = Color(0xFFA855F7);
}
