import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/formatters.dart';

void main() {
  // Reset precision before each test so state doesn't leak between groups.
  setUp(() {
    Formatters.setPrecision(DecimalPrecision.auto);
  });

  group('formatResult', () {
    test('integer displays without decimal point', () {
      expect(Formatters.formatResult(10), '10');
      expect(Formatters.formatResult(0), '0');
    });

    test('trailing zeros are removed', () {
      expect(Formatters.formatResult(10.5000), '10.5');
      expect(Formatters.formatResult(100.0), '100');
    });

    test('handles invalid values', () {
      expect(Formatters.formatResult(double.nan), 'Invalid');
      expect(Formatters.formatResult(double.infinity), 'Invalid');
    });

    test('normal range formatting', () {
      expect(Formatters.formatResult(1234567.891234), '1234567.9');
      expect(Formatters.formatResult(0.00123456), '0.00123456');
    });

    test('no scientific notation for tiny numbers', () {
      final result = Formatters.formatResult(0.00000012);
      expect(result, '0.00000012');
      expect(result, isNot(contains('e')));
      expect(result, isNot(contains('E')));
    });

    test('max 6 decimal places for values >= 1', () {
      final result = Formatters.formatResult(1.123456789);
      final dotIndex = result.indexOf('.');
      if (dotIndex != -1) {
        expect(result.length - dotIndex - 1, lessThanOrEqualTo(6));
      }
    });
  });

  group('formatInput', () {
    test('removes non-digit characters', () {
      expect(Formatters.formatInput('12a3'), '123');
    });

    test('allows single decimal point', () {
      expect(Formatters.formatInput('12.3'), '12.3');
    });

    test('removes extra decimal points', () {
      expect(Formatters.formatInput('12..3'), '12.3');
    });

    test('empty input returns empty string', () {
      expect(Formatters.formatInput(''), '');
    });

    test('letters-only returns empty', () {
      expect(Formatters.formatInput('abc'), '');
    });

    test('preserves leading minus sign', () {
      expect(Formatters.formatInput('-12.3'), '-12.3');
      expect(Formatters.formatInput('1-2.3'), '12.3');
    });
  });

  group('precision formatting', () {
    tearDown(() {
      // Reset after each precision test so auto tests are not affected.
      Formatters.setPrecision(DecimalPrecision.auto);
    });

    test('default auto formatting is unchanged', () {
      expect(Formatters.formatResult(10), '10');
      expect(Formatters.formatResult(0), '0');
      expect(Formatters.formatResult(3.14159), '3.14159');
    });

    test('2 decimal formatting', () {
      Formatters.setPrecision(DecimalPrecision.two);
      expect(Formatters.formatResult(10), '10.00');
      expect(Formatters.formatResult(3.14159), '3.14');
      expect(Formatters.formatResult(0), '0.00');
    });

    test('4 decimal formatting', () {
      Formatters.setPrecision(DecimalPrecision.four);
      expect(Formatters.formatResult(10), '10.0000');
      expect(Formatters.formatResult(3.14159), '3.1416');
      expect(Formatters.formatResult(100.5), '100.5000');
    });

    test('6 decimal formatting', () {
      Formatters.setPrecision(DecimalPrecision.six);
      expect(Formatters.formatResult(10), '10.000000');
      expect(Formatters.formatResult(3.1415926535), '3.141593');
    });

    test('8 decimal formatting', () {
      Formatters.setPrecision(DecimalPrecision.eight);
      expect(Formatters.formatResult(10), '10.00000000');
      expect(Formatters.formatResult(3.1415926535), '3.14159265');
    });

    test('invalid values with fixed precision', () {
      Formatters.setPrecision(DecimalPrecision.two);
      expect(Formatters.formatResult(double.nan), 'Invalid');
      expect(Formatters.formatResult(double.infinity), 'Invalid');
    });

    test('very small value with 4 decimals', () {
      Formatters.setPrecision(DecimalPrecision.four);
      expect(Formatters.formatResult(0.000001), '0.0000');
    });

    test('very large value with 2 decimals', () {
      Formatters.setPrecision(DecimalPrecision.two);
      expect(Formatters.formatResult(123456789.12345), '123456789.12');
    });

    test('currencyDecimals uses currency digits when precision is auto', () {
      // JPY: 0 decimal digits
      expect(Formatters.formatResult(1234.567, currencyDecimals: 0), '1235');
      // USD: 2 decimal digits
      expect(Formatters.formatResult(1234.567, currencyDecimals: 2), '1234.57');
      // KWD: 3 decimal digits
      expect(
        Formatters.formatResult(1234.5678, currencyDecimals: 3),
        '1234.568',
      );
    });

    test('currencyDecimals is ignored when global precision is set', () {
      Formatters.setPrecision(DecimalPrecision.four);
      // Even with currencyDecimals=0, global 4 decimals wins.
      expect(
        Formatters.formatResult(1234.567, currencyDecimals: 0),
        '1234.5670',
      );
    });

    test('precision getter returns current setting', () {
      expect(Formatters.precision, isNull);
      Formatters.setPrecision(DecimalPrecision.two);
      expect(Formatters.precision, DecimalPrecision.two);
      Formatters.setPrecision(DecimalPrecision.auto);
      expect(Formatters.precision, isNull);
    });
  });
}
