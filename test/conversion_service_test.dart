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
    km = getUnits(UnitCategory.length)[1];
    m = getUnits(UnitCategory.length)[0];
    cm = getUnits(UnitCategory.length)[2];
    kg = getUnits(UnitCategory.weight)[0];
    lb = getUnits(UnitCategory.weight)[4];
    c = getUnits(UnitCategory.temperature)[0];
    f = getUnits(UnitCategory.temperature)[1];
    k = getUnits(UnitCategory.temperature)[2];
    byte = getUnits(UnitCategory.data)[1];
    kb = getUnits(UnitCategory.data)[2];
    kmPerL = getUnits(UnitCategory.fuelEconomy)[0];
    lPer100km = getUnits(UnitCategory.fuelEconomy)[1];
    mpgUs = getUnits(UnitCategory.fuelEconomy)[2];
    mpgUk = getUnits(UnitCategory.fuelEconomy)[3];

    sqm = getUnits(UnitCategory.area)[0];
    sqft = getUnits(UnitCategory.area)[4];
    acre = getUnits(UnitCategory.area)[7];
    hectare = getUnits(UnitCategory.area)[8];

    liter = getUnits(UnitCategory.volume)[0];
    galUs = getUnits(UnitCategory.volume)[3];
    cup = getUnits(UnitCategory.volume)[5];

    kmh = getUnits(UnitCategory.speed)[1];
    mph = getUnits(UnitCategory.speed)[2];

    hour = getUnits(UnitCategory.time)[3];
    minute = getUnits(UnitCategory.time)[2];
    day = getUnits(UnitCategory.time)[4];

    degree = getUnits(UnitCategory.angle)[1];
    radian = getUnits(UnitCategory.angle)[0];

    joule = getUnits(UnitCategory.energy)[0];
    calorie = getUnits(UnitCategory.energy)[2];
    kwh = getUnits(UnitCategory.energy)[3];

    watt = getUnits(UnitCategory.power)[0];
    hp = getUnits(UnitCategory.power)[3];

    bar = getUnits(UnitCategory.pressure)[2];
    psi = getUnits(UnitCategory.pressure)[3];
    atm = getUnits(UnitCategory.pressure)[4];
    kpa = getUnits(UnitCategory.pressure)[1];

    newton = getUnits(UnitCategory.force)[0];
    lbf = getUnits(UnitCategory.force)[2];

    hz = getUnits(UnitCategory.frequency)[0];
    khz = getUnits(UnitCategory.frequency)[1];

    cupUs = getUnits(UnitCategory.cooking)[0];
    tbsp = getUnits(UnitCategory.cooking)[1];
    gram = getUnits(UnitCategory.cooking)[6];
    ozVolume = getUnits(UnitCategory.cooking)[3];
    mlVolume = getUnits(UnitCategory.cooking)[4];

    euShoe = getUnits(UnitCategory.shoeSize)[0];
    usMenShoe = getUnits(UnitCategory.shoeSize)[2];
    cmShoe = getUnits(UnitCategory.shoeSize)[4];

    usCloth = getUnits(UnitCategory.clothingSize)[0];
    euCloth = getUnits(UnitCategory.clothingSize)[1];

    dec = getUnits(UnitCategory.numberBase)[2];
    bin = getUnits(UnitCategory.numberBase)[0];
    hex = getUnits(UnitCategory.numberBase)[3];

    px = getUnits(UnitCategory.typography)[0];
    pt = getUnits(UnitCategory.typography)[2];
    em = getUnits(UnitCategory.typography)[3];
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
