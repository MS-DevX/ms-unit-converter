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
  late UnitModel sqm, sqft, acre, hectare;
  late UnitModel liter, galUs, cup;
  late UnitModel kmh, mph;
  late UnitModel hour, minute, day;
  late UnitModel degree, radian;
  late UnitModel joule, calorie, kwh;
  late UnitModel watt, hp;
  late UnitModel bar, psi, atm, kpa;
  late UnitModel newton, lbf;
  late UnitModel hz, khz;
  late UnitModel cupUs, tbsp, gram, ozVolume, mlVolume;
  late UnitModel euShoe, usMenShoe, cmShoe;
  late UnitModel usCloth, euCloth;
  late UnitModel dec, bin, hex;
  late UnitModel px, pt, em;

  setUp(() {
    UnitModel findUnit(UnitCategory cat, String name) =>
        getUnits(cat).firstWhere((u) => u.name.toLowerCase() == name.toLowerCase(),
            orElse: () => getUnits(cat).first);

    km = findUnit(UnitCategory.length, 'Kilometer');
    m = findUnit(UnitCategory.length, 'Meter');
    cm = findUnit(UnitCategory.length, 'Centimeter');
    kg = findUnit(UnitCategory.weight, 'Kilogram');
    lb = findUnit(UnitCategory.weight, 'Pound');
    c = findUnit(UnitCategory.temperature, 'Celsius');
    f = findUnit(UnitCategory.temperature, 'Fahrenheit');
    k = findUnit(UnitCategory.temperature, 'Kelvin');
    byte = findUnit(UnitCategory.data, 'Byte');
    kb = findUnit(UnitCategory.data, 'Kilobyte');
    kmPerL = findUnit(UnitCategory.fuelEconomy, 'Kilometers per Liter');
    lPer100km = findUnit(UnitCategory.fuelEconomy, 'Liters per 100km');
    mpgUs = findUnit(UnitCategory.fuelEconomy, 'MPG (US)');
    mpgUk = findUnit(UnitCategory.fuelEconomy, 'MPG (UK)');

    sqm = findUnit(UnitCategory.area, 'Square Meter');
    sqft = findUnit(UnitCategory.area, 'Square Foot');
    acre = findUnit(UnitCategory.area, 'Acre');
    hectare = findUnit(UnitCategory.area, 'Hectare');

    liter = findUnit(UnitCategory.volume, 'Liter');
    galUs = findUnit(UnitCategory.volume, 'Gallon (US)');
    cup = findUnit(UnitCategory.volume, 'Cup');

    kmh = findUnit(UnitCategory.speed, 'Kilometers per Hour');
    mph = findUnit(UnitCategory.speed, 'Miles per Hour');

    hour = findUnit(UnitCategory.time, 'Hour');
    minute = findUnit(UnitCategory.time, 'Minute');
    day = findUnit(UnitCategory.time, 'Day');

    degree = findUnit(UnitCategory.angle, 'Degree');
    radian = findUnit(UnitCategory.angle, 'Radian');

    joule = findUnit(UnitCategory.energy, 'Joule');
    calorie = findUnit(UnitCategory.energy, 'Calorie');
    kwh = findUnit(UnitCategory.energy, 'Kilowatt-hour');

    watt = findUnit(UnitCategory.power, 'Watt');
    hp = findUnit(UnitCategory.power, 'Horsepower');

    bar = findUnit(UnitCategory.pressure, 'Bar');
    psi = findUnit(UnitCategory.pressure, 'PSI');
    atm = findUnit(UnitCategory.pressure, 'Atmosphere');
    kpa = findUnit(UnitCategory.pressure, 'Kilopascal');

    newton = findUnit(UnitCategory.force, 'Newton');
    lbf = findUnit(UnitCategory.force, 'Pound-force');

    hz = findUnit(UnitCategory.frequency, 'Hertz');
    khz = findUnit(UnitCategory.frequency, 'Kilohertz');

    cupUs = findUnit(UnitCategory.cooking, 'Cup (US)');
    tbsp = findUnit(UnitCategory.cooking, 'Tablespoon');
    gram = findUnit(UnitCategory.cooking, 'Gram');
    ozVolume = findUnit(UnitCategory.cooking, 'Fluid Ounce');
    mlVolume = findUnit(UnitCategory.cooking, 'Milliliter');

    euShoe = findUnit(UnitCategory.shoeSize, 'EU');
    usMenShoe = findUnit(UnitCategory.shoeSize, 'US Men');
    cmShoe = findUnit(UnitCategory.shoeSize, 'CM');

    usCloth = findUnit(UnitCategory.clothingSize, 'US');
    euCloth = findUnit(UnitCategory.clothingSize, 'EU');

    dec = findUnit(UnitCategory.numberBase, 'Decimal');
    bin = findUnit(UnitCategory.numberBase, 'Binary');
    hex = findUnit(UnitCategory.numberBase, 'Hexadecimal');

    px = findUnit(UnitCategory.typography, 'Pixels');
    pt = findUnit(UnitCategory.typography, 'Points');
    em = findUnit(UnitCategory.typography, 'EM');
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
      final r = ConversionService.convert(
        273.15,
        k,
        c,
        UnitCategory.temperature,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(0, 0.01));
    });

    test('F to K', () {
      final r = ConversionService.convert(32, f, k, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(273.15, 0.01));
    });

    test('K to F', () {
      final r = ConversionService.convert(
        273.15,
        k,
        f,
        UnitCategory.temperature,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(32, 0.01));
    });

    test('same temperature unit', () {
      final r = ConversionService.convert(100, c, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, 100);
    });

    test('negative Celsius to Fahrenheit', () {
      final r = ConversionService.convert(-40, c, f, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(-40, 0.01));
    });

    test('negative Fahrenheit to Celsius', () {
      final r = ConversionService.convert(-4, f, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(-20, 0.01));
    });

    test('absolute zero Kelvin to Celsius', () {
      final r = ConversionService.convert(0, k, c, UnitCategory.temperature);
      expect(r.isValid, true);
      expect(r.result, closeTo(-273.15, 0.01));
    });
  });

  group('area conversions', () {
    test('sqm to sqft', () {
      final r = ConversionService.convert(1, sqm, sqft, UnitCategory.area);
      expect(r.isValid, true);
      expect(r.result, closeTo(10.7639, 0.01));
    });

    test('acre to hectare', () {
      final r = ConversionService.convert(1, acre, hectare, UnitCategory.area);
      expect(r.isValid, true);
      expect(r.result, closeTo(0.404686, 0.001));
    });
  });

  group('volume conversions', () {
    test('liter to gallon (US)', () {
      final r = ConversionService.convert(1, liter, galUs, UnitCategory.volume);
      expect(r.isValid, true);
      expect(r.result, closeTo(0.264172, 0.001));
    });

    test('liter to cup', () {
      final r = ConversionService.convert(1, liter, cup, UnitCategory.volume);
      expect(r.isValid, true);
      expect(r.result, closeTo(4.22675, 0.01));
    });
  });

  group('speed conversions', () {
    test('km/h to mph', () {
      final r = ConversionService.convert(100, kmh, mph, UnitCategory.speed);
      expect(r.isValid, true);
      expect(r.result, closeTo(62.1371, 0.01));
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

  group('time conversions', () {
    test('hour to minute', () {
      final r = ConversionService.convert(1, hour, minute, UnitCategory.time);
      expect(r.isValid, true);
      expect(r.result, closeTo(60, 0.01));
    });

    test('day to hour', () {
      final r = ConversionService.convert(1, day, hour, UnitCategory.time);
      expect(r.isValid, true);
      expect(r.result, closeTo(24, 0.01));
    });
  });

  group('angle conversions', () {
    test('degree to radian', () {
      final r = ConversionService.convert(
        180,
        degree,
        radian,
        UnitCategory.angle,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(3.14159, 0.001));
    });

    test('radian to degree', () {
      final r = ConversionService.convert(
        3.14159,
        radian,
        degree,
        UnitCategory.angle,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(180, 0.01));
    });
  });

  group('energy conversions', () {
    test('joule to calorie', () {
      final r = ConversionService.convert(
        1,
        joule,
        calorie,
        UnitCategory.energy,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(0.239006, 0.001));
    });

    test('kWh to joule', () {
      final r = ConversionService.convert(1, kwh, joule, UnitCategory.energy);
      expect(r.isValid, true);
      expect(r.result, closeTo(3600000, 1));
    });
  });

  group('power conversions', () {
    test('watt to horsepower', () {
      final r = ConversionService.convert(745.7, watt, hp, UnitCategory.power);
      expect(r.isValid, true);
      expect(r.result, closeTo(1, 0.01));
    });
  });

  group('pressure conversions', () {
    test('bar to psi', () {
      final r = ConversionService.convert(1, bar, psi, UnitCategory.pressure);
      expect(r.isValid, true);
      expect(r.result, closeTo(14.5038, 0.01));
    });

    test('atm to kPa', () {
      final r = ConversionService.convert(1, atm, kpa, UnitCategory.pressure);
      expect(r.isValid, true);
      expect(r.result, closeTo(101.325, 0.01));
    });
  });

  group('force conversions', () {
    test('newton to pound-force', () {
      final r = ConversionService.convert(1, newton, lbf, UnitCategory.force);
      expect(r.isValid, true);
      expect(r.result, closeTo(0.224809, 0.001));
    });
  });

  group('frequency conversions', () {
    test('hertz to kilohertz', () {
      final r = ConversionService.convert(
        1000,
        hz,
        khz,
        UnitCategory.frequency,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(1, 0.01));
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

  group('cooking conversions', () {
    test('same-group volume conversion', () {
      final r = ConversionService.convert(1, cupUs, tbsp, UnitCategory.cooking);
      expect(r.isValid, true);
      expect(r.result, closeTo(16.03, 0.1), reason: '1 cup ≈ 16 tbsp');
    });

    test('same-group volume milliliter to fluid ounce', () {
      final r = ConversionService.convert(
        100,
        mlVolume,
        ozVolume,
        UnitCategory.cooking,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(3.381, 0.01));
    });

    test('cross-group volume to weight returns invalid', () {
      final r = ConversionService.convert(1, cupUs, gram, UnitCategory.cooking);
      expect(r.isValid, false);
    });

    test('cross-group error message is descriptive', () {
      final err = ConversionService.cookingGroupError(cupUs, gram);
      expect(err, isNotNull);
      expect(err, contains('volume'));
      expect(err, contains('weight'));
    });

    test('same-group returns null error', () {
      final err = ConversionService.cookingGroupError(cupUs, tbsp);
      expect(err, isNull);
    });
  });

  group('shoe size conversions', () {
    test('EU 42 to US Men', () {
      final r = ConversionService.convert(
        42,
        euShoe,
        usMenShoe,
        UnitCategory.shoeSize,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(9.5, 0.5));
    });

    test('EU 39 to CM', () {
      final r = ConversionService.convert(
        39,
        euShoe,
        cmShoe,
        UnitCategory.shoeSize,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(24.5, 0.5));
    });
  });

  group('clothing size conversions', () {
    test('US 32 to EU', () {
      final r = ConversionService.convert(
        32,
        usCloth,
        euCloth,
        UnitCategory.clothingSize,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(42, 1));
    });
  });

  group('number base conversions', () {
    test('decimal 255 to binary', () {
      final r = ConversionService.convert(
        255,
        dec,
        bin,
        UnitCategory.numberBase,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(11111111, 1));
    });

    test('decimal 255 to hex', () {
      final r = ConversionService.convert(
        255,
        dec,
        hex,
        UnitCategory.numberBase,
      );
      expect(r.isValid, true);
      expect(r.result, closeTo(255, 1));
    });

    test('invalid digit in binary source returns failure', () {
      final r = ConversionService.convert(
        255,
        bin,
        dec,
        UnitCategory.numberBase,
      );
      expect(r.isValid, false);
    });
  });

  group('typography conversions', () {
    test('pixels to points', () {
      final r = ConversionService.convert(16, px, pt, UnitCategory.typography);
      expect(r.isValid, true);
      expect(r.result, closeTo(12, 0.5));
    });

    test('EM to pixels (16px base)', () {
      final r = ConversionService.convert(2, em, px, UnitCategory.typography);
      expect(r.isValid, true);
      expect(r.result, closeTo(32, 0.5));
    });
  });

  group('formula building', () {
    test('normal formula uses multiplication symbol', () {
      final formula = ConversionService.buildFormula(1, km, m, 1000);
      expect(formula, '1 km \u00D7 1000 = 1000 m');
    });

    test('special case formula uses equals sign', () {
      final formula = ConversionService.buildFormula(0, c, f, 32);
      expect(formula, contains('='));
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

    test('zero value converts normally for linear categories', () {
      final r = ConversionService.convert(0, m, km, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, 0);
    });

    test('extremely large input', () {
      final r = ConversionService.convert(1e12, m, km, UnitCategory.length);
      expect(r.isValid, true);
      expect(r.result, closeTo(1e9, 1));
    });

    test('cooking cross-group returns descriptive error', () {
      final r = ConversionService.convert(1, cupUs, gram, UnitCategory.cooking);
      expect(r.isValid, false);
    });
  });
}
