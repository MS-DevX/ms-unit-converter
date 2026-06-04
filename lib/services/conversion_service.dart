/// Pure-logic conversion engine for MS Unit Converter.
///
/// All conversions — normal, temperature, and fuel economy — pass through
/// [convert]. The service is stateless and deterministic;
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
    // ── Validate input ──────────────────────────────────────────
    if (value.isNaN || value.isInfinite) {
      return ConversionResult.failure('Invalid input');
    }

    // ── Same-unit short circuit ─────────────────────────────────
    if (from == to) {
      final formatted = Formatters.formatResult(value);
      return ConversionResult.success(
        result: value,
        formattedResult: formatted,
        formula: buildFormula(value, from, to, value),
      );
    }

    // ── Perform conversion ─────────────────────────────────────
    final double result;
    if (category == UnitCategory.temperature) {
      result = _convertTemperature(value, from, to);
    } else if (category == UnitCategory.fuelEconomy) {
      result = _convertFuelEconomy(value, from, to);
    } else {
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
  ///
  /// For linear conversions the format includes the multiplication factor:
  /// `"<value> <from.symbol> × <factor> = <result> <to.symbol>"`
  /// Example: `"1 km × 1000 = 1000 m"`.
  ///
  /// For special-case categories (temperature, fuel economy) the factor
  /// is omitted and the format is:
  /// `"<value> <from.symbol> = <result> <to.symbol>"`
  /// Example: `"100 °C = 212 °F"`.
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

  // ── Temperature (uses Celsius as intermediate) ─────────────────

  /// Converts a temperature value completely offline using
  /// Celsius as the intermediate reference.
  static double _convertTemperature(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    // Step 1: convert the input to Celsius.
    final double celsius = _toCelsius(value, from.name);

    // Step 2: convert from Celsius to the target unit.
    return _fromCelsius(celsius, to.name);
  }

  /// Converts [value] in [fromName] to Celsius.
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

  /// Converts a Celsius value to the unit identified by [toName].
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

  // ── Fuel Economy (uses km/L as intermediate) ──────────────────

  /// Converts a fuel-economy value using km/L as the intermediate.
  ///
  /// [L/100km] uses a reciprocal relationship (like temperature)
  /// and is handled as a special case. All other units use a
  /// linear multiplier to/from km/L.
  static double _convertFuelEconomy(
    double value,
    UnitModel from,
    UnitModel to,
  ) {
    // Step 1: convert the input to km/L.
    final double kmPerL = _toKmPerL(value, from);

    // Step 2: convert from km/L to the target unit.
    return _fromKmPerL(kmPerL, to);
  }

  /// Converts [value] in [from] to km/L.
  static double _toKmPerL(double value, UnitModel from) {
    if (from.name == 'Liters per 100km') {
      if (value == 0) return double.nan;
      return 100 / value;
    }
    return value * from.toBase;
  }

  /// Converts a km/L value to the unit identified by [to].
  static double _fromKmPerL(double kmPerL, UnitModel to) {
    if (to.name == 'Liters per 100km') {
      if (kmPerL == 0) return double.nan;
      return 100 / kmPerL;
    }
    return kmPerL / to.toBase;
  }
}
