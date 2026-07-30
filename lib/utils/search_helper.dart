/// Pure-Dart helper for searching conversion categories, units, and aliases.
///
/// ## Architecture
/// The synchronous static methods ([search], [searchDetailed], [matchesCategory])
/// continue to work against the in-memory [unitsData] map for backward
/// compatibility with all existing callers.
///
/// Additionally, [SearchHelper] now exposes async methods that delegate to
/// [SearchRepository], which backs lookups with the SQLite [search_aliases] table.
/// These async methods are the preferred path for new callers.
///
/// When FTS5 is enabled in a future release, only [SearchRepository] changes
/// internally — [SearchHelper] and all its callers remain unaffected.
library;

import '../data/units_data.dart';
import '../models/unit_model.dart';
import '../repositories/search_repository.dart';

/// Structured result for a category search match containing matched units.
class CategorySearchResult {
  final UnitCategory category;
  final List<UnitModel> matchingUnits;
  final bool matchesCategoryName;

  const CategorySearchResult({
    required this.category,
    required this.matchingUnits,
    required this.matchesCategoryName,
  });
}

/// Helper for searching conversion categories, units, and aliases.
class SearchHelper {
  SearchHelper._();

  /// Common spelling variations and alias mappings (in-memory fallback).
  ///
  /// Used by the synchronous API. The database alias table supersedes this
  /// for async lookups via [resolveAliasAsync].
  static const Map<String, List<String>> _aliases = {
    'meter': ['metre', 'm'],
    'metre': ['meter', 'm'],
    'kilometer': ['km', 'kilometre'],
    'kilometre': ['km', 'kilometer'],
    'centimeter': ['cm', 'centimetre'],
    'centimetre': ['cm', 'centimeter'],
    'millimeter': ['mm', 'millimetre'],
    'millimetre': ['mm', 'millimeter'],
    'kilogram': ['kg', 'kilos'],
    'pound': ['lbs', 'lb'],
    'lbs': ['pound', 'lb'],
    'ounce': ['oz'],
    'liter': ['litre', 'l'],
    'litre': ['liter', 'l'],
    'celsius': ['centigrade', 'temp', 'temperature'],
    'fahrenheit': ['temp', 'temperature'],
    'usd': ['dollar', 'us dollar'],
    'eur': ['euro'],
    'pkr': ['rupee', 'pakistan'],
    'inr': ['rupee', 'india'],
    'gbp': ['pound', 'uk'],
  };

  // ─── Synchronous API (backward-compatible) ─────────────────────────────────

  /// Returns categories whose name, description, or any unit name/symbol/alias
  /// matches [query]. Synchronous — uses in-memory [unitsData].
  static List<UnitCategory> search(
    String query, {
    List<UnitCategory>? categories,
  }) {
    final cats = categories ?? UnitCategory.values;
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return cats.where((cat) => _matches(cat, q)).toList();
  }

  /// Returns detailed search results including specific matching units
  /// for each category matching [query]. Synchronous.
  static List<CategorySearchResult> searchDetailed(
    String query, {
    List<UnitCategory>? categories,
  }) {
    final cats = categories ?? UnitCategory.values;
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final List<CategorySearchResult> results = [];
    final expandedTerms = _expandQuery(q);

    for (final cat in cats) {
      bool nameMatches = false;
      for (final term in expandedTerms) {
        if (cat.displayName.toLowerCase().contains(term) ||
            cat.description.toLowerCase().contains(term)) {
          nameMatches = true;
          break;
        }
      }

      final units = unitsData[cat] ?? [];
      final matchedUnits = units.where((u) {
        final uName = u.name.toLowerCase();
        final uSym = u.symbol.toLowerCase();
        for (final term in expandedTerms) {
          if (uName.contains(term) || uSym == term) return true;
        }
        return false;
      }).toList();

      if (nameMatches || matchedUnits.isNotEmpty) {
        results.add(
          CategorySearchResult(
            category: cat,
            matchingUnits: matchedUnits,
            matchesCategoryName: nameMatches,
          ),
        );
      }
    }

    return results;
  }

  /// Returns true if [query] matches [category] by name, description,
  /// or any unit name/symbol. Synchronous.
  static bool matchesCategory(UnitCategory category, String query) {
    return _matches(category, query.toLowerCase().trim());
  }

  // ─── Async API (DB-backed, preferred for new callers) ──────────────────────

  /// Resolves a keyword to its canonical display name via the alias table.
  ///
  /// Example: `'lbs'` → `'Pound'`, `'km'` → `'Kilometer'`.
  /// Falls back to the in-memory [_aliases] map if the DB returns null.
  static Future<String?> resolveAliasAsync(String keyword) async {
    final dbResult = await SearchRepository.instance.resolveAlias(keyword);
    if (dbResult != null) return dbResult;

    // In-memory fallback (Phase 1).
    final lower = keyword.toLowerCase();
    for (final entry in _aliases.entries) {
      if (entry.key == lower || entry.value.contains(lower)) {
        return entry.key;
      }
    }
    return null;
  }

  /// Searches categories asynchronously via [SearchRepository].
  static Future<List<CategorySearchResult>> searchDetailedAsync(String query) async {
    if (query.isEmpty) return [];
    final q = query.toLowerCase().trim();
    final expandedTerms = _expandQuery(q);

    final List<CategorySearchResult> results = [];
    for (final cat in UnitCategory.values) {
      bool nameMatches = false;
      for (final term in expandedTerms) {
        if (cat.displayName.toLowerCase().contains(term) ||
            cat.description.toLowerCase().contains(term)) {
          nameMatches = true;
          break;
        }
      }

      final matchedUnits = await SearchRepository.instance.searchUnits(q, cat);
      if (nameMatches || matchedUnits.isNotEmpty) {
        results.add(CategorySearchResult(
          category: cat,
          matchingUnits: matchedUnits,
          matchesCategoryName: nameMatches,
        ));
      }
    }
    return results;
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static bool _matches(UnitCategory cat, String query) {
    final expanded = _expandQuery(query);
    for (final term in expanded) {
      if (cat.displayName.toLowerCase().contains(term)) return true;
      if (cat.description.toLowerCase().contains(term)) return true;
      final units = unitsData[cat] ?? [];
      for (final unit in units) {
        if (unit.name.toLowerCase().contains(term)) return true;
        if (unit.symbol.toLowerCase() == term) return true;
      }
    }
    return false;
  }

  static List<String> _expandQuery(String q) {
    final terms = <String>{q};
    for (final entry in _aliases.entries) {
      if (entry.key == q || entry.value.contains(q)) {
        terms.add(entry.key);
        terms.addAll(entry.value);
      }
    }
    return terms.toList();
  }
}
