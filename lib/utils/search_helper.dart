import 'package:unit_converter/data/units_data.dart';

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
  ///
  /// Optionally restricts the search to [categories] (defaults to all
  /// [UnitCategory.values]).
  static List<UnitCategory> search(
    String query, {
    List<UnitCategory>? categories,
  }) {
    final cats = categories ?? UnitCategory.values;
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return cats.where((cat) => _matches(cat, q)).toList();
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
