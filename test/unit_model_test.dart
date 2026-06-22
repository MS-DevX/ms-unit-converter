import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/unit_model.dart';

void main() {
  group('UnitModel', () {
    const meter = UnitModel(name: 'Meter', symbol: 'm', toBase: 1.0);

    test('toString()', () {
      expect(
        meter.toString(),
        'UnitModel(name: Meter, symbol: m, toBase: 1.0, '
        'isSpecialCase: false, group: null)',
      );
    });

    test('equality', () {
      const same = UnitModel(name: 'Meter', symbol: 'm', toBase: 1.0);
      expect(meter, equals(same));
      expect(meter.hashCode, equals(same.hashCode));
    });

    test('inequality on different name', () {
      const other = UnitModel(name: 'Kilometer', symbol: 'm', toBase: 1.0);
      expect(meter, isNot(equals(other)));
    });

    test('copyWith() updates fields', () {
      final km = meter.copyWith(name: 'Kilometer', symbol: 'km', toBase: 1000);
      expect(km.name, 'Kilometer');
      expect(km.symbol, 'km');
      expect(km.toBase, 1000);
      expect(km.isSpecialCase, false);
    });

    test('copyWith() with no arguments returns equal instance', () {
      expect(meter.copyWith(), equals(meter));
    });

    test('isSpecialCase defaults to false', () {
      expect(meter.isSpecialCase, false);
      const celsius = UnitModel(
        name: 'Celsius',
        symbol: '°C',
        toBase: 0,
        isSpecialCase: true,
      );
      expect(celsius.isSpecialCase, true);
    });
  });
}
