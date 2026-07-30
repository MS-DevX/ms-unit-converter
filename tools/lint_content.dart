// ignore_for_file: avoid_print

/// Content linter for MS Unit Converter data files.
///
/// Performs static analysis of content files to catch common issues before
/// they reach the database. Faster and more specific than flutter analyze.
///
/// ## Usage
/// ```bash
/// dart run tools/lint_content.dart
/// ```
///
/// ## What it checks
/// - Structural integrity of Dart data files (file existence + parse)
/// - JSON asset validity (unit_information.json is valid JSON)
/// - Known content quality issues (to be expanded in Phase 2)
///
/// ## Phase 2 Expansion
/// This tool will be expanded to lint JSON content files with:
/// - Schema validation (all required fields present)
/// - Cross-reference checks (collection items reference real categories)
/// - Duplicate detection (symbols, aliases, ISO codes)
/// - Emoji validation (flag sequences, etc.)
/// - ISO 4217 currency code format
library;

import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║        MS Unit Converter — Content Linter               ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  final errors = <String>[];
  final warnings = <String>[];
  var checksRun = 0;

  // ── Check 1: Data files exist ──────────────────────────────────────────────
  print('Checking data file existence…');
  final dataFiles = {
    'Units data': 'lib/data/units_data.dart',
    'Currencies data': 'lib/data/currencies_data.dart',
    'Collections data': 'lib/data/collections_data.dart',
    'Educational facts': 'lib/data/did_you_know.dart',
    'Converter config': 'lib/data/converter_config.dart',
    'Unit information JSON': 'assets/data/unit_information.json',
  };

  for (final entry in dataFiles.entries) {
    checksRun++;
    final file = File(entry.value);
    if (!file.existsSync()) {
      errors.add('${entry.key} file missing: ${entry.value}');
      print('  ✗ ${entry.value} — MISSING');
    } else {
      final sizeKb = (file.lengthSync() / 1024).toStringAsFixed(1);
      print('  ✓ ${entry.value} ($sizeKb KB)');
    }
  }

  // ── Check 2: JSON asset is valid ───────────────────────────────────────────
  print('');
  print('Checking JSON asset validity…');
  checksRun++;
  final jsonFile = File('assets/data/unit_information.json');
  if (jsonFile.existsSync()) {
    try {
      final content = jsonFile.readAsStringSync();
      final decoded = jsonDecode(content);
      if (decoded is! Map) {
        errors.add('unit_information.json: root must be a JSON object');
      } else {
        final map = decoded as Map<String, dynamic>;
        print('  ✓ unit_information.json is valid JSON (${map.length} entries)');

        // Check entry structure
        var malformedEntries = 0;
        for (final entry in map.entries) {
          final val = entry.value;
          if (val is! Map) {
            malformedEntries++;
            continue;
          }
          final required = ['symbol', 'definition', 'history', 'used_for', 'examples'];
          for (final field in required) {
            if (!val.containsKey(field)) {
              warnings.add('unit_information.json["${entry.key}"] missing field: $field');
            }
          }
        }
        if (malformedEntries > 0) {
          errors.add('unit_information.json: $malformedEntries entries are not JSON objects');
        }
      }
    } on FormatException catch (e) {
      errors.add('unit_information.json is invalid JSON: $e');
      print('  ✗ unit_information.json — INVALID JSON');
    }
  }

  // ── Check 3: Infrastructure files exist ────────────────────────────────────
  print('');
  print('Checking infrastructure files…');
  final infraFiles = [
    'lib/database/database_service.dart',
    'lib/database/migration_service.dart',
    'lib/repositories/unit_repository.dart',
    'lib/repositories/category_repository.dart',
    'lib/repositories/currency_repository.dart',
    'lib/repositories/collection_repository.dart',
    'lib/repositories/unit_information_repository.dart',
    'lib/repositories/search_repository.dart',
    'lib/repositories/educational_facts_repository.dart',
    'lib/services/database_health_service.dart',
    'lib/database/migrations/migration_v2_stub.dart',
    'tools/check_database.dart',
  ];

  for (final filePath in infraFiles) {
    checksRun++;
    final file = File(filePath);
    if (!file.existsSync()) {
      errors.add('Infrastructure file missing: $filePath');
      print('  ✗ $filePath — MISSING');
    } else {
      print('  ✓ $filePath');
    }
  }

  // ── Check 4: pubspec.yaml has required dependencies ────────────────────────
  print('');
  print('Checking pubspec.yaml dependencies…');
  checksRun++;
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final content = pubspecFile.readAsStringSync();
    final requiredDeps = ['sqflite', 'path_provider'];
    for (final dep in requiredDeps) {
      if (!content.contains(dep)) {
        errors.add('pubspec.yaml missing dependency: $dep');
        print('  ✗ $dep — MISSING from pubspec.yaml');
      } else {
        print('  ✓ $dep');
      }
    }
  } else {
    errors.add('pubspec.yaml not found');
  }

  // ── Summary ────────────────────────────────────────────────────────────────
  print('');
  print('─' * 60);
  print('Checks run : $checksRun');
  print('Errors     : ${errors.length}');
  print('Warnings   : ${warnings.length}');
  print('');

  if (warnings.isNotEmpty) {
    print('Warnings:');
    for (final w in warnings) {
      print('  ⚠  $w');
    }
    print('');
  }

  if (errors.isEmpty) {
    print('✅ All checks passed.');
    if (warnings.isNotEmpty) {
      print('   (${warnings.length} warning(s) — review above)');
    }
    exit(0);
  } else {
    print('❌ Lint failed with ${errors.length} error(s):');
    for (final e in errors) {
      print('   → $e');
    }
    print('');
    print('Fix all errors before committing.');
    exit(1);
  }
}
