/// Represents a single fiat currency with metadata.
library;

import 'package:flutter/foundation.dart';

/// A fiat currency with its ISO code, display name, symbol, flag emoji,
/// and number of decimal digits for typical display.
@immutable
class CurrencyModel {
  /// ISO 4217 three-letter code (e.g. "USD", "EUR").
  final String code;

  /// Human-readable name (e.g. "US Dollar").
  final String name;

  /// Currency symbol (e.g. "\$", "€").
  final String symbol;

  /// Flag emoji for the currency's country / region.
  final String flag;

  /// Number of decimal places typically shown for this currency.
  final int decimalDigits;

  /// Creates a [CurrencyModel].
  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    this.decimalDigits = 2,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'CurrencyModel($code $symbol $name)';
}
