import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/units_data.dart';

void main() {
  group('unitsData', () {
    test('contains all 15 categories', () {
      expect(unitsData.length, 15);
    });

    test('every category has at least one unit', () {
      for (final entry in unitsData.entries) {
        expect(entry.value, isNotEmpty,
            reason: '${entry.key.displayName} has no units');
      }
    });

    test('temperature units are all isSpecialCase', () {
      final temps = getUnits(UnitCategory.temperature);
      for (final unit in temps) {
        expect(unit.isSpecialCase, isTrue,
            reason: '${unit.name} should be special case');
      }
    });

    test('fuel economy L/100km is isSpecialCase', () {
      final fuelUnits = getUnits(UnitCategory.fuelEconomy);
      final lPer100km = fuelUnits.firstWhere((u) => u.name == 'Liters per 100km');
      expect(lPer100km.isSpecialCase, isTrue);
    });

    test('non-temperature/fuel-economy units are not special case', () {
      for (final entry in unitsData.entries) {
        if (entry.key == UnitCategory.temperature) continue;
        if (entry.key == UnitCategory.fuelEconomy) {
          // Only L/100km is special in fuel economy
          for (final unit in entry.value) {
            if (unit.name == 'Liters per 100km') {
              expect(unit.isSpecialCase, isTrue);
            } else {
              expect(unit.isSpecialCase, isFalse,
                  reason: '${unit.name} should not be special case');
            }
          }
        } else {
          for (final unit in entry.value) {
            expect(unit.isSpecialCase, isFalse,
                reason: '${unit.name} should not be special case');
          }
        }
      }
    });

    test('each category has correct unit count', () {
      expect(getUnits(UnitCategory.length).length, 9);
      expect(getUnits(UnitCategory.weight).length, 7);
      expect(getUnits(UnitCategory.temperature).length, 3);
      expect(getUnits(UnitCategory.area).length, 9);
      expect(getUnits(UnitCategory.volume).length, 9);
      expect(getUnits(UnitCategory.speed).length, 5);
      expect(getUnits(UnitCategory.data).length, 7);
      expect(getUnits(UnitCategory.time).length, 8);
      expect(getUnits(UnitCategory.angle).length, 5);
      expect(getUnits(UnitCategory.energy).length, 7);
      expect(getUnits(UnitCategory.power).length, 5);
      expect(getUnits(UnitCategory.pressure).length, 7);
      expect(getUnits(UnitCategory.force).length, 4);
      expect(getUnits(UnitCategory.frequency).length, 4);
      expect(getUnits(UnitCategory.fuelEconomy).length, 4);
    });

    test('displayName returns correct labels for new categories', () {
      expect(UnitCategory.angle.displayName, 'Angle');
      expect(UnitCategory.energy.displayName, 'Energy');
      expect(UnitCategory.power.displayName, 'Power');
      expect(UnitCategory.pressure.displayName, 'Pressure');
      expect(UnitCategory.force.displayName, 'Force');
      expect(UnitCategory.frequency.displayName, 'Frequency');
      expect(UnitCategory.fuelEconomy.displayName, 'Fuel Economy');
    });

    test('icon returns non-empty string for all categories', () {
      for (final cat in UnitCategory.values) {
        expect(cat.icon, isNotEmpty);
      }
    });

    test('meters has correct toBase', () {
      final lengthUnits = getUnits(UnitCategory.length);
      final meter = lengthUnits.firstWhere((u) => u.name == 'Meter');
      expect(meter.symbol, 'm');
      expect(meter.toBase, 1);
    });

    test('gigabyte has correct toBase', () {
      final dataUnits = getUnits(UnitCategory.data);
      final gb = dataUnits.firstWhere((u) => u.name == 'Gigabyte');
      expect(gb.toBase, 1073741824);
    });
  });
}
