/// Repository for querying [UnitCategory] metadata from the SQLite database.
///
/// ## FTS5 Readiness
/// The public API of this repository is designed to be backend-agnostic.
/// When FTS5 is enabled in a future release, only the private query methods
/// change — all callers remain unaffected.
///
/// ## Future Migration Note
/// This repository does not handle any user data (favorites, pinned categories).
/// Those remain in SharedPreferences via [FavoritesService] and [PinnedService].
/// Migrating them to SQLite in a future release requires only adding new methods
/// to this repository without changing its existing public API.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';
import '../data/units_data.dart';

/// Row model returned from the [categories] table.
@immutable
class CategoryRow {
  /// Creates a [CategoryRow] from a database map.
  const CategoryRow({
    required this.id,
    required this.displayName,
    required this.description,
    required this.groupName,
    required this.emoji,
    required this.displayOrder,
    required this.isFeatured,
    required this.isHidden,
    required this.searchWeight,
  });

  /// Parses a [CategoryRow] from a raw SQLite row map.
  factory CategoryRow.fromMap(Map<String, Object?> map) {
    return CategoryRow(
      id: map['id'] as String,
      displayName: map['display_name'] as String,
      description: map['description'] as String,
      groupName: map['group_name'] as String,
      emoji: map['emoji'] as String? ?? '',
      displayOrder: map['display_order'] as int? ?? 0,
      isFeatured: (map['is_featured'] as int? ?? 0) == 1,
      isHidden: (map['is_hidden'] as int? ?? 0) == 1,
      searchWeight: map['search_weight'] as int? ?? 100,
    );
  }

  /// The [UnitCategory.name] value (primary key).
  final String id;

  /// User-visible display name, e.g. "Length", "Weight".
  final String displayName;

  /// Short description of the category.
  final String description;

  /// Group name, e.g. "Everyday", "Science", "Electrical".
  final String groupName;

  /// Emoji icon for the category.
  final String emoji;

  /// Sort position among all categories.
  final int displayOrder;

  /// Whether this category appears in featured/popular sections.
  final bool isFeatured;

  /// Whether this category is excluded from UI listings.
  final bool isHidden;

  /// Higher = ranked earlier in search results.
  final int searchWeight;
}

/// Singleton repository for [CategoryRow] data.
class CategoryRepository implements BaseRepository<CategoryRow, String> {
  CategoryRepository._();

  /// The singleton instance.
  static final CategoryRepository instance = CategoryRepository._();

  // In-memory cache — populated on first [loadAll] call and reused thereafter.
  List<CategoryRow>? _cache;
  Map<String, CategoryRow>? _cacheById;

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<CategoryRow>> getAll() => loadAll();

  @override
  Future<CategoryRow?> getById(String id) => findById(id);

  @override
  Future<int> count() async => (await loadAll()).length;

  @override
  Future<bool> exists(String id) async => (await findById(id)) != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads all categories, ordered by [display_order].
  ///
  /// Cached after the first call — subsequent calls return from memory.
  Future<List<CategoryRow>> loadAll() async {
    if (_cache != null) return _cache!;
    final rows = await _db.query(
      'categories',
      orderBy: 'display_order ASC',
    );
    _cache = rows.map(CategoryRow.fromMap).toList();
    _cacheById = {for (final r in _cache!) r.id: r};
    debugPrint('[CategoryRepository] Loaded ${_cache!.length} categories');
    return _cache!;
  }

  /// Loads featured categories (is_featured = 1), ordered by [display_order].
  Future<List<CategoryRow>> loadFeatured() async {
    final all = await loadAll();
    return all.where((r) => r.isFeatured && !r.isHidden).toList();
  }

  /// Finds a single category by its [UnitCategory.name] identifier.
  ///
  /// Returns `null` if not found.
  Future<CategoryRow?> findById(String id) async {
    if (_cacheById != null) return _cacheById![id];
    await loadAll();
    return _cacheById![id];
  }

  /// Searches categories by [query] against display_name and group_name.
  ///
  /// This method uses a LIKE query. The backend is designed so that a future
  /// FTS5 upgrade requires only changes inside this method, not in callers.
  @override
  Future<List<CategoryRow>> search(String query) async {
    if (query.isEmpty) return loadAll();
    final all = await loadAll();
    final lower = query.toLowerCase();
    return all
        .where(
          (r) =>
              r.displayName.toLowerCase().contains(lower) ||
              r.groupName.toLowerCase().contains(lower) ||
              r.description.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Loads categories belonging to a specific [groupName].
  Future<List<CategoryRow>> loadByGroup(String groupName) async {
    final all = await loadAll();
    return all.where((r) => r.groupName == groupName).toList();
  }

  /// Resolves a [CategoryRow] to its [UnitCategory] enum value.
  ///
  /// Returns `null` if the id does not match any known enum value.
  UnitCategory? toEnum(CategoryRow row) {
    try {
      return UnitCategory.values.firstWhere((e) => e.name == row.id);
    } catch (_) {
      return null;
    }
  }

  /// Clears the in-memory cache.
  ///
  /// Should be called if the database is reseeded at runtime (dev/test only).
  @override
  void clearCache() {
    _cache = null;
    _cacheById = null;
  }
}
