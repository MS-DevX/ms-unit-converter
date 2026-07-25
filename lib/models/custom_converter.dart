/// Models for user-created custom converter groups (linear ratio only).
library;

import 'package:flutter/foundation.dart';

/// A single unit inside a custom converter group.
@immutable
class CustomUnit {
  /// Human-readable name (e.g. "Box").
  final String name;

  /// Symbol / abbreviation (e.g. "bx").
  final String symbol;

  /// How many base units equal one of this unit (e.g. 24 for "1 Box = 24 Bottles").
  final double toBase;

  const CustomUnit({
    required this.name,
    required this.symbol,
    required this.toBase,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'symbol': symbol,
        'toBase': toBase,
      };

  factory CustomUnit.fromJson(Map<String, dynamic> json) => CustomUnit(
        name: json['name'] as String,
        symbol: json['symbol'] as String? ?? '',
        toBase: (json['toBase'] as num).toDouble(),
      );
}

/// A user-created custom converter (linear ratio, offline only).
///
/// Example:
///   name: "Package Units"
///   units: [
///     CustomUnit("Bottle",  "btl", 1),
///     CustomUnit("Box",     "bx",  24),
///     CustomUnit("Carton",  "ctn", 12 * 24),
///     CustomUnit("Pallet",  "plt", 48 * 12 * 24),
///   ]
@immutable
class CustomConverter {
  /// Unique identifier (timestamp-based).
  final String id;

  /// Display name of the group (e.g. "Package Units").
  final String name;

  /// Emoji icon (single character) for the category card.
  final String emoji;

  /// Ordered list of units in this group.
  final List<CustomUnit> units;

  const CustomConverter({
    required this.id,
    required this.name,
    required this.emoji,
    required this.units,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'units': units.map((u) => u.toJson()).toList(),
      };

  factory CustomConverter.fromJson(Map<String, dynamic> json) =>
      CustomConverter(
        id: json['id'] as String,
        name: json['name'] as String,
        emoji: json['emoji'] as String? ?? '📐',
        units: (json['units'] as List<dynamic>)
            .map((u) => CustomUnit.fromJson(u as Map<String, dynamic>))
            .toList(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomConverter && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
