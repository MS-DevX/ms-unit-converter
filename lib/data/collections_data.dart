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
  Collection(
    id: 'photometry',
    name: 'Photometry',
    emoji: '💡',
    description: 'Light, flux, illuminance & luminance',
    categories: [
      UnitCategory.illuminance,
      UnitCategory.luminousFlux,
      UnitCategory.luminousIntensity,
      UnitCategory.luminance,
    ],
  ),
  Collection(
    id: 'thermodynamics',
    name: 'Thermodynamics',
    emoji: '🌡️',
    description: 'Heat capacity, thermal conduction & resistance',
    categories: [
      UnitCategory.temperature,
      UnitCategory.specificHeat,
      UnitCategory.thermalConductivity,
      UnitCategory.thermalResistance,
      UnitCategory.heatFluxDensity,
      UnitCategory.energy,
    ],
  ),
  Collection(
    id: 'fluid_dynamics',
    name: 'Fluid Dynamics',
    emoji: '💧',
    description: 'Flow rates, viscosity & fluid mechanics',
    categories: [
      UnitCategory.flowRate,
      UnitCategory.massFlowRate,
      UnitCategory.kinematicViscosity,
      UnitCategory.dynamicViscosity,
      UnitCategory.surfaceTension,
      UnitCategory.density,
      UnitCategory.pressure,
      UnitCategory.volume,
    ],
  ),
  Collection(
    id: 'apparel',
    name: 'Apparel & Sizes',
    emoji: '👔',
    description: 'International clothing & shoe standards',
    categories: [
      UnitCategory.shoeSize,
      UnitCategory.clothingSize,
      UnitCategory.length,
    ],
  ),
  Collection(
    id: 'automotive',
    name: 'Automotive',
    emoji: '🏎️',
    description: 'Power, torque, speed & fuel efficiency',
    categories: [
      UnitCategory.speed,
      UnitCategory.fuelEconomy,
      UnitCategory.torque,
      UnitCategory.power,
      UnitCategory.acceleration,
      UnitCategory.pressure,
    ],
  ),
  Collection(
    id: 'acoustics',
    name: 'Acoustics & Waves',
    emoji: '🔊',
    description: 'Sound levels, frequencies & wave optics',
    categories: [
      UnitCategory.soundLevel,
      UnitCategory.frequency,
      UnitCategory.wavenumber,
      UnitCategory.time,
    ],
  ),
  Collection(
    id: 'medical',
    name: 'Clinical & Health',
    emoji: '🩺',
    description: 'Vitals, blood markers & medical dosimetry',
    categories: [
      UnitCategory.bloodPressure,
      UnitCategory.bloodSugar,
      UnitCategory.heartRate,
      UnitCategory.bmi,
      UnitCategory.weight,
      UnitCategory.radiationDose,
      UnitCategory.concentration,
    ],
  ),
  Collection(
    id: 'astronomy',
    name: 'Astronomy & Cosmos',
    emoji: '🌌',
    description: 'Interstellar distances & cosmic metrics',
    categories: [
      UnitCategory.astronomicalLength,
      UnitCategory.length,
      UnitCategory.time,
      UnitCategory.speed,
      UnitCategory.angle,
    ],
  ),
  Collection(
    id: 'nuclear',
    name: 'Nuclear Physics',
    emoji: '☢️',
    description: 'Decay, absorption & radiation exposure',
    categories: [
      UnitCategory.radioactivity,
      UnitCategory.radiationDose,
      UnitCategory.radiationExposure,
      UnitCategory.energy,
      UnitCategory.concentration,
    ],
  ),
  Collection(
    id: 'construction',
    name: 'Construction',
    emoji: '🏗️',
    description: 'Building, masonry & structural metrics',
    categories: [
      UnitCategory.length,
      UnitCategory.area,
      UnitCategory.volume,
      UnitCategory.weight,
      UnitCategory.pressure,
      UnitCategory.angle,
    ],
  ),
  Collection(
    id: 'aviation',
    name: 'Aviation & Flight',
    emoji: '✈️',
    description: 'Airspeed, altitude, pressure & navigation',
    categories: [
      UnitCategory.speed,
      UnitCategory.length,
      UnitCategory.astronomicalLength,
      UnitCategory.pressure,
      UnitCategory.temperature,
      UnitCategory.fuelEconomy,
    ],
  ),
  Collection(
    id: 'chemistry',
    name: 'Chemistry & Lab',
    emoji: '🧪',
    description: 'Solutions, concentrations & stoichiometry',
    categories: [
      UnitCategory.concentration,
      UnitCategory.density,
      UnitCategory.volume,
      UnitCategory.weight,
      UnitCategory.temperature,
      UnitCategory.specificHeat,
    ],
  ),
  Collection(
    id: 'maritime',
    name: 'Maritime & Sailing',
    emoji: '⚓',
    description: 'Knots, nautical miles & marine pressure',
    categories: [
      UnitCategory.speed,
      UnitCategory.length,
      UnitCategory.volume,
      UnitCategory.pressure,
      UnitCategory.time,
      UnitCategory.angle,
    ],
  ),
  Collection(
    id: 'hvac',
    name: 'HVAC & Climate',
    emoji: '❄️',
    description: 'Heating, ventilation, thermal flux & airflow',
    categories: [
      UnitCategory.temperature,
      UnitCategory.heatFluxDensity,
      UnitCategory.thermalConductivity,
      UnitCategory.thermalResistance,
      UnitCategory.flowRate,
      UnitCategory.pressure,
    ],
  ),
  Collection(
    id: 'baking',
    name: 'Baking & Pastry',
    emoji: '🥐',
    description: 'Exact flour weight, liquid volume & oven temps',
    categories: [
      UnitCategory.weight,
      UnitCategory.volume,
      UnitCategory.temperature,
      UnitCategory.cooking,
      UnitCategory.percentageRatio,
    ],
  ),
  Collection(
    id: 'meteorology',
    name: 'Weather & Climate',
    emoji: '🌩️',
    description: 'Barometric pressure, winds & temp scales',
    categories: [
      UnitCategory.temperature,
      UnitCategory.pressure,
      UnitCategory.speed,
      UnitCategory.illuminance,
      UnitCategory.surfaceTension,
    ],
  ),
  Collection(
    id: 'athletics',
    name: 'Track & Running',
    emoji: '🏃',
    description: 'Pace, distance, heart rate & interval timing',
    categories: [
      UnitCategory.pace,
      UnitCategory.speed,
      UnitCategory.length,
      UnitCategory.heartRate,
      UnitCategory.time,
      UnitCategory.bmi,
    ],
  ),
  Collection(
    id: 'mechanics',
    name: 'Classical Mechanics',
    emoji: '⚙️',
    description: 'Torque, momentum, force & acceleration',
    categories: [
      UnitCategory.force,
      UnitCategory.torque,
      UnitCategory.momentum,
      UnitCategory.acceleration,
      UnitCategory.angularVelocity,
      UnitCategory.massFlowRate,
    ],
  ),
  Collection(
    id: 'electronics',
    name: 'DIY Electronics',
    emoji: '🔌',
    description: 'Resistors, capacitors, volts & frequency',
    categories: [
      UnitCategory.voltage,
      UnitCategory.current,
      UnitCategory.resistance,
      UnitCategory.capacitance,
      UnitCategory.inductance,
      UnitCategory.frequency,
      UnitCategory.power,
    ],
  ),
  Collection(
    id: 'typography_design',
    name: 'Design & UI',
    emoji: '🎨',
    description: 'Points, pixels, rems & digital storage',
    categories: [
      UnitCategory.typography,
      UnitCategory.data,
      UnitCategory.length,
      UnitCategory.percentageRatio,
    ],
  ),
  Collection(
    id: 'optics_laser',
    name: 'Optics & Photonics',
    emoji: '🔦',
    description: 'Wavelenghts, lumens, lux & lasers',
    categories: [
      UnitCategory.wavenumber,
      UnitCategory.frequency,
      UnitCategory.illuminance,
      UnitCategory.luminousFlux,
      UnitCategory.luminousIntensity,
      UnitCategory.luminance,
    ],
  ),
  Collection(
    id: 'nutrition',
    name: 'Diet & Nutrition',
    emoji: '🥗',
    description: 'Food mass, fluid intake & body indices',
    categories: [
      UnitCategory.weight,
      UnitCategory.volume,
      UnitCategory.percentageRatio,
      UnitCategory.bloodSugar,
      UnitCategory.bmi,
      UnitCategory.concentration,
    ],
  ),
  Collection(
    id: 'quantum',
    name: 'Atomic & Particle',
    emoji: '⚛️',
    description: 'Subatomic energy, charge & radiation',
    categories: [
      UnitCategory.energy,
      UnitCategory.wavenumber,
      UnitCategory.radioactivity,
      UnitCategory.frequency,
      UnitCategory.electricCharge,
      UnitCategory.magneticFlux,
    ],
  ),
];
