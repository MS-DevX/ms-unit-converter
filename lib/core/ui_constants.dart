/// UI constants and cosmic design system tokens for MS Unit Converter.
library;

import 'package:flutter/material.dart';
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

  /// Exact gradient color pairs per category.
  static const Map<UnitCategory, List<Color>> categoryGradients = {
    UnitCategory.length: [Color(0xFF667EEA), Color(0xFF764BA2)],
    UnitCategory.weight: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    UnitCategory.temperature: [Color(0xFFFA709A), Color(0xFFFEE140)],
    UnitCategory.area: [Color(0xFF30CFD0), Color(0xFF330867)],
    UnitCategory.volume: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
    UnitCategory.speed: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    UnitCategory.data: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
    UnitCategory.time: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    UnitCategory.angle: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    UnitCategory.energy: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.power: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.pressure: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    UnitCategory.force: [Color(0xFF84CC16), Color(0xFF4D7C0F)],
    UnitCategory.frequency: [Color(0xFFEC4899), Color(0xFF9D174D)],
    UnitCategory.fuelEconomy: [Color(0xFF22D3EE), Color(0xFF0E7490)],
    UnitCategory.cooking: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.shoeSize: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.clothingSize: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.numberBase: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.typography: [Color(0xFF6366F1), Color(0xFF4338CA)],
  };

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
