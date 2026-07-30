/// Repository for querying STEM Academy categories, topics, and formula lessons from SQLite.
library;

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../database/database_service.dart';
import '../models/formula_model.dart';

/// Single responsibility repository for formulas and categories.
class FormulaRepository {
  FormulaRepository._();

  static final FormulaRepository instance = FormulaRepository._();

  final Map<String, List<FormulaModel>> _categoryFormulasCache = {};
  final Map<int, FormulaModel> _formulaIdCache = {};
  List<FormulaCategoryModel>? _categoriesCache;

  Database get _db => DatabaseService.instance.database;

  /// Loads categories for a given subject (default subjectId: 1 for Mathematics).
  Future<List<FormulaCategoryModel>> loadCategories({int subjectId = 1}) async {
    if (_categoriesCache != null) return _categoriesCache!;

    try {
      final rows = await _db.query(
        'formula_categories',
        where: 'subject_id = ?',
        whereArgs: [subjectId],
        orderBy: 'display_order ASC',
      );
      if (rows.isNotEmpty) {
        _categoriesCache = rows.map((r) => FormulaCategoryModel.fromRow(r)).toList();
        return _categoriesCache!;
      }
    } catch (e) {
      debugPrint('[FormulaRepository] Error loading categories from DB: $e');
    }

    return [];
  }

  /// Loads all formulas/lessons for a given category.
  Future<List<FormulaModel>> loadFormulasForCategory(String categoryId) async {
    if (_categoryFormulasCache.containsKey(categoryId)) {
      return _categoryFormulasCache[categoryId]!;
    }

    try {
      final rows = await _db.query(
        'formulas',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'display_order ASC',
      );

      final list = <FormulaModel>[];
      for (final r in rows) {
        final formulaId = r['id'] as int;
        final relatedRows = await _db.query(
          'related_content',
          where: 'source_type = ? AND source_id = ?',
          whereArgs: ['formula', formulaId.toString()],
        );
        final related = relatedRows.map((rel) => RelatedContentModel.fromRow(rel)).toList();
        final model = FormulaModel.fromRow(r, related: related);
        list.add(model);
        _formulaIdCache[formulaId] = model;
      }

      _categoryFormulasCache[categoryId] = list;
      return list;
    } catch (e) {
      debugPrint('[FormulaRepository] Error loading formulas for $categoryId: $e');
      return [];
    }
  }

  /// Groups formulas for a category into topics.
  Future<Map<String, List<FormulaModel>>> loadTopicsForCategory(String categoryId) async {
    final formulas = await loadFormulasForCategory(categoryId);
    final topics = <String, List<FormulaModel>>{};
    for (final f in formulas) {
      topics.putIfAbsent(f.topic, () => []).add(f);
    }
    return topics;
  }

  /// Fetches a single formula lesson by ID.
  Future<FormulaModel?> getFormulaById(int id) async {
    if (_formulaIdCache.containsKey(id)) return _formulaIdCache[id]!;

    try {
      final rows = await _db.query(
        'formulas',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final relatedRows = await _db.query(
        'related_content',
        where: 'source_type = ? AND source_id = ?',
        whereArgs: ['formula', id.toString()],
      );
      final related = relatedRows.map((rel) => RelatedContentModel.fromRow(rel)).toList();
      final model = FormulaModel.fromRow(rows.first, related: related);
      _formulaIdCache[id] = model;
      return model;
    } catch (e) {
      debugPrint('[FormulaRepository] Error fetching formula $id: $e');
      return null;
    }
  }

  /// Performs full SQLite LIKE search across all formulas.
  Future<List<FormulaModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final q = '%${query.trim().toLowerCase()}%';

    try {
      final rows = await _db.query(
        'formulas',
        where: 'LOWER(title) LIKE ? OR LOWER(expression) LIKE ? OR LOWER(description) LIKE ? OR LOWER(chapter) LIKE ?',
        whereArgs: [q, q, q, q],
        orderBy: 'display_order ASC',
      );

      final list = <FormulaModel>[];
      for (final r in rows) {
        final formulaId = r['id'] as int;
        if (_formulaIdCache.containsKey(formulaId)) {
          list.add(_formulaIdCache[formulaId]!);
        } else {
          final model = FormulaModel.fromRow(r);
          _formulaIdCache[formulaId] = model;
          list.add(model);
        }
      }
      return list;
    } catch (e) {
      debugPrint('[FormulaRepository] Error searching formulas: $e');
      return [];
    }
  }

  void clearCache() {
    _categoryFormulasCache.clear();
    _formulaIdCache.clear();
    _categoriesCache = null;
  }
}
