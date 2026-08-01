// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';

/// Standalone CLI executable auditing database content quality and completeness.
///
/// Run via: `dart run tools/content_quality.dart`
void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = DatabaseConstants.databaseAssetPath;
  final file = File(dbPath);

  if (!file.existsSync()) {
    print('❌ Database asset file not found at: $dbPath');
    exit(1);
  }

  print('=== MS Unit Converter Content Quality Audit ===');
  print('Path: $dbPath');
  print('');

  final db = await openDatabase(dbPath, readOnly: true);

  try {
    final categories = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories')) ?? 0;
    final units = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM units')) ?? 0;
    final unitInfo = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM unit_information')) ?? 0;
    final aliases = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM search_aliases')) ?? 0;
    final facts = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM educational_facts')) ?? 0;
    final collections = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM collections')) ?? 0;
    final collectionItems = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM collection_items')) ?? 0;
    final relatedEdges = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM related_content')) ?? 0;

    // Quality metrics
    final unitInfoCoverage = units > 0 ? (unitInfo / units * 100) : 0.0;
    final aliasRatio = units > 0 ? (aliases / units) : 0.0;
    final graphDensity = categories > 0 ? (relatedEdges / categories) : 0.0;
    final factDensity = categories > 0 ? (facts / categories) : 0.0;

    // Weight scoring (out of 100)
    double score = 0.0;
    score += (unitInfoCoverage / 100) * 35; // 35 pts for 100% unit info
    score += (aliasRatio >= 1.5 ? 1.0 : (aliasRatio / 1.5)) * 20; // 20 pts for search aliases
    score += (graphDensity >= 3.0 ? 1.0 : (graphDensity / 3.0)) * 15; // 15 pts for graph density
    score += (factDensity >= 10.0 ? 1.0 : (factDensity / 10.0)) * 15; // 15 pts for fact density
    score += (collections >= 30 ? 1.0 : (collections / 30)) * 15; // 15 pts for collections

    final int finalScore = score.round().clamp(0, 100);

    print('Category Count           : $categories');
    print('Unit Count               : $units');
    print('Educational Info Count   : $unitInfo (${unitInfoCoverage.toStringAsFixed(1)}% coverage)');
    print('Search Aliases           : $aliases (${aliasRatio.toStringAsFixed(2)}x ratio)');
    print('Knowledge Graph Edges    : $relatedEdges (${graphDensity.toStringAsFixed(2)}x density)');
    print('Educational Facts        : $facts (${factDensity.toStringAsFixed(1)} per category)');
    print('Predefined Collections   : $collections ($collectionItems items)');
    print('');
    print('Overall Content Quality Score: $finalScore / 100');
    print('');

    if (finalScore >= 90) {
      print('Status: PASS (Grade: A+)');
    } else if (finalScore >= 80) {
      print('Status: PASS (Grade: A)');
    } else {
      print('Status: FAIL (Quality score below threshold 80)');
      exit(1);
    }
  } finally {
    await db.close();
  }
}
