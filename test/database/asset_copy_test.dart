import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/services/database_health_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Asset Database & Health Verification', () {
    test('${DatabaseConstants.databaseAssetPath} binary asset exists and is non-empty', () {
      final file = File(DatabaseConstants.databaseAssetPath);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(100000));
    });

    test('DatabaseService initializes and DatabaseHealthService reports healthy state', () async {
      await DatabaseService.instance.initialize();
      expect(DatabaseService.instance.isInitialized, isTrue);

      final health = await DatabaseHealthService.checkHealth();
      expect(health.isHealthy, isTrue);
      expect(health.isInitialized, isTrue);
      expect(health.schemaVersion, equals(1));
      expect(health.contentVersion, startsWith('2.3.5'));

      expect(health.tableCounts['categories'], greaterThanOrEqualTo(50));
      expect(health.tableCounts['units'], greaterThanOrEqualTo(300));
      expect(health.tableCounts['currencies'], greaterThanOrEqualTo(100));
      expect(health.tableCounts['collections'], greaterThanOrEqualTo(15));
      expect(health.tableCounts['educational_facts'], greaterThanOrEqualTo(300));
      expect(health.tableCounts['search_aliases'], greaterThanOrEqualTo(100));
    });
  });
}
