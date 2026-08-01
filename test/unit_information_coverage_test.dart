import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';

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

  group('Phase B — Complete Unit Information (100% Coverage)', () {
    test('all 480 units have corresponding educational unit_information entries', () async {
      final totalUnits = await UnitRepository.instance.count();
      final totalInfoRecords = await UnitInformationRepository.instance.count();

      expect(totalUnits, equals(480));
      expect(totalInfoRecords, equals(480));

      final allUnits = await UnitRepository.instance.getAll();
      for (final unit in allUnits) {
        final info = await UnitInformationRepository.instance.getById(unit.name);
        expect(info, isNotNull, reason: 'Unit "${unit.name}" must have educational metadata.');
        expect(info!.definition, isNotEmpty);
      }
    });
  });
}
