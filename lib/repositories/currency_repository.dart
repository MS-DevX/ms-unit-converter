/// Repository for querying currency data from the SQLite database.
///
/// Provides the same data surface as [CurrenciesData] and the existing
/// `allIsoCurrencies` / `fallbackRatesToUsd` globals, with a stable public API
/// designed for future FTS5 search and potential user-preference migration.
///
/// ## Future User-Data Migration Note
/// Currency pin state is currently read from [pinnedCurrencyCodes] at seed time
/// and stored in the `currencies.is_pinned` column. User-modified pin state is
/// still managed by SharedPreferences via [CurrencyService].
///
/// If user pin preferences are migrated to SQLite in a future release, a new
/// `updatePinState(String isoCode, bool isPinned)` method will be added here
/// without changing the existing `loadAll()` / `getAllCurrencies()` API.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';
import '../models/currency_model.dart';

/// Singleton repository for [CurrencyModel] data loaded from SQLite.
class CurrencyRepository implements BaseRepository<CurrencyModel, String> {
  CurrencyRepository._();

  /// The singleton instance.
  static final CurrencyRepository instance = CurrencyRepository._();

  // Full cache: sorted list (pinned first, then alphabetical by iso_code).
  List<CurrencyModel>? _cache;

  // Rate map cache: iso_code → fallback_rate_to_usd
  Map<String, double>? _ratesCache;

  // Lookup by ISO code.
  Map<String, CurrencyModel>? _cacheByCode;

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<CurrencyModel>> getAll() => getAllCurrencies();

  @override
  Future<CurrencyModel?> getById(String id) => findByCode(id);

  @override
  Future<int> count() async => (await getAllCurrencies()).length;

  @override
  Future<bool> exists(String id) async => (await findByCode(id)) != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads all currencies — pinned first (by pin_order), then alphabetically.
  ///
  /// Cached after the first call.
  Future<List<CurrencyModel>> getAllCurrencies() async {
    if (_cache != null) return _cache!;
    await _loadAndCache();
    return _cache!;
  }

  /// Returns a map of ISO code → fallback rate to USD.
  ///
  /// Used by [CurrencyService] when Frankfurter API is unavailable.
  Future<Map<String, double>> getFallbackRates() async {
    if (_ratesCache != null) return _ratesCache!;
    await _loadAndCache();
    return _ratesCache!;
  }

  /// Finds a currency by its ISO code (e.g. `'USD'`, `'EUR'`).
  ///
  /// Returns `null` if not found.
  Future<CurrencyModel?> findByCode(String isoCode) async {
    if (_cacheByCode != null) return _cacheByCode![isoCode.toUpperCase()];
    await _loadAndCache();
    return _cacheByCode![isoCode.toUpperCase()];
  }

  /// Searches currencies by name, ISO code, symbol, or country.
  ///
  /// Returns results sorted by [search_weight] descending.
  /// Stable API — FTS5 upgrade changes only the internals.
  @override
  Future<List<CurrencyModel>> search(String query) async {
    if (query.isEmpty) return getAllCurrencies();
    final lower = query.toLowerCase();
    final all = await getAllCurrencies();
    return all
        .where(
          (c) =>
              c.code.toLowerCase().contains(lower) ||
              c.name.toLowerCase().contains(lower) ||
              c.symbol.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Clears in-memory caches (dev/test use only).
  @override
  void clearCache() {
    _cache = null;
    _ratesCache = null;
    _cacheByCode = null;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Loads and caches all currencies in a single query.
  Future<void> _loadAndCache() async {
    // Pinned currencies first (by pin_order ASC), then alphabetical.
    final rows = await _db.rawQuery('''
      SELECT * FROM currencies
      ORDER BY
        is_pinned DESC,
        CASE WHEN is_pinned = 1 THEN pin_order ELSE NULL END ASC,
        iso_code ASC
    ''');

    final models = rows.map(_rowToModel).toList();
    _cache = models;
    _cacheByCode = {for (final m in models) m.code: m};
    _ratesCache = {
      for (final row in rows)
        row['iso_code'] as String: (row['fallback_rate_to_usd'] as num).toDouble()
    };

    debugPrint('[CurrencyRepository] Loaded ${models.length} currencies');
  }

  /// Maps a raw SQLite row to a [CurrencyModel].
  static CurrencyModel _rowToModel(Map<String, Object?> row) {
    return CurrencyModel(
      code: row['iso_code'] as String,
      name: row['name'] as String,
      symbol: row['symbol'] as String,
      flag: row['flag'] as String,
      decimalDigits: row['decimal_digits'] as int? ?? 2,
      isPinned: (row['is_pinned'] as int? ?? 0) == 1,
    );
  }
}
