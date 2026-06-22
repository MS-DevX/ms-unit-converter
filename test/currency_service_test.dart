import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/data/currencies_data.dart';
import 'package:unit_converter/services/currency_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyService', () {
    group('convert()', () {
      test('same currency returns input amount', () {
        final result = CurrencyService.convert(10, 1.0, 1.0);
        expect(result, 10.0);
      });

      test('converts USD to EUR with correct formula', () {
        // 10 USD * 0.87 EUR/USD = 8.7 EUR
        final result = CurrencyService.convert(10, 1.0, 0.87);
        expect(result, closeTo(8.7, 0.001));
      });

      test('converts EUR to USD with correct formula', () {
        // 10 EUR / 0.87 USD/EUR = 11.49 USD (approximately)
        final result = CurrencyService.convert(10, 0.87, 1.0);
        expect(result, closeTo(11.494, 0.01));
      });

      test('converts PKR to USD with correct formula', () {
        // 1000 PKR * 1.0 / 278.4 = 3.592 USD (approximately)
        final result = CurrencyService.convert(1000, 278.4, 1.0);
        expect(result, closeTo(3.592, 0.01));
      });

      test('convert is symmetric', () {
        final a = CurrencyService.convert(100, 1.0, 0.87);
        final b = CurrencyService.convert(a, 0.87, 1.0);
        expect(b, closeTo(100, 0.01));
      });
    });

    group('getFallbackRates()', () {
      test('returns a copy of fallbackRatesToUsd', () {
        final rates = CurrencyService.getFallbackRates();
        expect(rates, fallbackRatesToUsd);
      });

      test('returned map is mutable (not const)', () {
        final rates = CurrencyService.getFallbackRates();
        rates['TEST'] = 1.0;
        expect(rates.containsKey('TEST'), isTrue);
        expect(fallbackRatesToUsd.containsKey('TEST'), isFalse);
      });

      test('contains all currencies from allCurrencies', () {
        final rates = CurrencyService.getFallbackRates();
        for (final c in allCurrencies) {
          expect(
            rates.containsKey(c.code),
            isTrue,
            reason: '${c.code} missing from fallback rates',
          );
        }
      });

      test('PKR rate matches data file', () {
        final rates = CurrencyService.getFallbackRates();
        expect(rates['PKR'], fallbackRatesToUsd['PKR']);
      });
    });

    group('cache round-trip', () {
      test('saveRates and loadCachedRates round-trip', () async {
        final testRates = <String, double>{
          'USD': 1.0,
          'PKR': 278.4,
          'EUR': 0.87,
        };

        await CurrencyService.saveRates(testRates);
        final loaded = await CurrencyService.loadCachedRates();

        expect(loaded, isNotNull);
        expect(loaded!['USD'], 1.0);
        expect(loaded['PKR'], 278.4);
        expect(loaded['EUR'], 0.87);
      });

      test('loadCachedRates returns null when no cache exists', () async {
        final loaded = await CurrencyService.loadCachedRates();
        expect(loaded, isNull);
      });

      test('corrupted cache returns null', () async {
        SharedPreferences.setMockInitialValues({
          'currency_rates': 'not-valid-json',
        });
        final loaded = await CurrencyService.loadCachedRates();
        expect(loaded, isNull);
      });

      test('saveRates stores timestamp', () async {
        final testRates = <String, double>{'USD': 1.0};
        await CurrencyService.saveRates(testRates);

        final prefs = await SharedPreferences.getInstance();
        final timestamp = prefs.getString('currency_rates_timestamp');
        expect(timestamp, isNotNull);
        expect(DateTime.tryParse(timestamp!), isNotNull);
      });

      test('loadLastUpdated returns matching timestamp', () async {
        final testRates = <String, double>{'USD': 1.0};
        await CurrencyService.saveRates(testRates);

        final loaded = await CurrencyService.loadLastUpdated();
        expect(loaded, isNotNull);
        // Should be within the last few seconds
        final diff = DateTime.now().difference(loaded!);
        expect(diff.inSeconds, lessThan(5));
      });

      test('loadLastUpdated returns null when no cache exists', () async {
        final loaded = await CurrencyService.loadLastUpdated();
        expect(loaded, isNull);
      });
    });
  });
}
