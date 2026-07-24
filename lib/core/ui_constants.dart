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
    // ── Core ──────────────────────────────────────────────────────
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
    // ── Electrical ──────────────────────────────────────────────────
    UnitCategory.voltage: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    UnitCategory.current: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    UnitCategory.resistance: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    UnitCategory.capacitance: [Color(0xFF34D399), Color(0xFF059669)],
    UnitCategory.inductance: [Color(0xFFF472B6), Color(0xFFDB2777)],
    UnitCategory.electricCharge: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    UnitCategory.conductance: [Color(0xFF4ADE80), Color(0xFF16A34A)],
    // ── Light ────────────────────────────────────────────────────────
    UnitCategory.illuminance: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
    UnitCategory.luminousFlux: [Color(0xFFFEF08A), Color(0xFFEAB308)],
    UnitCategory.luminousIntensity: [Color(0xFFFCD34D), Color(0xFFD97706)],
    UnitCategory.luminance: [Color(0xFFFEF3C7), Color(0xFFF59E0B)],
    // ── Heat ─────────────────────────────────────────────────────────
    UnitCategory.specificHeat: [Color(0xFFFDA4AF), Color(0xFFE11D48)],
    UnitCategory.thermalConductivity: [Color(0xFFFB923C), Color(0xFFEA580C)],
    UnitCategory.thermalResistance: [Color(0xFFBEF264), Color(0xFF65A30D)],
    UnitCategory.heatFluxDensity: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
    // ── Physics ──────────────────────────────────────────────────────
    UnitCategory.torque: [Color(0xFF94A3B8), Color(0xFF475569)],
    UnitCategory.momentum: [Color(0xFF7DD3FC), Color(0xFF0284C7)],
    UnitCategory.angularVelocity: [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
    UnitCategory.density: [Color(0xFF6EE7B7), Color(0xFF059669)],
    UnitCategory.surfaceTension: [Color(0xFF93C5FD), Color(0xFF1D4ED8)],
    UnitCategory.kinematicViscosity: [Color(0xFF67E8F9), Color(0xFF0891B2)],
    UnitCategory.dynamicViscosity: [Color(0xFF86EFAC), Color(0xFF15803D)],
    UnitCategory.acceleration: [Color(0xFFFDA4AF), Color(0xFFBE123C)],
    // ── Engineering ──────────────────────────────────────────────────
    UnitCategory.flowRate: [Color(0xFF7DD3FC), Color(0xFF0369A1)],
    UnitCategory.massFlowRate: [Color(0xFFA5F3FC), Color(0xFF0E7490)],
    // ── Radiation ────────────────────────────────────────────────────
    UnitCategory.radioactivity: [Color(0xFFFDE047), Color(0xFFCA8A04)],
    UnitCategory.radiationDose: [Color(0xFFFCA5A5), Color(0xFF991B1B)],
    UnitCategory.radiationExposure: [Color(0xFFFBBF24), Color(0xFF92400E)],
    // ── Astronomy ────────────────────────────────────────────────────
    UnitCategory.astronomicalLength: [Color(0xFF818CF8), Color(0xFF1E1B4B)],
    // ── Lifestyle ────────────────────────────────────────────────────
    UnitCategory.pace: [Color(0xFF6EE7B7), Color(0xFF047857)],
    UnitCategory.heartRate: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
    UnitCategory.bloodSugar: [Color(0xFFFDA4AF), Color(0xFFBE185D)],
    UnitCategory.bloodPressure: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    UnitCategory.bmi: [Color(0xFF74B9FF), Color(0xFF0984E3)],
    // ── Finance ──────────────────────────────────────────────────────
    UnitCategory.percentageRatio: [Color(0xFF55EFC4), Color(0xFF00B894)],
    // ── Sound ────────────────────────────────────────────────────────
    UnitCategory.soundLevel: [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    // ── Concentration ────────────────────────────────────────────────
    UnitCategory.concentration: [Color(0xFF81ECEC), Color(0xFF00CEC9)],
    // ── Magnetic ─────────────────────────────────────────────────────
    UnitCategory.magneticField: [Color(0xFFAA00FF), Color(0xFF6200EA)],
    UnitCategory.magneticFlux: [Color(0xFFE040FB), Color(0xFF9C27B0)],
    // ── Spectroscopy ─────────────────────────────────────────────────
    UnitCategory.wavenumber: [Color(0xFF26C6DA), Color(0xFF00838F)],
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
