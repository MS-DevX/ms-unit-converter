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
  final currencies = buildFallbackCurrencies();

  group('buildFallbackCurrencies', () {
    test('contains PKR', () {
      final pkr = currencyByCode('PKR', currencies);
      expect(pkr, isNotNull);
      expect(pkr!.code, 'PKR');
      expect(pkr.name, 'Pakistani Rupee');
    });

    test('PKR is pinned', () {
      final pkr = currencyByCode('PKR', currencies);
      expect(pkr!.isPinned, isTrue);
    });

    test('USD is pinned', () {
      final usd = currencyByCode('USD', currencies);
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
        expect(
          currencyByCode(code, currencies),
          isNotNull,
          reason: '$code should exist',
        );
        expect(
          currencyByCode(code, currencies)!.isPinned,
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
        expect(
          currencyByCode(code, currencies),
          isNotNull,
          reason: '$code should exist',
        );
      }
    });

    test('pinned currencies appear first in the list', () {
      final pinnedCodes = pinnedCurrencyOrder;
      for (int i = 0; i < pinnedCodes.length; i++) {
        expect(
          currencies[i].code,
          pinnedCodes[i],
          reason: 'Position $i should be ${pinnedCodes[i]}',
        );
      }
    });

    test('non-pinned currencies are sorted alphabetically', () {
      final nonPinned = currencies
          .where((c) => !c.isPinned)
          .map((c) => c.code)
          .toList();
      final sorted = List<String>.from(nonPinned)..sort();
      expect(nonPinned, sorted);
    });

    test('every currency has a non-empty symbol', () {
      for (final c in currencies) {
        expect(c.symbol, isNotEmpty, reason: '${c.code} has empty symbol');
      }
    });

    test('every currency has a non-empty flag', () {
      for (final c in currencies) {
        expect(c.flag, isNotEmpty, reason: '${c.code} has empty flag');
      }
    });

    test('currencyByCode returns null for unknown code', () {
      expect(currencyByCode('XYZ', currencies), isNull);
    });

    test('currencyByCode is case-sensitive', () {
      expect(currencyByCode('pkr', currencies), isNull);
      expect(currencyByCode('PKR', currencies), isNotNull);
    });
  });

  group('fallbackRatesToUsd', () {
    test('contains all currency codes', () {
      for (final c in currencies) {
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

    test('no duplicate entries in currencies', () {
      final codes = currencies.map((c) => c.code).toList();
      final unique = codes.toSet();
      expect(codes.length, unique.length);
    });
  });

  group('search matching', () {
    test('matches by code', () {
      final results = currencies.where((c) => _matchesSearch(c, 'PKR'));
      expect(results, hasLength(1));
      expect(results.first.code, 'PKR');
    });

    test('matches by name', () {
      final results = currencies.where((c) => _matchesSearch(c, 'dollar'));
      expect(results, isNotEmpty);
      expect(results.any((c) => c.code == 'USD'), isTrue);
    });

    test('matches by symbol', () {
      final results = currencies.where((c) => _matchesSearch(c, '\u00A3'));
      expect(results, isNotEmpty);
    });

    test('case-insensitive code match', () {
      expect(
        _matchesSearch(currencies.firstWhere((c) => c.code == 'PKR'), 'pkr'),
        isTrue,
      );
    });

    test('empty query matches all', () {
      for (final c in currencies) {
        expect(_matchesSearch(c, ''), isTrue);
      }
    });

    test('no match returns empty', () {
      final results = currencies.where((c) => _matchesSearch(c, 'ZZZZZZZ'));
      expect(results, isEmpty);
    });
  });

  group('buildCurrencyList', () {
    test('builds from API-style data', () {
      final apiData = [
        {'code': 'EUR', 'name': 'Euro', 'symbol': '\u20AC'},
        {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '\u00A5'},
        {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
      ];
      final result = buildCurrencyList(apiData);
      expect(result.length, greaterThanOrEqualTo(3));

      expect(result.firstWhere((c) => c.code == 'USD').isPinned, isTrue);
      expect(result.firstWhere((c) => c.code == 'EUR').isPinned, isTrue);
      expect(result.firstWhere((c) => c.code == 'JPY').isPinned, isTrue);
    });

    test('derives flag from code for known currencies', () {
      final apiData = [
        {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
        {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '\u00A5'},
      ];
      final result = buildCurrencyList(apiData);
      for (final c in result) {
        // USD → regional indicator US, JPY → regional indicator JP
        expect(c.flag, isNotEmpty);
        expect(c.flag, isNot('\u{1F30D}'));
      }
    });

    test('uses flag override for EUR', () {
      final apiData = [
        {'code': 'EUR', 'name': 'Euro', 'symbol': '\u20AC'},
      ];
      final result = buildCurrencyList(apiData);
      expect(result.firstWhere((c) => c.code == 'EUR').flag, '\u{1F1EA}\u{1F1FA}');
    });

    test('falls back to globe for X-currencies', () {
      final apiData = [
        {'code': 'XAU', 'name': 'Gold', 'symbol': 'oz t'},
      ];
      final result = buildCurrencyList(apiData);
      final match = result.firstWhere(
        (c) => c.code == 'XAU',
        orElse: () => const CurrencyModel(code: 'XAU', name: 'Gold', symbol: 'oz t', flag: '\u{1F30D}'),
      );
      expect(match.flag, '\u{1F30D}');
    });

    test('applies decimal digits override', () {
      final apiData = [
        {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '\u00A5'},
        {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
      ];
      final result = buildCurrencyList(apiData);
      expect(result.firstWhere((c) => c.code == 'JPY').decimalDigits, 0);
      expect(result.firstWhere((c) => c.code == 'USD').decimalDigits, 2);
    });

    test('currencyByCode finds currency in result list', () {
      final apiData = [
        {'code': 'GBP', 'name': 'British Pound', 'symbol': '\u00A3'},
        {'code': 'USD', 'name': 'US Dollar', 'symbol': r'$'},
      ];
      final result = buildCurrencyList(apiData);
      expect(currencyByCode('GBP', result)!.name, 'British Pound');
      expect(currencyByCode('USD', result)!.symbol, r'$');
    });
  });
}
