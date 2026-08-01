/// Repository for querying educational facts ("Did You Know") from SQLite.
///
/// Replaces the [didYouKnowFacts] list from [did_you_know.dart] with a
/// database-backed source, while keeping the [DidYouKnowFact] model interface
/// intact for compatibility with existing widgets.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';
import '../data/did_you_know.dart';
import '../data/units_data.dart';

/// Singleton repository for educational facts from the [educational_facts] table.
class EducationalFactsRepository implements BaseRepository<DidYouKnowFact, int> {
  EducationalFactsRepository._();

  /// The singleton instance.
  static final EducationalFactsRepository instance = EducationalFactsRepository._();

  // Full cache ordered by display_order.
  List<DidYouKnowFact>? _cache;

  // Cache by category.
  final Map<String, List<DidYouKnowFact>> _categoryCache = {};

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<DidYouKnowFact>> getAll() => loadAll();

  @override
  Future<DidYouKnowFact?> getById(int id) async {
    final all = await loadAll();
    if (id >= 0 && id < all.length) return all[id];
    return null;
  }

  @override
  Future<List<DidYouKnowFact>> search(String query) async {
    if (query.isEmpty) return loadAll();
    final all = await loadAll();
    final lower = query.toLowerCase();
    return all.where((f) => f.fact.toLowerCase().contains(lower)).toList();
  }

  @override
  Future<int> count() async => (await loadAll()).length;

  @override
  Future<bool> exists(int id) async {
    final total = await count();
    return id >= 0 && id < total;
  }

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads all educational facts ordered by [display_order].
  ///
  /// Cached after the first call.
  Future<List<DidYouKnowFact>> loadAll() async {
    if (_cache != null) return _cache!;

    final rows = await _db.query(
      'educational_facts',
      where: 'is_hidden = 0',
      orderBy: 'display_order ASC',
    );

    _cache = rows.map(_rowToFact).toList();
    debugPrint('[EducationalFactsRepository] Loaded ${_cache!.length} facts');
    return _cache!;
  }

  /// Loads facts related to a specific [category].
  ///
  /// Returns all general facts (category_id IS NULL) plus any facts
  /// specifically tagged to this category.
  Future<List<DidYouKnowFact>> loadForCategory(UnitCategory category) async {
    final key = category.name;
    if (_categoryCache.containsKey(key)) return _categoryCache[key]!;

    final rows = await _db.query(
      'educational_facts',
      where: 'is_hidden = 0 AND (category_id IS NULL OR category_id = ?)',
      whereArgs: [key],
      orderBy: 'display_order ASC',
    );

    final facts = rows.map(_rowToFact).toList();
    _categoryCache[key] = facts;
    return facts;
  }

  /// Loads a random subset of [count] facts for the "Did You Know" card.
  ///
  /// Uses SQLite's ORDER BY RANDOM() for efficient random selection.
  Future<List<DidYouKnowFact>> loadRandom(int count) async {
    final rows = await _db.query(
      'educational_facts',
      where: 'is_hidden = 0',
      orderBy: 'RANDOM()',
      limit: count,
    );
    return rows.map(_rowToFact).toList();
  }

  /// Loads featured facts (is_featured = 1).
  Future<List<DidYouKnowFact>> loadFeatured() async {
    final rows = await _db.query(
      'educational_facts',
      where: 'is_hidden = 0 AND is_featured = 1',
      orderBy: 'display_order ASC',
    );
    return rows.map(_rowToFact).toList();
  }

  /// Clears all in-memory caches (dev/test use only).
  @override
  void clearCache() {
    _cache = null;
    _categoryCache.clear();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  /// Maps a raw SQLite row to a [DidYouKnowFact].
  static DidYouKnowFact _rowToFact(Map<String, Object?> row) {
    return DidYouKnowFact(
      emoji: row['emoji'] as String,
      fact: row['fact'] as String,
    );
  }
}
