import 'dart:math' as math;

import 'package:unit_converter/models/unit_model.dart';

/// Conversion categories supported by the app.
enum UnitCategory {
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
}

/// Display helpers for [UnitCategory].
extension UnitCategoryExtension on UnitCategory {
  /// Human-readable label for this category.
  String get displayName {
    switch (this) {
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
        return 'Data';
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
    }
  }

  /// Short description of what this category converts.
  String get description {
    switch (this) {
      case UnitCategory.length:
        return 'Meters, feet, inches, miles \u2014 measure the world';
      case UnitCategory.weight:
        return 'Kilograms, pounds, ounces \u2014 weigh anything';
      case UnitCategory.temperature:
        return 'Celsius, Fahrenheit, Kelvin \u2014 temperature';
      case UnitCategory.area:
        return 'Square meters, acres, hectares \u2014 measure spaces';
      case UnitCategory.volume:
        return 'Liters, gallons, cups \u2014 volume & capacity';
      case UnitCategory.speed:
        return 'km/h, mph, knots \u2014 speed conversions';
      case UnitCategory.data:
        return 'Bytes, KB, MB, GB \u2014 digital storage';
      case UnitCategory.time:
        return 'Seconds, minutes, hours \u2014 time conversions';
      case UnitCategory.angle:
        return 'Degrees, radians \u2014 angular measurements';
      case UnitCategory.energy:
        return 'Joules, calories, kWh \u2014 energy conversions';
      case UnitCategory.power:
        return 'Watts, horsepower \u2014 power measurements';
      case UnitCategory.pressure:
        return 'Pascals, PSI, bar \u2014 pressure conversions';
      case UnitCategory.force:
        return 'Newtons, pound-force \u2014 force conversions';
      case UnitCategory.frequency:
        return 'Hertz, kHz, MHz \u2014 frequency conversions';
      case UnitCategory.fuelEconomy:
        return 'km/L, MPG \u2014 fuel efficiency';
    }
  }

  /// Short symbols of all units in this category.
  List<String> get unitSymbols =>
      unitsData[this]?.map((u) => u.symbol).toList() ?? [];

  /// Curated preset conversions for quick reference.
  ///
  /// Each entry provides a [value], the [fromUnitName], and the
  /// [toUnitName] so the UI can build a tappable shortcut.
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
          (value: 1, fromUnitName: 'Kilometers per Hour', toUnitName: 'Miles per Hour'),
          (value: 1, fromUnitName: 'Meters per Second', toUnitName: 'Foot per Second'),
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
          (value: 1, fromUnitName: 'Kilometers per Liter', toUnitName: 'MPG (US)'),
          (value: 10, fromUnitName: 'Liters per 100km', toUnitName: 'MPG (US)'),
          (value: 1, fromUnitName: 'MPG (US)', toUnitName: 'Kilometers per Liter'),
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
    }
  }
}

/// Complete dataset of all convertible units organized by category.
const Map<UnitCategory, List<UnitModel>> unitsData = {
  // ── Length (base: meter) ──────────────────────────────────────
  UnitCategory.length: [
    UnitModel(name: 'Meter', symbol: 'm', toBase: 1),
    UnitModel(name: 'Kilometer', symbol: 'km', toBase: 1000),
    UnitModel(name: 'Centimeter', symbol: 'cm', toBase: 0.01),
    UnitModel(name: 'Millimeter', symbol: 'mm', toBase: 0.001),
    UnitModel(name: 'Mile', symbol: 'mi', toBase: 1609.34),
    UnitModel(name: 'Yard', symbol: 'yd', toBase: 0.9144),
    UnitModel(name: 'Foot', symbol: 'ft', toBase: 0.3048),
    UnitModel(name: 'Inch', symbol: 'in', toBase: 0.0254),
    UnitModel(name: 'Nautical Mile', symbol: 'nmi', toBase: 1852),
  ],

  // ── Weight (base: kilogram) ───────────────────────────────────
  UnitCategory.weight: [
    UnitModel(name: 'Kilogram', symbol: 'kg', toBase: 1),
    UnitModel(name: 'Gram', symbol: 'g', toBase: 0.001),
    UnitModel(name: 'Milligram', symbol: 'mg', toBase: 0.000001),
    UnitModel(name: 'Tonne', symbol: 't', toBase: 1000),
    UnitModel(name: 'Pound', symbol: 'lb', toBase: 0.453592),
    UnitModel(name: 'Ounce', symbol: 'oz', toBase: 0.0283495),
    UnitModel(name: 'Stone', symbol: 'st', toBase: 6.35029),
  ],

  // ── Temperature (special formula, no multiplier) ──────────────
  UnitCategory.temperature: [
    UnitModel(
      name: 'Celsius',
      symbol: '\u00B0C',
      toBase: 1,
      isSpecialCase: true,
    ),
    UnitModel(
      name: 'Fahrenheit',
      symbol: '\u00B0F',
      toBase: 1,
      isSpecialCase: true,
    ),
    UnitModel(
      name: 'Kelvin',
      symbol: 'K',
      toBase: 1,
      isSpecialCase: true,
    ),
  ],

  // ── Area (base: square meter) ─────────────────────────────────
  UnitCategory.area: [
    UnitModel(name: 'Square Meter', symbol: 'm\u00B2', toBase: 1),
    UnitModel(name: 'Square Kilometer', symbol: 'km\u00B2', toBase: 1e6),
    UnitModel(name: 'Square Centimeter', symbol: 'cm\u00B2', toBase: 0.0001),
    UnitModel(name: 'Square Millimeter', symbol: 'mm\u00B2', toBase: 1e-6),
    UnitModel(name: 'Square Foot', symbol: 'ft\u00B2', toBase: 0.092903),
    UnitModel(name: 'Square Inch', symbol: 'in\u00B2', toBase: 0.00064516),
    UnitModel(name: 'Square Yard', symbol: 'yd\u00B2', toBase: 0.836127),
    UnitModel(name: 'Acre', symbol: 'ac', toBase: 4046.86),
    UnitModel(name: 'Hectare', symbol: 'ha', toBase: 10000),
  ],

  // ── Volume (base: cubic meter) ────────────────────────────────
  UnitCategory.volume: [
    UnitModel(name: 'Liter', symbol: 'L', toBase: 0.001),
    UnitModel(name: 'Milliliter', symbol: 'mL', toBase: 0.000001),
    UnitModel(name: 'Cubic Meter', symbol: 'm\u00B3', toBase: 1),
    UnitModel(name: 'Gallon (US)', symbol: 'gal (US)', toBase: 0.00378541),
    UnitModel(name: 'Gallon (UK)', symbol: 'gal (UK)', toBase: 0.00454609),
    UnitModel(name: 'Cup', symbol: 'cup', toBase: 0.000236588),
    UnitModel(name: 'Fluid Ounce', symbol: 'fl oz', toBase: 0.0000295735),
    UnitModel(name: 'Pint', symbol: 'pt', toBase: 0.000473176),
    UnitModel(name: 'Quart', symbol: 'qt', toBase: 0.000946353),
  ],

  // ── Speed (base: m/s) ─────────────────────────────────────────
  UnitCategory.speed: [
    UnitModel(name: 'Meters per Second', symbol: 'm/s', toBase: 1),
    UnitModel(name: 'Kilometers per Hour', symbol: 'km/h', toBase: 0.277778),
    UnitModel(name: 'Miles per Hour', symbol: 'mph', toBase: 0.44704),
    UnitModel(name: 'Knot', symbol: 'kn', toBase: 0.514444),
    UnitModel(name: 'Foot per Second', symbol: 'ft/s', toBase: 0.3048),
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
  ],

  // ── Time (base: second) ───────────────────────────────────────
  UnitCategory.time: [
    UnitModel(name: 'Millisecond', symbol: 'ms', toBase: 0.001),
    UnitModel(name: 'Second', symbol: 's', toBase: 1),
    UnitModel(name: 'Minute', symbol: 'min', toBase: 60),
    UnitModel(name: 'Hour', symbol: 'hr', toBase: 3600),
    UnitModel(name: 'Day', symbol: 'day', toBase: 86400),
    UnitModel(name: 'Week', symbol: 'wk', toBase: 604800),
    UnitModel(name: 'Month', symbol: 'mo', toBase: 2592000),
    UnitModel(name: 'Year', symbol: 'yr', toBase: 31536000),
  ],

  // ── Angle (base: radian) ──────────────────────────────────────
  UnitCategory.angle: [
    UnitModel(name: 'Radian', symbol: 'rad', toBase: 1),
    UnitModel(name: 'Degree', symbol: '\u00B0', toBase: math.pi / 180),
    UnitModel(name: 'Gradian', symbol: 'grad', toBase: math.pi / 200),
    UnitModel(
      name: 'Arcminute',
      symbol: '\'',
      toBase: math.pi / (180 * 60),
    ),
    UnitModel(
      name: 'Arcsecond',
      symbol: '"',
      toBase: math.pi / (180 * 3600),
    ),
  ],

  // ── Energy (base: joule) ──────────────────────────────────────
  UnitCategory.energy: [
    UnitModel(name: 'Joule', symbol: 'J', toBase: 1),
    UnitModel(name: 'Kilojoule', symbol: 'kJ', toBase: 1000),
    UnitModel(name: 'Calorie', symbol: 'cal', toBase: 4.184),
    UnitModel(name: 'Kilowatt-hour', symbol: 'kWh', toBase: 3600000),
    UnitModel(name: 'BTU', symbol: 'BTU', toBase: 1055.06),
    UnitModel(name: 'Electronvolt', symbol: 'eV', toBase: 1.602176634e-19),
    UnitModel(name: 'Foot-pound', symbol: 'ft\u00B7lb', toBase: 1.35581794833),
  ],

  // ── Power (base: watt) ────────────────────────────────────────
  UnitCategory.power: [
    UnitModel(name: 'Watt', symbol: 'W', toBase: 1),
    UnitModel(name: 'Kilowatt', symbol: 'kW', toBase: 1000),
    UnitModel(name: 'Megawatt', symbol: 'MW', toBase: 1000000),
    UnitModel(name: 'Horsepower', symbol: 'hp', toBase: 745.7),
    UnitModel(name: 'BTU per Hour', symbol: 'BTU/h', toBase: 0.293071),
  ],

  // ── Pressure (base: pascal) ───────────────────────────────────
  UnitCategory.pressure: [
    UnitModel(name: 'Pascal', symbol: 'Pa', toBase: 1),
    UnitModel(name: 'Kilopascal', symbol: 'kPa', toBase: 1000),
    UnitModel(name: 'Bar', symbol: 'bar', toBase: 100000),
    UnitModel(name: 'PSI', symbol: 'psi', toBase: 6894.757),
    UnitModel(name: 'Atmosphere', symbol: 'atm', toBase: 101325),
    UnitModel(name: 'Torr', symbol: 'Torr', toBase: 133.322),
    UnitModel(name: 'mmHg', symbol: 'mmHg', toBase: 133.322),
  ],

  // ── Force (base: newton) ──────────────────────────────────────
  UnitCategory.force: [
    UnitModel(name: 'Newton', symbol: 'N', toBase: 1),
    UnitModel(name: 'Dyne', symbol: 'dyn', toBase: 0.00001),
    UnitModel(name: 'Pound-force', symbol: 'lbf', toBase: 4.448222),
    UnitModel(name: 'Kilogram-force', symbol: 'kgf', toBase: 9.80665),
  ],

  // ── Frequency (base: hertz) ───────────────────────────────────
  UnitCategory.frequency: [
    UnitModel(name: 'Hertz', symbol: 'Hz', toBase: 1),
    UnitModel(name: 'Kilohertz', symbol: 'kHz', toBase: 1000),
    UnitModel(name: 'Megahertz', symbol: 'MHz', toBase: 1000000),
    UnitModel(name: 'Gigahertz', symbol: 'GHz', toBase: 1000000000),
  ],

  // ── Fuel Economy (base: km/L, special case like temp) ─────────
  UnitCategory.fuelEconomy: [
    UnitModel(
      name: 'Kilometers per Liter',
      symbol: 'km/L',
      toBase: 1,
    ),
    UnitModel(
      name: 'Liters per 100km',
      symbol: 'L/100km',
      toBase: 1,
      isSpecialCase: true,
    ),
    UnitModel(
      name: 'MPG (US)',
      symbol: 'mpg (US)',
      toBase: 0.425144,
    ),
    UnitModel(
      name: 'MPG (UK)',
      symbol: 'mpg (UK)',
      toBase: 0.354006,
    ),
  ],
};

/// Returns the list of units for the given [category].
///
/// Always returns a non-null list. Returns an empty list for
/// unknown categories (should never happen with the enum).
List<UnitModel> getUnits(UnitCategory category) {
  return unitsData[category] ?? [];
}
