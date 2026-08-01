import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/database/migration_service.dart';
import 'package:unit_converter/repositories/category_repository.dart';
import 'package:unit_converter/repositories/collection_repository.dart';
import 'package:unit_converter/repositories/currency_repository.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';
import 'package:unit_converter/repositories/search_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';
import 'package:unit_converter/services/database_health_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.instance.deleteDatabase();
    await DatabaseService.instance.initialize();
  });

  tearDownAll(() async {
    await DatabaseService.instance.close();
  });

  group('Phase A3 — Database Optimization & Health Diagnostics', () {
    test('DatabaseHealthService reports healthy database status', () async {
      final result = await DatabaseHealthService.checkHealth();
      expect(result.isHealthy, isTrue);
      expect(result.isInitialized, isTrue);
      expect(result.schemaVersion, equals(MigrationService.currentSchemaVersion));
      expect(result.contentVersion, equals('2.3.2'));
      expect(result.tableCounts['categories'], equals(60));
      expect(result.tableCounts['units'], equals(480));
      expect(result.tableCounts['currencies'], equals(151));
      expect(result.tableCounts['collections'], equals(18));
      expect(result.tableCounts['collection_items'], equals(126));
      expect(result.tableCounts['educational_facts'], equals(457));
      expect(result.tableCounts['search_aliases'], equals(242));
      expect(result.tableCounts['tags'], equals(16));
      expect(result.tableCounts['content_tags'], equals(82));
      expect(result.tableCounts['related_content'], equals(242));
      expect(result.errors, isEmpty);
    });

    test('SQLite indexes exist and foreign keys pass check', () async {
      final db = DatabaseService.instance.database;

      final fkRows = await db.rawQuery('PRAGMA foreign_key_check;');
      expect(fkRows, isEmpty, reason: 'Foreign key check discovered violations');

      final quickCheck = await db.rawQuery('PRAGMA quick_check;');
      expect(quickCheck.first.values.first, equals('ok'));

      final unitsIndexes = await db.rawQuery('PRAGMA index_list(units);');
      final indexNames = unitsIndexes.map((r) => r['name'] as String).toList();

      expect(indexNames, contains('idx_units_category'));
      expect(indexNames, contains('idx_units_name'));
      expect(indexNames, contains('idx_units_symbol'));
    });

    test('Repository query latency benchmarks execute under 50ms', () async {
      final sw = Stopwatch()..start();

      await CategoryRepository.instance.loadAll();
      await UnitRepository.instance.loadAll();
      await CurrencyRepository.instance.getAllCurrencies();
      await CollectionRepository.instance.loadFullCollections();
      await EducationalFactsRepository.instance.loadAll();
      await SearchRepository.instance.resolveAlias('meter');

      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(50),
          reason: 'Repository queries took ${sw.elapsedMilliseconds}ms, exceeding 50ms threshold');
    });
  });
}
