/// Repository for querying taxonomy tags and content-tag mappings from SQLite.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'base_repository.dart';
import '../database/database_service.dart';

/// Row model for a tag returned from the [tags] table.
@immutable
class TagRow {
  final int id;
  final String name;

  const TagRow({required this.id, required this.name});

  factory TagRow.fromMap(Map<String, Object?> map) {
    return TagRow(
      id: map['id'] as int,
      name: map['name'] as String,
    );
  }
}

/// Repository for querying tags and content-tag mappings.
class TagRepository implements BaseRepository<TagRow, int> {
  TagRepository._();

  /// The singleton instance.
  static final TagRepository instance = TagRepository._();

  List<TagRow>? _cache;

  Database get _db => DatabaseService.instance.database;

  // ─── BaseRepository API ───────────────────────────────────────────────────

  @override
  Future<List<TagRow>> getAll() async {
    if (_cache != null) return _cache!;
    final rows = await _db.query('tags', orderBy: 'name ASC');
    _cache = rows.map(TagRow.fromMap).toList();
    return _cache!;
  }

  @override
  Future<TagRow?> getById(int id) async {
    final all = await getAll();
    try {
      return all.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<TagRow>> search(String query) async {
    if (query.isEmpty) return getAll();
    final all = await getAll();
    final lower = query.toLowerCase();
    return all.where((t) => t.name.toLowerCase().contains(lower)).toList();
  }

  @override
  Future<int> count() async => (await getAll()).length;

  @override
  Future<bool> exists(int id) async => (await getById(id)) != null;

  @override
  void clearCache() => _cache = null;

  // ─── Domain Convenience API ───────────────────────────────────────────────

  /// Returns tags associated with a specific content item (e.g. source_type = 'category', source_id = 'length').
  Future<List<TagRow>> getTagsForContent(String sourceType, String sourceId) async {
    final rows = await _db.rawQuery('''
      SELECT t.* FROM tags t
      JOIN content_tags ct ON ct.tag_id = t.id
      WHERE ct.source_type = ? AND ct.source_id = ?
      ORDER BY t.name ASC
    ''', [sourceType, sourceId]);
    return rows.map(TagRow.fromMap).toList();
  }
}
