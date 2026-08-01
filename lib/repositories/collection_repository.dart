/// Repository for querying collection data from the SQLite database.
///
/// Provides the same surface as [predefinedCollections] from
/// [collections_data.dart] while backing it with SQLite.
///
/// ## Future User-Data Migration Note
/// Pinned collections are currently managed by [CollectionsService] via
/// SharedPreferences. If migrated to SQLite in a future release, a
/// `updatePinnedState(String collectionId, bool isPinned)` method will be
/// added here without changing [loadAll] or [loadCategories].
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';
import '../data/collections_data.dart';
import '../data/units_data.dart';

/// Row model for a collection returned from the [collections] table.
@immutable
class CollectionRow {
  /// Creates a [CollectionRow].
  const CollectionRow({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    required this.displayOrder,
    required this.isFeatured,
  });

  /// Factory from raw SQLite row.
  factory CollectionRow.fromMap(Map<String, Object?> map) {
    return CollectionRow(
      id: map['id'] as String,
      name: map['name'] as String,
      emoji: map['emoji'] as String,
      description: map['description'] as String,
      displayOrder: map['display_order'] as int? ?? 0,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
    );
  }

  /// Unique identifier (e.g. `'everyday'`, `'student'`).
  final String id;

  /// Display name, e.g. `'Everyday'`.
  final String name;

  /// Emoji representing the collection.
  final String emoji;

  /// Short description of the collection.
  final String description;

  /// Sort position among all collections.
  final int displayOrder;

  /// Whether this collection is shown in featured sections.
  final bool isFeatured;
}

/// Singleton repository for [CollectionRow] data.
class CollectionRepository implements BaseRepository<CollectionRow, String> {
  CollectionRepository._();

  /// The singleton instance.
  static final CollectionRepository instance = CollectionRepository._();

  // Full cache of all collections.
  List<CollectionRow>? _collectionsCache;

  // Cache of category IDs per collection id.
  final Map<String, List<UnitCategory>> _itemsCache = {};

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<CollectionRow>> getAll() => loadAll();

  @override
  Future<CollectionRow?> getById(String id) => findById(id);

  @override
  Future<List<CollectionRow>> search(String query) async {
    if (query.isEmpty) return loadAll();
    final all = await loadAll();
    final lower = query.toLowerCase();
    return all
        .where(
          (c) =>
              c.name.toLowerCase().contains(lower) ||
              c.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Future<int> count() async => (await loadAll()).length;

  @override
  Future<bool> exists(String id) async => (await findById(id)) != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads all collections ordered by [display_order].
  ///
  /// Cached after the first call.
  Future<List<CollectionRow>> loadAll() async {
    if (_collectionsCache != null) return _collectionsCache!;

    final rows = await _db.query(
      'collections',
      orderBy: 'display_order ASC',
    );

    _collectionsCache = rows.map(CollectionRow.fromMap).toList();
    debugPrint('[CollectionRepository] Loaded ${_collectionsCache!.length} collections');
    return _collectionsCache!;
  }

  /// Finds a single collection by its [id].
  ///
  /// Returns `null` if not found.
  Future<CollectionRow?> findById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Loads the ordered list of [UnitCategory] values belonging to [collectionId].
  ///
  /// Cached per collection after the first call.
  Future<List<UnitCategory>> loadCategories(String collectionId) async {
    if (_itemsCache.containsKey(collectionId)) return _itemsCache[collectionId]!;

    final rows = await _db.query(
      'collection_items',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
      orderBy: 'display_order ASC',
    );

    final categories = <UnitCategory>[];
    for (final row in rows) {
      final catId = row['category_id'] as String;
      try {
        categories.add(UnitCategory.values.firstWhere((e) => e.name == catId));
      } catch (_) {
        debugPrint('[CollectionRepository] Unknown category_id in DB: $catId');
      }
    }

    _itemsCache[collectionId] = categories;
    return categories;
  }

  /// Loads all [Collection] objects with populated category lists from SQLite.
  Future<List<Collection>> loadFullCollections() async {
    final rows = await loadAll();
    final result = <Collection>[];
    for (final row in rows) {
      final cats = await loadCategories(row.id);
      result.add(
        Collection(
          id: row.id,
          name: row.name,
          emoji: row.emoji,
          description: row.description,
          categories: cats,
        ),
      );
    }
    return result;
  }

  /// Clears all in-memory caches (dev/test use only).
  @override
  void clearCache() {
    _collectionsCache = null;
    _itemsCache.clear();
  }
}
