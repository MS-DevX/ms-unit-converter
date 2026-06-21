import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/data/currencies_data.dart';
import 'package:unit_converter/models/currency_model.dart';

/// Simulates the search filtering used in the currency screen.
bool _matchesSearch(CurrencyModel c, String query) {
  if (query.isEmpty) return true;
  final q = query.toLowerCase().trim();
  return c.code.toLowerCase().contains(q) ||
      c.name.toLowerCase().contains(q) ||
      c.symbol.toLowerCase().contains(q);
}

void main() {
  group('allCurrencies', () {
    test('contains PKR', () {
      final pkr = currencyByCode('PKR');
      expect(pkr, isNotNull);
      expect(pkr!.code, 'PKR');
      expect(pkr.name, 'Pakistani Rupee');
    });

    test('PKR is pinned', () {
      final pkr = currencyByCode('PKR');
      expect(pkr!.isPinned, isTrue);
    });

    test('USD is pinned', () {
      final usd = currencyByCode('USD');
      expect(usd!.isPinned, isTrue);
    });

    test('contains all expected pinned currencies', () {
      final pinnedCodes = [
        'PKR',
        'USD',
        'EUR',
        'GBP',
        'JPY',
        'AED',
        'SAR',
        'INR',
      ];
      for (final code in pinnedCodes) {
        expect(currencyByCode(code), isNotNull, reason: '$code should exist');
        expect(
          currencyByCode(code)!.isPinned,
          isTrue,
          reason: '$code should be pinned',
        );
      }
    });

    test('contains all expected major currencies', () {
      final expected = [
        'PKR',
        'USD',
        'EUR',
        'GBP',
        'JPY',
        'AED',
        'SAR',
        'INR',
        'ARS',
        'AUD',
        'BDT',
        'BGN',
        'BHD',
        'BRL',
        'CAD',
        'CHF',
        'CLP',
        'CNY',
        'COP',
        'CZK',
        'DKK',
        'EGP',
        'HKD',
        'HUF',
        'IDR',
        'ILS',
        'ISK',
        'JMD',
        'KES',
        'KRW',
        'KWD',
        'LKR',
        'MAD',
        'MXN',
        'MYR',
        'NGN',
        'NOK',
        'NPR',
        'NZD',
        'OMR',
        'PEN',
        'PHP',
        'PLN',
        'QAR',
        'RON',
        'RSD',
        'SEK',
        'SGD',
        'THB',
        'TRY',
        'TWD',
        'VND',
        'ZAR',
      ];
      for (final code in expected) {
        expect(currencyByCode(code), isNotNull, reason: '$code should exist');
      }
    });

    test('total count is 53', () {
      expect(allCurrencies.length, 53);
    });

    test('pinned currencies appear first in the list', () {
      final pinnedCodes = [
        'PKR',
        'USD',
        'EUR',
        'GBP',
        'JPY',
        'AED',
        'SAR',
        'INR',
      ];
      for (int i = 0; i < pinnedCodes.length; i++) {
        expect(
          allCurrencies[i].code,
          pinnedCodes[i],
          reason: 'Position $i should be ${pinnedCodes[i]}',
        );
      }
    });

    test('non-pinned currencies are sorted alphabetically', () {
      final nonPinned = allCurrencies
          .where((c) => !c.isPinned)
          .map((c) => c.code)
          .toList();
      final sorted = List<String>.from(nonPinned)..sort();
      expect(nonPinned, sorted);
    });

    test('every currency has a non-empty symbol', () {
      for (final c in allCurrencies) {
        expect(c.symbol, isNotEmpty, reason: '${c.code} has empty symbol');
      }
    });

    test('every currency has a non-empty flag', () {
      for (final c in allCurrencies) {
        expect(c.flag, isNotEmpty, reason: '${c.code} has empty flag');
      }
    });

    test('currencyByCode returns null for unknown code', () {
      expect(currencyByCode('XYZ'), isNull);
    });

    test('currencyByCode is case-sensitive', () {
      expect(currencyByCode('pkr'), isNull);
      expect(currencyByCode('PKR'), isNotNull);
    });
  });

  group('fallbackRatesToUsd', () {
    test('contains all currency codes', () {
      for (final c in allCurrencies) {
        expect(
          fallbackRatesToUsd.containsKey(c.code),
          isTrue,
          reason: '${c.code} missing from fallback rates',
        );
      }
    });

    test('PKR has a reasonable rate', () {
      final rate = fallbackRatesToUsd['PKR'];
      expect(rate, greaterThan(200));
      expect(rate, lessThan(350));
    });

    test('USD is 1.0', () {
      expect(fallbackRatesToUsd['USD'], 1.0);
    });

    test('EUR has a reasonable rate', () {
      final rate = fallbackRatesToUsd['EUR'];
      expect(rate, greaterThan(0.5));
      expect(rate, lessThan(1.5));
    });

    test('all rates are positive', () {
      for (final entry in fallbackRatesToUsd.entries) {
        expect(
          entry.value,
          greaterThan(0),
          reason: '${entry.key} has non-positive rate',
        );
      }
    });

    test('no duplicate entries in allCurrencies', () {
      final codes = allCurrencies.map((c) => c.code).toList();
      final unique = codes.toSet();
      expect(codes.length, unique.length);
    });
  });

  group('search matching', () {
    test('matches by code', () {
      final results = allCurrencies.where((c) => _matchesSearch(c, 'PKR'));
      expect(results, hasLength(1));
      expect(results.first.code, 'PKR');
    });

    test('matches by name', () {
      final results = allCurrencies.where((c) => _matchesSearch(c, 'dollar'));
      expect(results, isNotEmpty);
      expect(results.any((c) => c.code == 'USD'), isTrue);
    });

    test('matches by symbol', () {
      final results = allCurrencies.where((c) => _matchesSearch(c, '£'));
      expect(results, isNotEmpty);
    });

    test('case-insensitive code match', () {
      expect(
        _matchesSearch(allCurrencies.firstWhere((c) => c.code == 'PKR'), 'pkr'),
        isTrue,
      );
    });

    test('empty query matches all', () {
      for (final c in allCurrencies) {
        expect(_matchesSearch(c, ''), isTrue);
      }
    });

    test('no match returns empty', () {
      final results = allCurrencies.where((c) => _matchesSearch(c, 'ZZZZZZZ'));
      expect(results, isEmpty);
    });
  });

  group('formatting (row actions support)', () {
    test('PKR rate conversion result', () {
      final rate = fallbackRatesToUsd['PKR']!;
      const amount = 100.0;
      final result = amount * rate;
      expect(result, greaterThan(20000));
      expect(result, lessThan(35000));
    });

    test('USD rate conversion result for 1 PKR', () {
      final rate = fallbackRatesToUsd['PKR']!;
      const amount = 1.0;
      final result = amount / rate;
      expect(result, greaterThan(0.002));
      expect(result, lessThan(0.005));
    });

    test('EUR to USD conversion result', () {
      final eurRate = fallbackRatesToUsd['EUR']!;
      const amount = 50.0;
      final result = amount * eurRate;
      expect(result, greaterThan(25));
      expect(result, lessThan(75));
    });
  });
}
