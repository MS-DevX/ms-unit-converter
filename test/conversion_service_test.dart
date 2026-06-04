import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/models/unit_model.dart';
import 'package:unit_converter/services/conversion_service.dart';

void main() {
  late UnitModel km, m, cm;
  late UnitModel kg, lb;
  late UnitModel c, f, k;
  late UnitModel byte, kb;
  late UnitModel kmPerL, lPer100km, mpgUs, mpgUk;

  setUp(() {
    km = getUnits(UnitCategory.length)[1]; // Kilometer
    m = getUnits(UnitCategory.length)[0]; // Meter
    cm = getUnits(UnitCategory.length)[2]; // Centimeter
    kg = getUnits(UnitCategory.weight)[0]; // Kilogram
    lb = getUnits(UnitCategory.weight)[4]; // Pound
    c = getUnits(UnitCategory.temperature)[0]; // Celsius
    f = getUnits(UnitCategory.temperature)[1]; // Fahrenheit
    k = getUnits(UnitCategory.temperature)[2]; // Kelvin
    byte = getUnits(UnitCategory.data)[1];
    kb = getUnits(UnitCategory.data)[2];
    kmPerL = getUnits(UnitCategory.fuelEconomy)[0]; // km/L
    lPer100km = getUnits(UnitCategory.fuelEconomy)[1]; // L/100km
    mpgUs = getUnits(UnitCategory.fuelEconomy)[2]; // MPG (US)
    mpgUk = getUnits(UnitCategory.fuelEconomy)[3]; // MPG (UK)
  });

  group('length conversions', () {
    test('km to m', () {
      final r = ConversionService.convert(1, km, m, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, closeTo(1000, 0.01));
      expect(r.formula, '1 km \u00D7 1000 = 1000 m');
    });

    test('m to km', () {
      final r = ConversionService.convert(1000, m, km, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, closeTo(1, 0.0001));
    });

    test('m to cm', () {
      final r = ConversionService.convert(1, m, cm, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, closeTo(100, 0.01));
    });

    test('same unit short-circuit', () {
      final r = ConversionService.convert(42, m, m, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, 42);
    });
  });

  group('weight conversions', () {
    test('kg to lb', () {
      final r = ConversionService.convert(1, kg, lb, UnitCategory.weight);
      expect(r.isValid, true);
      expect(r.result, closeTo(2.20462, 0.001));
    });

    test('lb to kg', () {
      final r = ConversionService.convert(1, lb, kg, UnitCategory.weight);
      expect(r.isValid, true);
      expect(r.result, closeTo(0.453592, 0.0001));
    });
  });

  group('temperature conversions', () {
    test('C to F (freezing)', () {
      final r = ConversionService.convert(0, c, f, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(32, 0.01));
      expect(r.formattedResult, '32');
    });

    test('C to F (boiling)', () {
      final r = ConversionService.convert(100, c, f, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(212, 0.01));
    });

    test('F to C', () {
      final r = ConversionService.convert(32, f, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(0, 0.01));
    });

    test('C to K', () {
      final r = ConversionService.convert(0, c, k, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(273.15, 0.01));
    });

    test('K to C', () {
      final r = ConversionService.convert(273.15, k, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(0, 0.01));
    });

    test('F to K', () {
      final r = ConversionService.convert(32, f, k, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(273.15, 0.01));
    });

    test('K to F', () {
      final r = ConversionService.convert(273.15, k, f, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(32, 0.01));
    });

    test('same temperature unit', () {
      final r = ConversionService.convert(100, c, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, 100);
    });
  });

  group('data conversions', () {
    test('byte to KB', () {
      final r = ConversionService.convert(1024, byte, kb, UnitCategory.data);
      expect(r.isValid, true);
      expect(r.result, closeTo(1, 0.001));
    });

    test('KB to byte', () {
      final r = ConversionService.convert(1, kb, byte, UnitCategory.data);
      expect(r.isValid, true);
      expect(r.result, closeTo(1024, 0.5));
    });
  });

  group('fuel economy conversions', () {
    test('MPG (US) to km/L', () {
      final r = ConversionService.convert(
        20,
        mpgUs,
        kmPerL,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(8.50288, 0.001));
    });

    test('km/L to MPG (US)', () {
      final r = ConversionService.convert(
        8.5,
        kmPerL,
        mpgUs,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(19.99, 0.1));
    });

    test('MPG (US) to L/100km', () {
      final r = ConversionService.convert(
        20,
        mpgUs,
        lPer100km,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(11.7608, 0.1));
    });

    test('L/100km to MPG (US)', () {
      final r = ConversionService.convert(
        11.76,
        lPer100km,
        mpgUs,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(20, 0.5));
    });

    test('L/100km to km/L', () {
      final r = ConversionService.convert(
        10,
        lPer100km,
        kmPerL,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(10, 0.01));
    });

    test('MPG (UK) to MPG (US)', () {
      final r = ConversionService.convert(
        20,
        mpgUk,
        mpgUs,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(16.65, 0.1));
    });

    test('same fuel unit short-circuit', () {
      final r = ConversionService.convert(
        42,
        kmPerL,
        kmPerL,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, true);
      expect(r.result, 42);
    });
  });

  group('error handling', () {
    test('NaN input returns failure', () {
      final r = ConversionService.convert(
        double.nan,
        m,
        km,
        UnitCategory.length,
      );
      expect(r.isValid, false);
      expect(r.errorMessage, 'Invalid input');
    });

    test('infinite input returns failure', () {
      final r = ConversionService.convert(
        double.infinity,
        m,
        km,
        UnitCategory.length,
      );
      expect(r.isValid, false);
    });

    test('L/100km zero input returns failure', () {
      final r = ConversionService.convert(
        0,
        lPer100km,
        kmPerL,
        UnitCategory.fuelEconomy,
      );
      expect(r.isValid, false);
    });
  });

  group('buildFormula', () {
    test('produces correct string', () {
      final formula = ConversionService.buildFormula(1, km, m, 1000);
      expect(formula, '1 km \u00D7 1000 = 1000 m');
    });
  });
}
