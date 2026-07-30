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

import 'dart:convert';
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
    await _seedAcademyContentFromContentDir(db);
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
    'subjects',
    'formula_categories',
    'formulas',
    'related_content',
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

/// Seeds STEM Academy tables directly from developer JSON files in `content/academy/`.
Future<void> _seedAcademyContentFromContentDir(Database db) async {
  final contentDir = Directory(path.join(Directory.current.path, 'content', 'academy'));
  if (!contentDir.existsSync()) {
    print('⚠️ Warning: content/academy/ directory not found: ${contentDir.path}');
    return;
  }

  print('Seeding STEM Academy content from content/academy/…');

  await db.transaction((txn) async {
    // 1. Seed Subjects
    final subjectsFile = File(path.join(contentDir.path, 'subjects.json'));
    if (subjectsFile.existsSync()) {
      final List<dynamic> list = jsonDecode(subjectsFile.readAsStringSync());
      for (final item in list) {
        await txn.insert(
          'subjects',
          {
            'id': item['id'],
            'name': item['name'],
            'icon': item['icon'],
            'display_order': item['display_order'] ?? 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('  ↳ Seeded ${list.length} subjects');
    }

    // 2. Seed Formula Categories
    final categoriesFile = File(path.join(contentDir.path, 'mathematics_categories.json'));
    if (categoriesFile.existsSync()) {
      final List<dynamic> list = jsonDecode(categoriesFile.readAsStringSync());
      for (final item in list) {
        await txn.insert(
          'formula_categories',
          {
            'id': item['id'],
            'name': item['name'],
            'subject_id': item['subject_id'],
            'description': item['description'],
            'display_order': item['display_order'] ?? 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      print('  ↳ Seeded ${list.length} formula categories');
    }

    // 3. Seed Formulas & Related Content
    final formulasFile = File(path.join(contentDir.path, 'mathematics_formulas.json'));
    if (formulasFile.existsSync()) {
      final List<dynamic> list = jsonDecode(formulasFile.readAsStringSync());
      var formulaCount = 0;
      var relatedCount = 0;

      for (final item in list) {
        final formulaId = item['id'] as int;
        final variablesJson = jsonEncode(item['variables'] ?? []);
        final exampleJson = jsonEncode(item['worked_example'] ?? {});

        await txn.insert(
          'formulas',
          {
            'id': formulaId,
            'subject_id': item['subject_id'],
            'category_id': item['category_id'],
            'title': item['name'],
            'expression': item['formula'],
            'description': item['description'],
            'difficulty': item['difficulty'].toString(),
            'chapter': item['topic'],
            'example': exampleJson,
            'variables': variablesJson,
            'units': item['estimated_read_minutes']?.toString() ?? '3',
            'display_order': item['display_order'] ?? 0,
            'is_featured': 1,
            'is_hidden': 0,
            'search_weight': 100,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        formulaCount++;

        // Seed related content
        final relatedList = item['related_content'] as List<dynamic>? ?? [];
        for (final rel in relatedList) {
          await txn.insert(
            'related_content',
            {
              'source_type': 'formula',
              'source_id': formulaId.toString(),
              'target_type': rel['target_type'] ?? 'formula',
              'target_id': rel['target_id']?.toString() ?? '',
              'relationship_type': rel['relationship_type'] ?? 'related',
              'display_order': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          relatedCount++;
        }
      }
      print('  ↳ Seeded $formulaCount formulas & $relatedCount related content linkages');
    }
  });
}
