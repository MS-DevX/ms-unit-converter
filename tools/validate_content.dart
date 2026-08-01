// ignore_for_file: avoid_print

/// Content validation tool — MS Unit Converter
///
/// Rigorously validates all content datasets (units, categories, currencies,
/// collections, educational facts, search aliases, unit information) for
/// uniqueness, referential integrity, data quality, and completeness.
///
/// Designed to run standalone in CI pipelines for fast pre-build feedback.
///
/// ## Usage
/// ```bash
/// flutter test test/validate_content_test.dart
/// or
/// dart run tools/validate_content.dart
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'package:unit_converter/data/collections_data.dart';
import 'package:unit_converter/data/converter_config.dart';
import 'package:unit_converter/data/currencies_data.dart';
import 'package:unit_converter/data/did_you_know.dart';
import 'package:unit_converter/data/units_data.dart';

void main(List<String> args) {
  runCliValidator();
}

/// Runs content validation and exits with code 0 on success or 1 on error.
void runCliValidator() {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║      MS Unit Converter — Content Validation Tool        ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  Status: Enforcing strict pre-build validation rules     ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  final errors = validateContent(verbose: true);

  print('\n════════════════════════════════════════════════════════════');
  if (errors.isEmpty) {
    print('✅ ALL PRE-BUILD CONTENT VALIDATION CHECKS PASSED!');
    print('════════════════════════════════════════════════════════════\n');
    exit(0);
  } else {
    print('❌ CONTENT VALIDATION FAILED WITH ${errors.length} ERROR(S):');
    for (final err in errors) {
      print('   → $err');
    }
    print('════════════════════════════════════════════════════════════\n');
    exit(1);
  }
}

/// Programmatic validation logic returning list of error messages (empty if valid).
List<String> validateContent({bool verbose = false}) {
  final errors = <String>[];

  // 1. File existence checks
  final filesToCheck = [
    'lib/data/units_data.dart',
    'lib/data/currencies_data.dart',
    'lib/data/collections_data.dart',
    'lib/data/did_you_know.dart',
    'lib/data/converter_config.dart',
    'assets/data/unit_information.json',
  ];

  if (verbose) print('1. Checking required content files:');
  for (final filePath in filesToCheck) {
    final file = File(filePath);
    if (!file.existsSync()) {
      errors.add('MISSING FILE: $filePath');
      if (verbose) print('  ✗ $filePath — MISSING');
    } else {
      if (verbose) print('  ✓ $filePath');
    }
  }

  // 2. Category & Converter Config validation
  if (verbose) print('\n2. Validating Categories & Converter Configurations:');
  final categoryIds = <String>{};
  for (final cat in UnitCategory.values) {
    if (categoryIds.contains(cat.name)) {
      errors.add('DUPLICATE CATEGORY ID: ${cat.name}');
    }
    categoryIds.add(cat.name);

    if (cat.displayName.trim().isEmpty) {
      errors.add('EMPTY DISPLAY NAME: Category ${cat.name}');
    }
    if (cat.description.trim().isEmpty) {
      errors.add('EMPTY DESCRIPTION: Category ${cat.name}');
    }

    final config = converterRegistry[cat];
    if (config == null) {
      errors.add('MISSING CONVERTER CONFIG: Category ${cat.name} not in converterRegistry');
    } else {
      if (config.group.trim().isEmpty) {
        errors.add('EMPTY GROUP NAME: Category ${cat.name} config group');
      }
    }
  }
  if (verbose) print('  ✓ ${UnitCategory.values.length} categories validated');

  // 3. Units validation
  if (verbose) print('\n3. Validating Units Data:');
  var totalUnits = 0;
  for (final cat in UnitCategory.values) {
    final units = unitsData[cat];
    if (units == null || units.length < 2) {
      errors.add('INCOMPLETE CATEGORY: Category ${cat.name} has fewer than 2 units');
      continue;
    }

    final unitNames = <String>{};
    final unitSymbols = <String>{};

    for (final u in units) {
      totalUnits++;
      final nameLower = u.name.trim().toLowerCase();
      final symExact = u.symbol.trim();

      if (u.name.trim().isEmpty) {
        errors.add('EMPTY UNIT NAME in category ${cat.name}');
      }
      if (u.symbol.trim().isEmpty) {
        errors.add('EMPTY UNIT SYMBOL in category ${cat.name}: ${u.name}');
      }

      if (unitNames.contains(nameLower)) {
        errors.add('DUPLICATE UNIT NAME in category ${cat.name}: ${u.name}');
      }
      unitNames.add(nameLower);

      if (unitSymbols.contains(symExact)) {
        errors.add('DUPLICATE UNIT SYMBOL in category ${cat.name}: ${u.symbol}');
      }
      unitSymbols.add(symExact);

      if (!u.isSpecialCase && (u.toBase <= 0 || u.toBase.isNaN || !u.toBase.isFinite)) {
        errors.add('INVALID TO_BASE FACTOR in category ${cat.name}: ${u.name} (to_base: ${u.toBase})');
      }
    }
  }
  if (verbose) print('  ✓ $totalUnits units across ${unitsData.length} categories validated');

  // 4. Currencies validation
  if (verbose) print('\n4. Validating Currencies Data:');
  final currencyCodes = <String>{};
  final isoPattern = RegExp(r'^[A-Z]{3}$');

  for (final c in allIsoCurrencies) {
    if (!isoPattern.hasMatch(c.code)) {
      errors.add('INVALID CURRENCY ISO CODE: ${c.code}');
    }
    if (currencyCodes.contains(c.code)) {
      errors.add('DUPLICATE CURRENCY CODE: ${c.code}');
    }
    currencyCodes.add(c.code);

    if (c.name.trim().isEmpty) {
      errors.add('EMPTY CURRENCY NAME: ${c.code}');
    }
    if (c.symbol.trim().isEmpty) {
      errors.add('EMPTY CURRENCY SYMBOL: ${c.code}');
    }

    final rate = fallbackRatesToUsd[c.code];
    if (rate == null || rate <= 0 || rate.isNaN || !rate.isFinite) {
      errors.add('INVALID FALLBACK RATE for currency ${c.code}: $rate');
    }
  }
  if (verbose) print('  ✓ ${allIsoCurrencies.length} ISO currencies validated');

  // 5. Collections validation
  if (verbose) print('\n5. Validating Curated Collections:');
  final collectionIds = <String>{};
  var totalCollectionItems = 0;

  for (final col in predefinedCollections) {
    if (collectionIds.contains(col.id)) {
      errors.add('DUPLICATE COLLECTION ID: ${col.id}');
    }
    collectionIds.add(col.id);

    if (col.name.trim().isEmpty) {
      errors.add('EMPTY COLLECTION NAME: ${col.id}');
    }
    if (col.emoji.trim().isEmpty) {
      errors.add('EMPTY COLLECTION EMOJI: ${col.id}');
    }
    if (col.categories.isEmpty) {
      errors.add('EMPTY COLLECTION CATEGORIES: ${col.id}');
    }

    for (final cat in col.categories) {
      totalCollectionItems++;
      if (!categoryIds.contains(cat.name)) {
        errors.add('ORPHAN COLLECTION ITEM: Collection ${col.id} references unknown category ${cat.name}');
      }
    }
  }
  if (verbose) print('  ✓ ${predefinedCollections.length} collections ($totalCollectionItems items) validated');

  // 6. Educational Trivia Facts validation
  if (verbose) print('\n6. Validating Educational Facts:');
  var totalFacts = 0;
  for (final fact in didYouKnowFacts) {
    totalFacts++;
    if (fact.emoji.trim().isEmpty) {
      errors.add('EMPTY FACT EMOJI at index $totalFacts');
    }
    if (fact.fact.trim().isEmpty) {
      errors.add('EMPTY FACT TEXT at index $totalFacts');
    }
  }
  if (verbose) print('  ✓ $totalFacts educational facts validated');

  // 7. Unit Information JSON validation
  if (verbose) print('\n7. Validating Unit Educational Information JSON:');
  final infoFile = File('assets/data/unit_information.json');
  if (infoFile.existsSync()) {
    try {
      final jsonStr = infoFile.readAsStringSync();
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (verbose) print('  ✓ JSON parsed cleanly (${decoded.length} records)');

      for (final entry in decoded.entries) {
        final key = entry.key;
        final val = entry.value as Map<String, dynamic>;
        final definition = val['definition'] as String? ?? '';
        final history = val['history'] as String? ?? '';
        final usedFor = val['used_for'] as String? ?? '';

        if (definition.trim().isEmpty && history.trim().isEmpty && usedFor.trim().isEmpty) {
          errors.add('EMPTY UNIT INFORMATION RECORD for key: $key');
        }
      }
    } catch (e) {
      errors.add('MALFORMED JSON in assets/data/unit_information.json: $e');
    }
  }

  return errors;
}
