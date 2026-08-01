import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/data/did_you_know.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';

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

  group('Phase F — Rich Did You Know (700–1000 Educational Facts)', () {
    test('didYouKnowFacts list and database educational_facts table contain 700–1000 facts', () async {
      expect(didYouKnowFacts.length, greaterThanOrEqualTo(700),
          reason: 'Phase F requires expanding educational facts to 700–1000 entries.');
      expect(didYouKnowFacts.length, lessThanOrEqualTo(1000),
          reason: 'Phase F requires expanding educational facts to 700–1000 entries.');

      final dbFactsCount = await EducationalFactsRepository.instance.count();
      expect(dbFactsCount, greaterThanOrEqualTo(700));
      expect(dbFactsCount, lessThanOrEqualTo(1000));
    });
  });
}
