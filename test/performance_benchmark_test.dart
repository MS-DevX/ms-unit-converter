import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/category_repository.dart';
import 'package:unit_converter/repositories/collection_repository.dart';
import 'package:unit_converter/repositories/currency_repository.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';
import 'package:unit_converter/repositories/search_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.instance.initialize();
  });

  tearDownAll(() async {
    await DatabaseService.instance.close();
  });

  group('Phase A.4 — Performance & Database Optimization Benchmarks', () {
    test('All repository initial queries complete under 500ms total cold load', () async {
      CategoryRepository.instance.clearCache();
      UnitRepository.instance.clearCache();
      CurrencyRepository.instance.clearCache();
      CollectionRepository.instance.clearCache();
      EducationalFactsRepository.instance.clearCache();
      UnitInformationRepository.instance.clearCache();

      final sw = Stopwatch()..start();

      await CategoryRepository.instance.getAll();
      await UnitRepository.instance.getAll();
      await CurrencyRepository.instance.getAll();
      await CollectionRepository.instance.getAll();
      await EducationalFactsRepository.instance.getAll();
      await UnitInformationRepository.instance.getAll();
      await SearchRepository.instance.resolveAlias('km');

      sw.stop();
      expect(sw.elapsedMilliseconds, lessThan(500));
    });

    test('Cached lookups execute sub-millisecond for 1000 iterations', () async {
      await CategoryRepository.instance.getAll();
      await UnitRepository.instance.getAll();

      final sw = Stopwatch()..start();
      for (var i = 0; i < 1000; i++) {
        await CategoryRepository.instance.getAll();
        await UnitRepository.instance.getAll();
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(100));
    });

    test('EXPLAIN QUERY PLAN confirms index utilization on search_aliases and units', () async {
      final db = DatabaseService.instance.database;

      final aliasPlan = await db.rawQuery(
        'EXPLAIN QUERY PLAN SELECT * FROM search_aliases WHERE keyword = ?',
        ['km'],
      );
      expect(aliasPlan.toString(), contains('INDEX'));

      final unitPlan = await db.rawQuery(
        'EXPLAIN QUERY PLAN SELECT * FROM units WHERE category_id = ?',
        ['length'],
      );
      expect(unitPlan.toString(), contains('INDEX'));
    });
  });
}
