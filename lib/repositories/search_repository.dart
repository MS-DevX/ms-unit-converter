/// FTS5-ready search repository backed by the SQLite [search_aliases] table.
///
/// ## Architecture
///
/// The public API is defined by the abstract [SearchBackend] contract.
/// In Phase 1, [SqliteSearchBackend] resolves aliases via indexed `LIKE` queries
/// and in-memory category/unit filtering.
///
/// In a future release, a [Fts5SearchBackend] will be added. Enabling FTS5
/// requires:
/// 1. Creating FTS5 virtual tables in a new schema migration.
/// 2. Instantiating [Fts5SearchBackend] instead of [SqliteSearchBackend] in
///    [SearchRepository._backend].
///
/// **Zero changes required to providers, screens, or widgets.**
///
/// ## FTS5 Migration Path
/// ```dart
/// // Future: swap this one line
/// final SearchBackend _backend = Fts5SearchBackend();
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';
import '../data/units_data.dart';
import '../models/unit_model.dart';
import 'unit_repository.dart';
import 'category_repository.dart';

// ─── Backend Contract ──────────────────────────────────────────────────────

/// Abstract search backend. Implement this to swap from SQLite LIKE to FTS5.
abstract class SearchBackend {
  /// Resolves a short keyword to its canonical display name.
  ///
  /// Example: `'lbs'` → `'Pound'`, `'km'` → `'Kilometer'`.
  /// Returns `null` if no alias matches.
  Future<String?> resolveAlias(String keyword);

  /// Searches categories by [query].
  Future<List<CategoryRow>> searchCategories(String query);

  /// Searches units within a specific [category] by [query].
  Future<List<UnitModel>> searchUnits(String query, UnitCategory category);

  /// Searches across all categories for units matching [query].
  Future<List<UnitModel>> searchAllUnits(String query);
}

// ─── Phase 1: SQLite LIKE Backend ─────────────────────────────────────────

/// SQLite LIKE-based search backend (Phase 1).
///
/// Alias resolution uses an indexed `keyword` lookup.
/// Category/unit search uses [CategoryRepository] and [UnitRepository]
/// in-memory caches for zero-query performance after first load.
class SqliteSearchBackend implements SearchBackend {
  /// Creates the backend with the given database handle.
  SqliteSearchBackend(this._db);

  final Database _db;

  // In-memory alias map populated on first [resolveAlias] call.
  Map<String, String>? _aliasCache;

  @override
  Future<String?> resolveAlias(String keyword) async {
    await _warmAliasCache();
    final lower = keyword.toLowerCase().trim();
    return _aliasCache![lower];
  }

  @override
  Future<List<CategoryRow>> searchCategories(String query) async {
    return CategoryRepository.instance.search(query);
  }

  @override
  Future<List<UnitModel>> searchUnits(String query, UnitCategory category) async {
    if (query.isEmpty) return UnitRepository.instance.loadUnitsForCategory(category);
    final lower = query.toLowerCase();
    final units = await UnitRepository.instance.loadUnitsForCategory(category);
    return units.where((u) =>
      u.name.toLowerCase().contains(lower) ||
      u.symbol.toLowerCase().contains(lower),
    ).toList();
  }

  @override
  Future<List<UnitModel>> searchAllUnits(String query) async {
    return UnitRepository.instance.search(query);
  }

  /// Warms the alias cache from the [search_aliases] table.
  Future<void> _warmAliasCache() async {
    if (_aliasCache != null) return;
    final rows = await _db.query('search_aliases', columns: ['keyword', 'canonical']);
    _aliasCache = {
      for (final row in rows)
        (row['keyword'] as String).toLowerCase(): row['canonical'] as String,
    };
    debugPrint('[SqliteSearchBackend] Alias cache warmed: ${_aliasCache!.length} entries');
  }

  /// Clears the alias cache (dev/test use only).
  void clearAliasCache() => _aliasCache = null;
}

// ─── Repository Facade ─────────────────────────────────────────────────────

/// Singleton search repository that exposes [SearchBackend] operations.
///
/// All callers (SearchHelper, SmartParseService) use this repository.
/// The active backend can be swapped without changing any caller code.
class SearchRepository implements BaseRepository<Map<String, String>, String> {
  SearchRepository._();

  /// The singleton instance.
  static final SearchRepository instance = SearchRepository._();

  SearchBackend? _backend;

  /// Returns the active [SearchBackend], initializing it on first access.
  SearchBackend get backend {
    _backend ??= SqliteSearchBackend(DatabaseService.instance.database);
    return _backend!;
  }

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<Map<String, String>>> getAll() async {
    final rows = await DatabaseService.instance.database.query(
      'search_aliases',
      columns: ['keyword', 'canonical'],
    );
    return rows.map((r) => {
      'keyword': r['keyword'] as String,
      'canonical': r['canonical'] as String,
    }).toList();
  }

  @override
  Future<Map<String, String>?> getById(String id) async {
    final canonical = await resolveAlias(id);
    if (canonical != null) {
      return {'keyword': id, 'canonical': canonical};
    }
    return null;
  }

  @override
  Future<List<Map<String, String>>> search(String query) async {
    final all = await getAll();
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all.where((r) =>
      r['keyword']!.toLowerCase().contains(lower) ||
      r['canonical']!.toLowerCase().contains(lower),
    ).toList();
  }

  @override
  Future<int> count() async {
    final res = Sqflite.firstIntValue(
      await DatabaseService.instance.database.rawQuery('SELECT COUNT(*) FROM search_aliases'),
    );
    return res ?? 0;
  }

  @override
  Future<bool> exists(String id) async => (await resolveAlias(id)) != null;

  @override
  void clearCache() => resetBackend();

  /// Resolves [keyword] to its canonical display name via the alias table.
  ///
  /// Returns `null` if no alias matches. Falls back gracefully if the DB is
  /// not yet initialized.
  Future<String?> resolveAlias(String keyword) async {
    try {
      return await backend.resolveAlias(keyword);
    } catch (e) {
      debugPrint('[SearchRepository] resolveAlias error: $e');
      return null;
    }
  }

  /// Searches categories matching [query].
  Future<List<CategoryRow>> searchCategories(String query) async {
    try {
      return await backend.searchCategories(query);
    } catch (e) {
      debugPrint('[SearchRepository] searchCategories error: $e');
      return [];
    }
  }

  /// Searches units within [category] matching [query].
  Future<List<UnitModel>> searchUnits(String query, UnitCategory category) async {
    try {
      return await backend.searchUnits(query, category);
    } catch (e) {
      debugPrint('[SearchRepository] searchUnits error: $e');
      return [];
    }
  }

  /// Searches units across all categories matching [query].
  Future<List<UnitModel>> searchAllUnits(String query) async {
    try {
      return await backend.searchAllUnits(query);
    } catch (e) {
      debugPrint('[SearchRepository] searchAllUnits error: $e');
      return [];
    }
  }

  /// Resets the backend (dev/test use only).
  void resetBackend() {
    _backend = null;
  }
}
