import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/repositories/category_repository.dart';
import 'package:unit_converter/repositories/collection_repository.dart';
import 'package:unit_converter/repositories/currency_repository.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DatabaseService Initialization Guard Verification', () {
    test('DatabaseService throws StateError when database is accessed before initialization', () {
      expect(DatabaseService.instance.isInitialized, isFalse);
      expect(
        () => DatabaseService.instance.database,
        throwsA(isA<StateError>()),
      );
    });

    test('CategoryRepository throws StateError when DB is not initialized', () {
      expect(
        () => CategoryRepository.instance.loadAll(),
        throwsA(isA<StateError>()),
      );
    });

    test('CurrencyRepository throws StateError when DB is not initialized', () {
      expect(
        () => CurrencyRepository.instance.getAllCurrencies(),
        throwsA(isA<StateError>()),
      );
    });

    test('CollectionRepository throws StateError when DB is not initialized', () {
      expect(
        () => CollectionRepository.instance.loadAll(),
        throwsA(isA<StateError>()),
      );
    });

    test('EducationalFactsRepository throws StateError when DB is not initialized', () {
      expect(
        () => EducationalFactsRepository.instance.loadAll(),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Repository In-Memory Cache Interface Verification', () {
    test('UnitRepository clearCache resets in-memory cache', () {
      final repo = UnitRepository.instance;
      repo.clearCache();
      expect(repo.getCachedUnitsForCategory(UnitCategory.length), isNull);
    });

    test('CategoryRepository clearCache interface exists', () {
      final repo = CategoryRepository.instance;
      repo.clearCache();
    });

    test('CurrencyRepository clearCache interface exists', () {
      final repo = CurrencyRepository.instance;
      repo.clearCache();
    });

    test('CollectionRepository clearCache interface exists', () {
      final repo = CollectionRepository.instance;
      repo.clearCache();
    });

    test('EducationalFactsRepository clearCache interface exists', () {
      final repo = EducationalFactsRepository.instance;
      repo.clearCache();
    });

    test('UnitInformationRepository clearCache interface exists', () {
      final repo = UnitInformationRepository.instance;
      repo.clearCache();
    });
  });
}
