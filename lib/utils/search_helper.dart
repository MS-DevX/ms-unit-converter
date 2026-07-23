import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/models/unit_model.dart';

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

/// Pure-Dart helper for searching conversion categories and units.
///
/// All methods are stateless and deterministic. No Flutter UI dependency
/// is required, making this file safe for use in the data layer and tests.
class SearchHelper {
  SearchHelper._();

  /// Returns categories whose name, description, or any unit name/symbol
  /// matches [query].
  ///
  /// Matching is case-insensitive. Returns an empty list if [query] is
  /// empty or blank.
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
  /// for each category matching [query].
  static List<CategorySearchResult> searchDetailed(
    String query, {
    List<UnitCategory>? categories,
  }) {
    final cats = categories ?? UnitCategory.values;
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];

    final List<CategorySearchResult> results = [];

    for (final cat in cats) {
      final nameMatches = cat.displayName.toLowerCase().contains(q) ||
          cat.description.toLowerCase().contains(q);
      final units = unitsData[cat] ?? [];
      final matchedUnits = units
          .where(
            (u) =>
                u.name.toLowerCase().contains(q) ||
                u.symbol.toLowerCase().contains(q),
          )
          .toList();

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
  /// or any unit name/symbol.
  static bool matchesCategory(UnitCategory category, String query) {
    return _matches(category, query.toLowerCase().trim());
  }

  static bool _matches(UnitCategory cat, String query) {
    if (cat.displayName.toLowerCase().contains(query)) return true;
    if (cat.description.toLowerCase().contains(query)) return true;
    final units = unitsData[cat] ?? [];
    for (final unit in units) {
      if (unit.name.toLowerCase().contains(query)) return true;
      if (unit.symbol.toLowerCase().contains(query)) return true;
    }
    return false;
  }
}
