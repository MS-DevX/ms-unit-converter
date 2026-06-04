import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/conversion_result.dart';

void main() {
  group('ConversionResult', () {
    test('success factory sets isValid and errorMessage', () {
      final r = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      expect(r.result, 1000.0);
      expect(r.formattedResult, '1,000');
      expect(r.formula, '1 km = 1000 m');
      expect(r.isValid, true);
      expect(r.errorMessage, isNull);
    });

    test('failure factory sets default values', () {
      final r = ConversionResult.failure('Invalid input');
      expect(r.result, 0);
      expect(r.formattedResult, '');
      expect(r.formula, '');
      expect(r.isValid, false);
      expect(r.errorMessage, 'Invalid input');
    });

    test('equality', () {
      final a = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      final b = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality', () {
      final a = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      final b = ConversionResult.failure('Invalid input');
      expect(a, isNot(equals(b)));
    });

    test('copyWith()', () {
      final r = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      final modified = r.copyWith(result: 500.0, errorMessage: 'warn');
      expect(modified.result, 500.0);
      expect(modified.errorMessage, 'warn');
      expect(modified.formattedResult, '1,000');
    });

    test('copyWith() with no args returns equal instance', () {
      final r = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      expect(r.copyWith(), equals(r));
    });

    test('toString() format', () {
      final r = ConversionResult.success(
        result: 1000.0,
        formattedResult: '1,000',
        formula: '1 km = 1000 m',
      );
      final str = r.toString();
      expect(str, contains('1000.0'));
      expect(str, contains('1,000'));
      expect(str, contains('1 km = 1000 m'));
      expect(str, contains('isValid: true'));
      expect(str, contains('errorMessage: null'));
    });
  });
}
