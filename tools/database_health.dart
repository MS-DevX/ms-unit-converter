// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';

/// Standalone CLI executable diagnostic script auditing database health.
///
/// Run via: `dart run tools/database_health.dart`
void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = DatabaseConstants.databaseAssetPath;
  final file = File(dbPath);

  if (!file.existsSync()) {
    print('❌ Database asset file not found at: $dbPath');
    exit(1);
  }

  print('=== MS Unit Converter Database Health Audit ===');
  print('Path: $dbPath');
  print('Size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');
  print('');

  final db = await openDatabase(dbPath, readOnly: true);

  final errors = <String>[];
  final warnings = <String>[];

  try {
    // 1. Foreign Key Integrity Check
    final fkCheck = await db.rawQuery('PRAGMA foreign_key_check;');
    if (fkCheck.isNotEmpty) {
      errors.add('Foreign key violations discovered: $fkCheck');
    }

    // 2. PRAGMA Quick Check
    final quickCheck = await db.rawQuery('PRAGMA quick_check;');
    final status = quickCheck.isNotEmpty ? quickCheck.first.values.first as String? : null;
    if (status != 'ok') {
      errors.add('PRAGMA quick_check failed: $status');
    }

    // 3. Row Counts
    final categoriesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    final unitsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM units')) ?? 0;
    final factsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM educational_facts')) ?? 0;
    final aliasesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM search_aliases')) ?? 0;
    final collectionsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM collections')) ?? 0;
    final collectionItemsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM collection_items')) ?? 0;
    final currenciesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM currencies')) ?? 0;
    final unitInfoCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM unit_information')) ?? 0;
    final tagsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM tags')) ?? 0;
    final contentTagsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM content_tags')) ?? 0;
    final relatedCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM related_content')) ?? 0;

    // 4. Duplicate Units Check (same category_id + name)
    final dupUnits = await db.rawQuery('''
      SELECT category_id, name, COUNT(*) as cnt
      FROM units GROUP BY category_id, name HAVING cnt > 1
    ''');
    if (dupUnits.isNotEmpty) {
      errors.add('Duplicate unit names in same category: $dupUnits');
    }

    // 5. Duplicate Aliases Check
    final dupAliases = await db.rawQuery('''
      SELECT keyword, COUNT(*) as cnt
      FROM search_aliases GROUP BY keyword HAVING cnt > 1
    ''');
    if (dupAliases.isNotEmpty) {
      errors.add('Duplicate search alias keywords: $dupAliases');
    }

    // 6. Orphan Reference Check (collection_items -> categories)
    final orphanItems = await db.rawQuery('''
      SELECT ci.id FROM collection_items ci
      LEFT JOIN categories c ON ci.category_id = c.id
      WHERE c.id IS NULL
    ''');
    if (orphanItems.isNotEmpty) {
      errors.add('Orphan collection_items references: $orphanItems');
    }

    // 7. Missing Unit Information Check
    final missingInfoCount = unitsCount - unitInfoCount;
    if (missingInfoCount > 0) {
      warnings.add('$missingInfoCount units are missing educational information entries');
    }

    // 8. Empty Descriptions Check
    final emptyDesc = await db.rawQuery('''
      SELECT id FROM categories WHERE description = '' OR description IS NULL
    ''');
    if (emptyDesc.isNotEmpty) {
      warnings.add('Categories with empty descriptions: $emptyDesc');
    }

    print('Database Health');
    print('');
    if (errors.isEmpty) {
      print('PASS');
    } else {
      print('FAIL');
    }
    print('');
    print('$unitsCount Units');
    print('$categoriesCount Categories');
    print('$factsCount Facts');
    print('$aliasesCount Aliases');
    print('$collectionsCount Collections ($collectionItemsCount items)');
    print('$currenciesCount Currencies');
    print('$unitInfoCount Unit Information Records');
    print('$tagsCount Tags ($contentTagsCount links)');
    print('$relatedCount Related Content Edges');
    print('');

    if (errors.isEmpty) {
      print('No Errors');
    } else {
      print('❌ Errors (${errors.length}):');
      for (final e in errors) {
        print('   - $e');
      }
    }

    if (warnings.isEmpty) {
      print('No Warnings');
    } else {
      print('⚠️ Warnings (${warnings.length}):');
      for (final w in warnings) {
        print('   - $w');
      }
    }
  } finally {
    await db.close();
  }

  if (errors.isNotEmpty) {
    exit(1);
  }
}
