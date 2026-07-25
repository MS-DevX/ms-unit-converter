/// Single source of truth for per-category metadata.
///
/// [ConverterConfig] replaces the scattered switch statements across
/// home_screen.dart and ui_constants.dart with a single, easily
/// extendable registry. Adding a new converter category only requires
/// one new entry in [converterRegistry].
library;

import 'package:flutter/material.dart';
import 'units_data.dart';

/// Immutable configuration bundle for a single converter category.
@immutable
class ConverterConfig {
  /// The [UnitCategory] this config describes.
  final UnitCategory category;

  /// Icon displayed in category cards and chips.
  final IconData icon;

  /// Two-stop gradient used for card backgrounds.
  final List<Color> gradient;

  /// Short group label used in collection chips (e.g. "Science", "Everyday").
  final String group;

  const ConverterConfig({
    required this.category,
    required this.icon,
    required this.gradient,
    required this.group,
  });

  /// Human-readable display name delegated to [UnitCategory.displayName].
  String get displayName => category.displayName;

  /// Description delegated to [UnitCategory.description].
  String get description => category.description;

  /// Primary gradient color (start).
  Color get primaryColor => gradient.first;

  /// Secondary gradient color (end).
  Color get secondaryColor => gradient.last;
}

// ─────────────────────────────────────────────────────────────────────────────
// REGISTRY
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable map from every [UnitCategory] to its [ConverterConfig].
///
/// This is the single source of truth for category metadata (icon, gradient,
/// group). Use [converterRegistry] everywhere instead of switch statements.
const Map<UnitCategory, ConverterConfig> converterRegistry = {
  // ── Core / Everyday ──────────────────────────────────────────────────────
  UnitCategory.length: ConverterConfig(
    category: UnitCategory.length,
    icon: Icons.straighten_rounded,
    gradient: [Color(0xFF667EEA), Color(0xFF764BA2)],
    group: 'Everyday',
  ),
  UnitCategory.weight: ConverterConfig(
    category: UnitCategory.weight,
    icon: Icons.monitor_weight_rounded,
    gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    group: 'Everyday',
  ),
  UnitCategory.temperature: ConverterConfig(
    category: UnitCategory.temperature,
    icon: Icons.thermostat_rounded,
    gradient: [Color(0xFFFA709A), Color(0xFFFEE140)],
    group: 'Everyday',
  ),
  UnitCategory.area: ConverterConfig(
    category: UnitCategory.area,
    icon: Icons.area_chart_rounded,
    gradient: [Color(0xFF30CFD0), Color(0xFF330867)],
    group: 'Everyday',
  ),
  UnitCategory.volume: ConverterConfig(
    category: UnitCategory.volume,
    icon: Icons.opacity_rounded,
    gradient: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
    group: 'Everyday',
  ),
  UnitCategory.speed: ConverterConfig(
    category: UnitCategory.speed,
    icon: Icons.speed_rounded,
    gradient: [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    group: 'Everyday',
  ),
  UnitCategory.time: ConverterConfig(
    category: UnitCategory.time,
    icon: Icons.schedule_rounded,
    gradient: [Color(0xFF84FAB0), Color(0xFF8FD3F4)],
    group: 'Everyday',
  ),
  UnitCategory.data: ConverterConfig(
    category: UnitCategory.data,
    icon: Icons.sd_card_rounded,
    gradient: [Color(0xFFFFECD2), Color(0xFFFCB69F)],
    group: 'Technology',
  ),
  // ── Science & Engineering ────────────────────────────────────────────────
  UnitCategory.angle: ConverterConfig(
    category: UnitCategory.angle,
    icon: Icons.explore_rounded,
    gradient: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    group: 'Science',
  ),
  UnitCategory.energy: ConverterConfig(
    category: UnitCategory.energy,
    icon: Icons.bolt_rounded,
    gradient: [Color(0xFFF97316), Color(0xFFC2410C)],
    group: 'Engineering',
  ),
  UnitCategory.power: ConverterConfig(
    category: UnitCategory.power,
    icon: Icons.electric_bolt_rounded,
    gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    group: 'Engineering',
  ),
  UnitCategory.pressure: ConverterConfig(
    category: UnitCategory.pressure,
    icon: Icons.compress_rounded,
    gradient: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    group: 'Engineering',
  ),
  UnitCategory.force: ConverterConfig(
    category: UnitCategory.force,
    icon: Icons.fitness_center_rounded,
    gradient: [Color(0xFF84CC16), Color(0xFF4D7C0F)],
    group: 'Engineering',
  ),
  UnitCategory.frequency: ConverterConfig(
    category: UnitCategory.frequency,
    icon: Icons.graphic_eq_rounded,
    gradient: [Color(0xFFEC4899), Color(0xFF9D174D)],
    group: 'Science',
  ),
  // ── Lifestyle ────────────────────────────────────────────────────────────
  UnitCategory.fuelEconomy: ConverterConfig(
    category: UnitCategory.fuelEconomy,
    icon: Icons.local_gas_station_rounded,
    gradient: [Color(0xFF22D3EE), Color(0xFF0E7490)],
    group: 'Travel',
  ),
  UnitCategory.cooking: ConverterConfig(
    category: UnitCategory.cooking,
    icon: Icons.soup_kitchen_rounded,
    gradient: [Color(0xFFF97316), Color(0xFFC2410C)],
    group: 'Cooking',
  ),
  UnitCategory.shoeSize: ConverterConfig(
    category: UnitCategory.shoeSize,
    icon: Icons.roller_skating_rounded,
    gradient: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    group: 'Lifestyle',
  ),
  UnitCategory.clothingSize: ConverterConfig(
    category: UnitCategory.clothingSize,
    icon: Icons.checkroom_rounded,
    gradient: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    group: 'Lifestyle',
  ),
  // ── Technology ───────────────────────────────────────────────────────────
  UnitCategory.numberBase: ConverterConfig(
    category: UnitCategory.numberBase,
    icon: Icons.numbers_rounded,
    gradient: [Color(0xFF10B981), Color(0xFF047857)],
    group: 'Technology',
  ),
  UnitCategory.typography: ConverterConfig(
    category: UnitCategory.typography,
    icon: Icons.text_fields_rounded,
    gradient: [Color(0xFF6366F1), Color(0xFF4338CA)],
    group: 'Technology',
  ),
  // ── Electrical ───────────────────────────────────────────────────────────
  UnitCategory.voltage: ConverterConfig(
    category: UnitCategory.voltage,
    icon: Icons.electrical_services_rounded,
    gradient: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
    group: 'Electrical',
  ),
  UnitCategory.current: ConverterConfig(
    category: UnitCategory.current,
    icon: Icons.power_rounded,
    gradient: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    group: 'Electrical',
  ),
  UnitCategory.resistance: ConverterConfig(
    category: UnitCategory.resistance,
    icon: Icons.waves_rounded,
    gradient: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
    group: 'Electrical',
  ),
  UnitCategory.capacitance: ConverterConfig(
    category: UnitCategory.capacitance,
    icon: Icons.battery_charging_full_rounded,
    gradient: [Color(0xFF34D399), Color(0xFF059669)],
    group: 'Electrical',
  ),
  UnitCategory.inductance: ConverterConfig(
    category: UnitCategory.inductance,
    icon: Icons.loop_rounded,
    gradient: [Color(0xFFF472B6), Color(0xFFDB2777)],
    group: 'Electrical',
  ),
  UnitCategory.electricCharge: ConverterConfig(
    category: UnitCategory.electricCharge,
    icon: Icons.battery_full_rounded,
    gradient: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    group: 'Electrical',
  ),
  UnitCategory.conductance: ConverterConfig(
    category: UnitCategory.conductance,
    icon: Icons.link_rounded,
    gradient: [Color(0xFF4ADE80), Color(0xFF16A34A)],
    group: 'Electrical',
  ),
  // ── Light ────────────────────────────────────────────────────────────────
  UnitCategory.illuminance: ConverterConfig(
    category: UnitCategory.illuminance,
    icon: Icons.wb_sunny_rounded,
    gradient: [Color(0xFFFDE68A), Color(0xFFF59E0B)],
    group: 'Science',
  ),
  UnitCategory.luminousFlux: ConverterConfig(
    category: UnitCategory.luminousFlux,
    icon: Icons.lightbulb_rounded,
    gradient: [Color(0xFFFEF08A), Color(0xFFEAB308)],
    group: 'Science',
  ),
  UnitCategory.luminousIntensity: ConverterConfig(
    category: UnitCategory.luminousIntensity,
    icon: Icons.flashlight_on_rounded,
    gradient: [Color(0xFFFCD34D), Color(0xFFD97706)],
    group: 'Science',
  ),
  UnitCategory.luminance: ConverterConfig(
    category: UnitCategory.luminance,
    icon: Icons.brightness_high_rounded,
    gradient: [Color(0xFFFEF3C7), Color(0xFFF59E0B)],
    group: 'Science',
  ),
  // ── Heat ─────────────────────────────────────────────────────────────────
  UnitCategory.specificHeat: ConverterConfig(
    category: UnitCategory.specificHeat,
    icon: Icons.whatshot_rounded,
    gradient: [Color(0xFFFDA4AF), Color(0xFFE11D48)],
    group: 'Science',
  ),
  UnitCategory.thermalConductivity: ConverterConfig(
    category: UnitCategory.thermalConductivity,
    icon: Icons.device_thermostat_rounded,
    gradient: [Color(0xFFFB923C), Color(0xFFEA580C)],
    group: 'Engineering',
  ),
  UnitCategory.thermalResistance: ConverterConfig(
    category: UnitCategory.thermalResistance,
    icon: Icons.house_rounded,
    gradient: [Color(0xFFBEF264), Color(0xFF65A30D)],
    group: 'Engineering',
  ),
  UnitCategory.heatFluxDensity: ConverterConfig(
    category: UnitCategory.heatFluxDensity,
    icon: Icons.wb_incandescent_rounded,
    gradient: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
    group: 'Science',
  ),
  // ── Physics ──────────────────────────────────────────────────────────────
  UnitCategory.torque: ConverterConfig(
    category: UnitCategory.torque,
    icon: Icons.settings_rounded,
    gradient: [Color(0xFF94A3B8), Color(0xFF475569)],
    group: 'Engineering',
  ),
  UnitCategory.momentum: ConverterConfig(
    category: UnitCategory.momentum,
    icon: Icons.rocket_launch_rounded,
    gradient: [Color(0xFF7DD3FC), Color(0xFF0284C7)],
    group: 'Science',
  ),
  UnitCategory.angularVelocity: ConverterConfig(
    category: UnitCategory.angularVelocity,
    icon: Icons.rotate_right_rounded,
    gradient: [Color(0xFFC4B5FD), Color(0xFF7C3AED)],
    group: 'Science',
  ),
  UnitCategory.density: ConverterConfig(
    category: UnitCategory.density,
    icon: Icons.water_drop_rounded,
    gradient: [Color(0xFF6EE7B7), Color(0xFF059669)],
    group: 'Science',
  ),
  UnitCategory.surfaceTension: ConverterConfig(
    category: UnitCategory.surfaceTension,
    icon: Icons.bubble_chart_rounded,
    gradient: [Color(0xFF93C5FD), Color(0xFF1D4ED8)],
    group: 'Science',
  ),
  UnitCategory.kinematicViscosity: ConverterConfig(
    category: UnitCategory.kinematicViscosity,
    icon: Icons.oil_barrel_rounded,
    gradient: [Color(0xFF67E8F9), Color(0xFF0891B2)],
    group: 'Engineering',
  ),
  UnitCategory.dynamicViscosity: ConverterConfig(
    category: UnitCategory.dynamicViscosity,
    icon: Icons.invert_colors_rounded,
    gradient: [Color(0xFF86EFAC), Color(0xFF15803D)],
    group: 'Engineering',
  ),
  UnitCategory.acceleration: ConverterConfig(
    category: UnitCategory.acceleration,
    icon: Icons.electric_car_rounded,
    gradient: [Color(0xFFFDA4AF), Color(0xFFBE123C)],
    group: 'Science',
  ),
  // ── Engineering ──────────────────────────────────────────────────────────
  UnitCategory.flowRate: ConverterConfig(
    category: UnitCategory.flowRate,
    icon: Icons.water_rounded,
    gradient: [Color(0xFF7DD3FC), Color(0xFF0369A1)],
    group: 'Engineering',
  ),
  UnitCategory.massFlowRate: ConverterConfig(
    category: UnitCategory.massFlowRate,
    icon: Icons.air_rounded,
    gradient: [Color(0xFFA5F3FC), Color(0xFF0E7490)],
    group: 'Engineering',
  ),
  // ── Radiation ────────────────────────────────────────────────────────────
  UnitCategory.radioactivity: ConverterConfig(
    category: UnitCategory.radioactivity,
    icon: Icons.warning_amber_rounded,
    gradient: [Color(0xFFFDE047), Color(0xFFCA8A04)],
    group: 'Science',
  ),
  UnitCategory.radiationDose: ConverterConfig(
    category: UnitCategory.radiationDose,
    icon: Icons.health_and_safety_rounded,
    gradient: [Color(0xFFFCA5A5), Color(0xFF991B1B)],
    group: 'Science',
  ),
  UnitCategory.radiationExposure: ConverterConfig(
    category: UnitCategory.radiationExposure,
    icon: Icons.science_rounded,
    gradient: [Color(0xFFFBBF24), Color(0xFF92400E)],
    group: 'Science',
  ),
  // ── Astronomy ────────────────────────────────────────────────────────────
  UnitCategory.astronomicalLength: ConverterConfig(
    category: UnitCategory.astronomicalLength,
    icon: Icons.public_rounded,
    gradient: [Color(0xFF818CF8), Color(0xFF1E1B4B)],
    group: 'Science',
  ),
  // ── Lifestyle & Health ───────────────────────────────────────────────────
  UnitCategory.pace: ConverterConfig(
    category: UnitCategory.pace,
    icon: Icons.directions_run_rounded,
    gradient: [Color(0xFF6EE7B7), Color(0xFF047857)],
    group: 'Fitness',
  ),
  UnitCategory.heartRate: ConverterConfig(
    category: UnitCategory.heartRate,
    icon: Icons.favorite_rounded,
    gradient: [Color(0xFFFCA5A5), Color(0xFFDC2626)],
    group: 'Fitness',
  ),
  UnitCategory.bloodSugar: ConverterConfig(
    category: UnitCategory.bloodSugar,
    icon: Icons.bloodtype_rounded,
    gradient: [Color(0xFFFDA4AF), Color(0xFFBE185D)],
    group: 'Fitness',
  ),
  UnitCategory.bloodPressure: ConverterConfig(
    category: UnitCategory.bloodPressure,
    icon: Icons.monitor_heart_rounded,
    gradient: [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
    group: 'Fitness',
  ),
  UnitCategory.bmi: ConverterConfig(
    category: UnitCategory.bmi,
    icon: Icons.person_rounded,
    gradient: [Color(0xFF74B9FF), Color(0xFF0984E3)],
    group: 'Fitness',
  ),
  // ── Finance ──────────────────────────────────────────────────────────────
  UnitCategory.percentageRatio: ConverterConfig(
    category: UnitCategory.percentageRatio,
    icon: Icons.percent_rounded,
    gradient: [Color(0xFF55EFC4), Color(0xFF00B894)],
    group: 'Everyday',
  ),
  // ── Sound ────────────────────────────────────────────────────────────────
  UnitCategory.soundLevel: ConverterConfig(
    category: UnitCategory.soundLevel,
    icon: Icons.volume_up_rounded,
    gradient: [Color(0xFFA29BFE), Color(0xFF6C5CE7)],
    group: 'Science',
  ),
  // ── Concentration ────────────────────────────────────────────────────────
  UnitCategory.concentration: ConverterConfig(
    category: UnitCategory.concentration,
    icon: Icons.science_rounded,
    gradient: [Color(0xFF81ECEC), Color(0xFF00CEC9)],
    group: 'Science',
  ),
  // ── Magnetic ─────────────────────────────────────────────────────────────
  UnitCategory.magneticField: ConverterConfig(
    category: UnitCategory.magneticField,
    icon: Icons.radar_rounded,
    gradient: [Color(0xFFAA00FF), Color(0xFF6200EA)],
    group: 'Science',
  ),
  UnitCategory.magneticFlux: ConverterConfig(
    category: UnitCategory.magneticFlux,
    icon: Icons.blur_circular_rounded,
    gradient: [Color(0xFFE040FB), Color(0xFF9C27B0)],
    group: 'Science',
  ),
  // ── Spectroscopy ─────────────────────────────────────────────────────────
  UnitCategory.wavenumber: ConverterConfig(
    category: UnitCategory.wavenumber,
    icon: Icons.ssid_chart_rounded,
    gradient: [Color(0xFF26C6DA), Color(0xFF00838F)],
    group: 'Science',
  ),
};

/// Convenience accessor: returns the [ConverterConfig] for [category].
///
/// Returns a safe fallback (length) if somehow unregistered.
ConverterConfig configFor(UnitCategory category) {
  return converterRegistry[category] ?? converterRegistry[UnitCategory.length]!;
}
