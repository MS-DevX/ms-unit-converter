// ignore_for_file: avoid_print

/// Database Build Tool — MS Unit Converter
///
/// Hardened database generation pipeline:
/// 1. Runs pre-build content integrity & referential validation.
/// 2. Initializes SQLite via FFI and seeds all reference tables.
/// 3. Executes `PRAGMA foreign_key_check` & `PRAGMA quick_check`.
/// 4. Optimizes SQLite page storage (`VACUUM`, `PRAGMA optimize`).
/// 5. Audits table row counts for full build reporting.
///
/// Usage:
///   flutter pub run tools/build_database.dart
///   or
///   flutter test test/build_database_runner_test.dart
library;

import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/database/migration_service.dart';
import 'validate_content.dart' as content_validator;

Future<void> main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║        MS Unit Converter — Database Build Tool          ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  Status: Hardened production database build pipeline     ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  // 1. Pre-build validation pass
  print('=== STEP 1: Running Pre-Build Content Integrity Pass ===');
  final errors = content_validator.validateContent(verbose: true);
  if (errors.isNotEmpty) {
    print('❌ Pre-build content validation failed with ${errors.length} error(s):');
    for (final err in errors) {
      print('   → $err');
    }
    exit(1);
  }

  // 2. Initialize FFI SQLite database factory for desktop CLI environment.
  print('\n=== STEP 2: Generating SQLite Database Binary ===');
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final outputPath = path.join(
    Directory.current.path,
    'assets',
    'database',
    DatabaseConstants.databaseFileName,
  );

  final dir = Directory(path.dirname(outputPath));
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
    print('Created directory: ${dir.path}');
  }

  final targetFile = File(outputPath);
  if (targetFile.existsSync()) {
    targetFile.deleteSync();
  }

  print('Building pre-populated SQLite database at: $outputPath…');
  final stopwatch = Stopwatch()..start();

  final db = await openDatabase(outputPath);

  try {
    await DatabaseService.seedDatabase(db);

    // Integrity checks
    final fkCheck = await db.rawQuery('PRAGMA foreign_key_check;');
    if (fkCheck.isNotEmpty) {
      print('❌ FOREIGN KEY VIOLATIONS DISCOVERED: $fkCheck');
      exit(1);
    }

    final quickCheck = await db.rawQuery('PRAGMA quick_check;');
    final status = quickCheck.isNotEmpty ? quickCheck.first.values.first as String? : null;
    if (status != 'ok') {
      print('❌ PRAGMA QUICK_CHECK FAILED: $status');
      exit(1);
    }

    await db.execute('PRAGMA user_version = ${MigrationService.currentSchemaVersion};');
    await db.execute('VACUUM;');
    await db.execute('PRAGMA optimize;');
  } finally {
    await db.close();
  }

  stopwatch.stop();

  final file = File(outputPath);
  final bytes = file.lengthSync();
  final sizeKb = (bytes / 1024).toStringAsFixed(2);

  print('');
  print('✅ Pre-populated database generated & verified successfully!');
  print('   Path       : $outputPath');
  print('   File Size  : $sizeKb KB ($bytes bytes)');
  print('   Build Time : ${stopwatch.elapsedMilliseconds} ms');
  print('');

  // 3. Audit generated table row counts
  print('=== STEP 3: Generated Table Row Counts ===');
  final auditDb = await openDatabase(outputPath, readOnly: true);
  print('────────────────────────────────────────────────────────────');

  const tables = [
    'categories',
    'units',
    'currencies',
    'collections',
    'collection_items',
    'educational_facts',
    'search_aliases',
    'unit_information',
    'schema_version',
    'content_version',
  ];

  final counts = <String, int>{};
  for (final t in tables) {
    final count = Sqflite.firstIntValue(
          await auditDb.rawQuery('SELECT COUNT(*) FROM $t'),
        ) ??
        0;
    counts[t] = count;
    print('  ✓ ${t.padRight(20)} : $count rows');
  }

  await auditDb.close();
  print('────────────────────────────────────────────────────────────\n');

  // 4. Generate build_report.md
  final reportPath = path.join(Directory.current.path, 'assets', 'database', 'build_report.md');
  final reportFile = File(reportPath);
  final reportContent = '''# BUILD REPORT

Categories: ${counts['categories'] ?? 0}

Units: ${counts['units'] ?? 0}

Facts: ${counts['educational_facts'] ?? 0}

Aliases: ${counts['search_aliases'] ?? 0}

Collections: ${counts['collections'] ?? 0}

Currencies: ${counts['currencies'] ?? 0}

Indexes: 14

Database Size: $sizeKb KB

Completed Successfully
''';
  reportFile.writeAsStringSync(reportContent);
  print('✅ Generated markdown build report at: $reportPath');
}
