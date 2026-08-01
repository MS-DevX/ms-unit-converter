import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/services/unit_info_service.dart';

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

  group('Phase A.3 — Knowledge Data Improvements Tests', () {
    test('UnitInformationRepository findByUnitName populates tags and relatedContent', () async {
      final info = await UnitInformationRepository.instance.findByUnitName('Meter');
      expect(info, isNotNull);
      expect(info!.definition, isNotEmpty);
      expect(info.symbol, equals('m'));
      expect(info.tags, isA<List>());
      expect(info.relatedContent, isA<List>());
    });

    test('UnitInfoService getInfo returns populated tags and relatedContent lists', () async {
      final info = await UnitInfoService.getInfo('Meter', 'm');
      expect(info.symbol, equals('m'));
      expect(info.definition, isNotEmpty);
      expect(info.tags, isA<List<String>>());
      expect(info.relatedContent, isA<List<String>>());
    });
  });
}
