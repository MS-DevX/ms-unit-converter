import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/utils/formatters.dart';

void main() {
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
}
