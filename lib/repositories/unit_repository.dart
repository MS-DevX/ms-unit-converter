/// Repository for querying unit data from the SQLite database.
///
/// Bridges SQLite rows back to the [UnitModel] objects expected by
/// [ConversionService] and existing providers.
///
/// ## Design Contract
/// - All units for a category are loaded into memory on first access per category.
/// - A full-cache load (`loadAll`) is available for search or provider warming.
/// - [ConversionService] remains a pure-Dart stateless engine — it receives
///   [UnitModel] objects from this repository and performs math. No SQL ever
///   enters the conversion engine.
///
/// ## Future User-Data Migration Note
/// If unit selection history is later migrated to SQLite, it belongs in a
/// separate `UserUnitPreferenceRepository`. The public API of this repository
/// remains unchanged.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../data/units_data.dart';
import '../models/unit_model.dart';

/// Only layer allowed to query SQLite for unit data.
///
/// ## ARCHITECTURE GUARDRAILS
/// - Widgets and Providers must NEVER perform SQL queries directly.
/// - Transforms SQLite database rows into typed [UnitModel] instances.
/// - Caches loaded units in memory per category for 0ms access latency.
class UnitRepository {
  UnitRepository._();

  /// The singleton instance.
  static final UnitRepository instance = UnitRepository._();

  // Per-category lazy cache.
  final Map<String, List<UnitModel>> _categoryCache = {};

  // Full cross-category cache (populated when [loadAll] is called).
  List<UnitModel>? _fullCache;

  Database get _db => DatabaseService.instance.database;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads all [UnitModel]s for [category], ordered by [display_order].
  ///
  /// Cached per category after the first call.
  Future<List<UnitModel>> loadUnitsForCategory(UnitCategory category) async {
    final key = category.name;
    if (_categoryCache.containsKey(key)) return _categoryCache[key]!;

    final rows = await _db.query(
      'units',
      where: 'category_id = ?',
      whereArgs: [key],
      orderBy: 'display_order ASC',
    );

    final units = rows.map(_rowToModel).toList();
    _categoryCache[key] = units;
    return units;
  }

  /// Loads all units from every category into a single flat list.
  ///
  /// Cached after the first call. Useful for warming caches or full search.
  Future<List<UnitModel>> loadAll() async {
    if (_fullCache != null) return _fullCache!;

    final rows = await _db.query(
      'units',
      orderBy: 'category_id ASC, display_order ASC',
    );

    _fullCache = rows.map(_rowToModel).toList();

    // Also populate per-category cache from the same query.
    for (final row in rows) {
      final catId = row['category_id'] as String;
      _categoryCache.putIfAbsent(catId, () => []).add(_rowToModel(row));
    }

    debugPrint('[UnitRepository] Loaded ${_fullCache!.length} total units');
    return _fullCache!;
  }

  /// Finds a unit by exact name within a category.
  ///
  /// Returns `null` if not found.
  Future<UnitModel?> findByName(UnitCategory category, String name) async {
    final units = await loadUnitsForCategory(category);
    try {
      return units.firstWhere(
        (u) => u.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Finds a unit by exact symbol within a category.
  ///
  /// Returns `null` if not found.
  Future<UnitModel?> findBySymbol(UnitCategory category, String symbol) async {
    final units = await loadUnitsForCategory(category);
    try {
      return units.firstWhere(
        (u) => u.symbol.toLowerCase() == symbol.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Returns the database row id of a unit by its name within a category.
  ///
  /// Used by [UnitInformationRepository] to join on unit_id.
  /// Returns `null` if not found.
  Future<int?> findRowId(UnitCategory category, String unitName) async {
    final rows = await _db.query(
      'units',
      columns: ['id'],
      where: 'category_id = ? AND name = ?',
      whereArgs: [category.name, unitName],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['id'] as int?;
  }

  /// Searches units by name or symbol across all categories.
  ///
  /// The method signature is stable. A future FTS5 backend upgrade
  /// will only change the internals of this method.
  Future<List<UnitModel>> search(String query) async {
    if (query.isEmpty) return [];
    final lower = query.toLowerCase();
    final all = await loadAll();
    return all
        .where(
          (u) =>
              u.name.toLowerCase().contains(lower) ||
              u.symbol.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Returns the cached units for [category] if already loaded, or `null`.
  ///
  /// This allows callers (e.g. [ConverterProvider]) to decide between a
  /// synchronous return (cache hit) and an async load (cache miss) without
  /// triggering an unnecessary Future.
  List<UnitModel>? getCachedUnitsForCategory(UnitCategory category) {
    return _categoryCache[category.name];
  }

  /// Clears all in-memory caches.
  ///
  /// Should only be called during dev/test reseeding.
  void clearCache() {
    _categoryCache.clear();
    _fullCache = null;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Maps a raw SQLite row to a [UnitModel].
  static UnitModel _rowToModel(Map<String, Object?> row) {
    return UnitModel(
      name: row['name'] as String,
      symbol: row['symbol'] as String,
      toBase: (row['to_base'] as num).toDouble(),
      isSpecialCase: (row['is_special_case'] as int? ?? 0) == 1,
      group: row['group_name'] as String?,
    );
  }
}
