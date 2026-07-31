// ignore_for_file: avoid_print

/// Database Build Tool — MS Unit Converter
///
/// Generates the pre-populated SQLite database binary file at
/// `assets/database/stem_data.db` from all reference data sources
/// (categories, units, currencies, collections, educational facts, aliases,
/// and unit educational information).
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

Future<void> main(List<String> args) async {
  print('');
  print('╔══════════════════════════════════════════════════════════╗');
  print('║        MS Unit Converter — Database Build Tool          ║');
  print('╠══════════════════════════════════════════════════════════╣');
  print('║  Status: Executable developer build pipeline             ║');
  print('╚══════════════════════════════════════════════════════════╝');
  print('');

  // 1. Initialize FFI SQLite database factory for desktop CLI environment.
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

  print('Building pre-populated SQLite database at: $outputPath…');
  final stopwatch = Stopwatch()..start();

  final db = await openDatabase(outputPath);

  try {
    await DatabaseService.seedDatabase(db);
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
  print('✅ Pre-populated database generated successfully!');
  print('   Path       : $outputPath');
  print('   File Size  : $sizeKb KB ($bytes bytes)');
  print('   Build Time : ${stopwatch.elapsedMilliseconds} ms');
  print('');

  // 2. Audit generated table row counts
  final auditDb = await openDatabase(outputPath, readOnly: true);
  print('Generated Table Row Counts:');
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

  for (final t in tables) {
    final count = Sqflite.firstIntValue(
          await auditDb.rawQuery('SELECT COUNT(*) FROM $t'),
        ) ??
        0;
    print('  ✓ ${t.padRight(20)} : $count rows');
  }

  await auditDb.close();
  print('────────────────────────────────────────────────────────────');
  print('');
}
