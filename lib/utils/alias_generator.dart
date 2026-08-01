/// Algorithmic generator for unit search aliases and spelling variants.
///
/// Reduces manual alias duplication by generating plurals, US/UK spellings,
/// hyphenations, and case variants automatically.
library;

import '../models/unit_model.dart';

/// Algorithmic search alias generator.
class AliasGenerator {
  AliasGenerator._();

  /// Common US to UK spelling mapping pairs.
  static const Map<String, String> _usToUkSpelling = {
    'meter': 'metre',
    'liter': 'litre',
    'gram': 'gramme',
  };

  /// Generates a set of search aliases for a single [UnitModel].
  static Set<String> generateForUnit(UnitModel unit) {
    final aliases = <String>{};
    final lowerName = unit.name.toLowerCase().trim();
    final lowerSymbol = unit.symbol.trim();

    if (lowerName.isNotEmpty) {
      aliases.add(lowerName);
      _addVariations(lowerName, aliases);
    }

    if (lowerSymbol.isNotEmpty) {
      aliases.add(lowerSymbol);
    }

    return aliases;
  }

  /// Adds delimiter, plural, and US/UK spelling variations for [term].
  static void _addVariations(String term, Set<String> aliases) {
    // 1. Delimiter variations (hyphen, underscore, space)
    if (term.contains(' ')) {
      aliases.add(term.replaceAll(' ', '-'));
      aliases.add(term.replaceAll(' ', '_'));
    }
    if (term.contains('-')) {
      aliases.add(term.replaceAll('-', ' '));
      aliases.add(term.replaceAll('-', '_'));
    }

    // 2. Plural variations
    if (term == 'foot') {
      aliases.add('feet');
    } else if (term.endsWith('inch')) {
      aliases.add('${term}es');
    } else if (term.endsWith('ch') || term.endsWith('sh') || term.endsWith('x') || term.endsWith('z')) {
      aliases.add('${term}es');
    } else if (term.endsWith('y') &&
        !term.endsWith('ay') &&
        !term.endsWith('ey') &&
        !term.endsWith('oy') &&
        !term.endsWith('uy')) {
      aliases.add('${term.substring(0, term.length - 1)}ies');
    } else if (!term.endsWith('s')) {
      aliases.add('${term}s');
    }

    // 3. US <-> UK spelling variations
    for (final entry in _usToUkSpelling.entries) {
      if (term.contains(entry.key)) {
        final uk = term.replaceAll(entry.key, entry.value);
        aliases.add(uk);
        if (!uk.endsWith('s')) aliases.add('${uk}s');
      }
      if (term.contains(entry.value)) {
        final us = term.replaceAll(entry.value, entry.key);
        aliases.add(us);
        if (!us.endsWith('s')) aliases.add('${us}s');
      }
    }
  }
}
