import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/units_data.dart';
import 'package:unit_converter/services/smart_parse_service.dart';

void main() {
  group('SmartParseService.parse', () {
    test('10 km to miles', () {
      final result = SmartParseService.parse('10 km to miles');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 10);
      expect(result.fromUnitName, 'Kilometer');
      expect(result.toUnitName, 'Mile');
      expect(result.category, isNotNull);
      expect(result.isCurrency, isFalse);
    });

    test('5 feet to cm', () {
      final result = SmartParseService.parse('5 feet to cm');
      expect(result.errorMessage, isNull);
      expect(result.isRecognized, isTrue);
      expect(result.amount, 5);
      expect(result.fromUnitName, 'Foot');
      expect(result.toUnitName, 'Centimeter');
    });

    test('100 c to f', () {
      final result = SmartParseService.parse('100 c to f');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 100);
      expect(result.fromUnitName, 'Celsius');
      expect(result.toUnitName, 'Fahrenheit');
      expect(result.category, isNotNull);
    });

    test('1 kg to lb', () {
      final result = SmartParseService.parse('1 kg to lb');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 1);
      expect(result.fromUnitName, 'Kilogram');
      expect(result.toUnitName, 'Pound');
    });

    test('100 usd to pkr', () {
      final result = SmartParseService.parse('100 usd to pkr');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 100);
      expect(result.isCurrency, isTrue);
      expect(result.fromCurrencyCode, 'USD');
      expect(result.toCurrencyCode, 'PKR');
    });

    test('100 USD to PKR (uppercase)', () {
      final result = SmartParseService.parse('100 USD to PKR');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 100);
      expect(result.isCurrency, isTrue);
      expect(result.fromCurrencyCode, 'USD');
      expect(result.toCurrencyCode, 'PKR');
    });

    test('255 decimal to hex', () {
      final result = SmartParseService.parse('255 decimal to hex');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 255);
      expect(result.fromUnitName, 'Decimal');
      expect(result.toUnitName, 'Hexadecimal');
      expect(result.category, isNotNull);
    });

    test('5 feet 9 inches to cm (compound)', () {
      final result = SmartParseService.parse('5 feet 9 inches to cm');
      expect(result.errorMessage, isNull);
      expect(result.isRecognized, isTrue);
      expect(result.amount, isNotNull);
      // 5 feet + 9 inches = 5.75 feet
      expect(result.amount!, closeTo(5.75, 0.001));
      expect(result.fromUnitName, 'Foot');
      expect(result.toUnitName, 'Centimeter');
      expect(result.category, isNotNull);
      expect(result.secondaryAmount, 9);
      expect(result.secondaryFromUnitName, 'Inch');
    });

    test('invalid query returns not recognized', () {
      final result = SmartParseService.parse('hello world');
      expect(result.isRecognized, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('empty query returns error', () {
      final result = SmartParseService.parse('');
      expect(result.isRecognized, isFalse);
    });

    test('missing to-unit returns error', () {
      final result = SmartParseService.parse('10 km');
      expect(result.isRecognized, isFalse);
    });

    test('case insensitive units work', () {
      final result = SmartParseService.parse('10 KM to MILES');
      expect(result.errorMessage, isNull);
      expect(result.isRecognized, isTrue);
      expect(result.amount, 10);
      expect(result.fromUnitName, 'Kilometer');
      expect(result.toUnitName, 'Mile');
    });

    test('1 meter to feet', () {
      final result = SmartParseService.parse('1 meter to feet');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 1);
      expect(result.fromUnitName, 'Meter');
      expect(result.toUnitName, 'Foot');
    });

    test('1 dollar to rupee', () {
      final result = SmartParseService.parse('1 dollar to rupee');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 1);
      expect(result.isCurrency, isTrue);
      expect(result.fromCurrencyCode, 'USD');
      expect(result.toCurrencyCode, 'PKR');
    });

    test('unrelated units return category mismatch error', () {
      final result = SmartParseService.parse('10 kg to meters');
      expect(result.isRecognized, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage!.toLowerCase(), contains('cannot convert'));
    });

    test('arrow separator works', () {
      final result = SmartParseService.parse('100 c -> f');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 100);
      expect(result.fromUnitName, 'Celsius');
      expect(result.toUnitName, 'Fahrenheit');
    });

    test('100 pkr to usd (reverse currency)', () {
      final result = SmartParseService.parse('100 pkr to usd');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 100);
      expect(result.isCurrency, isTrue);
      expect(result.fromCurrencyCode, 'PKR');
      expect(result.toCurrencyCode, 'USD');
    });
  });

  group('SmartParseResult', () {
    test('isRecognized returns true for valid unit result', () {
      final result = SmartParseResult(
        amount: 10,
        fromUnitName: 'Kilometer',
        toUnitName: 'Mile',
        category: UnitCategory.length,
        rawQuery: '10 km to miles',
      );
      expect(result.isRecognized, isTrue);
    });

    test('isRecognized returns true for valid currency result', () {
      final result = SmartParseResult(
        amount: 100,
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'PKR',
        isCurrency: true,
        rawQuery: '100 usd to pkr',
      );
      expect(result.isRecognized, isTrue);
    });

    test('isRecognized returns false with error', () {
      final result = SmartParseResult(
        errorMessage: 'Something went wrong',
        rawQuery: 'bad query',
      );
      expect(result.isRecognized, isFalse);
    });

    test('isRecognized returns false without amount', () {
      final result = SmartParseResult(
        fromUnitName: 'Kilometer',
        toUnitName: 'Mile',
        rawQuery: 'test',
      );
      expect(result.isRecognized, isFalse);
    });
  });

  group('SmartParseService edge cases', () {
    test('partial unit name resolves correctly', () {
      // "in" is ambiguous — should resolve to Inch for unit conversions.
      final result = SmartParseService.parse('10 in to cm');
      expect(result.isRecognized, isTrue);
      expect(result.fromUnitName, 'Inch');
      expect(result.toUnitName, 'Centimeter');
    });

    test('kilogram alias kg works', () {
      final result = SmartParseService.parse('50 kg to lb');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 50);
      expect(result.fromUnitName, 'Kilogram');
    });

    test('fahrenheit alias f works', () {
      final result = SmartParseService.parse('212 f to c');
      expect(result.isRecognized, isTrue);
      expect(result.amount, 212);
      expect(result.fromUnitName, 'Fahrenheit');
      expect(result.toUnitName, 'Celsius');
    });
  });
}
