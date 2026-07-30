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
  final rootManifestFile = File(path.join(contentDir.path, 'manifest.json'));
  if (!rootManifestFile.existsSync()) {
    print('⚠️ Warning: content/academy/manifest.json not found: ${rootManifestFile.path}');
    return;
  }

  print('Seeding STEM Academy content dynamically from manifests…');

  final rootManifest = jsonDecode(rootManifestFile.readAsStringSync()) as Map<String, dynamic>;
  final subjectsList = rootManifest['subjects'] as List<dynamic>? ?? [];

  await db.transaction((txn) async {
    var subjectCount = 0;
    var categoryCount = 0;
    var formulaCount = 0;
    var relatedCount = 0;

    final subjectIdMap = <String, int>{};

    for (final sub in subjectsList) {
      final subStringId = sub['id'] as String;
      final numericId = sub['numeric_id'] as int? ?? (subjectCount + 1);
      subjectIdMap[subStringId] = numericId;

      await txn.insert(
        'subjects',
        {
          'id': numericId,
          'name': sub['name'],
          'icon': sub['icon'],
          'display_order': sub['display_order'] ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      subjectCount++;

      final manifestRelativePath = sub['manifest_path'] as String?;
      if (manifestRelativePath == null || sub['is_available'] != true) {
        continue;
      }

      final subjectManifestFile = File(path.join(contentDir.path, manifestRelativePath));
      if (!subjectManifestFile.existsSync()) {
        continue;
      }

      final subjectManifest = jsonDecode(subjectManifestFile.readAsStringSync()) as Map<String, dynamic>;
      final categoriesList = subjectManifest['categories'] as List<dynamic>? ?? [];
      final subjectDir = subjectManifestFile.parent;

      for (final catRef in categoriesList) {
        final catFileName = catRef['file'] as String;
        final catFile = File(path.join(subjectDir.path, catFileName));
        if (!catFile.existsSync()) continue;

        final catData = jsonDecode(catFile.readAsStringSync()) as Map<String, dynamic>;
        final catObj = catData['category'] as Map<String, dynamic>;
        final categoryId = catObj['id'] as String;

        await txn.insert(
          'formula_categories',
          {
            'id': categoryId,
            'name': catObj['name'],
            'subject_id': numericId,
            'description': catObj['description'],
            'display_order': catObj['display_order'] ?? 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        categoryCount++;

        final lessons = catData['lessons'] as List<dynamic>? ?? [];
        for (final lesson in lessons) {
          final formulaId = lesson['numeric_id'] as int;
          final variablesJson = jsonEncode(lesson['variables'] ?? []);
          final exampleJson = jsonEncode(lesson['worked_example'] ?? {});
          final calculatorJson = lesson['calculator'] != null ? jsonEncode(lesson['calculator']) : null;
          final sectionsJson = lesson['sections'] != null ? jsonEncode(lesson['sections']) : null;

          await txn.insert(
            'formulas',
            {
              'id': formulaId,
              'subject_id': numericId,
              'category_id': categoryId,
              'title': lesson['name'],
              'expression': lesson['formula'],
              'description': lesson['description'],
              'difficulty': lesson['difficulty'].toString(),
              'chapter': lesson['topic'],
              'example': exampleJson,
              'variables': variablesJson,
              'units': lesson['estimated_read_minutes']?.toString() ?? '3',
              'calculator_json': calculatorJson,
              'sections_json': sectionsJson,
              'display_order': lesson['display_order'] ?? 0,
              'is_featured': 1,
              'is_hidden': 0,
              'search_weight': 100,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          formulaCount++;

          final relatedList = lesson['related_content'] as List<dynamic>? ?? [];
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
      }
    }

    print('  ↳ Seeded $subjectCount subjects');
    print('  ↳ Seeded $categoryCount categories');
    print('  ↳ Seeded $formulaCount formulas & $relatedCount related content linkages');
  });
}
