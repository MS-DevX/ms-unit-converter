import 'package:flutter/foundation.dart';
import '../data/units_data.dart';

/// Represents a single conversion stored in history.
///
/// Persisted to [SharedPreferences] via JSON serialization.
/// All fields are immutable. Use [copyWith] to derive modified copies.
@immutable
class HistoryEntry {
  /// Unique identifier for this entry.
  final String id;

  /// Conversion category (e.g. "Length", "Weight").
  final String category;

  /// Numeric value entered by the user.
  final double inputValue;

  /// Name of the source unit.
  final String fromUnit;

  /// Name of the target unit.
  final String toUnit;

  /// Symbol of the source unit (e.g. "km"). Empty string for legacy entries.
  final String fromSymbol;

  /// Symbol of the target unit (e.g. "mi"). Empty string for legacy entries.
  final String toSymbol;

  /// Converted result value.
  final double result;

  /// Timestamp when the conversion was performed.
  final DateTime timestamp;

  /// Creates a [HistoryEntry] with the given properties.
  const HistoryEntry({
    required this.id,
    required this.category,
    required this.inputValue,
    required this.fromUnit,
    required this.toUnit,
    this.fromSymbol = '',
    this.toSymbol = '',
    required this.result,
    required this.timestamp,
  });

  /// Returns the corresponding [UnitCategory] for this entry.
  UnitCategory get categoryEnum {
    return UnitCategory.values.firstWhere(
      (c) => c.displayName.toLowerCase() == category.toLowerCase(),
      orElse: () => UnitCategory.length,
    );
  }

  /// Serializes this entry to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'inputValue': inputValue,
      'fromUnit': fromUnit,
      'toUnit': toUnit,
      'fromSymbol': fromSymbol,
      'toSymbol': toSymbol,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Deserializes a [HistoryEntry] from a JSON map.
  ///
  /// Numeric values stored as [int] are safely promoted to [double].
  /// Symbol fields default to empty string for backward-compatibility with
  /// entries saved before this field was added.
  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'] as String,
      category: json['category'] as String,
      inputValue: (json['inputValue'] as num).toDouble(),
      fromUnit: json['fromUnit'] as String,
      toUnit: json['toUnit'] as String,
      fromSymbol: (json['fromSymbol'] as String?) ?? '',
      toSymbol: (json['toSymbol'] as String?) ?? '',
      result: (json['result'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Returns a copy of this [HistoryEntry] with the given fields replaced.
  HistoryEntry copyWith({
    String? id,
    String? category,
    double? inputValue,
    String? fromUnit,
    String? toUnit,
    String? fromSymbol,
    String? toSymbol,
    double? result,
    DateTime? timestamp,
  }) {
    return HistoryEntry(
      id: id ?? this.id,
      category: category ?? this.category,
      inputValue: inputValue ?? this.inputValue,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      fromSymbol: fromSymbol ?? this.fromSymbol,
      toSymbol: toSymbol ?? this.toSymbol,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'HistoryEntry(\n'
        '  id: $id,\n'
        '  category: $category,\n'
        '  inputValue: $inputValue,\n'
        '  fromUnit: $fromUnit ($fromSymbol),\n'
        '  toUnit: $toUnit ($toSymbol),\n'
        '  result: $result,\n'
        '  timestamp: ${timestamp.toIso8601String()}\n'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HistoryEntry &&
        other.id == id &&
        other.category == category &&
        other.inputValue == inputValue &&
        other.fromUnit == fromUnit &&
        other.toUnit == toUnit &&
        other.fromSymbol == fromSymbol &&
        other.toSymbol == toSymbol &&
        other.result == result &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      category,
      inputValue,
      fromUnit,
      toUnit,
      fromSymbol,
      toSymbol,
      result,
      timestamp,
    );
  }
}
