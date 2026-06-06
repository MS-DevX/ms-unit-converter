import 'package:flutter/foundation.dart';

/// Represents a single convertible unit with its conversion factor.
///
/// Every unit has a human-readable [name], a short [symbol], a [toBase]
/// factor that converts one of that unit into the category's base unit,
/// and an optional [isSpecialCase] flag for units such as temperature
/// that require a non-linear conversion formula.
@immutable
class UnitModel {
  /// Human-readable name of the unit (e.g. "Meter", "Kilogram").
  final String name;

  /// Short symbol or abbreviation (e.g. "m", "kg", "°C").
  final String symbol;

  /// Conversion multiplier from this unit to the category base unit.
  final double toBase;

  /// Whether this unit requires a special (non-linear) conversion formula.
  ///
  /// Defaults to `false`. Set to `true` for temperature units and any
  /// other unit whose conversion cannot be expressed as a simple multiply.
  final bool isSpecialCase;

  /// Optional group identifier for sub-categorisation (e.g. 'volume' vs
  /// 'weight' in Cooking). Cross-group conversions return an error.
  final String? group;

  /// Creates a [UnitModel] with the given properties.
  const UnitModel({
    required this.name,
    required this.symbol,
    required this.toBase,
    this.isSpecialCase = false,
    this.group,
  });

  /// Returns a copy of this [UnitModel] with the given fields replaced.
  UnitModel copyWith({
    String? name,
    String? symbol,
    double? toBase,
    bool? isSpecialCase,
    String? group,
  }) {
    return UnitModel(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      toBase: toBase ?? this.toBase,
      isSpecialCase: isSpecialCase ?? this.isSpecialCase,
      group: group ?? this.group,
    );
  }

  @override
  String toString() {
    return 'UnitModel(name: $name, symbol: $symbol, '
        'toBase: $toBase, isSpecialCase: $isSpecialCase, group: $group)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitModel &&
        other.name == name &&
        other.symbol == symbol &&
        other.toBase == toBase &&
        other.isSpecialCase == isSpecialCase &&
        other.group == group;
  }

  @override
  int get hashCode {
    return Object.hash(name, symbol, toBase, isSpecialCase, group);
  }
}
