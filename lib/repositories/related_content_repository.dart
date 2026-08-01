/// Repository for querying relationship edges between content nodes in SQLite.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';

/// Row model for a relationship edge from the [related_content] table.
@immutable
class RelatedContentRow {
  final int id;
  final String sourceType;
  final String sourceId;
  final String targetType;
  final String targetId;
  final String relationshipType;
  final int displayOrder;

  const RelatedContentRow({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.targetType,
    required this.targetId,
    required this.relationshipType,
    required this.displayOrder,
  });

  factory RelatedContentRow.fromMap(Map<String, Object?> map) {
    return RelatedContentRow(
      id: map['id'] as int,
      sourceType: map['source_type'] as String,
      sourceId: map['source_id'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      relationshipType: map['relationship_type'] as String,
      displayOrder: map['display_order'] as int? ?? 0,
    );
  }
}

/// Repository for querying content relationship edges in SQLite.
class RelatedContentRepository implements BaseRepository<RelatedContentRow, int> {
  RelatedContentRepository._();

  /// The singleton instance.
  static final RelatedContentRepository instance = RelatedContentRepository._();

  List<RelatedContentRow>? _cache;

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<RelatedContentRow>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _db.query('related_content', orderBy: 'display_order ASC');
    _cache = rows.map(RelatedContentRow.fromMap).toList();
    return _cache!;
  }

  @override
  Future<RelatedContentRow?> getById(int id) async {
    final all = await getAll();
    try {
      return all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RelatedContentRow>> search(String query) async {
    if (query.isEmpty) return getAll();
    final all = await getAll();
    final lower = query.toLowerCase();
    return all.where((r) =>
      r.sourceId.toLowerCase().contains(lower) ||
      r.targetId.toLowerCase().contains(lower) ||
      r.relationshipType.toLowerCase().contains(lower),
    ).toList();
  }

  @override
  Future<int> count() async => (await getAll()).length;

  @override
  Future<bool> exists(int id) async => (await getById(id)) != null;

  @override
  void clearCache() => _cache = null;

  // ─── Domain Convenience API ───────────────────────────────────────────────

  /// Gets all relationship edges where [sourceId] is the source or target.
  Future<List<RelatedContentRow>> getRelatedContent(String sourceType, String sourceId) async {
    final rows = await _db.query(
      'related_content',
      where: '(source_type = ? AND source_id = ?) OR (target_type = ? AND target_id = ?)',
      whereArgs: [sourceType, sourceId, sourceType, sourceId],
      orderBy: 'display_order ASC',
    );
    return rows.map(RelatedContentRow.fromMap).toList();
  }
}
