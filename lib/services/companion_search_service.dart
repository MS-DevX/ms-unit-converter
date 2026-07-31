// ignore_for_file: use_build_context_synchronously

/// Pure offline search engine orchestrating multi-adapter searches across all local app data.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/collections_data.dart';
import '../data/converter_config.dart';
import '../data/currencies_data.dart';
import '../data/did_you_know.dart';
import '../data/units_data.dart';
import '../models/companion_result.dart';
import '../providers/custom_converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/pinned_provider.dart';
import '../screens/collection_screen.dart';
import '../screens/converter_screen.dart';
import '../screens/custom_converter_screen.dart';
import '../screens/notes_screen.dart';
import '../core/colors.dart';
import '../services/smart_parse_service.dart';
import '../services/unit_info_service.dart';
import '../utils/formatters.dart';

/// Pure-Dart offline search orchestrator for STEM Companion.
class CompanionSearchService {
  CompanionSearchService._();

  /// Normalized search query terms including alias expansion.
  static final Map<String, List<String>> _aliases = {
    'meter': ['m', 'metre', 'length'],
    'kilometre': ['km', 'kilometer', 'dist', 'distance'],
    'kilometer': ['km', 'kilometre', 'dist', 'distance'],
    'centimeter': ['cm', 'centimetre'],
    'millimeter': ['mm', 'millimetre'],
    'foot': ['ft', 'feet'],
    'feet': ['ft', 'foot'],
    'inch': ['in', 'inches'],
    'mile': ['mi', 'miles'],
    'pound': ['lb', 'lbs', 'weight', 'mass'],
    'kilogram': ['kg', 'kilos', 'kilo', 'weight'],
    'gram': ['g', 'grams'],
    'ounce': ['oz', 'ounces'],
    'liter': ['l', 'litre', 'vol', 'volume'],
    'celsius': ['c', 'centigrade', 'temp', 'temperature'],
    'fahrenheit': ['f', 'temp', 'temperature'],
    'kelvin': ['k', 'temp', 'temperature'],
    'usd': ['dollar', 'dollars', 'us dollar', 'money', 'currency'],
    'pkr': ['rupee', 'rupees', 'pakistan rupee', 'money', 'currency'],
    'eur': ['euro', 'euros', 'money', 'currency'],
    'gbp': ['pound sterling', 'uk pound', 'money', 'currency'],
    'inr': ['indian rupee', 'money', 'currency'],
    'byte': ['bytes', 'b', 'storage', 'data'],
    'kilobyte': ['kb'],
    'megabyte': ['mb'],
    'gigabyte': ['gb'],
    'terabyte': ['tb'],
    'pixel': ['px', 'typography', 'resolution'],
    'volt': ['v', 'voltage', 'electric'],
    'watt': ['w', 'power'],
    'joule': ['j', 'energy'],
    'bar': ['pressure', 'psi'],
    'psi': ['pressure', 'bar'],
    'bmi': ['body mass index', 'health', 'fitness'],
    'mathematics': ['math', 'angle', 'numberbase', 'percentage', 'formula'],
    'physics': ['speed', 'force', 'energy', 'power', 'pressure', 'acceleration', 'torque', 'momentum'],
    'chemistry': ['concentration', 'volume', 'density', 'temperature', 'cooking'],
    'constants': ['constant', 'speed of light', 'gravity', 'avogadro'],
    'engineering': ['pressure', 'stress', 'torque', 'voltage', 'current', 'resistance', 'power'],
    'recently viewed': ['recent', 'history'],
    'bookmarks': ['favorite', 'pinned', 'star', 'bookmark'],
  };


  /// Performs an offline search across all 11 local data sources.
  static Future<List<CompanionSearchResult>> search({
    required BuildContext context,
    required String query,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    // Safely pre-read provider data before any async gap
    CustomConverterProvider? customProv;
    NotesProvider? notesProv;
    FavoritesProvider? favProv;
    PinnedProvider? pinnedProv;
    HistoryProvider? historyProv;

    try {
      customProv = Provider.of<CustomConverterProvider>(context, listen: false);
      notesProv = Provider.of<NotesProvider>(context, listen: false);
      favProv = Provider.of<FavoritesProvider>(context, listen: false);
      pinnedProv = Provider.of<PinnedProvider>(context, listen: false);
      historyProv = Provider.of<HistoryProvider>(context, listen: false);
    } catch (_) {}

    final terms = _expandQuery(q);
    final results = <CompanionSearchResult>[];

    // Ensure UnitInfo JSON cache is loaded
    await UnitInfoService.load();

    // 0. Parse Natural Language Intent (e.g., "10 ft to m", "100 USD to PKR", "180 C to F")
    _parseNaturalLanguageIntent(context, q, results);

    // 0b. Search Everyday Measurement Guides (e.g., "TV size", "road distance", "baking", "tire pressure")
    _searchMeasurementGuides(context, q, terms, results);

    // 1. Search Units & Categories
    _searchUnitsAndCategories(context, q, terms, results);

    // 2. Search Definitions & Info
    await _searchDefinitions(context, q, terms, results);

    // 3. Search Formulas
    await _searchFormulas(context, q, terms, results);

    // 4. Search Currencies
    _searchCurrencies(context, q, terms, results);

    // 5. Search Curated Collections
    _searchCollections(context, q, terms, results);

    // 6. Search Custom Converters
    if (customProv != null) {
      _searchCustomConverters(context, customProv, q, terms, results);
    }

    // 7. Search Conversion Notes
    if (notesProv != null) {
      _searchNotes(context, notesProv, q, terms, results);
    }

    // 8. Search Favorites & Pinned
    if (favProv != null && pinnedProv != null) {
      _searchFavoritesAndPinned(context, favProv, pinnedProv, q, terms, results);
    }

    // 9. Search Recent History
    if (historyProv != null) {
      _searchHistory(context, historyProv, q, terms, results);
    }

    // 10. Search Did You Know Facts
    _searchFacts(context, q, terms, results);

    // Sort deterministically by score (highest score first)
    results.sort((a, b) => b.score.compareTo(a.score));

    return results;
  }

  static Set<String> _expandQuery(String raw) {
    final clean = raw.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    final set = <String>{clean, ...parts};

    for (final part in parts) {
      if (_aliases.containsKey(part)) {
        set.addAll(_aliases[part]!);
      }
      _aliases.forEach((key, val) {
        if (val.contains(part)) {
          set.add(key);
          set.addAll(val);
        }
      });
    }

    return set;
  }

  static void _searchUnitsAndCategories(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    for (final cat in UnitCategory.values) {
      final config = configFor(cat);
      final catNameLower = cat.displayName.toLowerCase();
      final catDescLower = cat.description.toLowerCase();

      // Check category match
      double catScore = 0;
      if (catNameLower == rawQuery) {
        catScore = 100;
      } else if (catNameLower.startsWith(rawQuery)) {
        catScore = 80;
      } else if (terms.any((t) => catNameLower.contains(t) || catDescLower.contains(t))) {
        catScore = 60;
      }

      if (catScore > 0) {
        results.add(
          CompanionSearchResult(
            id: 'cat_${cat.name}',
            type: CompanionResultType.category,
            title: cat.displayName,
            categoryName: 'Category',
            description: cat.description,
            icon: config.icon,
            accentColor: config.primaryColor,
            score: catScore,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConverterScreen(
                    initialCategory: cat,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }

      // Check units in category
      final units = unitsData[cat] ?? [];
      final relatedUnitNames = units.take(6).map((u) => u.name).toList();

      for (final unit in units) {
        final uNameLower = unit.name.toLowerCase();
        final uSymLower = unit.symbol.toLowerCase();

        double unitScore = 0;
        if (uNameLower == rawQuery || uSymLower == rawQuery) {
          unitScore = 95;
        } else if (uNameLower.startsWith(rawQuery)) {
          unitScore = 85;
        } else if (terms.any((t) => uNameLower.contains(t) || uSymLower == t)) {
          unitScore = 70;
        }

        if (unitScore > 0) {
          results.add(
            CompanionSearchResult(
              id: 'unit_${cat.name}_${unit.name}',
              type: CompanionResultType.unit,
              title: '${unit.name} (${unit.symbol})',
              categoryName: cat.displayName,
              description: 'Unit of ${cat.displayName.toLowerCase()}. Tap to convert using ${unit.name}.',
              icon: config.icon,
              accentColor: config.primaryColor,
              relatedUnits: relatedUnitNames.where((n) => n != unit.name).take(4).toList(),
              score: unitScore,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConverterScreen(
                      initialCategory: cat,
                      presetFromUnitName: unit.name,
                      isCompanion: true,
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }
  }

  static Future<void> _searchDefinitions(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) async {
    for (final cat in UnitCategory.values) {
      final units = unitsData[cat] ?? [];
      final config = configFor(cat);

      for (final unit in units) {
        final info = await UnitInfoService.getInfo(unit.name, unit.symbol);
        final defLower = info.definition.toLowerCase();
        final histLower = info.history.toLowerCase();
        final usedLower = info.usedFor.toLowerCase();

        bool matched = false;
        double score = 0;

        for (final term in terms) {
          if (term.length > 2 && (defLower.contains(term) || histLower.contains(term) || usedLower.contains(term))) {
            matched = true;
            score = 55;
            break;
          }
        }

        if (matched) {
          results.add(
            CompanionSearchResult(
              id: 'def_${unit.name}',
              type: CompanionResultType.definition,
              title: '${unit.name} Definition & Background',
              categoryName: cat.displayName,
              description: info.definition,
              matchingSnippet: 'Used for: ${info.usedFor}',
              icon: Icons.menu_book_rounded,
              accentColor: config.primaryColor,
              score: score,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConverterScreen(
                      initialCategory: cat,
                      presetFromUnitName: unit.name,
                      isCompanion: true,
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    }
  }

  static Future<void> _searchFormulas(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) async {
    // Unit conversion formulas
    if (terms.any((t) => t.contains('formula') || t.contains('calc') || t.contains('convert') || t.contains('how'))) {
      for (final cat in UnitCategory.values) {
        final units = unitsData[cat] ?? [];
        if (units.length < 2) continue;
        final config = configFor(cat);
        final baseUnit = units.firstWhere((u) => u.toBase == 1.0, orElse: () => units.first);
        final secondary = units.firstWhere((u) => u.name != baseUnit.name, orElse: () => units.last);

        String formulaStr;
        if (cat == UnitCategory.temperature) {
          formulaStr = '°F = (°C × 9/5) + 32  |  K = °C + 273.15';
        } else {
          formulaStr = '1 ${secondary.name} = ${secondary.toBase} ${baseUnit.name}';
        }

        results.add(
          CompanionSearchResult(
            id: 'formula_${cat.name}',
            type: CompanionResultType.formula,
            title: '${cat.displayName} Conversion Formula',
            categoryName: cat.displayName,
            description: 'Official formula for ${cat.displayName.toLowerCase()} conversions.',
            formula: formulaStr,
            icon: Icons.functions_rounded,
            accentColor: config.primaryColor,
            score: 65,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConverterScreen(
                    initialCategory: cat,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchCurrencies(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    final fallbackCurrencies = buildFallbackCurrencies();

    for (final c in fallbackCurrencies) {
      final codeLower = c.code.toLowerCase();
      final nameLower = c.name.toLowerCase();
      final symLower = c.symbol.toLowerCase();

      double score = 0;
      if (codeLower == rawQuery || symLower == rawQuery) {
        score = 95;
      } else if (nameLower == rawQuery) {
        score = 90;
      } else if (nameLower.startsWith(rawQuery) || codeLower.startsWith(rawQuery)) {
        score = 80;
      } else if (terms.any((t) => nameLower.contains(t) || codeLower == t)) {
        score = 65;
      }

      if (score > 0) {
        results.add(
          CompanionSearchResult(
            id: 'curr_${c.code}',
            type: CompanionResultType.currency,
            title: '${c.name} (${c.code})',
            categoryName: 'Currency',
            description: '${c.flag} ${c.symbol} • Global FX Currency Rate',
            icon: Icons.currency_exchange_rounded,
            accentColor: const Color(0xFF22C55E),
            score: score,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConverterScreen(initialCategory: UnitCategory.length),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchCollections(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    for (final col in predefinedCollections) {
      final nameLower = col.name.toLowerCase();
      final descLower = col.description.toLowerCase();

      double score = 0;
      if (nameLower == rawQuery) {
        score = 90;
      } else if (terms.any((t) => nameLower.contains(t) || descLower.contains(t))) {
        score = 65;
      }

      if (score > 0) {
        results.add(
          CompanionSearchResult(
            id: 'col_${col.id}',
            type: CompanionResultType.collection,
            title: '${col.emoji} ${col.name} Collection',
            categoryName: 'Curated Collection',
            description: col.description,
            icon: Icons.grid_view_rounded,
            accentColor: const Color(0xFF4F8CFF),
            score: score,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CollectionScreen(collection: col),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchCustomConverters(
    BuildContext context,
    CustomConverterProvider customProv,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    for (final custom in customProv.converters) {
      final nameLower = custom.name.toLowerCase();

      double score = 0;
      if (nameLower == rawQuery) {
        score = 90;
      } else if (terms.any((t) => nameLower.contains(t))) {
        score = 70;
      }

      if (score > 0) {
        results.add(
          CompanionSearchResult(
            id: 'custom_${custom.id}',
            type: CompanionResultType.customConverter,
            title: '${custom.emoji} ${custom.name}',
            categoryName: 'Custom Converter',
            description: 'User-created linear converter with ${custom.units.length} units.',
            icon: Icons.dashboard_customize_rounded,
            accentColor: const Color(0xFFA855F7),
            score: score,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomConverterScreen(),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchNotes(
    BuildContext context,
    NotesProvider notesProv,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    for (final note in notesProv.notes) {
      final titleLower = note.title.toLowerCase();
      final bodyLower = note.body.toLowerCase();

      double score = 0;
      if (titleLower.contains(rawQuery)) {
        score = 80;
      } else if (terms.any((t) => bodyLower.contains(t))) {
        score = 60;
      }

      if (score > 0) {
        results.add(
          CompanionSearchResult(
            id: 'note_${note.id}',
            type: CompanionResultType.note,
            title: note.title,
            categoryName: 'Conversion Note',
            description: note.body,
            icon: Icons.note_alt_rounded,
            accentColor: const Color(0xFFF59E0B),
            score: score,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotesScreen(),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchFavoritesAndPinned(
    BuildContext context,
    FavoritesProvider favProv,
    PinnedProvider pinnedProv,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    final isBookmarkSearch = terms.any(
      (t) => t == 'bookmarks' || t == 'bookmark' || t == 'favorite' || t == 'pinned' || t == 'star',
    );

    for (final cat in favProv.favorites) {
      final config = configFor(cat);
      final nameLower = cat.displayName.toLowerCase();
      if (isBookmarkSearch || terms.any((t) => nameLower.contains(t))) {
        results.add(
          CompanionSearchResult(
            id: 'fav_${cat.name}',
            type: CompanionResultType.favorite,
            title: '${cat.displayName} (Favorite)',
            categoryName: 'Favorite Category',
            description: 'Favorite converter category in your library.',
            icon: Icons.star_rounded,
            accentColor: config.primaryColor,
            score: isBookmarkSearch ? 95 : 85,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConverterScreen(
                    initialCategory: cat,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    for (final cat in pinnedProv.pinned) {
      final config = configFor(cat);
      final nameLower = cat.displayName.toLowerCase();
      if (isBookmarkSearch || terms.any((t) => nameLower.contains(t))) {
        results.add(
          CompanionSearchResult(
            id: 'pinned_${cat.name}',
            type: CompanionResultType.pinned,
            title: '${cat.displayName} (Pinned)',
            categoryName: 'Pinned Converter',
            description: 'Pinned quick-access converter on your Home dashboard.',
            icon: Icons.push_pin_rounded,
            accentColor: config.primaryColor,
            score: isBookmarkSearch ? 95 : 85,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConverterScreen(
                    initialCategory: cat,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchHistory(
    BuildContext context,
    HistoryProvider historyProv,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    final isRecentSearch = terms.any(
      (t) => t == 'recently viewed' || t == 'recent' || t == 'history',
    );

    for (final entry in historyProv.entries.take(20)) {
      final catNameLower = entry.category.toLowerCase();
      final fromLower = entry.fromUnit.toLowerCase();
      final toLower = entry.toUnit.toLowerCase();

      if (isRecentSearch || terms.any((t) => catNameLower.contains(t) || fromLower.contains(t) || toLower.contains(t))) {
        final catEnum = entry.categoryEnum;
        final config = configFor(catEnum);
        results.add(
          CompanionSearchResult(
            id: 'hist_${entry.id}',
            type: CompanionResultType.recent,
            title: '${Formatters.cleanFloatingPoint(entry.inputValue)} ${entry.fromSymbol} → ${Formatters.cleanFloatingPoint(entry.result)} ${entry.toSymbol}',
            categoryName: entry.category,
            description: 'Recent conversion: ${entry.fromUnit} to ${entry.toUnit}',
            icon: Icons.history_rounded,
            accentColor: config.primaryColor,
            score: isRecentSearch ? 90 : 60,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConverterScreen(
                    initialCategory: catEnum,
                    presetFromUnitName: entry.fromUnit,
                    presetToUnitName: entry.toUnit,
                    presetValue: entry.inputValue,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }

  static void _searchFacts(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    for (final fact in didYouKnowFacts) {
      final factLower = fact.fact.toLowerCase();

      if (terms.any((t) => t.length > 3 && factLower.contains(t))) {
        results.add(
          CompanionSearchResult(
            id: 'fact_${fact.fact.hashCode}',
            type: CompanionResultType.fact,
            title: 'Educational Fact ${fact.emoji}',
            categoryName: 'Educational Insight',
            description: fact.fact,
            icon: Icons.lightbulb_outline_rounded,
            accentColor: const Color(0xFF4F8CFF),
            score: 50,
            onTap: () {},
          ),
        );
      }
    }
  }

  static void _parseNaturalLanguageIntent(
    BuildContext context,
    String rawQuery,
    List<CompanionSearchResult> results,
  ) {
    final parsed = SmartParseService.parse(rawQuery);
    if (!parsed.isRecognized) return;

    if (parsed.isCurrency) {
      final fromCode = parsed.fromCurrencyCode ?? 'USD';
      final toCode = parsed.toCurrencyCode ?? 'EUR';
      final amount = parsed.amount ?? 1.0;

      results.add(
        CompanionSearchResult(
          id: 'intent_currency_$rawQuery',
          type: CompanionResultType.intent,
          title: 'Direct FX: $amount $fromCode → $toCode',
          categoryName: 'Currency Exchange',
          description: 'Convert $amount $fromCode to $toCode using live offline currency rates.',
          icon: Icons.currency_exchange_rounded,
          accentColor: AppColors.primary,
          score: 250.0,
          onTap: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      );
    } else if (parsed.category != null &&
        parsed.fromUnitName != null &&
        parsed.toUnitName != null) {
      final cat = parsed.category!;
      final config = configFor(cat);
      final amount = parsed.amount ?? 1.0;

      results.add(
        CompanionSearchResult(
          id: 'intent_unit_$rawQuery',
          type: CompanionResultType.intent,
          title: 'Direct Conversion: $amount ${parsed.fromUnitName} → ${parsed.toUnitName}',
          categoryName: cat.displayName,
          description: 'Open ${cat.displayName} converter with $amount ${parsed.fromUnitName} pre-filled.',
          icon: config.icon,
          accentColor: config.primaryColor,
          formula: '${parsed.fromUnitName} → ${parsed.toUnitName}',
          relatedUnits: [parsed.fromUnitName!, parsed.toUnitName!],
          score: 250.0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ConverterScreen(
                  initialCategory: cat,
                  presetFromUnitName: parsed.fromUnitName,
                  presetToUnitName: parsed.toUnitName,
                  presetValue: amount,
                  isCompanion: true,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  static void _searchMeasurementGuides(
    BuildContext context,
    String rawQuery,
    Set<String> terms,
    List<CompanionSearchResult> results,
  ) {
    const guides = [
      (
        key: 'tv size',
        title: 'TV & Display Screen Size',
        cat: UnitCategory.length,
        desc: 'Convert TV & display screen diagonals between Inches and Centimeters.',
        units: ['Inch', 'Centimeter']
      ),
      (
        key: 'monitor',
        title: 'TV & Display Screen Size',
        cat: UnitCategory.length,
        desc: 'Convert display screen diagonals between Inches and Centimeters.',
        units: ['Inch', 'Centimeter']
      ),
      (
        key: 'road distance',
        title: 'Driving & Road Travel',
        cat: UnitCategory.length,
        desc: 'Convert highway travel distances between Miles and Kilometers.',
        units: ['Mile', 'Kilometer']
      ),
      (
        key: 'driving',
        title: 'Driving & Road Travel',
        cat: UnitCategory.length,
        desc: 'Convert highway travel distances between Miles and Kilometers.',
        units: ['Mile', 'Kilometer']
      ),
      (
        key: 'cooking',
        title: 'Kitchen & Recipe Measurement',
        cat: UnitCategory.cooking,
        desc: 'Convert recipe ingredients between Cups, Milliliters, Tablespoons, and Grams.',
        units: ['Cup', 'Milliliter', 'Tablespoon', 'Gram']
      ),
      (
        key: 'baking',
        title: 'Kitchen & Recipe Measurement',
        cat: UnitCategory.cooking,
        desc: 'Convert recipe ingredients between Cups, Milliliters, Tablespoons, and Grams.',
        units: ['Cup', 'Milliliter', 'Tablespoon', 'Gram']
      ),
      (
        key: 'screen resolution',
        title: 'Display Density & Resolution',
        cat: UnitCategory.typography,
        desc: 'Convert display density between Pixels, Points, and Inches.',
        units: ['Pixel', 'Point', 'Inch']
      ),
      (
        key: 'tire pressure',
        title: 'Vehicle Tire Pressure',
        cat: UnitCategory.pressure,
        desc: 'Compare vehicle tire inflation ratings between PSI, Bar, and Kilopascals.',
        units: ['PSI', 'Bar', 'Kilopascal']
      ),
      (
        key: 'car tires',
        title: 'Vehicle Tire Pressure',
        cat: UnitCategory.pressure,
        desc: 'Compare vehicle tire inflation ratings between PSI, Bar, and Kilopascals.',
        units: ['PSI', 'Bar', 'Kilopascal']
      ),
      (
        key: 'fever',
        title: 'Body Temperature & Fever',
        cat: UnitCategory.temperature,
        desc: 'Measure body fever readings between Celsius and Fahrenheit.',
        units: ['Celsius', 'Fahrenheit']
      ),
      (
        key: 'fuel economy',
        title: 'Vehicle Fuel Economy',
        cat: UnitCategory.fuelEconomy,
        desc: 'Compare gas mileage efficiency between MPG and Liters per 100km.',
        units: ['Miles per Gallon (US)', 'Liters per 100km']
      ),
      (
        key: 'mileage',
        title: 'Vehicle Fuel Economy',
        cat: UnitCategory.fuelEconomy,
        desc: 'Compare gas mileage efficiency between MPG and Liters per 100km.',
        units: ['Miles per Gallon (US)', 'Liters per 100km']
      ),
    ];

    for (final guide in guides) {
      if (guide.key.contains(rawQuery) ||
          rawQuery.contains(guide.key) ||
          terms.any((t) => guide.key.contains(t))) {
        final config = configFor(guide.cat);
        results.add(
          CompanionSearchResult(
            id: 'guide_${guide.key}',
            type: CompanionResultType.guide,
            title: guide.title,
            categoryName: guide.cat.displayName,
            description: guide.desc,
            icon: config.icon,
            accentColor: config.primaryColor,
            relatedUnits: guide.units,
            score: 180.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConverterScreen(
                    initialCategory: guide.cat,
                    isCompanion: true,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
  }
}
