import '../data/units_data.dart';
import '../models/unit_model.dart';

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

/// Pure-Dart helper for searching conversion categories, units, and aliases.
class SearchHelper {
  SearchHelper._();

  /// Common spelling variations and alias mappings.
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

  /// Returns categories whose name, description, or any unit name/symbol/alias
  /// matches [query].
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
  /// or any unit name/symbol.
  static bool matchesCategory(UnitCategory category, String query) {
    return _matches(category, query.toLowerCase().trim());
  }

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
