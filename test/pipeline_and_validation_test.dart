import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/models/unit_model.dart';
import 'package:unit_converter/utils/alias_generator.dart';

void main() {
  group('Phase A.2 — Build Pipeline & Validation Tests', () {
    test('AliasGenerator generates plurals, US/UK spellings, and symbol aliases', () {
      const meterUnit = UnitModel(name: 'Meter', symbol: 'm', toBase: 1.0);
      final meterAliases = AliasGenerator.generateForUnit(meterUnit);

      expect(meterAliases, contains('meter'));
      expect(meterAliases, contains('m'));
      expect(meterAliases, contains('meters'));
      expect(meterAliases, contains('metre'));
      expect(meterAliases, contains('metres'));

      const footUnit = UnitModel(name: 'Foot', symbol: 'ft', toBase: 0.3048);
      final footAliases = AliasGenerator.generateForUnit(footUnit);

      expect(footAliases, contains('foot'));
      expect(footAliases, contains('feet'));
      expect(footAliases, contains('ft'));

      const inchUnit = UnitModel(name: 'Inch', symbol: 'in', toBase: 0.0254);
      final inchAliases = AliasGenerator.generateForUnit(inchUnit);

      expect(inchAliases, contains('inch'));
      expect(inchAliases, contains('inches'));
      expect(inchAliases, contains('in'));
    });

    test('Pre-populated SQLite database asset exists and build_report.md exists', () {
      final dbFile = File(DatabaseConstants.databaseAssetPath);
      expect(dbFile.existsSync(), isTrue);
      expect(dbFile.lengthSync(), greaterThan(100000));
    });
  });
}
