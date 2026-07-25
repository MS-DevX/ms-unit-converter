/// Predefined curated collections of converter categories.
///
/// Collections are static — they ship with the app. Users can pin/unpin
/// them but cannot create or modify predefined collections.
/// Custom collections may be added in a future release.
library;

import 'package:flutter/foundation.dart';
import '../data/units_data.dart';

/// A curated group of converter categories.
@immutable
class Collection {
  /// Unique stable identifier (used for persistence).
  final String id;

  /// Human-readable display name.
  final String name;

  /// Emoji icon displayed in the collection chip.
  final String emoji;

  /// One-line description shown in the collection card.
  final String description;

  /// Ordered list of categories included in this collection.
  final List<UnitCategory> categories;

  const Collection({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.categories,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PREDEFINED COLLECTIONS
// ─────────────────────────────────────────────────────────────────────────────

/// All predefined collections shipped with the app.
const List<Collection> predefinedCollections = [
  Collection(
    id: 'everyday',
    name: 'Everyday',
    emoji: '🕌',
    description: 'The essentials for daily life',
    categories: [
      UnitCategory.length,
      UnitCategory.weight,
      UnitCategory.volume,
      UnitCategory.time,
      UnitCategory.temperature,
      UnitCategory.speed,
      UnitCategory.area,
      UnitCategory.percentageRatio,
    ],
  ),
  Collection(
    id: 'student',
    name: 'Student',
    emoji: '📚',
    description: 'Converters for science and math class',
    categories: [
      UnitCategory.length,
      UnitCategory.area,
      UnitCategory.volume,
      UnitCategory.time,
      UnitCategory.speed,
      UnitCategory.numberBase,
      UnitCategory.data,
      UnitCategory.temperature,
      UnitCategory.angle,
      UnitCategory.energy,
      UnitCategory.pressure,
      UnitCategory.force,
    ],
  ),
  Collection(
    id: 'developer',
    name: 'Developer',
    emoji: '👨‍💻',
    description: 'Data, typography, bases & more',
    categories: [
      UnitCategory.data,
      UnitCategory.typography,
      UnitCategory.numberBase,
      UnitCategory.frequency,
      UnitCategory.speed,
    ],
  ),
  Collection(
    id: 'engineering',
    name: 'Engineering',
    emoji: '👷',
    description: 'Professional engineering units',
    categories: [
      UnitCategory.length,
      UnitCategory.pressure,
      UnitCategory.force,
      UnitCategory.torque,
      UnitCategory.power,
      UnitCategory.energy,
      UnitCategory.flowRate,
      UnitCategory.density,
      UnitCategory.thermalConductivity,
      UnitCategory.kinematicViscosity,
      UnitCategory.dynamicViscosity,
      UnitCategory.massFlowRate,
      UnitCategory.acceleration,
    ],
  ),
  Collection(
    id: 'cooking',
    name: 'Cooking',
    emoji: '🍳',
    description: 'Kitchen measurements made easy',
    categories: [
      UnitCategory.volume,
      UnitCategory.weight,
      UnitCategory.temperature,
      UnitCategory.cooking,
    ],
  ),
  Collection(
    id: 'travel',
    name: 'Travel',
    emoji: '✈️',
    description: 'Everything you need when abroad',
    categories: [
      UnitCategory.length,
      UnitCategory.temperature,
      UnitCategory.speed,
      UnitCategory.fuelEconomy,
      UnitCategory.weight,
      UnitCategory.volume,
    ],
  ),
  Collection(
    id: 'fitness',
    name: 'Fitness',
    emoji: '🏋️',
    description: 'Health and fitness tracking',
    categories: [
      UnitCategory.weight,
      UnitCategory.bmi,
      UnitCategory.pace,
      UnitCategory.heartRate,
      UnitCategory.bloodSugar,
      UnitCategory.bloodPressure,
      UnitCategory.length,
    ],
  ),
  Collection(
    id: 'science',
    name: 'Science',
    emoji: '🔬',
    description: 'Physics, chemistry and more',
    categories: [
      UnitCategory.energy,
      UnitCategory.frequency,
      UnitCategory.radioactivity,
      UnitCategory.radiationDose,
      UnitCategory.concentration,
      UnitCategory.magneticField,
      UnitCategory.magneticFlux,
      UnitCategory.density,
      UnitCategory.momentum,
      UnitCategory.angularVelocity,
      UnitCategory.acceleration,
      UnitCategory.surfaceTension,
      UnitCategory.wavenumber,
      UnitCategory.astronomicalLength,
    ],
  ),
  Collection(
    id: 'electrical',
    name: 'Electrical',
    emoji: '⚡',
    description: 'Circuits, signals & electromagnetism',
    categories: [
      UnitCategory.voltage,
      UnitCategory.current,
      UnitCategory.resistance,
      UnitCategory.capacitance,
      UnitCategory.inductance,
      UnitCategory.electricCharge,
      UnitCategory.conductance,
      UnitCategory.power,
      UnitCategory.frequency,
    ],
  ),
];
