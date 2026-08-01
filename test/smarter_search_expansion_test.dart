import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
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

  group('Phase D — Smarter Search (500+ Search Aliases)', () {
    test('search_aliases table contains 500+ rich aliases including plurals, typos, and symbols', () async {
      final totalAliases = await SearchRepository.instance.count();

      expect(totalAliases, greaterThanOrEqualTo(500),
          reason: 'Phase D requires expanding search aliases to 500+ entries.');

      // Plural checks
      expect(await SearchRepository.instance.resolveAlias('meters'), equals('Meter'));
      expect(await SearchRepository.instance.resolveAlias('pounds'), equals('Pound'));
      expect(await SearchRepository.instance.resolveAlias('gallons'), equals('Gallon (US)'));

      // Spelling variations & typos
      expect(await SearchRepository.instance.resolveAlias('celcius'), equals('Celsius'));
      expect(await SearchRepository.instance.resolveAlias('farenheit'), equals('Fahrenheit'));
      expect(await SearchRepository.instance.resolveAlias('kilometre'), equals('Kilometer'));

      // Abbreviations & Symbols
      expect(await SearchRepository.instance.resolveAlias('lbs'), equals('Pound'));
      expect(await SearchRepository.instance.resolveAlias('fl oz'), equals('Fluid Ounce (US)'));
      expect(await SearchRepository.instance.resolveAlias('kmh'), equals('Kilometers per Hour'));
    });
  });
}
