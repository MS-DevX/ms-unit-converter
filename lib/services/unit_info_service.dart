/// Loads and caches unit definitions and educational metadata from JSON assets.
library;

import 'dart:convert';
import 'package:flutter/services.dart';

/// Structure of educational metadata for a unit.
class UnitInfo {
  final String symbol;
  final String definition;
  final String history;
  final String usedFor;
  final List<String> examples;

  const UnitInfo({
    required this.symbol,
    required this.definition,
    required this.history,
    required this.usedFor,
    required this.examples,
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(
      symbol: json['symbol'] as String? ?? '',
      definition: json['definition'] as String? ?? 'Standard unit of measurement.',
      history: json['history'] as String? ?? 'Historical measurement standard.',
      usedFor: json['used_for'] as String? ?? 'General scientific and everyday applications.',
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Service that loads assets/data/unit_information.json once and caches it.
class UnitInfoService {
  UnitInfoService._();

  static Map<String, UnitInfo>? _cache;

  /// Loads and caches the unit information database.
  static Future<void> load() async {
    if (_cache != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/unit_information.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      _cache = decoded.map((key, val) => MapEntry(key.toLowerCase(), UnitInfo.fromJson(val as Map<String, dynamic>)));
    } catch (_) {
      _cache = {};
    }
  }

  /// Returns [UnitInfo] for [unitName] or a smart fallback if not found.
  static Future<UnitInfo> getInfo(String unitName, String symbol) async {
    await load();
    final key = unitName.toLowerCase().replaceAll(' ', '_');
    if (_cache != null && _cache!.containsKey(key)) {
      return _cache![key]!;
    }
    return UnitInfo(
      symbol: symbol,
      definition: '$unitName ($symbol) is a standard unit of measurement.',
      history: 'Standardized unit used internationally across science and industry.',
      usedFor: 'Everyday and professional conversions.',
      examples: ['Standard measurement applications'],
    );
  }
}
