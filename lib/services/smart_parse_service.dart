/// Offline, pure-Dart natural-language conversion parser.
///
/// Handles queries like "10 km to miles", "100 c to f", "5 feet 9 inches to cm",
/// and "100 usd to pkr". No internet, no cloud AI, no paid API required.
library;

import '../data/currencies_data.dart';
import '../data/units_data.dart';
import '../models/unit_model.dart';

/// Result of a single [SmartParseService.parse] call.
///
/// [isRecognized] is `true` when the query could be fully parsed and
/// contains enough information to perform a conversion.
class SmartParseResult {
  /// The numeric amount to convert.
  final double? amount;

  /// Canonical from-unit name (e.g. "Kilometer", "Celsius", "USD").
  final String? fromUnitName;

  /// Canonical to-unit name.
  final String? toUnitName;

  /// Detected category for unit conversions.
  final UnitCategory? category;

  /// The original query string.
  final String? rawQuery;

  /// Human-readable error message when parsing fails.
  final String? errorMessage;

  /// `true` when this is a currency conversion (not a unit conversion).
  final bool isCurrency;

  /// Three-letter ISO from-currency code when [isCurrency] is true.
  final String? fromCurrencyCode;

  /// Three-letter ISO to-currency code when [isCurrency] is true.
  final String? toCurrencyCode;

  /// Secondary amount for compound units (e.g. 9 in "5 feet 9 inches").
  final double? secondaryAmount;

  /// Secondary from-unit name for compound units.
  final String? secondaryFromUnitName;

  const SmartParseResult({
    this.amount,
    this.fromUnitName,
    this.toUnitName,
    this.category,
    this.rawQuery,
    this.errorMessage,
    this.isCurrency = false,
    this.fromCurrencyCode,
    this.toCurrencyCode,
    this.secondaryAmount,
    this.secondaryFromUnitName,
  });

  /// `true` when the query was successfully parsed with enough data for a
  /// conversion.
  bool get isRecognized {
    if (errorMessage != null) return false;
    if (amount == null) return false;
    if (isCurrency) {
      return fromCurrencyCode != null && toCurrencyCode != null;
    }
    return fromUnitName != null && toUnitName != null && category != null;
  }
}

/// Pure-Dart offline parser for natural-language conversion queries.
///
/// Usage:
/// ```dart
/// final result = SmartParseService.parse('10 km to miles');
/// if (result.isRecognized) { ... }
/// ```
class SmartParseService {
  SmartParseService._();

  // ── Alias map ─────────────────────────────────────────────────────────

  static Map<String, ({UnitCategory category, UnitModel unit})>? _aliasCache;

  /// Maps a lowercase alias/abbreviation to a canonical (category, unit) pair.
  static Map<String, ({UnitCategory category, UnitModel unit})> get _aliases {
    if (_aliasCache != null) return _aliasCache!;
    _aliasCache = _buildAliases();
    return _aliasCache!;
  }

  static Map<String, ({UnitCategory category, UnitModel unit})>
  _buildAliases() {
    final map = <String, ({UnitCategory category, UnitModel unit})>{};

    // Auto-generate from all unit names in unitsData.
    // Uses [putIfAbsent] so the first category (e.g. Length) wins when a
    // unit name appears in multiple categories (e.g. "Centimeter" appears
    // in both Length and Typography).
    for (final entry in unitsData.entries) {
      final cat = entry.key;
      for (final unit in entry.value) {
        final lower = unit.name.toLowerCase();
        map.putIfAbsent(lower, () => (category: cat, unit: unit));
        if (!lower.endsWith('s')) {
          map.putIfAbsent('${lower}s', () => (category: cat, unit: unit));
        }
      }
    }

    // ── Length ──────────────────────────────────────────────────────
    _alias(map, 'km', 'Kilometer');
    _alias(map, 'm', 'Meter');
    _alias(map, 'cm', 'Centimeter');
    _alias(map, 'mm', 'Millimeter');
    _alias(map, 'mi', 'Mile');
    _alias(map, 'ft', 'Foot');
    _alias(map, 'foot', 'Foot');
    _alias(map, 'feet', 'Foot');
    _alias(map, 'in', 'Inch');
    _alias(map, 'inch', 'Inch');
    _alias(map, 'inches', 'Inch');
    _alias(map, 'yd', 'Yard');

    // ── Weight ──────────────────────────────────────────────────────
    _alias(map, 'kg', 'Kilogram');
    _alias(map, 'g', 'Gram');
    _alias(map, 'mg', 'Milligram');
    _alias(map, 't', 'Tonne');
    _alias(map, 'tonne', 'Tonne');
    _alias(map, 'lb', 'Pound');
    _alias(map, 'lbs', 'Pound');
    _alias(map, 'pound', 'Pound');
    _alias(map, 'pounds', 'Pound');
    _alias(map, 'oz', 'Ounce');
    _alias(map, 'ounce', 'Ounce');
    _alias(map, 'ounces', 'Ounce');
    _alias(map, 'st', 'Stone');
    _alias(map, 'stone', 'Stone');

    // ── Temperature ─────────────────────────────────────────────────
    _alias(map, 'c', 'Celsius');
    _alias(map, 'celsius', 'Celsius');
    _alias(map, 'f', 'Fahrenheit');
    _alias(map, 'fahrenheit', 'Fahrenheit');
    _alias(map, 'k', 'Kelvin');
    _alias(map, 'kelvin', 'Kelvin');

    // ── Area ────────────────────────────────────────────────────────
    _alias(map, 'sqm', 'Square Meter');
    _alias(map, 'sq km', 'Square Kilometer');
    _alias(map, 'sqft', 'Square Foot');
    _alias(map, 'sq ft', 'Square Foot');
    _alias(map, 'sq in', 'Square Inch');
    _alias(map, 'sqin', 'Square Inch');
    _alias(map, 'sq yd', 'Square Yard');
    _alias(map, 'sqyd', 'Square Yard');
    _alias(map, 'hectare', 'Hectare');
    _alias(map, 'acre', 'Acre');

    // ── Volume ──────────────────────────────────────────────────────
    _alias(map, 'l', 'Liter');
    _alias(map, 'liter', 'Liter');
    _alias(map, 'liters', 'Liter');
    _alias(map, 'litre', 'Liter');
    _alias(map, 'ml', 'Milliliter');
    _alias(map, 'milliliter', 'Milliliter');
    _alias(map, 'gal', 'Gallon (US)');
    _alias(map, 'gallon', 'Gallon (US)');
    _alias(map, 'gallons', 'Gallon (US)');
    _alias(map, 'cup', 'Cup');
    _alias(map, 'fl oz', 'Fluid Ounce');
    _alias(map, 'pint', 'Pint');
    _alias(map, 'quart', 'Quart');

    // ── Speed ───────────────────────────────────────────────────────
    _alias(map, 'kmh', 'Kilometers per Hour');
    _alias(map, 'km/h', 'Kilometers per Hour');
    _alias(map, 'kph', 'Kilometers per Hour');
    _alias(map, 'mph', 'Miles per Hour');
    _alias(map, 'knot', 'Knot');
    _alias(map, 'knots', 'Knot');
    _alias(map, 'mps', 'Meters per Second');
    _alias(map, 'm/s', 'Meters per Second');
    _alias(map, 'fps', 'Foot per Second');
    _alias(map, 'ft/s', 'Foot per Second');

    // ── Data ────────────────────────────────────────────────────────
    _alias(map, 'byte', 'Byte');
    _alias(map, 'kb', 'Kilobyte');
    _alias(map, 'mb', 'Megabyte');
    _alias(map, 'gb', 'Gigabyte');
    _alias(map, 'tb', 'Terabyte');
    _alias(map, 'pb', 'Petabyte');

    // ── Time ────────────────────────────────────────────────────────
    _alias(map, 'ms', 'Millisecond');
    _alias(map, 'millisecond', 'Millisecond');
    _alias(map, 'sec', 'Second');
    _alias(map, 'second', 'Second');
    _alias(map, 'seconds', 'Second');
    _alias(map, 'min', 'Minute');
    _alias(map, 'minute', 'Minute');
    _alias(map, 'minutes', 'Minute');
    _alias(map, 'hr', 'Hour');
    _alias(map, 'hour', 'Hour');
    _alias(map, 'hours', 'Hour');
    _alias(map, 'day', 'Day');
    _alias(map, 'days', 'Day');
    _alias(map, 'week', 'Week');
    _alias(map, 'weeks', 'Week');
    _alias(map, 'month', 'Month');
    _alias(map, 'months', 'Month');
    _alias(map, 'year', 'Year');
    _alias(map, 'years', 'Year');

    // ── Angle ───────────────────────────────────────────────────────
    _alias(map, 'deg', 'Degree');
    _alias(map, 'degree', 'Degree');
    _alias(map, 'degrees', 'Degree');
    _alias(map, 'rad', 'Radian');
    _alias(map, 'radian', 'Radian');
    _alias(map, 'radians', 'Radian');

    // ── Number base ─────────────────────────────────────────────────
    _alias(map, 'binary', 'Binary');
    _alias(map, 'bin', 'Binary');
    _alias(map, 'decimal', 'Decimal');
    _alias(map, 'dec', 'Decimal');
    _alias(map, 'hex', 'Hexadecimal');
    _alias(map, 'hexadecimal', 'Hexadecimal');
    _alias(map, 'octal', 'Octal');
    _alias(map, 'oct', 'Octal');

    // ── Energy ──────────────────────────────────────────────────────
    _alias(map, 'j', 'Joule');
    _alias(map, 'joule', 'Joule');
    _alias(map, 'kj', 'Kilojoule');
    _alias(map, 'cal', 'Calorie');
    _alias(map, 'calorie', 'Calorie');
    _alias(map, 'kwh', 'Kilowatt-hour');
    _alias(map, 'btu', 'BTU');

    // ── Power ───────────────────────────────────────────────────────
    _alias(map, 'w', 'Watt');
    _alias(map, 'watt', 'Watt');
    _alias(map, 'kw', 'Kilowatt');
    _alias(map, 'mw', 'Megawatt');
    _alias(map, 'hp', 'Horsepower');

    // ── Pressure ────────────────────────────────────────────────────
    _alias(map, 'pa', 'Pascal');
    _alias(map, 'pascal', 'Pascal');
    _alias(map, 'kpa', 'Kilopascal');
    _alias(map, 'bar', 'Bar');
    _alias(map, 'psi', 'PSI');
    _alias(map, 'atm', 'Atmosphere');

    // ── Force ───────────────────────────────────────────────────────
    _alias(map, 'n', 'Newton');
    _alias(map, 'newton', 'Newton');
    _alias(map, 'lbf', 'Pound-force');
    _alias(map, 'kgf', 'Kilogram-force');

    return map;
  }

  /// Convenience helper to insert an alias into the map.
  static void _alias(
    Map<String, ({UnitCategory category, UnitModel unit})> map,
    String alias,
    String canonicalName,
  ) {
    final lower = canonicalName.toLowerCase();
    final entry = map[lower];
    if (entry != null) {
      map[alias] = (category: entry.category, unit: entry.unit);
    }
  }

  // ── Currency helpers ─────────────────────────────────────────────────

  /// Set of all known ISO currency codes (lowercase for lookup).
  static Set<String>? _currencyCodeSet;

  static Set<String> get _currencyCodes {
    if (_currencyCodeSet != null) return _currencyCodeSet!;
    _currencyCodeSet = allCurrencies.map((c) => c.code.toLowerCase()).toSet();
    return _currencyCodeSet!;
  }

  /// Maps lowercase currency aliases (code or common name) to uppercase ISO
  /// code.
  static Map<String, String>? _currencyAliasCache;

  static Map<String, String> get _currencyAliases {
    if (_currencyAliasCache != null) return _currencyAliasCache!;
    _currencyAliasCache = _buildCurrencyAliases();
    return _currencyAliasCache!;
  }

  static Map<String, String> _buildCurrencyAliases() {
    final map = <String, String>{};
    for (final c in allCurrencies) {
      map[c.code.toLowerCase()] = c.code;
      map[c.name.toLowerCase()] = c.code;
    }
    // Additional common aliases.
    map['dollar'] = 'USD';
    map['dollars'] = 'USD';
    map['euro'] = 'EUR';
    map['euros'] = 'EUR';
    map['pound'] = 'GBP';
    map['pounds'] = 'GBP';
    map['rupee'] = 'PKR';
    map['rupees'] = 'PKR';
    map['yen'] = 'JPY';
    map['yuan'] = 'CNY';
    return map;
  }

  // ── Public API ────────────────────────────────────────────────────────

  /// Parses a natural-language conversion [query].
  ///
  /// Supported patterns:
  /// - `"10 km to miles"`
  /// - `"100 c to f"`
  /// - `"5 feet 9 inches to cm"`
  /// - `"100 usd to pkr"`
  /// - `"255 decimal to hex"`
  ///
  /// Returns a [SmartParseResult] with [isRecognized] indicating whether
  /// parsing succeeded.
  static SmartParseResult parse(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return SmartParseResult(rawQuery: query, errorMessage: 'Empty query');
    }

    // Normalise whitespace.
    final normalised = trimmed.replaceAll(RegExp(r'\s+'), ' ');

    // Find separator: " to ", " in ", or arrow characters.
    const separators = [' to ', ' → ', ' -> ', ' > '];
    String? separator;
    int sepIndex = -1;
    for (final sep in separators) {
      final idx = normalised.indexOf(sep);
      if (idx != -1) {
        separator = sep;
        sepIndex = idx;
        break;
      }
    }

    // Also try " in " as a separator (but be careful — "in" is also a unit
    // alias for Inch).
    if (separator == null) {
      final inIdx = normalised.indexOf(' in ');
      if (inIdx != -1) {
        // Only treat as separator if the word after "in" is a known unit or
        // currency, to avoid false positives.
        final afterIn = normalised.substring(inIdx + 4).trim();
        if (_looksLikeTarget(afterIn)) {
          separator = ' in ';
          sepIndex = inIdx;
        }
      }
    }

    if (separator == null || sepIndex == -1) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Could not find a conversion target (use " to ")',
      );
    }

    final left = normalised.substring(0, sepIndex).trim();
    final right = normalised.substring(sepIndex + separator.length).trim();

    if (left.isEmpty || right.isEmpty) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Missing source or target unit',
      );
    }

    // First try currency parsing — if both sides look like currencies, it
    // takes priority.
    final fromCurrency = _resolveCurrency(left);
    final toCurrency = _resolveCurrency(right);
    if (fromCurrency != null && toCurrency != null) {
      final amount = _extractAmount(left);
      if (amount == null) {
        return SmartParseResult(
          rawQuery: query,
          errorMessage: 'Could not parse amount',
        );
      }
      return SmartParseResult(
        amount: amount,
        fromCurrencyCode: fromCurrency,
        toCurrencyCode: toCurrency,
        isCurrency: true,
        rawQuery: query,
      );
    }

    // Try compound unit parsing first (e.g. "5 feet 9 inches").
    final compoundResult = _tryParseCompound(left, right);
    if (compoundResult != null) return compoundResult;

    // Simple parsing: extract amount and from-unit from left, to-unit from
    // right.
    return _parseSimple(left, right, query);
  }

  // ── Internal helpers ─────────────────────────────────────────────────

  /// Returns `true` if [word] looks like a target unit or currency code.
  static bool _looksLikeTarget(String word) {
    if (word.isEmpty) return false;
    final firstWord = word.split(' ').first;
    if (_currencyCodes.contains(firstWord.toLowerCase())) return true;
    if (_aliases.containsKey(firstWord.toLowerCase())) return true;
    return false;
  }

  /// Resolves a full left-side string like "100 usd" or "100 pakistani
  /// rupees" to a currency code, or `null` if it doesn't look like a
  /// currency.
  static String? _resolveCurrency(String side) {
    final cleaned = side.replaceAll(RegExp(r'^[\d\s.]+'), '').trim();
    if (cleaned.isEmpty) return null;
    final lower = cleaned.toLowerCase();
    // Check the entire phrase first (e.g. "pakistani rupee").
    if (_currencyAliases.containsKey(lower)) {
      return _currencyAliases[lower];
    }
    // Check the last word (usually the currency code/name).
    final words = lower.split(RegExp(r'\s+'));
    for (int i = words.length - 1; i >= 0; i--) {
      if (_currencyAliases.containsKey(words[i])) {
        return _currencyAliases[words[i]];
      }
    }
    return null;
  }

  /// Extracts the numeric amount from the beginning of a string.
  ///
  /// Returns `null` if no number is found at the start.
  static double? _extractAmount(String side) {
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(side.trim());
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  /// Attempts to parse a compound left side like "5 feet 9 inches".
  ///
  /// Returns a [SmartParseResult] on success or `null` to fall through to
  /// simple parsing.
  static SmartParseResult? _tryParseCompound(String left, String right) {
    // Pattern: <number> <unit> <number> <unit>
    final compoundMatch = RegExp(
      r'^(\d+(?:\.\d+)?)\s+(.+?)\s+(\d+(?:\.\d+)?)\s+(.+)$',
    ).firstMatch(left);

    if (compoundMatch == null) return null;

    final amount1 = double.tryParse(compoundMatch.group(1)!);
    final rawUnit1 = compoundMatch.group(2)!.trim();
    final amount2 = double.tryParse(compoundMatch.group(3)!);
    final rawUnit2 = compoundMatch.group(4)!.trim();

    if (amount1 == null || amount2 == null) return null;

    final unit1 = _resolveUnit(rawUnit1);
    final unit2 = _resolveUnit(rawUnit2);
    if (unit1 == null || unit2 == null) return null;

    final targetUnit = _resolveUnit(right);
    if (targetUnit == null) return null;

    // Both source units must belong to the same category as the target.
    if (unit1.category != targetUnit.category) return null;
    if (unit2.category != targetUnit.category) return null;

    // Convert both amounts to the first unit's base, then sum, then express
    // as a single value in the first unit.
    final totalInBase =
        amount1 * unit1.unit.toBase + amount2 * unit2.unit.toBase;
    final combinedValue = totalInBase / unit1.unit.toBase;

    return SmartParseResult(
      amount: combinedValue,
      fromUnitName: unit1.unit.name,
      toUnitName: targetUnit.unit.name,
      category: targetUnit.category,
      rawQuery: '$left to $right',
      secondaryAmount: amount2,
      secondaryFromUnitName: unit2.unit.name,
    );
  }

  /// Parses a simple (non-compound) query.
  static SmartParseResult _parseSimple(
    String left,
    String right,
    String query,
  ) {
    final amount = _extractAmount(left);
    if (amount == null) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Could not parse amount',
      );
    }

    // Extract the from-unit from the left (everything after the amount).
    final fromRaw = left.replaceFirst(RegExp(r'^\d+(?:\.\d+)?\s*'), '').trim();
    if (fromRaw.isEmpty) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Missing source unit',
      );
    }

    final toRaw = right.trim();
    if (toRaw.isEmpty) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Missing target unit',
      );
    }

    final from = _resolveUnit(fromRaw);
    final to = _resolveUnit(toRaw);

    if (from == null || to == null) {
      final unknown = from == null ? fromRaw : toRaw;
      return SmartParseResult(
        rawQuery: query,
        errorMessage: 'Unknown unit: "$unknown"',
      );
    }

    if (from.category != to.category) {
      return SmartParseResult(
        rawQuery: query,
        errorMessage:
            'Cannot convert between ${from.category.name} and ${to.category.name}',
      );
    }

    return SmartParseResult(
      amount: amount,
      fromUnitName: from.unit.name,
      toUnitName: to.unit.name,
      category: from.category,
      rawQuery: query,
    );
  }

  /// Resolves a raw unit string (e.g. "km", "kilometers", "feet") to a
  /// canonical (category, unit) pair, or `null` if unknown.
  static ({UnitCategory category, UnitModel unit})? _resolveUnit(String raw) {
    final lower = raw.trim().toLowerCase();
    return _aliases[lower];
  }
}
