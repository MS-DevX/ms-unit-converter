import 'dart:math' as math;

import 'package:unit_converter/models/unit_model.dart';

/// Conversion categories supported by the app.
enum UnitCategory {
  // ── Existing Core ──────────────────────────────────────────────
  length,
  weight,
  temperature,
  area,
  volume,
  speed,
  data,
  time,
  angle,
  energy,
  power,
  pressure,
  force,
  frequency,
  fuelEconomy,
  cooking,
  shoeSize,
  clothingSize,
  numberBase,
  typography,

  // ── Electrical ─────────────────────────────────────────────────
  voltage,
  current,
  resistance,
  capacitance,
  inductance,
  electricCharge,
  conductance,

  // ── Light ──────────────────────────────────────────────────────
  illuminance,
  luminousFlux,
  luminousIntensity,
  luminance,

  // ── Heat & Thermodynamics ──────────────────────────────────────
  specificHeat,
  thermalConductivity,
  thermalResistance,
  heatFluxDensity,

  // ── Physics ────────────────────────────────────────────────────
  torque,
  momentum,
  angularVelocity,
  density,
  surfaceTension,
  kinematicViscosity,
  dynamicViscosity,
  acceleration,

  // ── Engineering ────────────────────────────────────────────────
  flowRate,
  massFlowRate,

  // ── Radiation ──────────────────────────────────────────────────
  radioactivity,
  radiationDose,
  radiationExposure,

  // ── Astronomy ─────────────────────────────────────────────────
  astronomicalLength,

  // ── Lifestyle & Everyday ───────────────────────────────────────
  pace,
  heartRate,
  bloodSugar,
  bloodPressure,
  bmi,

  // ── Finance / Ratio ────────────────────────────────────────────
  percentageRatio,

  // ── Sound ─────────────────────────────────────────────────────
  soundLevel,

  // ── Concentration ─────────────────────────────────────────────
  concentration,

  // ── Magnetic ──────────────────────────────────────────────────
  magneticField,
  magneticFlux,

  // ── Wavenumber / Spectroscopy ─────────────────────────────────
  wavenumber,
}

// ════════════════════════════════════════════════════════════════
// Extension helpers
// ════════════════════════════════════════════════════════════════

/// Display helpers for [UnitCategory].
extension UnitCategoryExtension on UnitCategory {
  /// Human-readable label for this category.
  String get displayName {
    switch (this) {
      // ── Existing ──────────────────────────────────────────────
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.weight:
        return 'Weight';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.data:
        return 'Data Storage';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.angle:
        return 'Angle';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.force:
        return 'Force';
      case UnitCategory.frequency:
        return 'Frequency';
      case UnitCategory.fuelEconomy:
        return 'Fuel Economy';
      case UnitCategory.cooking:
        return 'Cooking';
      case UnitCategory.shoeSize:
        return 'Shoe Size';
      case UnitCategory.clothingSize:
        return 'Clothing Size';
      case UnitCategory.numberBase:
        return 'Number Base';
      case UnitCategory.typography:
        return 'Typography';
      // ── Electrical ────────────────────────────────────────────
      case UnitCategory.voltage:
        return 'Voltage';
      case UnitCategory.current:
        return 'Electric Current';
      case UnitCategory.resistance:
        return 'Resistance';
      case UnitCategory.capacitance:
        return 'Capacitance';
      case UnitCategory.inductance:
        return 'Inductance';
      case UnitCategory.electricCharge:
        return 'Electric Charge';
      case UnitCategory.conductance:
        return 'Conductance';
      // ── Light ─────────────────────────────────────────────────
      case UnitCategory.illuminance:
        return 'Illuminance';
      case UnitCategory.luminousFlux:
        return 'Luminous Flux';
      case UnitCategory.luminousIntensity:
        return 'Luminous Intensity';
      case UnitCategory.luminance:
        return 'Luminance';
      // ── Heat ──────────────────────────────────────────────────
      case UnitCategory.specificHeat:
        return 'Specific Heat';
      case UnitCategory.thermalConductivity:
        return 'Thermal Conductivity';
      case UnitCategory.thermalResistance:
        return 'Thermal Resistance';
      case UnitCategory.heatFluxDensity:
        return 'Heat Flux Density';
      // ── Physics ───────────────────────────────────────────────
      case UnitCategory.torque:
        return 'Torque';
      case UnitCategory.momentum:
        return 'Momentum';
      case UnitCategory.angularVelocity:
        return 'Angular Velocity';
      case UnitCategory.density:
        return 'Density';
      case UnitCategory.surfaceTension:
        return 'Surface Tension';
      case UnitCategory.kinematicViscosity:
        return 'Kinematic Viscosity';
      case UnitCategory.dynamicViscosity:
        return 'Dynamic Viscosity';
      case UnitCategory.acceleration:
        return 'Acceleration';
      // ── Engineering ───────────────────────────────────────────
      case UnitCategory.flowRate:
        return 'Flow Rate';
      case UnitCategory.massFlowRate:
        return 'Mass Flow Rate';
      // ── Radiation ─────────────────────────────────────────────
      case UnitCategory.radioactivity:
        return 'Radioactivity';
      case UnitCategory.radiationDose:
        return 'Radiation Dose';
      case UnitCategory.radiationExposure:
        return 'Radiation Exposure';
      // ── Astronomy ─────────────────────────────────────────────
      case UnitCategory.astronomicalLength:
        return 'Astronomical Length';
      // ── Lifestyle ─────────────────────────────────────────────
      case UnitCategory.pace:
        return 'Running Pace';
      case UnitCategory.heartRate:
        return 'Heart Rate';
      case UnitCategory.bloodSugar:
        return 'Blood Sugar';
      case UnitCategory.bloodPressure:
        return 'Blood Pressure';
      case UnitCategory.bmi:
        return 'Body Mass Index';
      // ── Finance ───────────────────────────────────────────────
      case UnitCategory.percentageRatio:
        return 'Percentage & Ratio';
      // ── Sound ─────────────────────────────────────────────────
      case UnitCategory.soundLevel:
        return 'Sound Level';
      // ── Concentration ─────────────────────────────────────────
      case UnitCategory.concentration:
        return 'Concentration';
      // ── Magnetic ──────────────────────────────────────────────
      case UnitCategory.magneticField:
        return 'Magnetic Field';
      case UnitCategory.magneticFlux:
        return 'Magnetic Flux';
      // ── Spectroscopy ──────────────────────────────────────────
      case UnitCategory.wavenumber:
        return 'Wavenumber';
    }
  }

  /// Short description of what this category converts.
  String get description {
    switch (this) {
      case UnitCategory.length:
        return 'Meters, feet, inches, miles — measure the world';
      case UnitCategory.weight:
        return 'Kilograms, pounds, ounces — weigh anything';
      case UnitCategory.temperature:
        return 'Celsius, Fahrenheit, Kelvin — temperature';
      case UnitCategory.area:
        return 'Square meters, acres, hectares — measure spaces';
      case UnitCategory.volume:
        return 'Liters, gallons, cups — volume & capacity';
      case UnitCategory.speed:
        return 'km/h, mph, knots — speed conversions';
      case UnitCategory.data:
        return 'Bytes, KB, MB, GB — digital storage';
      case UnitCategory.time:
        return 'Seconds, minutes, hours — time conversions';
      case UnitCategory.angle:
        return 'Degrees, radians — angular measurements';
      case UnitCategory.energy:
        return 'Joules, calories, kWh — energy conversions';
      case UnitCategory.power:
        return 'Watts, horsepower — power measurements';
      case UnitCategory.pressure:
        return 'Pascals, PSI, bar — pressure conversions';
      case UnitCategory.force:
        return 'Newtons, pound-force — force conversions';
      case UnitCategory.frequency:
        return 'Hertz, kHz, MHz — frequency conversions';
      case UnitCategory.fuelEconomy:
        return 'km/L, MPG — fuel efficiency';
      case UnitCategory.cooking:
        return 'Cups, tbsp, grams — recipe conversions';
      case UnitCategory.shoeSize:
        return 'EU, UK, US, CM — shoe sizing';
      case UnitCategory.clothingSize:
        return 'US, EU, UK — clothing sizes';
      case UnitCategory.numberBase:
        return 'Binary, Hex, Decimal — base conversion';
      case UnitCategory.typography:
        return 'px, pt, em, rem — type scaling';
      case UnitCategory.voltage:
        return 'Volts, millivolts, kilovolts — EMF';
      case UnitCategory.current:
        return 'Amperes, milliamps — electric current';
      case UnitCategory.resistance:
        return 'Ohms, kilohms, megohms — resistance';
      case UnitCategory.capacitance:
        return 'Farads, microfarads — capacitance';
      case UnitCategory.inductance:
        return 'Henrys, millihenrys — inductance';
      case UnitCategory.electricCharge:
        return 'Coulombs, ampere-hours — charge';
      case UnitCategory.conductance:
        return 'Siemens, millisiemens — conductance';
      case UnitCategory.illuminance:
        return 'Lux, foot-candles — light intensity';
      case UnitCategory.luminousFlux:
        return 'Lumens — luminous flux';
      case UnitCategory.luminousIntensity:
        return 'Candela — point light intensity';
      case UnitCategory.luminance:
        return 'cd/m², nit — surface brightness';
      case UnitCategory.specificHeat:
        return 'J/(kg·K), cal/(g·°C) — heat capacity per mass';
      case UnitCategory.thermalConductivity:
        return 'W/(m·K) — heat transfer rate';
      case UnitCategory.thermalResistance:
        return '°C/W, R-value — insulation rating';
      case UnitCategory.heatFluxDensity:
        return 'W/m² — heat flux density';
      case UnitCategory.torque:
        return 'N·m, ft·lb — rotational force';
      case UnitCategory.momentum:
        return 'kg·m/s — linear momentum';
      case UnitCategory.angularVelocity:
        return 'rad/s, rpm — rotation speed';
      case UnitCategory.density:
        return 'kg/m³, g/cm³ — mass per volume';
      case UnitCategory.surfaceTension:
        return 'N/m, dyn/cm — surface tension';
      case UnitCategory.kinematicViscosity:
        return 'm²/s, stokes — kinematic viscosity';
      case UnitCategory.dynamicViscosity:
        return 'Pa·s, poise — dynamic viscosity';
      case UnitCategory.acceleration:
        return 'm/s², g — acceleration & gravity';
      case UnitCategory.flowRate:
        return 'L/s, m³/h — volumetric flow';
      case UnitCategory.massFlowRate:
        return 'kg/s, lb/min — mass flow';
      case UnitCategory.radioactivity:
        return 'Becquerel, Curie — radioactive decay';
      case UnitCategory.radiationDose:
        return 'Gray, Sievert — absorbed radiation dose';
      case UnitCategory.radiationExposure:
        return 'Roentgen, C/kg — radiation exposure';
      case UnitCategory.astronomicalLength:
        return 'AU, light-year, parsec — cosmic distances';
      case UnitCategory.pace:
        return 'min/km, min/mile — running pace';
      case UnitCategory.heartRate:
        return 'bpm — beats per minute';
      case UnitCategory.bloodSugar:
        return 'mg/dL, mmol/L — blood glucose';
      case UnitCategory.bloodPressure:
        return 'mmHg — systolic / diastolic';
      case UnitCategory.bmi:
        return 'kg/m² — body mass index';
      case UnitCategory.percentageRatio:
        return 'Percent, fraction, PPM — ratios';
      case UnitCategory.soundLevel:
        return 'Decibels — sound intensity level';
      case UnitCategory.concentration:
        return 'mol/L, g/L — solution concentration';
      case UnitCategory.magneticField:
        return 'Tesla, Gauss — magnetic flux density';
      case UnitCategory.magneticFlux:
        return 'Weber, Maxwell — magnetic flux';
      case UnitCategory.wavenumber:
        return 'cm⁻¹, m⁻¹ — spectroscopic wavenumber';
    }
  }

  /// Short symbols of all units in this category.
  List<String> get unitSymbols =>
      unitsData[this]?.map((u) => u.symbol).toList() ?? [];

  /// Curated preset conversions for quick reference.
  List<({double value, String fromUnitName, String toUnitName})>
  get commonConversions {
    switch (this) {
      case UnitCategory.length:
        return [
          (value: 1, fromUnitName: 'Kilometer', toUnitName: 'Mile'),
          (value: 1, fromUnitName: 'Meter', toUnitName: 'Foot'),
          (value: 1, fromUnitName: 'Foot', toUnitName: 'Meter'),
        ];
      case UnitCategory.weight:
        return [
          (value: 1, fromUnitName: 'Kilogram', toUnitName: 'Pound'),
          (value: 1, fromUnitName: 'Pound', toUnitName: 'Ounce'),
          (value: 1, fromUnitName: 'Tonne', toUnitName: 'Kilogram'),
        ];
      case UnitCategory.temperature:
        return [
          (value: 0, fromUnitName: 'Celsius', toUnitName: 'Fahrenheit'),
          (value: 100, fromUnitName: 'Celsius', toUnitName: 'Fahrenheit'),
          (value: 0, fromUnitName: 'Celsius', toUnitName: 'Kelvin'),
        ];
      case UnitCategory.area:
        return [
          (value: 1, fromUnitName: 'Square Kilometer', toUnitName: 'Acre'),
          (value: 1, fromUnitName: 'Hectare', toUnitName: 'Acre'),
          (value: 1, fromUnitName: 'Square Meter', toUnitName: 'Square Foot'),
        ];
      case UnitCategory.volume:
        return [
          (value: 1, fromUnitName: 'Liter', toUnitName: 'Gallon (US)'),
          (value: 1, fromUnitName: 'Liter', toUnitName: 'Cup'),
          (value: 1, fromUnitName: 'Gallon (US)', toUnitName: 'Liter'),
        ];
      case UnitCategory.speed:
        return [
          (
            value: 1,
            fromUnitName: 'Kilometers per Hour',
            toUnitName: 'Miles per Hour',
          ),
          (
            value: 1,
            fromUnitName: 'Meters per Second',
            toUnitName: 'Foot per Second',
          ),
          (value: 1, fromUnitName: 'Knot', toUnitName: 'Kilometers per Hour'),
        ];
      case UnitCategory.data:
        return [
          (value: 1, fromUnitName: 'Megabyte', toUnitName: 'Kilobyte'),
          (value: 1, fromUnitName: 'Gigabyte', toUnitName: 'Megabyte'),
          (value: 1, fromUnitName: 'Terabyte', toUnitName: 'Gigabyte'),
        ];
      case UnitCategory.time:
        return [
          (value: 1, fromUnitName: 'Minute', toUnitName: 'Second'),
          (value: 1, fromUnitName: 'Hour', toUnitName: 'Minute'),
          (value: 1, fromUnitName: 'Day', toUnitName: 'Hour'),
        ];
      case UnitCategory.angle:
        return [
          (value: 180, fromUnitName: 'Degree', toUnitName: 'Radian'),
          (value: 1, fromUnitName: 'Radian', toUnitName: 'Degree'),
          (value: 1, fromUnitName: 'Gradian', toUnitName: 'Degree'),
        ];
      case UnitCategory.energy:
        return [
          (value: 1, fromUnitName: 'Kilojoule', toUnitName: 'Calorie'),
          (value: 1, fromUnitName: 'Kilowatt-hour', toUnitName: 'Joule'),
          (value: 1, fromUnitName: 'Calorie', toUnitName: 'Joule'),
        ];
      case UnitCategory.power:
        return [
          (value: 1, fromUnitName: 'Kilowatt', toUnitName: 'Horsepower'),
          (value: 1, fromUnitName: 'Megawatt', toUnitName: 'Kilowatt'),
          (value: 1, fromUnitName: 'Horsepower', toUnitName: 'Watt'),
        ];
      case UnitCategory.pressure:
        return [
          (value: 1, fromUnitName: 'Bar', toUnitName: 'PSI'),
          (value: 1, fromUnitName: 'Atmosphere', toUnitName: 'Kilopascal'),
          (value: 1, fromUnitName: 'PSI', toUnitName: 'Kilopascal'),
        ];
      case UnitCategory.force:
        return [
          (value: 1, fromUnitName: 'Newton', toUnitName: 'Pound-force'),
          (value: 1, fromUnitName: 'Kilogram-force', toUnitName: 'Newton'),
          (value: 1, fromUnitName: 'Newton', toUnitName: 'Dyne'),
        ];
      case UnitCategory.frequency:
        return [
          (value: 1, fromUnitName: 'Kilohertz', toUnitName: 'Hertz'),
          (value: 1, fromUnitName: 'Megahertz', toUnitName: 'Kilohertz'),
          (value: 1, fromUnitName: 'Gigahertz', toUnitName: 'Megahertz'),
        ];
      case UnitCategory.fuelEconomy:
        return [
          (
            value: 1,
            fromUnitName: 'Kilometers per Liter',
            toUnitName: 'MPG (US)',
          ),
          (
            value: 10,
            fromUnitName: 'Liters per 100km',
            toUnitName: 'MPG (US)',
          ),
          (
            value: 1,
            fromUnitName: 'MPG (US)',
            toUnitName: 'Kilometers per Liter',
          ),
        ];
      case UnitCategory.cooking:
        return [
          (value: 1, fromUnitName: 'Cup (US)', toUnitName: 'Tablespoon'),
          (value: 1, fromUnitName: 'Cup (US)', toUnitName: 'Milliliter'),
          (value: 1, fromUnitName: 'Ounce', toUnitName: 'Gram'),
        ];
      case UnitCategory.shoeSize:
        return [
          (value: 42, fromUnitName: 'EU', toUnitName: 'US Men'),
          (value: 39, fromUnitName: 'EU', toUnitName: 'CM'),
          (value: 42, fromUnitName: 'EU', toUnitName: 'UK'),
        ];
      case UnitCategory.clothingSize:
        return [
          (value: 32, fromUnitName: 'US', toUnitName: 'EU'),
          (value: 38, fromUnitName: 'US', toUnitName: 'UK'),
          (value: 32, fromUnitName: 'US', toUnitName: 'Asian'),
        ];
      case UnitCategory.numberBase:
        return [
          (value: 255, fromUnitName: 'Decimal', toUnitName: 'Hexadecimal'),
          (value: 255, fromUnitName: 'Decimal', toUnitName: 'Binary'),
          (value: 255, fromUnitName: 'Decimal', toUnitName: 'Octal'),
        ];
      case UnitCategory.typography:
        return [
          (value: 16, fromUnitName: 'Pixels', toUnitName: 'Points'),
          (value: 1, fromUnitName: 'Inch', toUnitName: 'Pixels'),
          (value: 16, fromUnitName: 'Pixels', toUnitName: 'DP'),
        ];
      case UnitCategory.voltage:
        return [
          (value: 1, fromUnitName: 'Volt', toUnitName: 'Millivolt'),
          (value: 1, fromUnitName: 'Kilovolt', toUnitName: 'Volt'),
          (value: 120, fromUnitName: 'Volt', toUnitName: 'Millivolt'),
        ];
      case UnitCategory.current:
        return [
          (value: 1, fromUnitName: 'Ampere', toUnitName: 'Milliampere'),
          (value: 1, fromUnitName: 'Kiloampere', toUnitName: 'Ampere'),
          (value: 500, fromUnitName: 'Milliampere', toUnitName: 'Ampere'),
        ];
      case UnitCategory.resistance:
        return [
          (value: 1, fromUnitName: 'Kilohm', toUnitName: 'Ohm'),
          (value: 1, fromUnitName: 'Megohm', toUnitName: 'Kilohm'),
          (value: 47, fromUnitName: 'Ohm', toUnitName: 'Kilohm'),
        ];
      case UnitCategory.capacitance:
        return [
          (value: 1, fromUnitName: 'Microfarad', toUnitName: 'Nanofarad'),
          (value: 1, fromUnitName: 'Farad', toUnitName: 'Microfarad'),
          (value: 100, fromUnitName: 'Picofarad', toUnitName: 'Nanofarad'),
        ];
      case UnitCategory.inductance:
        return [
          (value: 1, fromUnitName: 'Henry', toUnitName: 'Millihenry'),
          (value: 1, fromUnitName: 'Millihenry', toUnitName: 'Microhenry'),
          (value: 10, fromUnitName: 'Millihenry', toUnitName: 'Henry'),
        ];
      case UnitCategory.electricCharge:
        return [
          (value: 1, fromUnitName: 'Coulomb', toUnitName: 'Millicoulomb'),
          (value: 1, fromUnitName: 'Ampere-hour', toUnitName: 'Coulomb'),
          (value: 1, fromUnitName: 'Milliampere-hour', toUnitName: 'Coulomb'),
        ];
      case UnitCategory.conductance:
        return [
          (value: 1, fromUnitName: 'Siemens', toUnitName: 'Millisiemens'),
          (value: 1, fromUnitName: 'Millisiemens', toUnitName: 'Microsiemens'),
          (value: 1000, fromUnitName: 'Microsiemens', toUnitName: 'Millisiemens'),
        ];
      case UnitCategory.illuminance:
        return [
          (value: 1, fromUnitName: 'Lux', toUnitName: 'Foot-candle'),
          (value: 1, fromUnitName: 'Kilolux', toUnitName: 'Lux'),
          (value: 10, fromUnitName: 'Foot-candle', toUnitName: 'Lux'),
        ];
      case UnitCategory.luminousFlux:
        return [
          (value: 1000, fromUnitName: 'Lumen', toUnitName: 'Lumen'),
          (value: 1, fromUnitName: 'Kilolumen', toUnitName: 'Lumen'),
          (value: 100, fromUnitName: 'Lumen', toUnitName: 'Lumen'),
        ];
      case UnitCategory.luminousIntensity:
        return [
          (value: 1, fromUnitName: 'Candela', toUnitName: 'Millicandela'),
          (value: 1, fromUnitName: 'Kilocandela', toUnitName: 'Candela'),
          (value: 100, fromUnitName: 'Candela', toUnitName: 'Kilocandela'),
        ];
      case UnitCategory.luminance:
        return [
          (value: 1, fromUnitName: 'Candela per Square Meter', toUnitName: 'Foot-lambert'),
          (value: 1, fromUnitName: 'Nit', toUnitName: 'Candela per Square Meter'),
          (value: 100, fromUnitName: 'Nit', toUnitName: 'Foot-lambert'),
        ];
      case UnitCategory.specificHeat:
        return [
          (value: 1, fromUnitName: 'J/(kg·K)', toUnitName: 'cal/(g·°C)'),
          (value: 4186, fromUnitName: 'J/(kg·K)', toUnitName: 'BTU/(lb·°F)'),
          (value: 1, fromUnitName: 'kJ/(kg·K)', toUnitName: 'J/(kg·K)'),
        ];
      case UnitCategory.thermalConductivity:
        return [
          (value: 1, fromUnitName: 'W/(m·K)', toUnitName: 'BTU/(h·ft·°F)'),
          (value: 1, fromUnitName: 'W/(m·K)', toUnitName: 'cal/(s·cm·°C)'),
          (value: 10, fromUnitName: 'W/(m·K)', toUnitName: 'BTU/(h·ft·°F)'),
        ];
      case UnitCategory.thermalResistance:
        return [
          (value: 1, fromUnitName: '°C/W', toUnitName: '°F·h/BTU'),
          (value: 1, fromUnitName: 'R-value (US)', toUnitName: 'RSI (SI)'),
          (value: 10, fromUnitName: 'R-value (US)', toUnitName: 'RSI (SI)'),
        ];
      case UnitCategory.heatFluxDensity:
        return [
          (value: 1, fromUnitName: 'Watt per Square Meter', toUnitName: 'BTU/(h·ft²)'),
          (value: 1, fromUnitName: 'Kilowatt per Square Meter', toUnitName: 'Watt per Square Meter'),
          (value: 1000, fromUnitName: 'Watt per Square Meter', toUnitName: 'Kilowatt per Square Meter'),
        ];
      case UnitCategory.torque:
        return [
          (value: 1, fromUnitName: 'Newton-meter', toUnitName: 'Foot-pound'),
          (value: 1, fromUnitName: 'Kilogram-force meter', toUnitName: 'Newton-meter'),
          (value: 10, fromUnitName: 'Newton-meter', toUnitName: 'Inch-pound'),
        ];
      case UnitCategory.momentum:
        return [
          (value: 1, fromUnitName: 'Kilogram meter per second', toUnitName: 'Gram cm/s'),
          (value: 1, fromUnitName: 'Pound foot per second', toUnitName: 'Kilogram meter per second'),
          (value: 10, fromUnitName: 'Kilogram meter per second', toUnitName: 'Pound foot per second'),
        ];
      case UnitCategory.angularVelocity:
        return [
          (value: 1, fromUnitName: 'Radian per Second', toUnitName: 'Revolution per Minute'),
          (value: 60, fromUnitName: 'Revolution per Minute', toUnitName: 'Radian per Second'),
          (value: 1, fromUnitName: 'Degree per Second', toUnitName: 'Radian per Second'),
        ];
      case UnitCategory.density:
        return [
          (value: 1, fromUnitName: 'Kilogram per Cubic Meter', toUnitName: 'Gram per Cubic Centimeter'),
          (value: 1, fromUnitName: 'Gram per Cubic Centimeter', toUnitName: 'Kilogram per Cubic Meter'),
          (value: 1, fromUnitName: 'Pound per Cubic Foot', toUnitName: 'Kilogram per Cubic Meter'),
        ];
      case UnitCategory.surfaceTension:
        return [
          (value: 1, fromUnitName: 'Newton per Meter', toUnitName: 'Dyne per Centimeter'),
          (value: 1, fromUnitName: 'Millinewton per Meter', toUnitName: 'Newton per Meter'),
          (value: 1, fromUnitName: 'Pound-force per Inch', toUnitName: 'Newton per Meter'),
        ];
      case UnitCategory.kinematicViscosity:
        return [
          (value: 1, fromUnitName: 'Square Meter per Second', toUnitName: 'Stokes'),
          (value: 1, fromUnitName: 'Centistokes', toUnitName: 'Stokes'),
          (value: 1, fromUnitName: 'Square Foot per Second', toUnitName: 'Square Meter per Second'),
        ];
      case UnitCategory.dynamicViscosity:
        return [
          (value: 1, fromUnitName: 'Pascal-second', toUnitName: 'Poise'),
          (value: 1, fromUnitName: 'Centipoise', toUnitName: 'Pascal-second'),
          (value: 1, fromUnitName: 'Pound-force second per Square Foot', toUnitName: 'Pascal-second'),
        ];
      case UnitCategory.acceleration:
        return [
          (value: 1, fromUnitName: 'Standard Gravity', toUnitName: 'Meter per Second Squared'),
          (value: 9.81, fromUnitName: 'Meter per Second Squared', toUnitName: 'Standard Gravity'),
          (value: 1, fromUnitName: 'Foot per Second Squared', toUnitName: 'Meter per Second Squared'),
        ];
      case UnitCategory.flowRate:
        return [
          (value: 1, fromUnitName: 'Cubic Meter per Hour', toUnitName: 'Liter per Second'),
          (value: 1, fromUnitName: 'Gallon per Minute (US)', toUnitName: 'Liter per Minute'),
          (value: 1, fromUnitName: 'Liter per Second', toUnitName: 'Cubic Meter per Hour'),
        ];
      case UnitCategory.massFlowRate:
        return [
          (value: 1, fromUnitName: 'Kilogram per Second', toUnitName: 'Pound per Second'),
          (value: 1, fromUnitName: 'Kilogram per Hour', toUnitName: 'Kilogram per Second'),
          (value: 1, fromUnitName: 'Pound per Minute', toUnitName: 'Kilogram per Second'),
        ];
      case UnitCategory.radioactivity:
        return [
          (value: 1, fromUnitName: 'Curie', toUnitName: 'Becquerel'),
          (value: 1, fromUnitName: 'Millicurie', toUnitName: 'Becquerel'),
          (value: 1, fromUnitName: 'Becquerel', toUnitName: 'Curie'),
        ];
      case UnitCategory.radiationDose:
        return [
          (value: 1, fromUnitName: 'Gray', toUnitName: 'Rad'),
          (value: 1, fromUnitName: 'Sievert', toUnitName: 'Rem'),
          (value: 1, fromUnitName: 'Millisievert', toUnitName: 'Microsievert'),
        ];
      case UnitCategory.radiationExposure:
        return [
          (value: 1, fromUnitName: 'Roentgen', toUnitName: 'Coulomb per Kilogram'),
          (value: 1, fromUnitName: 'Milliroentgen', toUnitName: 'Roentgen'),
          (value: 1000, fromUnitName: 'Milliroentgen', toUnitName: 'Roentgen'),
        ];
      case UnitCategory.astronomicalLength:
        return [
          (value: 1, fromUnitName: 'Astronomical Unit', toUnitName: 'Kilometer'),
          (value: 1, fromUnitName: 'Light-year', toUnitName: 'Parsec'),
          (value: 1, fromUnitName: 'Parsec', toUnitName: 'Light-year'),
        ];
      case UnitCategory.pace:
        return [
          (value: 5, fromUnitName: 'Min per Kilometer', toUnitName: 'Min per Mile'),
          (value: 6, fromUnitName: 'Min per Mile', toUnitName: 'Min per Kilometer'),
          (value: 4, fromUnitName: 'Min per Kilometer', toUnitName: 'Kilometers per Hour'),
        ];
      case UnitCategory.heartRate:
        return [
          (value: 60, fromUnitName: 'Beats per Minute', toUnitName: 'Beats per Second'),
          (value: 1, fromUnitName: 'Beats per Second', toUnitName: 'Beats per Minute'),
          (value: 72, fromUnitName: 'Beats per Minute', toUnitName: 'Beats per Second'),
        ];
      case UnitCategory.bloodSugar:
        return [
          (value: 100, fromUnitName: 'mg/dL', toUnitName: 'mmol/L'),
          (value: 5.5, fromUnitName: 'mmol/L', toUnitName: 'mg/dL'),
          (value: 180, fromUnitName: 'mg/dL', toUnitName: 'mmol/L'),
        ];
      case UnitCategory.bloodPressure:
        return [
          (value: 120, fromUnitName: 'mmHg', toUnitName: 'kPa'),
          (value: 80, fromUnitName: 'mmHg', toUnitName: 'kPa'),
          (value: 1, fromUnitName: 'kPa', toUnitName: 'mmHg'),
        ];
      case UnitCategory.bmi:
        return [
          (value: 22, fromUnitName: 'kg/m²', toUnitName: 'lb/in²'),
          (value: 30, fromUnitName: 'kg/m²', toUnitName: 'lb/in²'),
          (value: 1, fromUnitName: 'lb/in²', toUnitName: 'kg/m²'),
        ];
      case UnitCategory.percentageRatio:
        return [
          (value: 50, fromUnitName: 'Percent', toUnitName: 'Fraction'),
          (value: 0.5, fromUnitName: 'Fraction', toUnitName: 'Percent'),
          (value: 1, fromUnitName: 'Parts per Million', toUnitName: 'Percent'),
        ];
      case UnitCategory.soundLevel:
        return [
          (value: 0, fromUnitName: 'Decibel', toUnitName: 'Decibel'),
          (value: 85, fromUnitName: 'Decibel', toUnitName: 'Decibel'),
          (value: 120, fromUnitName: 'Decibel', toUnitName: 'Decibel'),
        ];
      case UnitCategory.concentration:
        return [
          (value: 1, fromUnitName: 'Mole per Liter', toUnitName: 'Millimole per Liter'),
          (value: 1, fromUnitName: 'Gram per Liter', toUnitName: 'Milligram per Liter'),
          (value: 36.5, fromUnitName: 'Gram per Liter', toUnitName: 'Mole per Liter'),
        ];
      case UnitCategory.magneticField:
        return [
          (value: 1, fromUnitName: 'Tesla', toUnitName: 'Gauss'),
          (value: 1, fromUnitName: 'Millitesla', toUnitName: 'Tesla'),
          (value: 1, fromUnitName: 'Gauss', toUnitName: 'Microtesla'),
        ];
      case UnitCategory.magneticFlux:
        return [
          (value: 1, fromUnitName: 'Weber', toUnitName: 'Maxwell'),
          (value: 1, fromUnitName: 'Milliweber', toUnitName: 'Weber'),
          (value: 1000, fromUnitName: 'Maxwell', toUnitName: 'Weber'),
        ];
      case UnitCategory.wavenumber:
        return [
          (value: 1, fromUnitName: 'Reciprocal Centimeter', toUnitName: 'Reciprocal Meter'),
          (value: 100, fromUnitName: 'Reciprocal Centimeter', toUnitName: 'Reciprocal Meter'),
          (value: 1000, fromUnitName: 'Reciprocal Meter', toUnitName: 'Reciprocal Centimeter'),
        ];
    }
  }

  /// Emoji icon representing this category.
  String get icon {
    switch (this) {
      case UnitCategory.length:
        return '\u{1F4CF}';
      case UnitCategory.weight:
        return '\u{2696}\u{FE0F}';
      case UnitCategory.temperature:
        return '\u{1F321}\u{FE0F}';
      case UnitCategory.area:
        return '\u{1F4D0}';
      case UnitCategory.volume:
        return '\u{1F9EA}';
      case UnitCategory.speed:
        return '\u{1F680}';
      case UnitCategory.data:
        return '\u{1F4BE}';
      case UnitCategory.time:
        return '\u{23F1}\u{FE0F}';
      case UnitCategory.angle:
        return '\u{1F4A0}';
      case UnitCategory.energy:
        return '\u{26A1}';
      case UnitCategory.power:
        return '\u{1F50B}';
      case UnitCategory.pressure:
        return '\u{1F4A8}';
      case UnitCategory.force:
        return '\u{1F4AA}';
      case UnitCategory.frequency:
        return '\u{1F501}';
      case UnitCategory.fuelEconomy:
        return '\u{26FD}';
      case UnitCategory.cooking:
        return '\u{1F373}';
      case UnitCategory.shoeSize:
        return '\u{1F460}';
      case UnitCategory.clothingSize:
        return '\u{1F455}';
      case UnitCategory.numberBase:
        return '\u{1F522}';
      case UnitCategory.typography:
        return '\u{1F4D6}';
      case UnitCategory.voltage:
        return '\u{26A1}';
      case UnitCategory.current:
        return '\u{1F50C}';
      case UnitCategory.resistance:
        return '\u{1F300}';
      case UnitCategory.capacitance:
        return '\u{1F4E6}';
      case UnitCategory.inductance:
        return '\u{1F9F2}';
      case UnitCategory.electricCharge:
        return '\u{1F50B}';
      case UnitCategory.conductance:
        return '\u{1F517}';
      case UnitCategory.illuminance:
        return '\u{1F4A1}';
      case UnitCategory.luminousFlux:
        return '\u{2728}';
      case UnitCategory.luminousIntensity:
        return '\u{1F526}';
      case UnitCategory.luminance:
        return '\u{1F315}';
      case UnitCategory.specificHeat:
        return '\u{1F321}\u{FE0F}';
      case UnitCategory.thermalConductivity:
        return '\u{1F525}';
      case UnitCategory.thermalResistance:
        return '\u{1F9F1}';
      case UnitCategory.heatFluxDensity:
        return '\u{2600}\u{FE0F}';
      case UnitCategory.torque:
        return '\u{1F527}';
      case UnitCategory.momentum:
        return '\u{1F4A8}';
      case UnitCategory.angularVelocity:
        return '\u{1F300}';
      case UnitCategory.density:
        return '\u{1F9FC}';
      case UnitCategory.surfaceTension:
        return '\u{1F4A7}';
      case UnitCategory.kinematicViscosity:
        return '\u{1F30A}';
      case UnitCategory.dynamicViscosity:
        return '\u{1F6E2}\u{FE0F}';
      case UnitCategory.acceleration:
        return '\u{1F3CE}\u{FE0F}';
      case UnitCategory.flowRate:
        return '\u{1F6B0}';
      case UnitCategory.massFlowRate:
        return '\u{2696}\u{FE0F}';
      case UnitCategory.radioactivity:
        return '\u{2622}\u{FE0F}';
      case UnitCategory.radiationDose:
        return '\u{2623}\u{FE0F}';
      case UnitCategory.radiationExposure:
        return '\u{1F9EA}';
      case UnitCategory.astronomicalLength:
        return '\u{1FA90}';
      case UnitCategory.pace:
        return '\u{1F3C3}';
      case UnitCategory.heartRate:
        return '\u{2764}\u{FE0F}';
      case UnitCategory.bloodSugar:
        return '\u{1FA78}';
      case UnitCategory.bloodPressure:
        return '\u{1FAE0}';
      case UnitCategory.bmi:
        return '\u{1F9CD}';
      case UnitCategory.percentageRatio:
        return '\u{0025}';
      case UnitCategory.soundLevel:
        return '\u{1F4E2}';
      case UnitCategory.concentration:
        return '\u{1F9EA}';
      case UnitCategory.magneticField:
        return '\u{1F9F2}';
      case UnitCategory.magneticFlux:
        return '\u{1F300}';
      case UnitCategory.wavenumber:
        return '\u{1F52D}';
    }
  }

  /// A user-friendly explanation of how conversions in this category work.
  String get formulaExplanation {
    switch (this) {
      case UnitCategory.length:
        return 'Multiply by the source unit\'s meter factor, '
            'then divide by the target unit\'s meter factor. '
            'Example: 1 km = 1000 m.';
      case UnitCategory.weight:
        return 'Multiply by the source unit\'s kilogram factor, '
            'then divide by the target unit\'s kilogram factor. '
            'Example: 1 kg ≈ 2.205 lb.';
      case UnitCategory.temperature:
        return 'Uses special formulas, not a simple multiplier.\n'
            '°F = (°C × 9/5) + 32\n'
            '°C = (°F − 32) × 5/9\n'
            'K = °C + 273.15';
      case UnitCategory.area:
        return 'Multiply by the source unit\'s square-meter factor, '
            'then divide by the target unit\'s square-meter factor. '
            'Example: 1 m² ≈ 10.764 ft².';
      case UnitCategory.volume:
        return 'Multiply by the source unit\'s cubic-meter factor, '
            'then divide by the target unit\'s cubic-meter factor. '
            'Example: 1 L ≈ 0.264 gal (US).';
      case UnitCategory.speed:
        return 'Multiply by the source unit\'s m/s factor, '
            'then divide by the target unit\'s m/s factor. '
            'Example: 1 km/h ≈ 0.278 m/s.';
      case UnitCategory.data:
        return 'Multiply by the source unit\'s byte factor, '
            'then divide by the target unit\'s byte factor.\n'
            '1 byte = 8 bits. Units use powers of 1024 (binary).';
      case UnitCategory.time:
        return 'Multiply by the source unit\'s second factor, '
            'then divide by the target unit\'s second factor. '
            'Example: 1 hour = 3600 seconds.';
      case UnitCategory.angle:
        return 'Multiply by the source unit\'s radian factor, '
            'then divide by the target unit\'s radian factor.\n'
            '° × π/180 = rad.';
      case UnitCategory.energy:
        return 'Multiply by the source unit\'s joule factor, '
            'then divide by the target unit\'s joule factor. '
            'Example: 1 kWh = 3,600,000 J.';
      case UnitCategory.power:
        return 'Multiply by the source unit\'s watt factor, '
            'then divide by the target unit\'s watt factor. '
            'Example: 1 kW ≈ 1.341 hp.';
      case UnitCategory.pressure:
        return 'Multiply by the source unit\'s pascal factor, '
            'then divide by the target unit\'s pascal factor. '
            'Example: 1 bar ≈ 14.504 psi.';
      case UnitCategory.force:
        return 'Multiply by the source unit\'s newton factor, '
            'then divide by the target unit\'s newton factor. '
            'Example: 1 N ≈ 0.2248 lbf.';
      case UnitCategory.frequency:
        return 'Multiply by the source unit\'s hertz factor, '
            'then divide by the target unit\'s hertz factor. '
            'Example: 1 kHz = 1000 Hz.';
      case UnitCategory.fuelEconomy:
        return 'Most conversions use a simple multiplier, but '
            'L/100km is inversely related to km/L and MPG.\n'
            'A higher L/100km value means worse fuel efficiency. '
            'Special formulas handle this automatically.';
      case UnitCategory.cooking:
        return 'Volume and weight units are grouped separately.\n'
            'Conversions within each group work normally, but '
            'cross-group conversions (e.g. cups to grams) are blocked '
            'because ingredient density varies.';
      case UnitCategory.shoeSize:
        return 'Sizes are approximate and based on standard '
            'conversion formulas using foot length (cm) as '
            'the intermediate value.\n'
            'Actual fit varies by brand and style.';
      case UnitCategory.clothingSize:
        return 'Sizes are approximate — brand standards vary '
            'widely. US numeric size is used as the intermediate '
            'value.\n'
            'Men\'s and women\'s sizing uses different conversion formulas.';
      case UnitCategory.numberBase:
        return 'Enter a value in the source base to see it '
            'converted to other bases.\n'
            'Decimal = base 10, Binary = base 2, '
            'Octal = base 8, Hexadecimal = base 16.';
      case UnitCategory.typography:
        return 'px = the base screen unit.\n'
            'pt = 1/72 inch, em = relative to parent font, '
            'rem = relative to root font.\n'
            'Percent = % of the base font size.\n'
            'Adjust the base font size above if needed '
            '(default: 16px).';
      case UnitCategory.voltage:
        return 'SI base unit is Volt (V).\n'
            'Multiply by source factor to get volts, '
            'then divide by target factor. '
            'Example: 1 kV = 1000 V.';
      case UnitCategory.current:
        return 'SI base unit is Ampere (A).\n'
            'Multiply by source factor to get amperes, '
            'then divide by target factor. '
            'Example: 1 A = 1000 mA.';
      case UnitCategory.resistance:
        return 'SI base unit is Ohm (Ω).\n'
            'Multiply by source factor to get ohms, '
            'then divide by target factor. '
            'Example: 1 kΩ = 1000 Ω.';
      case UnitCategory.capacitance:
        return 'SI base unit is Farad (F).\n'
            'Multiply by source factor to get farads, '
            'then divide by target factor. '
            'Example: 1 μF = 10⁻⁶ F.';
      case UnitCategory.inductance:
        return 'SI base unit is Henry (H).\n'
            'Multiply by source factor to get henrys, '
            'then divide by target factor. '
            'Example: 1 mH = 10⁻³ H.';
      case UnitCategory.electricCharge:
        return 'SI base unit is Coulomb (C).\n'
            '1 Ah = 3600 C, 1 mAh = 3.6 C.';
      case UnitCategory.conductance:
        return 'SI base unit is Siemens (S), the reciprocal of ohms.\n'
            '1 S = 1000 mS = 1,000,000 μS.';
      case UnitCategory.illuminance:
        return 'SI base unit is Lux (lx).\n'
            '1 foot-candle ≈ 10.764 lux.\n'
            'Multiply by source factor to get lux.';
      case UnitCategory.luminousFlux:
        return 'SI base unit is Lumen (lm).\n'
            '1 kilolumen = 1000 lm.\n'
            'Lumens measure total visible light output.';
      case UnitCategory.luminousIntensity:
        return 'SI base unit is Candela (cd).\n'
            'Candela measures light emitted in a particular direction.\n'
            'Example: 1 kcd = 1000 cd.';
      case UnitCategory.luminance:
        return 'SI base unit is Candela per Square Meter (cd/m²), also called Nit.\n'
            '1 foot-lambert ≈ 3.426 cd/m².';
      case UnitCategory.specificHeat:
        return 'SI base unit is J/(kg·K).\n'
            '1 cal/(g·°C) = 4186 J/(kg·K)\n'
            '1 BTU/(lb·°F) ≈ 4186.8 J/(kg·K)';
      case UnitCategory.thermalConductivity:
        return 'SI base unit is W/(m·K).\n'
            '1 BTU/(h·ft·°F) ≈ 1.7307 W/(m·K).\n'
            'Higher values indicate better heat conductors.';
      case UnitCategory.thermalResistance:
        return 'Thermal resistance measures insulation performance.\n'
            'R-value (US) uses h·ft²·°F/BTU.\n'
            'RSI (SI) uses m²·K/W.\n'
            '1 R-value (US) ≈ 0.1761 RSI.';
      case UnitCategory.heatFluxDensity:
        return 'SI base unit is W/m².\n'
            '1 BTU/(h·ft²) ≈ 3.15459 W/m².';
      case UnitCategory.torque:
        return 'SI base unit is Newton-meter (N·m).\n'
            '1 ft·lb ≈ 1.3558 N·m\n'
            '1 kgf·m = 9.80665 N·m.';
      case UnitCategory.momentum:
        return 'SI base unit is kg·m/s.\n'
            'p = m × v (mass × velocity).\n'
            '1 lb·ft/s ≈ 0.1383 kg·m/s.';
      case UnitCategory.angularVelocity:
        return 'SI base unit is Radian per Second (rad/s).\n'
            '1 RPM = 2π/60 rad/s ≈ 0.10472 rad/s.\n'
            '1 deg/s = π/180 rad/s.';
      case UnitCategory.density:
        return 'SI base unit is kg/m³.\n'
            '1 g/cm³ = 1000 kg/m³\n'
            '1 lb/ft³ ≈ 16.0185 kg/m³.';
      case UnitCategory.surfaceTension:
        return 'SI base unit is N/m.\n'
            '1 dyn/cm = 10⁻³ N/m\n'
            '1 lbf/in ≈ 175.127 N/m.';
      case UnitCategory.kinematicViscosity:
        return 'SI base unit is m²/s.\n'
            '1 stoke (St) = 10⁻⁴ m²/s\n'
            '1 cSt = 10⁻⁶ m²/s.';
      case UnitCategory.dynamicViscosity:
        return 'SI base unit is Pascal-second (Pa·s).\n'
            '1 poise = 0.1 Pa·s\n'
            '1 cP = 10⁻³ Pa·s.';
      case UnitCategory.acceleration:
        return 'SI base unit is m/s².\n'
            'Standard gravity g = 9.80665 m/s².\n'
            '1 Gal = 0.01 m/s².';
      case UnitCategory.flowRate:
        return 'SI base unit is m³/s.\n'
            '1 L/s = 0.001 m³/s\n'
            '1 GPM (US) ≈ 0.0000631 m³/s.';
      case UnitCategory.massFlowRate:
        return 'SI base unit is kg/s.\n'
            '1 lb/s ≈ 0.4536 kg/s\n'
            '1 kg/h ≈ 0.000278 kg/s.';
      case UnitCategory.radioactivity:
        return 'SI unit is Becquerel (Bq) — one decay per second.\n'
            '1 Curie = 3.7 × 10¹⁰ Bq.';
      case UnitCategory.radiationDose:
        return 'Gray (Gy) = absorbed energy per kg (J/kg).\n'
            'Sievert (Sv) = biologically weighted dose.\n'
            '1 Gy = 100 rad, 1 Sv = 100 rem.';
      case UnitCategory.radiationExposure:
        return 'Measures ionization in air.\n'
            '1 Roentgen ≈ 2.58 × 10⁻⁴ C/kg.';
      case UnitCategory.astronomicalLength:
        return 'For cosmic distances:\n'
            '1 AU ≈ 1.496 × 10¹¹ m (Earth–Sun distance)\n'
            '1 light-year ≈ 9.461 × 10¹⁵ m\n'
            '1 parsec ≈ 3.086 × 10¹⁶ m.';
      case UnitCategory.pace:
        return 'Running pace is the inverse of speed.\n'
            'Min/km and min/mile measure time per distance.\n'
            'Lower values = faster runner.';
      case UnitCategory.heartRate:
        return 'Heart rate is measured in beats per minute (bpm).\n'
            'Normal resting HR: 60–100 bpm.\n'
            '1 bps = 60 bpm.';
      case UnitCategory.bloodSugar:
        return 'Blood glucose is measured in mg/dL (US) or mmol/L (international).\n'
            '1 mmol/L = 18.0182 mg/dL.\n'
            'Normal fasting: 70–100 mg/dL.';
      case UnitCategory.bloodPressure:
        return 'Blood pressure is measured in mmHg.\n'
            '1 mmHg = 0.133322 kPa.\n'
            'Normal: 120/80 mmHg (systolic/diastolic).';
      case UnitCategory.bmi:
        return 'BMI = weight (kg) / height² (m²).\n'
            'Underweight: < 18.5\n'
            'Normal: 18.5–24.9\n'
            'Overweight: 25–29.9\n'
            'Obese: ≥ 30.';
      case UnitCategory.percentageRatio:
        return '1% = 0.01 fraction = 10,000 ppm = 1 per mille × 10.\n'
            'Percent literally means "per hundred".';
      case UnitCategory.soundLevel:
        return 'Decibels are a logarithmic unit of sound intensity.\n'
            'dB SPL uses 20 μPa as reference (threshold of hearing).\n'
            'dB(A) applies a frequency weighting filter.\n'
            'Note: dB values are direct labels, not converted by factor.';
      case UnitCategory.concentration:
        return 'SI unit is mol/m³.\n'
            '1 mol/L (M) = 1000 mol/m³\n'
            '1 g/L = depends on molar mass of solute.';
      case UnitCategory.magneticField:
        return 'SI unit is Tesla (T).\n'
            '1 T = 10,000 Gauss (G)\n'
            '1 mT = 10 Gauss.';
      case UnitCategory.magneticFlux:
        return 'SI unit is Weber (Wb).\n'
            '1 Wb = 10⁸ Maxwell (Mx)\n'
            '1 mWb = 10⁵ Maxwell.';
      case UnitCategory.wavenumber:
        return 'Wavenumber = 1/wavelength.\n'
            '1 cm⁻¹ = 100 m⁻¹.\n'
            'Used in infrared and Raman spectroscopy.';
    }
  }
}

// ════════════════════════════════════════════════════════════════
// Unit Data Map
// ════════════════════════════════════════════════════════════════

/// Complete dataset of all convertible units organized by category.
const Map<UnitCategory, List<UnitModel>> unitsData = {
  // ── Length (base: meter) ──────────────────────────────────────
  UnitCategory.length: [
    UnitModel(name: 'Meter', symbol: 'm', toBase: 1),
    UnitModel(name: 'Kilometer', symbol: 'km', toBase: 1000),
    UnitModel(name: 'Centimeter', symbol: 'cm', toBase: 0.01),
    UnitModel(name: 'Millimeter', symbol: 'mm', toBase: 0.001),
    UnitModel(name: 'Micrometer', symbol: 'μm', toBase: 1e-6),
    UnitModel(name: 'Nanometer', symbol: 'nm', toBase: 1e-9),
    UnitModel(name: 'Mile', symbol: 'mi', toBase: 1609.344),
    UnitModel(name: 'Yard', symbol: 'yd', toBase: 0.9144),
    UnitModel(name: 'Foot', symbol: 'ft', toBase: 0.3048),
    UnitModel(name: 'Inch', symbol: 'in', toBase: 0.0254),
    UnitModel(name: 'Nautical Mile', symbol: 'nmi', toBase: 1852),
    UnitModel(name: 'Furlong', symbol: 'fur', toBase: 201.168),
    UnitModel(name: 'Fathom', symbol: 'ftm', toBase: 1.8288),
    UnitModel(name: 'Chain', symbol: 'ch', toBase: 20.1168),
    UnitModel(name: 'Angstrom', symbol: 'Å', toBase: 1e-10),
  ],

  // ── Weight / Mass (base: kilogram) ──────────────────────────
  UnitCategory.weight: [
    UnitModel(name: 'Kilogram', symbol: 'kg', toBase: 1),
    UnitModel(name: 'Gram', symbol: 'g', toBase: 0.001),
    UnitModel(name: 'Milligram', symbol: 'mg', toBase: 0.000001),
    UnitModel(name: 'Microgram', symbol: 'μg', toBase: 1e-9),
    UnitModel(name: 'Tonne', symbol: 't', toBase: 1000),
    UnitModel(name: 'Pound', symbol: 'lb', toBase: 0.45359237),
    UnitModel(name: 'Ounce', symbol: 'oz', toBase: 0.028349523),
    UnitModel(name: 'Stone', symbol: 'st', toBase: 6.35029318),
    UnitModel(name: 'Short Ton (US)', symbol: 'US ton', toBase: 907.18474),
    UnitModel(name: 'Long Ton (UK)', symbol: 'UK ton', toBase: 1016.04691),
    UnitModel(name: 'Carat', symbol: 'ct', toBase: 0.0002),
    UnitModel(name: 'Grain', symbol: 'gr', toBase: 0.00006479891),
    UnitModel(name: 'Troy Ounce', symbol: 'troy oz', toBase: 0.031103476),
  ],

  // ── Temperature (special formula, no multiplier) ─────────────
  UnitCategory.temperature: [
    UnitModel(name: 'Celsius', symbol: '°C', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Fahrenheit', symbol: '°F', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Kelvin', symbol: 'K', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Rankine', symbol: '°R', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Delisle', symbol: '°De', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Newton', symbol: '°N', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Réaumur', symbol: '°Ré', toBase: 1, isSpecialCase: true),
  ],

  // ── Area (base: square meter) ─────────────────────────────────
  UnitCategory.area: [
    UnitModel(name: 'Square Meter', symbol: 'm²', toBase: 1),
    UnitModel(name: 'Square Kilometer', symbol: 'km²', toBase: 1e6),
    UnitModel(name: 'Square Centimeter', symbol: 'cm²', toBase: 0.0001),
    UnitModel(name: 'Square Millimeter', symbol: 'mm²', toBase: 1e-6),
    UnitModel(name: 'Square Foot', symbol: 'ft²', toBase: 0.09290304),
    UnitModel(name: 'Square Inch', symbol: 'in²', toBase: 0.00064516),
    UnitModel(name: 'Square Yard', symbol: 'yd²', toBase: 0.83612736),
    UnitModel(name: 'Square Mile', symbol: 'mi²', toBase: 2589988.11),
    UnitModel(name: 'Acre', symbol: 'ac', toBase: 4046.8564224),
    UnitModel(name: 'Hectare', symbol: 'ha', toBase: 10000),
    UnitModel(name: 'Are', symbol: 'a', toBase: 100),
    UnitModel(name: 'Barn', symbol: 'b', toBase: 1e-28),
  ],

  // ── Volume (base: cubic meter) ────────────────────────────────
  UnitCategory.volume: [
    UnitModel(name: 'Cubic Meter', symbol: 'm³', toBase: 1),
    UnitModel(name: 'Liter', symbol: 'L', toBase: 0.001),
    UnitModel(name: 'Milliliter', symbol: 'mL', toBase: 0.000001),
    UnitModel(name: 'Centiliter', symbol: 'cL', toBase: 0.00001),
    UnitModel(name: 'Cubic Centimeter', symbol: 'cm³', toBase: 0.000001),
    UnitModel(name: 'Cubic Inch', symbol: 'in³', toBase: 0.000016387064),
    UnitModel(name: 'Cubic Foot', symbol: 'ft³', toBase: 0.028316846592),
    UnitModel(name: 'Cubic Yard', symbol: 'yd³', toBase: 0.764554857984),
    UnitModel(name: 'Gallon (US)', symbol: 'gal (US)', toBase: 0.003785411784),
    UnitModel(name: 'Gallon (UK)', symbol: 'gal (UK)', toBase: 0.00454609),
    UnitModel(name: 'Quart (US)', symbol: 'qt (US)', toBase: 0.000946352946),
    UnitModel(name: 'Pint (US)', symbol: 'pt (US)', toBase: 0.000473176473),
    UnitModel(name: 'Pint (UK)', symbol: 'pt (UK)', toBase: 0.00056826125),
    UnitModel(name: 'Cup', symbol: 'cup', toBase: 0.0002365882365),
    UnitModel(name: 'Fluid Ounce (US)', symbol: 'fl oz (US)', toBase: 0.000029573529563),
    UnitModel(name: 'Fluid Ounce (UK)', symbol: 'fl oz (UK)', toBase: 0.0000284130625),
    UnitModel(name: 'Tablespoon', symbol: 'tbsp', toBase: 0.000014786764782),
    UnitModel(name: 'Teaspoon', symbol: 'tsp', toBase: 0.000004928921594),
    UnitModel(name: 'Barrel (oil)', symbol: 'bbl', toBase: 0.158987294928),
  ],

  // ── Speed (base: m/s) ─────────────────────────────────────────
  UnitCategory.speed: [
    UnitModel(name: 'Meters per Second', symbol: 'm/s', toBase: 1),
    UnitModel(name: 'Kilometers per Hour', symbol: 'km/h', toBase: 1 / 3.6),
    UnitModel(name: 'Miles per Hour', symbol: 'mph', toBase: 0.44704),
    UnitModel(name: 'Knot', symbol: 'kn', toBase: 0.514444),
    UnitModel(name: 'Foot per Second', symbol: 'ft/s', toBase: 0.3048),
    UnitModel(name: 'Mach (at sea level)', symbol: 'Ma', toBase: 340.29),
    UnitModel(name: 'Speed of Light', symbol: 'c', toBase: 299792458),
    UnitModel(name: 'Kilometer per Second', symbol: 'km/s', toBase: 1000),
  ],

  // ── Data (base: byte) ─────────────────────────────────────────
  UnitCategory.data: [
    UnitModel(name: 'Bit', symbol: 'bit', toBase: 0.125),
    UnitModel(name: 'Byte', symbol: 'B', toBase: 1),
    UnitModel(name: 'Kilobyte', symbol: 'KB', toBase: 1024),
    UnitModel(name: 'Megabyte', symbol: 'MB', toBase: 1048576),
    UnitModel(name: 'Gigabyte', symbol: 'GB', toBase: 1073741824),
    UnitModel(name: 'Terabyte', symbol: 'TB', toBase: 1099511627776),
    UnitModel(name: 'Petabyte', symbol: 'PB', toBase: 1125899906842624),
    UnitModel(name: 'Kibibyte', symbol: 'KiB', toBase: 1024),
    UnitModel(name: 'Mebibyte', symbol: 'MiB', toBase: 1048576),
    UnitModel(name: 'Gibibyte', symbol: 'GiB', toBase: 1073741824),
    UnitModel(name: 'Tebibyte', symbol: 'TiB', toBase: 1099511627776),
    UnitModel(name: 'Nibble', symbol: 'nibble', toBase: 0.5),
  ],

  // ── Time (base: second) ───────────────────────────────────────
  UnitCategory.time: [
    UnitModel(name: 'Nanosecond', symbol: 'ns', toBase: 1e-9),
    UnitModel(name: 'Microsecond', symbol: 'μs', toBase: 1e-6),
    UnitModel(name: 'Millisecond', symbol: 'ms', toBase: 0.001),
    UnitModel(name: 'Second', symbol: 's', toBase: 1),
    UnitModel(name: 'Minute', symbol: 'min', toBase: 60),
    UnitModel(name: 'Hour', symbol: 'hr', toBase: 3600),
    UnitModel(name: 'Day', symbol: 'day', toBase: 86400),
    UnitModel(name: 'Week', symbol: 'wk', toBase: 604800),
    UnitModel(name: 'Month', symbol: 'mo', toBase: 2629746),
    UnitModel(name: 'Year', symbol: 'yr', toBase: 31556952),
    UnitModel(name: 'Decade', symbol: 'dec', toBase: 315569520),
    UnitModel(name: 'Century', symbol: 'cen', toBase: 3155695200),
    UnitModel(name: 'Fortnight', symbol: 'fn', toBase: 1209600),
  ],

  // ── Angle (base: radian) ──────────────────────────────────────
  UnitCategory.angle: [
    UnitModel(name: 'Radian', symbol: 'rad', toBase: 1),
    UnitModel(name: 'Degree', symbol: '°', toBase: math.pi / 180),
    UnitModel(name: 'Gradian', symbol: 'grad', toBase: math.pi / 200),
    UnitModel(name: 'Arcminute', symbol: "'", toBase: math.pi / (180 * 60)),
    UnitModel(name: 'Arcsecond', symbol: '"', toBase: math.pi / (180 * 3600)),
    UnitModel(name: 'Turn', symbol: 'turn', toBase: 2 * math.pi),
    UnitModel(name: 'Milliradian', symbol: 'mrad', toBase: 0.001),
    UnitModel(name: 'Quadrant', symbol: 'quad', toBase: math.pi / 2),
  ],

  // ── Energy (base: joule) ──────────────────────────────────────
  UnitCategory.energy: [
    UnitModel(name: 'Joule', symbol: 'J', toBase: 1),
    UnitModel(name: 'Kilojoule', symbol: 'kJ', toBase: 1000),
    UnitModel(name: 'Megajoule', symbol: 'MJ', toBase: 1000000),
    UnitModel(name: 'Calorie', symbol: 'cal', toBase: 4.184),
    UnitModel(name: 'Kilocalorie', symbol: 'kcal', toBase: 4184),
    UnitModel(name: 'Kilowatt-hour', symbol: 'kWh', toBase: 3600000),
    UnitModel(name: 'Megawatt-hour', symbol: 'MWh', toBase: 3600000000),
    UnitModel(name: 'BTU', symbol: 'BTU', toBase: 1055.05585),
    UnitModel(name: 'Therm (US)', symbol: 'thm', toBase: 105480400),
    UnitModel(name: 'Electronvolt', symbol: 'eV', toBase: 1.602176634e-19),
    UnitModel(name: 'Foot-pound', symbol: 'ft·lb', toBase: 1.35581794833),
    UnitModel(name: 'Erg', symbol: 'erg', toBase: 1e-7),
    UnitModel(name: 'Watt-second', symbol: 'Ws', toBase: 1),
    UnitModel(name: 'Watt-hour', symbol: 'Wh', toBase: 3600),
  ],

  // ── Power (base: watt) ────────────────────────────────────────
  UnitCategory.power: [
    UnitModel(name: 'Watt', symbol: 'W', toBase: 1),
    UnitModel(name: 'Milliwatt', symbol: 'mW', toBase: 0.001),
    UnitModel(name: 'Kilowatt', symbol: 'kW', toBase: 1000),
    UnitModel(name: 'Megawatt', symbol: 'MW', toBase: 1000000),
    UnitModel(name: 'Gigawatt', symbol: 'GW', toBase: 1000000000),
    UnitModel(name: 'Horsepower', symbol: 'hp', toBase: 745.69987158),
    UnitModel(name: 'Metric Horsepower', symbol: 'PS', toBase: 735.49875),
    UnitModel(name: 'BTU per Hour', symbol: 'BTU/h', toBase: 0.29307107),
    UnitModel(name: 'BTU per Minute', symbol: 'BTU/min', toBase: 17.5842642),
    UnitModel(name: 'Foot-pound per Second', symbol: 'ft·lb/s', toBase: 1.35581795),
  ],

  // ── Pressure (base: pascal) ───────────────────────────────────
  UnitCategory.pressure: [
    UnitModel(name: 'Pascal', symbol: 'Pa', toBase: 1),
    UnitModel(name: 'Kilopascal', symbol: 'kPa', toBase: 1000),
    UnitModel(name: 'Megapascal', symbol: 'MPa', toBase: 1000000),
    UnitModel(name: 'Bar', symbol: 'bar', toBase: 100000),
    UnitModel(name: 'Millibar', symbol: 'mbar', toBase: 100),
    UnitModel(name: 'PSI', symbol: 'psi', toBase: 6894.757293168),
    UnitModel(name: 'Atmosphere', symbol: 'atm', toBase: 101325),
    UnitModel(name: 'Torr', symbol: 'Torr', toBase: 133.322387415),
    UnitModel(name: 'mmHg', symbol: 'mmHg', toBase: 133.322387415),
    UnitModel(name: 'inHg', symbol: 'inHg', toBase: 3386.3886666667),
    UnitModel(name: 'cmH₂O', symbol: 'cmH₂O', toBase: 98.0665),
    UnitModel(name: 'kgf/cm²', symbol: 'kgf/cm²', toBase: 98066.5),
  ],

  // ── Force (base: newton) ──────────────────────────────────────
  UnitCategory.force: [
    UnitModel(name: 'Newton', symbol: 'N', toBase: 1),
    UnitModel(name: 'Kilonewton', symbol: 'kN', toBase: 1000),
    UnitModel(name: 'Meganewton', symbol: 'MN', toBase: 1000000),
    UnitModel(name: 'Dyne', symbol: 'dyn', toBase: 0.00001),
    UnitModel(name: 'Pound-force', symbol: 'lbf', toBase: 4.448221615),
    UnitModel(name: 'Kilogram-force', symbol: 'kgf', toBase: 9.80665),
    UnitModel(name: 'Ounce-force', symbol: 'ozf', toBase: 0.278013850953),
    UnitModel(name: 'Poundal', symbol: 'pdl', toBase: 0.138254954376),
  ],

  // ── Frequency (base: hertz) ───────────────────────────────────
  UnitCategory.frequency: [
    UnitModel(name: 'Hertz', symbol: 'Hz', toBase: 1),
    UnitModel(name: 'Kilohertz', symbol: 'kHz', toBase: 1000),
    UnitModel(name: 'Megahertz', symbol: 'MHz', toBase: 1000000),
    UnitModel(name: 'Gigahertz', symbol: 'GHz', toBase: 1000000000),
    UnitModel(name: 'Terahertz', symbol: 'THz', toBase: 1000000000000),
    UnitModel(name: 'Revolution per Minute', symbol: 'RPM', toBase: 1 / 60),
    UnitModel(name: 'Radian per Second', symbol: 'rad/s', toBase: 1 / (2 * math.pi)),
    UnitModel(name: 'Cycle per Second', symbol: 'cps', toBase: 1),
  ],

  // ── Fuel Economy (base: km/L, special case) ───────────────────
  UnitCategory.fuelEconomy: [
    UnitModel(name: 'Kilometers per Liter', symbol: 'km/L', toBase: 1),
    UnitModel(name: 'Liters per 100km', symbol: 'L/100km', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'MPG (US)', symbol: 'mpg (US)', toBase: 0.425143707),
    UnitModel(name: 'MPG (UK)', symbol: 'mpg (UK)', toBase: 0.354006189),
    UnitModel(name: 'Miles per Liter', symbol: 'mi/L', toBase: 1.60934),
    UnitModel(name: 'Liters per Mile', symbol: 'L/mi', toBase: 1, isSpecialCase: true),
  ],

  // ── Cooking (volume + weight groups, no cross-conversion) ─────
  UnitCategory.cooking: [
    UnitModel(name: 'Cup (US)', symbol: 'cup', toBase: 236.588, group: 'volume'),
    UnitModel(name: 'Tablespoon', symbol: 'tbsp', toBase: 14.7868, group: 'volume'),
    UnitModel(name: 'Teaspoon', symbol: 'tsp', toBase: 4.92892, group: 'volume'),
    UnitModel(name: 'Fluid Ounce', symbol: 'fl oz', toBase: 29.5735, group: 'volume'),
    UnitModel(name: 'Milliliter', symbol: 'mL', toBase: 1, group: 'volume'),
    UnitModel(name: 'Liter', symbol: 'L', toBase: 1000, group: 'volume'),
    UnitModel(name: 'Pint (US)', symbol: 'pt', toBase: 473.176, group: 'volume'),
    UnitModel(name: 'Gram', symbol: 'g', toBase: 1, group: 'weight'),
    UnitModel(name: 'Kilogram', symbol: 'kg', toBase: 1000, group: 'weight'),
    UnitModel(name: 'Ounce', symbol: 'oz', toBase: 28.3495, group: 'weight'),
    UnitModel(name: 'Pound', symbol: 'lb', toBase: 453.592, group: 'weight'),
  ],

  // ── Shoe Size (special formula via CM, 0.5 rounding) ──────────
  UnitCategory.shoeSize: [
    UnitModel(name: 'EU', symbol: 'EU', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'UK', symbol: 'UK', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'US Men', symbol: 'US (M)', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'US Women', symbol: 'US (W)', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'CM', symbol: 'cm', toBase: 1, isSpecialCase: true),
  ],

  // ── Clothing Size (special formula via US numeric) ────────────
  UnitCategory.clothingSize: [
    UnitModel(name: 'US', symbol: 'US', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'EU', symbol: 'EU', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'UK', symbol: 'UK', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Asian', symbol: 'AS', toBase: 1, isSpecialCase: true),
  ],

  // ── Number Base (int-parsed via radix) ────────────────────────
  UnitCategory.numberBase: [
    UnitModel(name: 'Binary', symbol: 'bin', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Octal', symbol: 'oct', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Decimal', symbol: 'dec', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Hexadecimal', symbol: 'hex', toBase: 1, isSpecialCase: true),
  ],

  // ── Typography (base: px) ─────────────────────────────────────
  UnitCategory.typography: [
    UnitModel(name: 'Pixels', symbol: 'px', toBase: 1),
    UnitModel(name: 'DP', symbol: 'dp', toBase: 0.6),
    UnitModel(name: 'Points', symbol: 'pt', toBase: 1.333333),
    UnitModel(name: 'EM', symbol: 'em', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'REM', symbol: 'rem', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Percent', symbol: '%', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Inch', symbol: 'in', toBase: 96),
    UnitModel(name: 'Centimeter', symbol: 'cm', toBase: 37.7952755906),
    UnitModel(name: 'Millimeter', symbol: 'mm', toBase: 3.77952755906),
    UnitModel(name: 'Pica', symbol: 'pc', toBase: 16),
  ],

  // ────────────────────────────────────────────────────────────
  // ELECTRICAL
  // ────────────────────────────────────────────────────────────

  // ── Voltage (base: volt) ──────────────────────────────────────
  UnitCategory.voltage: [
    UnitModel(name: 'Volt', symbol: 'V', toBase: 1),
    UnitModel(name: 'Millivolt', symbol: 'mV', toBase: 0.001),
    UnitModel(name: 'Microvolt', symbol: 'μV', toBase: 0.000001),
    UnitModel(name: 'Kilovolt', symbol: 'kV', toBase: 1000),
    UnitModel(name: 'Megavolt', symbol: 'MV', toBase: 1000000),
    UnitModel(name: 'Gigavolt', symbol: 'GV', toBase: 1000000000),
    UnitModel(name: 'Nanovolt', symbol: 'nV', toBase: 1e-9),
    UnitModel(name: 'Abvolt', symbol: 'abV', toBase: 1e-8),
    UnitModel(name: 'Statvolt', symbol: 'statV', toBase: 299.792458),
  ],

  // ── Current (base: ampere) ────────────────────────────────────
  UnitCategory.current: [
    UnitModel(name: 'Ampere', symbol: 'A', toBase: 1),
    UnitModel(name: 'Milliampere', symbol: 'mA', toBase: 0.001),
    UnitModel(name: 'Microampere', symbol: 'μA', toBase: 0.000001),
    UnitModel(name: 'Kiloampere', symbol: 'kA', toBase: 1000),
    UnitModel(name: 'Nanoampere', symbol: 'nA', toBase: 1e-9),
    UnitModel(name: 'Biot', symbol: 'Bi', toBase: 10),
    UnitModel(name: 'Statampere', symbol: 'statA', toBase: 3.335641e-10),
    UnitModel(name: 'Abampere', symbol: 'abA', toBase: 10),
  ],

  // ── Resistance (base: ohm) ────────────────────────────────────
  UnitCategory.resistance: [
    UnitModel(name: 'Ohm', symbol: 'Ω', toBase: 1),
    UnitModel(name: 'Milliohm', symbol: 'mΩ', toBase: 0.001),
    UnitModel(name: 'Microohm', symbol: 'μΩ', toBase: 0.000001),
    UnitModel(name: 'Kilohm', symbol: 'kΩ', toBase: 1000),
    UnitModel(name: 'Megohm', symbol: 'MΩ', toBase: 1000000),
    UnitModel(name: 'Gigohm', symbol: 'GΩ', toBase: 1000000000),
    UnitModel(name: 'Abohm', symbol: 'abΩ', toBase: 1e-9),
    UnitModel(name: 'Statohm', symbol: 'statΩ', toBase: 898755178740),
  ],

  // ── Capacitance (base: farad) ─────────────────────────────────
  UnitCategory.capacitance: [
    UnitModel(name: 'Farad', symbol: 'F', toBase: 1),
    UnitModel(name: 'Millifarad', symbol: 'mF', toBase: 0.001),
    UnitModel(name: 'Microfarad', symbol: 'μF', toBase: 0.000001),
    UnitModel(name: 'Nanofarad', symbol: 'nF', toBase: 1e-9),
    UnitModel(name: 'Picofarad', symbol: 'pF', toBase: 1e-12),
    UnitModel(name: 'Attofarad', symbol: 'aF', toBase: 1e-18),
  ],

  // ── Inductance (base: henry) ──────────────────────────────────
  UnitCategory.inductance: [
    UnitModel(name: 'Henry', symbol: 'H', toBase: 1),
    UnitModel(name: 'Millihenry', symbol: 'mH', toBase: 0.001),
    UnitModel(name: 'Microhenry', symbol: 'μH', toBase: 0.000001),
    UnitModel(name: 'Nanohenry', symbol: 'nH', toBase: 1e-9),
    UnitModel(name: 'Kilohenry', symbol: 'kH', toBase: 1000),
  ],

  // ── Electric Charge (base: coulomb) ───────────────────────────
  UnitCategory.electricCharge: [
    UnitModel(name: 'Coulomb', symbol: 'C', toBase: 1),
    UnitModel(name: 'Millicoulomb', symbol: 'mC', toBase: 0.001),
    UnitModel(name: 'Microcoulomb', symbol: 'μC', toBase: 0.000001),
    UnitModel(name: 'Nanocoulomb', symbol: 'nC', toBase: 1e-9),
    UnitModel(name: 'Picocoulomb', symbol: 'pC', toBase: 1e-12),
    UnitModel(name: 'Ampere-hour', symbol: 'Ah', toBase: 3600),
    UnitModel(name: 'Milliampere-hour', symbol: 'mAh', toBase: 3.6),
    UnitModel(name: 'Faraday (charge)', symbol: 'F (charge)', toBase: 96485.33212),
    UnitModel(name: 'Electron Charge', symbol: 'e', toBase: 1.602176634e-19),
  ],

  // ── Conductance (base: siemens) ───────────────────────────────
  UnitCategory.conductance: [
    UnitModel(name: 'Siemens', symbol: 'S', toBase: 1),
    UnitModel(name: 'Millisiemens', symbol: 'mS', toBase: 0.001),
    UnitModel(name: 'Microsiemens', symbol: 'μS', toBase: 0.000001),
    UnitModel(name: 'Mho', symbol: 'mho', toBase: 1),
    UnitModel(name: 'Kilosiemens', symbol: 'kS', toBase: 1000),
    UnitModel(name: 'Megasiemens', symbol: 'MS', toBase: 1000000),
  ],

  // ────────────────────────────────────────────────────────────
  // LIGHT
  // ────────────────────────────────────────────────────────────

  // ── Illuminance (base: lux) ───────────────────────────────────
  UnitCategory.illuminance: [
    UnitModel(name: 'Lux', symbol: 'lx', toBase: 1),
    UnitModel(name: 'Kilolux', symbol: 'klx', toBase: 1000),
    UnitModel(name: 'Foot-candle', symbol: 'fc', toBase: 10.7639104167),
    UnitModel(name: 'Phot', symbol: 'ph', toBase: 10000),
    UnitModel(name: 'Nox', symbol: 'nox', toBase: 0.001),
    UnitModel(name: 'Millilux', symbol: 'mlx', toBase: 0.001),
  ],

  // ── Luminous Flux (base: lumen) ───────────────────────────────
  UnitCategory.luminousFlux: [
    UnitModel(name: 'Lumen', symbol: 'lm', toBase: 1),
    UnitModel(name: 'Kilolumen', symbol: 'klm', toBase: 1000),
    UnitModel(name: 'Millilumen', symbol: 'mlm', toBase: 0.001),
    UnitModel(name: 'Candela Steradian', symbol: 'cd·sr', toBase: 1),
  ],

  // ── Luminous Intensity (base: candela) ────────────────────────
  UnitCategory.luminousIntensity: [
    UnitModel(name: 'Candela', symbol: 'cd', toBase: 1),
    UnitModel(name: 'Millicandela', symbol: 'mcd', toBase: 0.001),
    UnitModel(name: 'Kilocandela', symbol: 'kcd', toBase: 1000),
    UnitModel(name: 'Hefner Candle', symbol: 'HK', toBase: 0.903),
    UnitModel(name: 'Carcel', symbol: 'car', toBase: 9.74),
  ],

  // ── Luminance (base: cd/m²) ───────────────────────────────────
  UnitCategory.luminance: [
    UnitModel(name: 'Candela per Square Meter', symbol: 'cd/m²', toBase: 1),
    UnitModel(name: 'Nit', symbol: 'nt', toBase: 1),
    UnitModel(name: 'Kilocandela per Square Meter', symbol: 'kcd/m²', toBase: 1000),
    UnitModel(name: 'Stilb', symbol: 'sb', toBase: 10000),
    UnitModel(name: 'Lambert', symbol: 'L', toBase: 3183.098861837907),
    UnitModel(name: 'Foot-lambert', symbol: 'fL', toBase: 3.426259),
    UnitModel(name: 'Apostilb', symbol: 'asb', toBase: 1 / math.pi),
    UnitModel(name: 'Skot', symbol: 'sk', toBase: 1e-3 / math.pi),
  ],

  // ────────────────────────────────────────────────────────────
  // HEAT & THERMODYNAMICS
  // ────────────────────────────────────────────────────────────

  // ── Specific Heat (base: J/(kg·K)) ───────────────────────────
  UnitCategory.specificHeat: [
    UnitModel(name: 'J/(kg·K)', symbol: 'J/(kg·K)', toBase: 1),
    UnitModel(name: 'kJ/(kg·K)', symbol: 'kJ/(kg·K)', toBase: 1000),
    UnitModel(name: 'cal/(g·°C)', symbol: 'cal/(g·°C)', toBase: 4186.8),
    UnitModel(name: 'kcal/(kg·°C)', symbol: 'kcal/(kg·°C)', toBase: 4186.8),
    UnitModel(name: 'BTU/(lb·°F)', symbol: 'BTU/(lb·°F)', toBase: 4186.8),
    UnitModel(name: 'BTU/(lb·°R)', symbol: 'BTU/(lb·°R)', toBase: 4186.8),
    UnitModel(name: 'J/(mol·K)', symbol: 'J/(mol·K)', toBase: 1),
  ],

  // ── Thermal Conductivity (base: W/(m·K)) ─────────────────────
  UnitCategory.thermalConductivity: [
    UnitModel(name: 'W/(m·K)', symbol: 'W/(m·K)', toBase: 1),
    UnitModel(name: 'W/(cm·K)', symbol: 'W/(cm·K)', toBase: 100),
    UnitModel(name: 'kW/(m·K)', symbol: 'kW/(m·K)', toBase: 1000),
    UnitModel(name: 'BTU/(h·ft·°F)', symbol: 'BTU/(h·ft·°F)', toBase: 1.730734666),
    UnitModel(name: 'BTU/(s·ft·°F)', symbol: 'BTU/(s·ft·°F)', toBase: 6230.64),
    UnitModel(name: 'cal/(s·cm·°C)', symbol: 'cal/(s·cm·°C)', toBase: 418.68),
    UnitModel(name: 'kcal/(h·m·°C)', symbol: 'kcal/(h·m·°C)', toBase: 1.163),
  ],

  // ── Thermal Resistance (base: °C/W) ──────────────────────────
  UnitCategory.thermalResistance: [
    UnitModel(name: '°C/W', symbol: '°C/W', toBase: 1),
    UnitModel(name: '°F·h/BTU', symbol: '°F·h/BTU', toBase: 0.52752792),
    UnitModel(name: 'R-value (US)', symbol: 'R (US)', toBase: 0.17611019),
    UnitModel(name: 'RSI (SI)', symbol: 'RSI', toBase: 1),
    UnitModel(name: 'K/W', symbol: 'K/W', toBase: 1),
    UnitModel(name: 'K·m²/W', symbol: 'K·m²/W', toBase: 1),
  ],

  // ── Heat Flux Density (base: W/m²) ───────────────────────────
  UnitCategory.heatFluxDensity: [
    UnitModel(name: 'Watt per Square Meter', symbol: 'W/m²', toBase: 1),
    UnitModel(name: 'Kilowatt per Square Meter', symbol: 'kW/m²', toBase: 1000),
    UnitModel(name: 'BTU/(h·ft²)', symbol: 'BTU/(h·ft²)', toBase: 3.154591),
    UnitModel(name: 'BTU/(s·ft²)', symbol: 'BTU/(s·ft²)', toBase: 11356.53),
    UnitModel(name: 'cal/(s·cm²)', symbol: 'cal/(s·cm²)', toBase: 41868),
    UnitModel(name: 'kcal/(h·m²)', symbol: 'kcal/(h·m²)', toBase: 1.163),
    UnitModel(name: 'Langley per Minute', symbol: 'Ly/min', toBase: 697.8),
  ],

  // ────────────────────────────────────────────────────────────
  // PHYSICS
  // ────────────────────────────────────────────────────────────

  // ── Torque (base: N·m) ────────────────────────────────────────
  UnitCategory.torque: [
    UnitModel(name: 'Newton-meter', symbol: 'N·m', toBase: 1),
    UnitModel(name: 'Kilonewton-meter', symbol: 'kN·m', toBase: 1000),
    UnitModel(name: 'Millinewton-meter', symbol: 'mN·m', toBase: 0.001),
    UnitModel(name: 'Foot-pound', symbol: 'ft·lb', toBase: 1.35581794833),
    UnitModel(name: 'Inch-pound', symbol: 'in·lb', toBase: 0.11298482933),
    UnitModel(name: 'Inch-ounce', symbol: 'in·oz', toBase: 0.00706155183),
    UnitModel(name: 'Kilogram-force meter', symbol: 'kgf·m', toBase: 9.80665),
    UnitModel(name: 'Gram-force centimeter', symbol: 'gf·cm', toBase: 0.0000980665),
    UnitModel(name: 'Dyne-centimeter', symbol: 'dyn·cm', toBase: 0.0000001),
  ],

  // ── Momentum (base: kg·m/s) ───────────────────────────────────
  UnitCategory.momentum: [
    UnitModel(name: 'Kilogram meter per second', symbol: 'kg·m/s', toBase: 1),
    UnitModel(name: 'Gram cm/s', symbol: 'g·cm/s', toBase: 0.00001),
    UnitModel(name: 'Pound foot per second', symbol: 'lb·ft/s', toBase: 0.138254954),
    UnitModel(name: 'Slug foot per second', symbol: 'slug·ft/s', toBase: 4.44822162),
    UnitModel(name: 'Newton-second', symbol: 'N·s', toBase: 1),
  ],

  // ── Angular Velocity (base: rad/s) ────────────────────────────
  UnitCategory.angularVelocity: [
    UnitModel(name: 'Radian per Second', symbol: 'rad/s', toBase: 1),
    UnitModel(name: 'Degree per Second', symbol: '°/s', toBase: math.pi / 180),
    UnitModel(name: 'Revolution per Minute', symbol: 'RPM', toBase: 2 * math.pi / 60),
    UnitModel(name: 'Revolution per Second', symbol: 'RPS', toBase: 2 * math.pi),
    UnitModel(name: 'Gradian per Second', symbol: 'grad/s', toBase: math.pi / 200),
    UnitModel(name: 'Revolution per Hour', symbol: 'RPH', toBase: 2 * math.pi / 3600),
  ],

  // ── Density (base: kg/m³) ─────────────────────────────────────
  UnitCategory.density: [
    UnitModel(name: 'Kilogram per Cubic Meter', symbol: 'kg/m³', toBase: 1),
    UnitModel(name: 'Gram per Cubic Centimeter', symbol: 'g/cm³', toBase: 1000),
    UnitModel(name: 'Gram per Liter', symbol: 'g/L', toBase: 1),
    UnitModel(name: 'Kilogram per Liter', symbol: 'kg/L', toBase: 1000),
    UnitModel(name: 'Milligram per Liter', symbol: 'mg/L', toBase: 0.001),
    UnitModel(name: 'Pound per Cubic Foot', symbol: 'lb/ft³', toBase: 16.0184634),
    UnitModel(name: 'Pound per Cubic Inch', symbol: 'lb/in³', toBase: 27679.9047),
    UnitModel(name: 'Ounce per Cubic Foot', symbol: 'oz/ft³', toBase: 1.00115397),
    UnitModel(name: 'Pound per Gallon (US)', symbol: 'lb/gal (US)', toBase: 119.826427),
    UnitModel(name: 'Pound per Gallon (UK)', symbol: 'lb/gal (UK)', toBase: 99.7763726),
    UnitModel(name: 'Tonne per Cubic Meter', symbol: 't/m³', toBase: 1000),
  ],

  // ── Surface Tension (base: N/m) ───────────────────────────────
  UnitCategory.surfaceTension: [
    UnitModel(name: 'Newton per Meter', symbol: 'N/m', toBase: 1),
    UnitModel(name: 'Millinewton per Meter', symbol: 'mN/m', toBase: 0.001),
    UnitModel(name: 'Dyne per Centimeter', symbol: 'dyn/cm', toBase: 0.001),
    UnitModel(name: 'Pound-force per Inch', symbol: 'lbf/in', toBase: 175.1268),
    UnitModel(name: 'Pound-force per Foot', symbol: 'lbf/ft', toBase: 14.5939),
    UnitModel(name: 'Erg per Square Centimeter', symbol: 'erg/cm²', toBase: 0.001),
  ],

  // ── Kinematic Viscosity (base: m²/s) ─────────────────────────
  UnitCategory.kinematicViscosity: [
    UnitModel(name: 'Square Meter per Second', symbol: 'm²/s', toBase: 1),
    UnitModel(name: 'Square Centimeter per Second', symbol: 'cm²/s', toBase: 0.0001),
    UnitModel(name: 'Square Millimeter per Second', symbol: 'mm²/s', toBase: 0.000001),
    UnitModel(name: 'Square Foot per Second', symbol: 'ft²/s', toBase: 0.09290304),
    UnitModel(name: 'Square Inch per Second', symbol: 'in²/s', toBase: 0.00064516),
    UnitModel(name: 'Stokes', symbol: 'St', toBase: 0.0001),
    UnitModel(name: 'Centistokes', symbol: 'cSt', toBase: 0.000001),
  ],

  // ── Dynamic Viscosity (base: Pa·s) ───────────────────────────
  UnitCategory.dynamicViscosity: [
    UnitModel(name: 'Pascal-second', symbol: 'Pa·s', toBase: 1),
    UnitModel(name: 'Millipascal-second', symbol: 'mPa·s', toBase: 0.001),
    UnitModel(name: 'Micropascal-second', symbol: 'μPa·s', toBase: 0.000001),
    UnitModel(name: 'Poise', symbol: 'P', toBase: 0.1),
    UnitModel(name: 'Centipoise', symbol: 'cP', toBase: 0.001),
    UnitModel(name: 'Pound-force second per Square Foot', symbol: 'lbf·s/ft²', toBase: 47.8802589803),
    UnitModel(name: 'Pound per Foot Second', symbol: 'lb/(ft·s)', toBase: 1.48816394),
    UnitModel(name: 'Pound per Foot Hour', symbol: 'lb/(ft·h)', toBase: 0.000413378),
  ],

  // ── Acceleration (base: m/s²) ─────────────────────────────────
  UnitCategory.acceleration: [
    UnitModel(name: 'Meter per Second Squared', symbol: 'm/s²', toBase: 1),
    UnitModel(name: 'Standard Gravity', symbol: 'g', toBase: 9.80665),
    UnitModel(name: 'Foot per Second Squared', symbol: 'ft/s²', toBase: 0.3048),
    UnitModel(name: 'Inch per Second Squared', symbol: 'in/s²', toBase: 0.0254),
    UnitModel(name: 'Kilometer per Second Squared', symbol: 'km/s²', toBase: 1000),
    UnitModel(name: 'Gal', symbol: 'Gal', toBase: 0.01),
    UnitModel(name: 'Milligal', symbol: 'mGal', toBase: 0.00001),
  ],

  // ────────────────────────────────────────────────────────────
  // ENGINEERING
  // ────────────────────────────────────────────────────────────

  // ── Flow Rate (base: m³/s) ────────────────────────────────────
  UnitCategory.flowRate: [
    UnitModel(name: 'Cubic Meter per Second', symbol: 'm³/s', toBase: 1),
    UnitModel(name: 'Cubic Meter per Hour', symbol: 'm³/h', toBase: 1 / 3600),
    UnitModel(name: 'Cubic Meter per Minute', symbol: 'm³/min', toBase: 1 / 60),
    UnitModel(name: 'Liter per Second', symbol: 'L/s', toBase: 0.001),
    UnitModel(name: 'Liter per Minute', symbol: 'L/min', toBase: 0.001 / 60),
    UnitModel(name: 'Liter per Hour', symbol: 'L/h', toBase: 0.001 / 3600),
    UnitModel(name: 'Gallon per Minute (US)', symbol: 'GPM (US)', toBase: 0.000063090196),
    UnitModel(name: 'Gallon per Hour (US)', symbol: 'GPH (US)', toBase: 0.000001051503),
    UnitModel(name: 'Gallon per Minute (UK)', symbol: 'GPM (UK)', toBase: 0.00007576819),
    UnitModel(name: 'Cubic Foot per Second', symbol: 'ft³/s', toBase: 0.028316847),
    UnitModel(name: 'Cubic Foot per Minute', symbol: 'ft³/min', toBase: 0.00047194745),
    UnitModel(name: 'Barrel per Day', symbol: 'bbl/day', toBase: 0.0000018401),
  ],

  // ── Mass Flow Rate (base: kg/s) ───────────────────────────────
  UnitCategory.massFlowRate: [
    UnitModel(name: 'Kilogram per Second', symbol: 'kg/s', toBase: 1),
    UnitModel(name: 'Kilogram per Minute', symbol: 'kg/min', toBase: 1 / 60),
    UnitModel(name: 'Kilogram per Hour', symbol: 'kg/h', toBase: 1 / 3600),
    UnitModel(name: 'Gram per Second', symbol: 'g/s', toBase: 0.001),
    UnitModel(name: 'Gram per Minute', symbol: 'g/min', toBase: 0.001 / 60),
    UnitModel(name: 'Tonne per Hour', symbol: 't/h', toBase: 1000 / 3600),
    UnitModel(name: 'Pound per Second', symbol: 'lb/s', toBase: 0.45359237),
    UnitModel(name: 'Pound per Minute', symbol: 'lb/min', toBase: 0.45359237 / 60),
    UnitModel(name: 'Pound per Hour', symbol: 'lb/h', toBase: 0.45359237 / 3600),
  ],

  // ────────────────────────────────────────────────────────────
  // RADIATION
  // ────────────────────────────────────────────────────────────

  // ── Radioactivity (base: becquerel) ──────────────────────────
  UnitCategory.radioactivity: [
    UnitModel(name: 'Becquerel', symbol: 'Bq', toBase: 1),
    UnitModel(name: 'Kilobecquerel', symbol: 'kBq', toBase: 1000),
    UnitModel(name: 'Megabecquerel', symbol: 'MBq', toBase: 1000000),
    UnitModel(name: 'Gigabecquerel', symbol: 'GBq', toBase: 1000000000),
    UnitModel(name: 'Terabecquerel', symbol: 'TBq', toBase: 1000000000000),
    UnitModel(name: 'Curie', symbol: 'Ci', toBase: 37000000000),
    UnitModel(name: 'Millicurie', symbol: 'mCi', toBase: 37000000),
    UnitModel(name: 'Microcurie', symbol: 'μCi', toBase: 37000),
    UnitModel(name: 'Rutherford', symbol: 'Rd', toBase: 1000000),
    UnitModel(name: 'Disintegration per Second', symbol: 'dps', toBase: 1),
    UnitModel(name: 'Disintegration per Minute', symbol: 'dpm', toBase: 1 / 60),
  ],

  // ── Radiation Dose (base: gray) ───────────────────────────────
  UnitCategory.radiationDose: [
    UnitModel(name: 'Gray', symbol: 'Gy', toBase: 1),
    UnitModel(name: 'Milligray', symbol: 'mGy', toBase: 0.001),
    UnitModel(name: 'Centigray', symbol: 'cGy', toBase: 0.01),
    UnitModel(name: 'Rad', symbol: 'rad', toBase: 0.01),
    UnitModel(name: 'Sievert', symbol: 'Sv', toBase: 1),
    UnitModel(name: 'Millisievert', symbol: 'mSv', toBase: 0.001),
    UnitModel(name: 'Microsievert', symbol: 'μSv', toBase: 0.000001),
    UnitModel(name: 'Rem', symbol: 'rem', toBase: 0.01),
    UnitModel(name: 'Millirem', symbol: 'mrem', toBase: 0.00001),
  ],

  // ── Radiation Exposure (base: C/kg) ───────────────────────────
  UnitCategory.radiationExposure: [
    UnitModel(name: 'Coulomb per Kilogram', symbol: 'C/kg', toBase: 1),
    UnitModel(name: 'Millicoulomb per Kilogram', symbol: 'mC/kg', toBase: 0.001),
    UnitModel(name: 'Roentgen', symbol: 'R', toBase: 0.000258),
    UnitModel(name: 'Milliroentgen', symbol: 'mR', toBase: 0.000000258),
    UnitModel(name: 'Microroentgen', symbol: 'μR', toBase: 0.000000000258),
    UnitModel(name: 'Parker', symbol: 'parker', toBase: 0.000258),
  ],

  // ────────────────────────────────────────────────────────────
  // ASTRONOMY
  // ────────────────────────────────────────────────────────────

  // ── Astronomical Length (base: meter) ─────────────────────────
  UnitCategory.astronomicalLength: [
    UnitModel(name: 'Astronomical Unit', symbol: 'AU', toBase: 149597870700),
    UnitModel(name: 'Light-year', symbol: 'ly', toBase: 9460730472580800),
    UnitModel(name: 'Parsec', symbol: 'pc', toBase: 30856775814671900),
    UnitModel(name: 'Kiloparsec', symbol: 'kpc', toBase: 3.085677581467190e+19),
    UnitModel(name: 'Megaparsec', symbol: 'Mpc', toBase: 3.0856775814671915e+22),
    UnitModel(name: 'Kilometer', symbol: 'km', toBase: 1000),
    UnitModel(name: 'Light-minute', symbol: 'lm', toBase: 17987547480),
    UnitModel(name: 'Light-second', symbol: 'ls', toBase: 299792458),
    UnitModel(name: 'Solar Radius', symbol: 'R☉', toBase: 695700000),
  ],

  // ────────────────────────────────────────────────────────────
  // LIFESTYLE & EVERYDAY
  // ────────────────────────────────────────────────────────────

  // ── Pace (base: s/m, special) ─────────────────────────────────
  UnitCategory.pace: [
    UnitModel(name: 'Min per Kilometer', symbol: 'min/km', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Min per Mile', symbol: 'min/mi', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Seconds per Meter', symbol: 's/m', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Kilometers per Hour', symbol: 'km/h', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'Miles per Hour', symbol: 'mph', toBase: 1, isSpecialCase: true),
  ],

  // ── Heart Rate (base: bpm) ────────────────────────────────────
  UnitCategory.heartRate: [
    UnitModel(name: 'Beats per Minute', symbol: 'bpm', toBase: 1),
    UnitModel(name: 'Beats per Second', symbol: 'bps', toBase: 60),
    UnitModel(name: 'Beats per Hour', symbol: 'bph', toBase: 1 / 60),
  ],

  // ── Blood Sugar (base: mg/dL, special) ───────────────────────
  UnitCategory.bloodSugar: [
    UnitModel(name: 'mg/dL', symbol: 'mg/dL', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'mmol/L', symbol: 'mmol/L', toBase: 1, isSpecialCase: true),
    UnitModel(name: 'μmol/L', symbol: 'μmol/L', toBase: 1, isSpecialCase: true),
  ],

  // ── Blood Pressure (base: mmHg) ───────────────────────────────
  UnitCategory.bloodPressure: [
    UnitModel(name: 'mmHg', symbol: 'mmHg', toBase: 1),
    UnitModel(name: 'kPa', symbol: 'kPa', toBase: 7.500617),
    UnitModel(name: 'Pa', symbol: 'Pa', toBase: 0.007500617),
    UnitModel(name: 'Bar', symbol: 'bar', toBase: 750.0617),
    UnitModel(name: 'PSI', symbol: 'psi', toBase: 51.71507),
    UnitModel(name: 'Atmosphere', symbol: 'atm', toBase: 760),
    UnitModel(name: 'cmH₂O', symbol: 'cmH₂O', toBase: 0.735559),
  ],

  // ── BMI (base: kg/m²) ─────────────────────────────────────────
  UnitCategory.bmi: [
    UnitModel(name: 'kg/m²', symbol: 'kg/m²', toBase: 1),
    UnitModel(name: 'lb/in²', symbol: 'lb/in²', toBase: 703.06957964),
  ],

  // ────────────────────────────────────────────────────────────
  // FINANCE / RATIO
  // ────────────────────────────────────────────────────────────

  // ── Percentage & Ratio (base: fraction 0–1) ───────────────────
  UnitCategory.percentageRatio: [
    UnitModel(name: 'Percent', symbol: '%', toBase: 0.01),
    UnitModel(name: 'Fraction', symbol: 'frac', toBase: 1),
    UnitModel(name: 'Per mille', symbol: '‰', toBase: 0.001),
    UnitModel(name: 'Parts per Million', symbol: 'ppm', toBase: 0.000001),
    UnitModel(name: 'Parts per Billion', symbol: 'ppb', toBase: 1e-9),
    UnitModel(name: 'Parts per Trillion', symbol: 'ppt', toBase: 1e-12),
    UnitModel(name: 'Basis Points', symbol: 'bps', toBase: 0.0001),
    UnitModel(name: 'Degrees (slope)', symbol: '°', toBase: 1, isSpecialCase: true),
  ],

  // ────────────────────────────────────────────────────────────
  // SOUND
  // ────────────────────────────────────────────────────────────

  // ── Sound Level (base: dB – label only, no unit factor math) ──
  UnitCategory.soundLevel: [
    UnitModel(name: 'Decibel', symbol: 'dB', toBase: 1),
    UnitModel(name: 'Decibel A-weighted', symbol: 'dB(A)', toBase: 1),
    UnitModel(name: 'Decibel C-weighted', symbol: 'dB(C)', toBase: 1),
    UnitModel(name: 'Neper', symbol: 'Np', toBase: 8.685889638),
    UnitModel(name: 'Bel', symbol: 'B', toBase: 10),
  ],

  // ────────────────────────────────────────────────────────────
  // CONCENTRATION
  // ────────────────────────────────────────────────────────────

  // ── Concentration (base: mol/m³) ──────────────────────────────
  UnitCategory.concentration: [
    UnitModel(name: 'Mole per Liter', symbol: 'mol/L', toBase: 1000),
    UnitModel(name: 'Millimole per Liter', symbol: 'mmol/L', toBase: 1),
    UnitModel(name: 'Micromole per Liter', symbol: 'μmol/L', toBase: 0.001),
    UnitModel(name: 'Nanomole per Liter', symbol: 'nmol/L', toBase: 0.000001),
    UnitModel(name: 'Mole per Cubic Meter', symbol: 'mol/m³', toBase: 1),
    UnitModel(name: 'Gram per Liter', symbol: 'g/L', toBase: 1),
    UnitModel(name: 'Milligram per Liter', symbol: 'mg/L', toBase: 0.001),
    UnitModel(name: 'Microgram per Liter', symbol: 'μg/L', toBase: 0.000001),
    UnitModel(name: 'Gram per Milliliter', symbol: 'g/mL', toBase: 1000),
    UnitModel(name: 'Percent (w/v)', symbol: '% w/v', toBase: 10),
  ],

  // ────────────────────────────────────────────────────────────
  // MAGNETIC
  // ────────────────────────────────────────────────────────────

  // ── Magnetic Field (base: tesla) ──────────────────────────────
  UnitCategory.magneticField: [
    UnitModel(name: 'Tesla', symbol: 'T', toBase: 1),
    UnitModel(name: 'Millitesla', symbol: 'mT', toBase: 0.001),
    UnitModel(name: 'Microtesla', symbol: 'μT', toBase: 0.000001),
    UnitModel(name: 'Nanotesla', symbol: 'nT', toBase: 1e-9),
    UnitModel(name: 'Gauss', symbol: 'G', toBase: 0.0001),
    UnitModel(name: 'Kilogauss', symbol: 'kG', toBase: 0.1),
    UnitModel(name: 'Oersted', symbol: 'Oe', toBase: 0.0001 * (4 * math.pi / 10)),
    UnitModel(name: 'Weber per Square Meter', symbol: 'Wb/m²', toBase: 1),
    UnitModel(name: 'Gamma', symbol: 'γ', toBase: 1e-9),
  ],

  // ── Magnetic Flux (base: weber) ───────────────────────────────
  UnitCategory.magneticFlux: [
    UnitModel(name: 'Weber', symbol: 'Wb', toBase: 1),
    UnitModel(name: 'Milliweber', symbol: 'mWb', toBase: 0.001),
    UnitModel(name: 'Microweber', symbol: 'μWb', toBase: 0.000001),
    UnitModel(name: 'Kiloweber', symbol: 'kWb', toBase: 1000),
    UnitModel(name: 'Maxwell', symbol: 'Mx', toBase: 1e-8),
    UnitModel(name: 'Tesla Square Meter', symbol: 'T·m²', toBase: 1),
    UnitModel(name: 'Volt-second', symbol: 'V·s', toBase: 1),
  ],

  // ────────────────────────────────────────────────────────────
  // SPECTROSCOPY
  // ────────────────────────────────────────────────────────────

  // ── Wavenumber (base: m⁻¹) ────────────────────────────────────
  UnitCategory.wavenumber: [
    UnitModel(name: 'Reciprocal Meter', symbol: 'm⁻¹', toBase: 1),
    UnitModel(name: 'Reciprocal Centimeter', symbol: 'cm⁻¹', toBase: 100),
    UnitModel(name: 'Reciprocal Millimeter', symbol: 'mm⁻¹', toBase: 1000),
    UnitModel(name: 'Reciprocal Inch', symbol: 'in⁻¹', toBase: 39.3700787),
    UnitModel(name: 'Reciprocal Foot', symbol: 'ft⁻¹', toBase: 3.280839895),
    UnitModel(name: 'Kayser', symbol: 'K', toBase: 100),
  ],
};

/// Returns the list of units for the given [category].
List<UnitModel> getUnits(UnitCategory category) {
  return unitsData[category] ?? [];
}
