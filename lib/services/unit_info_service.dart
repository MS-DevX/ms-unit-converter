/// Loads and caches unit definitions and educational metadata.
///
/// ## Data source strategy
/// 1. **SQLite (Phase 2+)**: Queries [UnitInformationRepository] when the
///    [unit_information] table is populated. This will be the primary source
///    once `tools/build_database.dart` seeds the table.
/// 2. **JSON asset (Phase 1 fallback)**: Falls back to
///    `assets/data/unit_information.json` when the DB table is empty.
///    This is the current behavior and requires no changes to existing callers.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../repositories/unit_information_repository.dart';

/// Structure of educational metadata for a unit.
class UnitInfo {
  final String symbol;
  final String definition;
  final String history;
  final String usedFor;
  final List<String> examples;
  final List<String> tags;
  final List<String> relatedContent;

  const UnitInfo({
    required this.symbol,
    required this.definition,
    required this.history,
    required this.usedFor,
    required this.examples,
    this.tags = const [],
    this.relatedContent = const [],
  });

  factory UnitInfo.fromJson(Map<String, dynamic> json) {
    return UnitInfo(
      symbol: json['symbol'] as String? ?? '',
      definition: json['definition'] as String? ?? 'Standard unit of measurement.',
      history: json['history'] as String? ?? 'Historical measurement standard.',
      usedFor: json['used_for'] as String? ?? 'General scientific and everyday applications.',
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      relatedContent: (json['related_content'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

/// Service that loads unit educational info, preferring SQLite over JSON asset.
class UnitInfoService {
  UnitInfoService._();

  // JSON asset cache (Phase 1 fallback).
  static Map<String, UnitInfo>? _jsonCache;

  // Whether the DB table has data — checked once per session.
  static bool? _dbHasData;

  /// Pre-loads the JSON asset cache.
  ///
  /// Called lazily by [getInfo] if not already loaded.
  static Future<void> load() async {
    if (_jsonCache != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/data/unit_information.json');
      final Map<String, dynamic> decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      _jsonCache = decoded.map(
        (key, val) => MapEntry(
          key.toLowerCase(),
          UnitInfo.fromJson(val as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      _jsonCache = {};
    }
  }

  /// Returns [UnitInfo] for [unitName].
  ///
  /// Checks the SQLite [unit_information] table first (Phase 2+).
  /// Falls back to the JSON asset when the table is empty (Phase 1).
  /// Returns a generated fallback if neither source has data.
  static Future<UnitInfo> getInfo(String unitName, String symbol) async {
    // Phase 2+: try SQLite first.
    _dbHasData ??= await UnitInformationRepository.instance.hasData();
    if (_dbHasData!) {
      try {
        final dbRow = await UnitInformationRepository.instance.findByUnitName(unitName);
        if (dbRow != null) {
          final tags = dbRow.tags.map((t) => t.name).toList();
          final related = dbRow.relatedContent.map((r) => r.targetId).toList();
          return UnitInfo(
            symbol: dbRow.symbol,
            definition: dbRow.definition,
            history: dbRow.history,
            usedFor: dbRow.usedFor,
            examples: dbRow.examples,
            tags: tags,
            relatedContent: related,
          );
        }
      } catch (e) {
        debugPrint('[UnitInfoService] DB lookup failed for $unitName: $e');
      }
    }

    // Phase 1 fallback: JSON asset.
    await load();
    final key = unitName.toLowerCase();
    if (_jsonCache != null && _jsonCache!.containsKey(key)) {
      return _jsonCache![key]!;
    }

    // Generated fallback for unknown units.
    return UnitInfo(
      symbol: symbol,
      definition: '$unitName ($symbol) is a standard unit of measurement.',
      history: 'Standardized unit used internationally across science and industry.',
      usedFor: 'Everyday and professional conversions.',
      examples: ['Standard measurement applications'],
    );
  }
}
