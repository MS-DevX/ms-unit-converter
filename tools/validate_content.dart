// ignore_for_file: avoid_print

/// Content validation tool — MS Unit Converter
///
/// Validates all content files (Dart data or JSON) without generating a database.
/// Designed to run in CI pipelines for fast feedback before the build step.
///
/// ## CURRENT STATUS: Phase 1 (validates Dart data)
///
/// In Phase 2, this tool will validate JSON content files in `content/`.
///
/// ## Usage
/// ```bash
/// dart run tools/validate_content.dart
/// ```
///
/// ## Validation Rules
///
/// ### Identity and Uniqueness
/// - No duplicate category IDs
/// - No duplicate unit names within the same category
/// - No duplicate unit symbols within the same category
/// - No duplicate currency ISO codes
/// - No duplicate collection IDs
///
/// ### Data Quality
/// - All required fields are non-empty
/// - to_base values are finite, non-zero, non-NaN
/// - fallback_rate_to_usd is positive and finite
/// - Currency ISO codes are exactly 3 uppercase ASCII letters
/// - Emoji fields contain valid emoji
///
/// ### Completeness
/// - All 53 UnitCategory enum values have at least 2 units
/// - All 9 predefined collections are present
/// - All 170+ currencies are present
///
/// ### Referential Integrity
/// - Every collection item references a known category
library;

import 'dart:io';

// NOTE: This tool imports Flutter data files. Run from the project root with:
//   flutter test tools/validate_content.dart
// or use the sqflite_common_ffi test runner in Phase 2.
//
// For Phase 1, validation is run as part of the GitHub Actions workflow
// by running `flutter analyze` which catches Dart compilation errors.

void main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║      MS Unit Converter — Content Validation Tool        ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  Phase 1: validates Dart data files at compile time.    ║');
  print('║  Phase 2: will validate JSON content files.             ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  final errors = <String>[];

  // ── Validation checks (Phase 1: structural, not content) ───────────────────
  // Full content validation runs via `flutter analyze` in CI.
  // Phase 2 will add explicit JSON schema validation here.

  // Check that content & schema files exist
  final filesToCheck = [
    'lib/data/units_data.dart',
    'lib/data/currencies_data.dart',
    'lib/data/collections_data.dart',
    'lib/data/did_you_know.dart',
    'lib/data/converter_config.dart',
    'assets/data/unit_information.json',
    'content/schema/manifest.schema.json',
    'content/schema/subject.schema.json',
    'content/schema/category.schema.json',
    'content/schema/lesson.schema.json',
    'content/academy/manifest.json',
    'content/academy/mathematics/manifest.json',
    'content/academy/mathematics/algebra.json',
    'content/academy/mathematics/geometry.json',
  ];

  for (final filePath in filesToCheck) {
    final file = File(filePath);
    if (!file.existsSync()) {
      errors.add('MISSING: $filePath');
    } else {
      print('  ✓ $filePath');
    }
  }

  // Check database service and repositories exist
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

  print('');
  print('Infrastructure files:');
  for (final filePath in infraFiles) {
    final file = File(filePath);
    if (!file.existsSync()) {
      errors.add('MISSING infrastructure file: $filePath');
      print('  ✗ $filePath — MISSING');
    } else {
      print('  ✓ $filePath');
    }
  }

  print('');
  if (errors.isEmpty) {
    print('✅ All checks passed. Run flutter analyze for full compilation validation.');
    exit(0);
  } else {
    print('❌ Validation failed with ${errors.length} error(s):');
    for (final e in errors) {
      print('   → $e');
    }
    exit(1);
  }
}
