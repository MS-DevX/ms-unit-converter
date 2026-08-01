// ignore_for_file: avoid_print

import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/category_repository.dart';
import 'package:unit_converter/repositories/collection_repository.dart';
import 'package:unit_converter/repositories/currency_repository.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';
import 'package:unit_converter/repositories/related_content_repository.dart';
import 'package:unit_converter/repositories/search_repository.dart';
import 'package:unit_converter/repositories/tag_repository.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';
import 'package:unit_converter/services/database_health_service.dart';

/// CLI tool for auditing database query performance, repository load latency,
/// and memory footprint.
///
/// Run via: `dart run tools/performance_audit.dart`
void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final dbPath = DatabaseConstants.databaseAssetPath;
  final file = File(dbPath);

  if (!file.existsSync()) {
    print('❌ Database asset file not found at: $dbPath');
    exit(1);
  }

  print('=== MS Unit Converter Developer Performance Audit ===');
  print('Asset Path: $dbPath');
  print('File Size : ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');
  print('');

  final initStopwatch = Stopwatch()..start();
  await DatabaseService.instance.initialize();
  initStopwatch.stop();

  print('⚡ Initialization Latency: ${initStopwatch.elapsedMilliseconds} ms');
  print('');

  final health = await DatabaseHealthService.checkHealth();
  print('🏥 Database Health Status: ${health.isHealthy ? "PASS" : "FAIL"} (${health.message})');
  print('');

  print('--- Repository Cold-Load Benchmark ---');
  final sw = Stopwatch();

  sw.start();
  final categories = await CategoryRepository.instance.getAll();
  sw.stop();
  final catTime = sw.elapsedMilliseconds;
  print('CategoryRepository.getAll()             : ${categories.length} items in ${catTime}ms');

  sw.reset();
  sw.start();
  final units = await UnitRepository.instance.getAll();
  sw.stop();
  final unitTime = sw.elapsedMilliseconds;
  print('UnitRepository.getAll()                 : ${units.length} items in ${unitTime}ms');

  sw.reset();
  sw.start();
  final currencies = await CurrencyRepository.instance.getAll();
  sw.stop();
  final currTime = sw.elapsedMilliseconds;
  print('CurrencyRepository.getAll()             : ${currencies.length} items in ${currTime}ms');

  sw.reset();
  sw.start();
  final collections = await CollectionRepository.instance.getAll();
  sw.stop();
  final collTime = sw.elapsedMilliseconds;
  print('CollectionRepository.getAll()           : ${collections.length} items in ${collTime}ms');

  sw.reset();
  sw.start();
  final facts = await EducationalFactsRepository.instance.getAll();
  sw.stop();
  final factTime = sw.elapsedMilliseconds;
  print('EducationalFactsRepository.getAll()     : ${facts.length} items in ${factTime}ms');

  sw.reset();
  sw.start();
  final searchCount = await SearchRepository.instance.count();
  sw.stop();
  final searchTime = sw.elapsedMilliseconds;
  print('SearchRepository.count()                : $searchCount items in ${searchTime}ms');

  sw.reset();
  sw.start();
  final unitInfoCount = await UnitInformationRepository.instance.count();
  sw.stop();
  final infoTime = sw.elapsedMilliseconds;
  print('UnitInformationRepository.count()       : $unitInfoCount items in ${infoTime}ms');

  sw.reset();
  sw.start();
  final tags = await TagRepository.instance.getAll();
  sw.stop();
  final tagTime = sw.elapsedMilliseconds;
  print('TagRepository.getAll()                  : ${tags.length} items in ${tagTime}ms');

  sw.reset();
  sw.start();
  final edges = await RelatedContentRepository.instance.getAll();
  sw.stop();
  final edgeTime = sw.elapsedMilliseconds;
  print('RelatedContentRepository.getAll()       : ${edges.length} items in ${edgeTime}ms');

  final totalTime = initStopwatch.elapsedMilliseconds + catTime + unitTime + currTime + collTime + factTime + searchTime + infoTime + tagTime + edgeTime;

  print('');
  print('----------------------------------------------------');
  print('Total Cold Load Benchmark Time: $totalTime ms');
  print('Benchmark Threshold           : < 500 ms');
  if (totalTime < 500) {
    print('Benchmark Result               : PASS (PERFORMANCE OPTIMAL)');
  } else {
    print('Benchmark Result               : WARNING (Latency exceeded target threshold)');
  }

  await DatabaseService.instance.close();
}
