/// Repository for querying STEM Academy subjects from SQLite.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../models/subject_model.dart';

/// Single responsibility repository for subjects.
class SubjectRepository {
  SubjectRepository._();

  static final SubjectRepository instance = SubjectRepository._();

  List<SubjectModel>? _cache;

  Database get _db => DatabaseService.instance.database;

  /// Loads all subjects ordered by display order.
  Future<List<SubjectModel>> loadSubjects() async {
    if (_cache != null) return _cache!;

    try {
      final rows = await _db.query(
        'subjects',
        orderBy: 'display_order ASC',
      );
      if (rows.isNotEmpty) {
        _cache = rows.map((r) => SubjectModel.fromRow(r)).toList();
        return _cache!;
      }
    } catch (e) {
      debugPrint('[SubjectRepository] Error loading subjects from DB: $e');
    }

    // Default fallback if database table is empty before first reseed
    _cache = const [
      SubjectModel(id: 1, name: 'Mathematics', icon: '📐', isAvailable: true, displayOrder: 1),
      SubjectModel(id: 2, name: 'Physics', icon: '⚛️', isAvailable: false, displayOrder: 2),
      SubjectModel(id: 3, name: 'Chemistry', icon: '🧪', isAvailable: false, displayOrder: 3),
      SubjectModel(id: 4, name: 'Engineering', icon: '⚙️', isAvailable: false, displayOrder: 4),
      SubjectModel(id: 5, name: 'Computer Science', icon: '💻', isAvailable: false, displayOrder: 5),
      SubjectModel(id: 6, name: 'Scientific Constants', icon: '🔬', isAvailable: false, displayOrder: 6),
    ];
    return _cache!;
  }

  void clearCache() => _cache = null;
}
