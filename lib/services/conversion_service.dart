/// Pure-logic conversion engine for MS Unit Converter.
///
/// All conversions — normal, temperature, fuel economy, cooking, shoe size,
/// clothing size, number base, typography, pace, blood sugar, and all other
/// special cases — pass through [convert].
/// The service is stateless and deterministic;
/// it holds no UI, storage, or network dependencies.
library;

import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/models/conversion_result.dart';
import 'package:unit_converter/models/unit_model.dart';
import 'package:unit_converter/utils/formatters.dart';

/// Pure mathematical conversion engine for MS Unit Converter.
///
/// ## ARCHITECTURE GUARDRAILS
/// - Must remain a 100% pure, stateless, deterministic Dart service.
/// - Performs ONLY mathematical calculations.
/// - NEVER import repositories, database classes, or UI providers.
class ConversionService {
  ConversionService._();

  /// Converts [value] from [from] to [to] within [category].
  ///
  /// Returns a [ConversionResult.success] with the computed value
  /// and a human-readable formula string, or
  /// [ConversionResult.failure] when the input is invalid.
  static ConversionResult convert(
    double value,
    UnitModel from,
    UnitModel to,
    UnitCategory category,
  ) {
    if (value.isNaN || value.isInfinite) {
      return ConversionResult.failure('Invalid input');
    }

    if (from == to) {
      final formatted = Formatters.formatResult(value);
      return ConversionResult.success(
        result: value,
        formattedResult: formatted,
        formula: buildFormula(value, from, to, value),
      );
    }

    final double result;
    switch (category) {
      case UnitCategory.temperature:
        result = _convertTemperature(value, from, to);
      case UnitCategory.fuelEconomy:
        result = _convertFuelEconomy(value, from, to);
      case UnitCategory.cooking:
        result = _convertCooking(value, from, to);
      case UnitCategory.shoeSize:
        result = _convertShoeSize(value, from, to);
      case UnitCategory.clothingSize:
        result = _convertClothingSize(value, from, to);
      case UnitCategory.numberBase:
        result = _convertNumberBase(value, from, to);
      case UnitCategory.typography:
        result = _convertTypography(value, from, to);
      case UnitCategory.pace:
        result = _convertPace(value, from, to);
      case UnitCategory.bloodSugar:
        result = _convertBloodSugar(value, from, to);
      case UnitCategory.percentageRatio:
        result = _convertPercentageRatio(value, from, to);
      default:
        result = (value * from.toBase) / to.toBase;
    }

    if (result.isNaN || result.isInfinite) {
      return ConversionResult.failure('Invalid input');
    }

    final formatted = Formatters.formatResult(result);
    final formula = buildFormula(value, from, to, result);

    return ConversionResult.success(
      result: result,
      formattedResult: formatted,
      formula: formula,
    );
  }

  /// Builds a human-readable formula string.
  static String buildFormula(
    double value,
    UnitModel from,
    UnitModel to,
    double result,
  ) {
    final valStr = Formatters.formatResult(value);
    final resStr = Formatters.formatResult(result);

    if (from.isSpecialCase || to.isSpecialCase) {
      return '$valStr ${from.symbol} = $resStr ${to.symbol}';
    }

    final factor = from.toBase / to.toBase;
    final factorStr = Formatters.formatResult(factor);
    return '$valStr ${from.symbol} × $factorStr = $resStr ${to.symbol}';
  }

  // ── Temperature ─────────────────────────────────────────────────

  static double _convertTemperature(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    final double celsius = _toCelsius(value, from.name);
    return _fromCelsius(celsius, to.name);
  }

  static double _toCelsius(double value, String fromName) {
    switch (fromName) {
      case 'Celsius':
        return value;
      case 'Fahrenheit':
        return (value - 32) * 5 / 9;
      case 'Kelvin':
        return value - 273.15;
      case 'Rankine':
        return (value - 491.67) * 5 / 9;
      case 'Delisle':
        return 100 - (value * 2 / 3);
      case 'Newton':
        return value * 100 / 33;
      case 'Réaumur':
        return value * 5 / 4;
      default:
        return double.nan;
    }
  }

  static double _fromCelsius(double celsius, String toName) {
    switch (toName) {
      case 'Celsius':
        return celsius;
      case 'Fahrenheit':
        return (celsius * 9 / 5) + 32;
      case 'Kelvin':
        return celsius + 273.15;
      case 'Rankine':
        return (celsius + 273.15) * 9 / 5;
      case 'Delisle':
        return (100 - celsius) * 3 / 2;
      case 'Newton':
        return celsius * 33 / 100;
      case 'Réaumur':
        return celsius * 4 / 5;
      default:
        return double.nan;
    }
  }

  // ── Fuel Economy ────────────────────────────────────────────────

  static double _convertFuelEconomy(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    final double kmPerL = _toKmPerL(value, from);
    return _fromKmPerL(kmPerL, to);
  }

  static double _toKmPerL(double value, UnitModel from) {
    switch (from.name) {
      case 'Liters per 100km':
        if (value == 0) return double.nan;
        return 100 / value;
      case 'Liters per Mile':
        if (value == 0) return double.nan;
        return 1.60934 / value;
      default:
        return value * from.toBase;
    }
  }

  static double _fromKmPerL(double kmPerL, UnitModel to) {
    switch (to.name) {
      case 'Liters per 100km':
        if (kmPerL == 0) return double.nan;
        return 100 / kmPerL;
      case 'Liters per Mile':
        if (kmPerL == 0) return double.nan;
        return 1.60934 / kmPerL;
      default:
        return kmPerL / to.toBase;
    }
  }

  // ── Cooking (volume vs weight groups) ─────────────────────────

  /// Converts a cooking measurement. Cross-group (volume → weight)
  /// conversions return [double.nan] with an error message.
  static double _convertCooking(double value, UnitModel from, UnitModel to) {
    if (from.group != to.group) {
      return double.nan;
    }
    return (value * from.toBase) / to.toBase;
  }

  /// Returns a cross-group error message when volume/weight mismatch.
  static String? cookingGroupError(UnitModel? from, UnitModel? to) {
    if (from == null || to == null) return null;
    if (from.group == to.group) return null;
    return 'Cannot convert ${from.group} to ${to.group}';
  }

  // ── Shoe Size (via CM intermediate, 0.5 rounding) ─────────────

  /// Converts a shoe size using CM as intermediate reference.
  /// Results are rounded to the nearest 0.5 increment.
  static double _convertShoeSize(double value, UnitModel from, UnitModel to) {
    final double cm = _shoeToCm(value, from.name);
    if (cm.isNaN) return double.nan;
    final double result = _cmToShoe(cm, to.name);
    if (result.isNaN) return double.nan;
    return (result * 2).roundToDouble() / 2;
  }

  static double _shoeToCm(double value, String fromName) {
    switch (fromName) {
      case 'CM':
        return value;
      case 'EU':
        return (value - 1.5) / 1.5;
      case 'UK':
        return (value + 31.5) / 1.5;
      case 'US Men':
        return (value + 30.5) / 1.5;
      case 'US Women':
        return (value + 29) / 1.5;
      default:
        return double.nan;
    }
  }

  static double _cmToShoe(double cm, String toName) {
    switch (toName) {
      case 'CM':
        return cm;
      case 'EU':
        return cm * 1.5 + 1.5;
      case 'UK':
        return cm * 1.5 - 31.5;
      case 'US Men':
        return cm * 1.5 - 30.5;
      case 'US Women':
        return cm * 1.5 - 29;
      default:
        return double.nan;
    }
  }

  // ── Clothing Size (via US numeric, men/women) ────────────────

  /// Converts clothing size using US as intermediate.
  /// Defaults to men's sizing when called without extra state.
  static double _convertClothingSize(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    final double us = _clothingToUs(value, from.name, true);
    if (us.isNaN) return double.nan;
    return _usToClothing(us, to.name, true);
  }

  static double _clothingToUs(double value, String fromName, bool isMen) {
    switch (fromName) {
      case 'US':
        return value;
      case 'EU':
        return isMen ? value - 10 : value - 30;
      case 'UK':
        return isMen ? value + 1 : value - 4;
      case 'Asian':
        return value - 5;
      default:
        return double.nan;
    }
  }

  static double _usToClothing(double us, String toName, bool isMen) {
    switch (toName) {
      case 'US':
        return us;
      case 'EU':
        return isMen ? us + 10 : us + 30;
      case 'UK':
        return isMen ? us - 1 : us + 4;
      case 'Asian':
        return us + 5;
      default:
        return double.nan;
    }
  }

  // ── Number Base (radix conversion via string) ─────────────────

  /// Converts a number between radices.
  ///
  /// Interprets [value] as an integer string in [from]'s radix,
  /// then renders that integer as a string in [to]'s radix.
  /// Returns [double.nan] if [value] contains digits invalid for [from]'s radix.
  static double _convertNumberBase(double value, UnitModel from, UnitModel to) {
    final inputStr = value.toInt().toString();
    final fromRadix = _radixFor(from.name);
    final toRadix = _radixFor(to.name);
    final int intValue;
    try {
      intValue = int.parse(inputStr, radix: fromRadix);
    } on FormatException {
      return double.nan;
    }
    final resultStr = intValue.toRadixString(toRadix);
    return double.tryParse(resultStr) ?? intValue.toDouble();
  }

  static int _radixFor(String unitName) {
    return switch (unitName) {
      'Binary' => 2,
      'Octal' => 8,
      'Decimal' => 10,
      'Hexadecimal' => 16,
      _ => 10,
    };
  }

  // ── Typography (px base, em/rem via baseFontSize) ────────────

  /// Converts a typographic value using px as the base.
  /// Uses 16px default base font when called without extra state.
  static double _convertTypography(double value, UnitModel from, UnitModel to) {
    final double px = _typoToPx(value, from, 16.0);
    if (px.isNaN) return double.nan;
    return _pxToTypo(px, to, 16.0);
  }

  static double _typoToPx(double value, UnitModel from, double baseFontSize) {
    switch (from.name) {
      case 'Pixels':
      case 'DP':
      case 'Points':
      case 'Inch':
      case 'Centimeter':
      case 'Millimeter':
      case 'Pica':
        return value * from.toBase;
      case 'EM':
        return value * baseFontSize;
      case 'REM':
        return value * baseFontSize;
      case 'Percent':
        return (value / 100) * baseFontSize;
      default:
        return double.nan;
    }
  }

  static double _pxToTypo(double px, UnitModel to, double baseFontSize) {
    switch (to.name) {
      case 'Pixels':
      case 'DP':
      case 'Points':
      case 'Inch':
      case 'Centimeter':
      case 'Millimeter':
      case 'Pica':
        return px / to.toBase;
      case 'EM':
        return px / baseFontSize;
      case 'REM':
        return px / baseFontSize;
      case 'Percent':
        return (px / baseFontSize) * 100;
      default:
        return double.nan;
    }
  }

  // ── Pace (running pace ↔ speed) ───────────────────────────────

  /// Converts running pace and speed using seconds/meter as intermediate.
  static double _convertPace(double value, UnitModel from, UnitModel to) {
    // Convert to seconds per meter first
    final double sPerM = _paceToSecondsPerMeter(value, from.name);
    if (sPerM.isNaN || sPerM <= 0) return double.nan;
    return _secondsPerMeterToPace(sPerM, to.name);
  }

  static double _paceToSecondsPerMeter(double value, String fromName) {
    switch (fromName) {
      case 'Min per Kilometer':
        // value is min/km → s/m
        return (value * 60) / 1000;
      case 'Min per Mile':
        // value is min/mi → s/m
        return (value * 60) / 1609.344;
      case 'Seconds per Meter':
        return value;
      case 'Kilometers per Hour':
        // km/h → m/s → s/m
        if (value == 0) return double.nan;
        return 1 / (value / 3.6);
      case 'Miles per Hour':
        if (value == 0) return double.nan;
        return 1 / (value * 0.44704);
      default:
        return double.nan;
    }
  }

  static double _secondsPerMeterToPace(double sPerM, String toName) {
    switch (toName) {
      case 'Min per Kilometer':
        return (sPerM * 1000) / 60;
      case 'Min per Mile':
        return (sPerM * 1609.344) / 60;
      case 'Seconds per Meter':
        return sPerM;
      case 'Kilometers per Hour':
        return (1 / sPerM) * 3.6;
      case 'Miles per Hour':
        return (1 / sPerM) / 0.44704;
      default:
        return double.nan;
    }
  }

  // ── Blood Sugar ───────────────────────────────────────────────

  /// Converts blood glucose between mg/dL, mmol/L, and μmol/L.
  static double _convertBloodSugar(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    // Convert to mg/dL first (base)
    final double mgdl = _bloodSugarToMgdl(value, from.name);
    if (mgdl.isNaN) return double.nan;
    return _mgdlToBloodSugar(mgdl, to.name);
  }

  static double _bloodSugarToMgdl(double value, String fromName) {
    switch (fromName) {
      case 'mg/dL':
        return value;
      case 'mmol/L':
        return value * 18.01559;
      case 'μmol/L':
        return value * 0.018016;
      default:
        return double.nan;
    }
  }

  static double _mgdlToBloodSugar(double mgdl, String toName) {
    switch (toName) {
      case 'mg/dL':
        return mgdl;
      case 'mmol/L':
        return mgdl / 18.01559;
      case 'μmol/L':
        return mgdl / 0.018016;
      default:
        return double.nan;
    }
  }

  // ── Percentage & Ratio ────────────────────────────────────────

  /// Converts between percentage, fraction, ppm, ppb, ppt, basis points.
  /// Degrees (slope) is a special pass-through label.
  static double _convertPercentageRatio(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    if (from.name == 'Degrees (slope)' || to.name == 'Degrees (slope)') {
      return value; // pass-through label only
    }
    // Convert to fraction first (base = 1)
    final double fraction = value * from.toBase;
    return fraction / to.toBase;
  }
}
