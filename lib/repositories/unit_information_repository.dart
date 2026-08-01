/// Repository for querying unit educational information from SQLite.
///
/// Replaces [UnitInfoService]'s `rootBundle.loadString` JSON-based approach
/// with a direct SQLite query, while maintaining the same public API shape.
///
/// ## Phase 1 Note
/// The [unit_information] table is NOT pre-seeded in Phase 1 because the
/// source JSON (`assets/data/unit_information.json`) uses unit names as keys,
/// and cross-referencing them to `units.id` row IDs requires a full unit load
/// pass that would complicate the seeder. The table is created and ready;
/// [UnitInfoService] continues to use `rootBundle` in Phase 1 and will
/// delegate to this repository in Phase 2 once the JSON content file is the
/// canonical source.
///
/// To seed unit information, run `tools/build_database.dart` (Phase 2+).
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';

import 'tag_repository.dart';
import 'related_content_repository.dart';

/// Represents a single unit's educational information record.
@immutable
class UnitInfoRow {
  /// Creates a [UnitInfoRow].
  const UnitInfoRow({
    required this.symbol,
    required this.definition,
    required this.history,
    required this.usedFor,
    required this.examples,
    this.tags = const [],
    this.relatedContent = const [],
  });

  /// Factory from raw SQLite row.
  factory UnitInfoRow.fromMap(Map<String, Object?> map, {
    List<TagRow> tags = const [],
    List<RelatedContentRow> relatedContent = const [],
  }) {
    final rawExamples = map['examples'] as String? ?? '[]';
    List<String> examples;
    try {
      // Examples stored as JSON array string.
      final cleaned = rawExamples.replaceAll(RegExp(r'^\[|\]$'), '');
      examples = cleaned.isEmpty
          ? []
          : cleaned
              .split('","')
              .map((s) => s.replaceAll('"', '').trim())
              .toList();
    } catch (_) {
      examples = [];
    }

    return UnitInfoRow(
      symbol: map['symbol'] as String? ?? '',
      definition: map['definition'] as String? ?? '',
      history: map['history'] as String? ?? '',
      usedFor: map['used_for'] as String? ?? '',
      examples: examples,
      tags: tags,
      relatedContent: relatedContent,
    );
  }

  /// The unit symbol, e.g. `'m'`, `'kg'`.
  final String symbol;

  /// Formal definition of the unit.
  final String definition;

  /// Historical context of the unit.
  final String history;

  /// Common usage examples and fields of application.
  final String usedFor;

  /// Concrete measurement examples.
  final List<String> examples;

  /// Taxonomy tags.
  final List<TagRow> tags;

  /// Related content edges.
  final List<RelatedContentRow> relatedContent;
}

/// Singleton repository for [UnitInfoRow] data.
class UnitInformationRepository implements BaseRepository<UnitInfoRow, String> {
  UnitInformationRepository._();

  /// The singleton instance.
  static final UnitInformationRepository instance = UnitInformationRepository._();

  // Per-unit lazy cache keyed by unit name.
  final Map<String, UnitInfoRow?> _cache = {};

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<UnitInfoRow>> getAll() async {
    final rows = await _db.query('unit_information');
    return rows.map(UnitInfoRow.fromMap).toList();
  }

  @override
  Future<UnitInfoRow?> getById(String id) => findByUnitName(id);

  @override
  Future<List<UnitInfoRow>> search(String query) async {
    if (query.isEmpty) return getAll();
    final all = await getAll();
    final lower = query.toLowerCase();
    return all
        .where(
          (u) =>
              u.definition.toLowerCase().contains(lower) ||
              u.history.toLowerCase().contains(lower) ||
              u.usedFor.toLowerCase().contains(lower) ||
              u.symbol.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Future<int> count() async {
    if (!DatabaseService.instance.isInitialized) return 0;
    try {
      final res = Sqflite.firstIntValue(
        await _db.rawQuery('SELECT COUNT(*) FROM unit_information'),
      );
      return res ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<bool> exists(String id) async => (await findByUnitName(id)) != null;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Loads the educational info for a unit by its [unitId] (row id).
  ///
  /// Returns `null` if no record exists (the table may be empty in Phase 1).
  Future<UnitInfoRow?> findByUnitId(int unitId) async {
    final rows = await _db.query(
      'unit_information',
      where: 'unit_id = ?',
      whereArgs: [unitId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UnitInfoRow.fromMap(rows.first);
  }

  /// Loads the educational info for a unit by its [unitName].
  ///
  /// Performs a JOIN to resolve the name to a unit_id internally.
  /// Returns `null` if no record exists.
  Future<UnitInfoRow?> findByUnitName(String unitName) async {
    if (_cache.containsKey(unitName)) return _cache[unitName];

    final rows = await _db.rawQuery('''
      SELECT ui.* FROM unit_information ui
      JOIN units u ON u.id = ui.unit_id
      WHERE u.name = ?
      LIMIT 1
    ''', [unitName]);

    if (rows.isEmpty) return null;
    final tags = await TagRepository.instance.getTagsForContent('unit', unitName);
    final related = await RelatedContentRepository.instance.getRelatedContent('unit', unitName);
    final result = UnitInfoRow.fromMap(rows.first, tags: tags, relatedContent: related);
    _cache[unitName] = result;
    return result;
  }

  /// Inserts or replaces a [UnitInfoRow] for a given [unitId].
  ///
  /// Used by the Phase 2 build tool and migration scripts.
  Future<void> upsert(int unitId, UnitInfoRow info) async {
    await _db.insert(
      'unit_information',
      {
        'unit_id': unitId,
        'symbol': info.symbol,
        'definition': info.definition,
        'history': info.history,
        'used_for': info.usedFor,
        'examples': '[${info.examples.map((e) => '"$e"').join(',')}]',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Returns whether any unit information rows exist in the table.
  ///
  /// Used by [UnitInfoService] to decide whether to fall back to JSON asset.
  Future<bool> hasData() async {
    if (!DatabaseService.instance.isInitialized) return false;
    try {
      final count = Sqflite.firstIntValue(
        await _db.rawQuery('SELECT COUNT(*) FROM unit_information'),
      );
      return (count ?? 0) > 0;
    } catch (_) {
      return false;
    }
  }

  /// Clears in-memory cache (dev/test use only).
  @override
  void clearCache() => _cache.clear();
}
