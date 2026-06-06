/// Pure-logic conversion engine for MS Unit Converter.
///
/// All conversions — normal, temperature, fuel economy, cooking, shoe size,
/// clothing size, number base, and typography — pass through [convert].
/// The service is stateless and deterministic;
/// it holds no UI, storage, or network dependencies.
library;

import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/models/conversion_result.dart';
import 'package:unit_converter/models/unit_model.dart';
import 'package:unit_converter/utils/formatters.dart';

/// Pure-logic conversion engine for MS Unit Converter.
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
      case UnitCategory.typography:
        result = _convertTypography(value, from, to);
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
    if (from.name == 'Liters per 100km') {
      if (value == 0) return double.nan;
      return 100 / value;
    }
    return value * from.toBase;
  }

  static double _fromKmPerL(double kmPerL, UnitModel to) {
    if (to.name == 'Liters per 100km') {
      if (kmPerL == 0) return double.nan;
      return 100 / kmPerL;
    }
    return kmPerL / to.toBase;
  }

  // ── Cooking (volume vs weight groups) ─────────────────────────

  /// Converts a cooking measurement. Cross-group (volume → weight)
  /// conversions return [double.nan] with an error message.
  static double _convertCooking(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
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
  static double _convertShoeSize(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
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

  // ── Typography (px base, em/rem via baseFontSize) ────────────

  /// Converts a typographic value using px as the base.
  /// Uses 16px default base font when called without extra state.
  static double _convertTypography(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
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
}
