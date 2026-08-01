/// Service for fetching, caching, and applying currency exchange rates.
///
/// Rates are sourced from [Frankfurter](https://www.frankfurter.dev) (free,
/// no API key required). The service caches the latest rates in
/// [SharedPreferences] for offline use and stores the last-fetch timestamp.
///
/// Conversion formula: `amount × targetRate / sourceRate`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/currencies_data.dart';
import '../repositories/currency_repository.dart';

/// Cache key for the rates JSON map.
const String _cacheKeyRates = 'currency_rates';

/// Cache key for the ISO-8601 timestamp of the last successful fetch.
const String _cacheKeyTimestamp = 'currency_rates_timestamp';

/// Cache key for the currencies list (ISO code → name map).
const String _cacheKeyCurrencies = 'currencies_cache';

/// Service for fetching, caching, and applying exchange rates.
class CurrencyService {
  CurrencyService._();

  /// Frankfurter v2 API base URL — returns all active currencies as an array.
  static const String _apiBase = 'https://api.frankfurter.dev/v2';

  /// Connection timeout for HTTP requests.
  static const Duration _connectionTimeout = Duration(seconds: 10);

  /// Total response timeout for HTTP requests.
  static const Duration _responseTimeout = Duration(seconds: 15);

  /// Fetches the latest rates relative to [base] currency (default USD).
  ///
  /// Returns a `Map<String, double>` of currency code → rate relative to
  /// [base]. Throws on network failure or non-200 response.
  static Future<Map<String, double>> fetchRates({String base = 'USD'}) async {
    final url = Uri.parse('$_apiBase/rates?base=$base');
    final client = HttpClient();
    client.connectionTimeout = _connectionTimeout;
    try {
      final request = await client.getUrl(url);
      request.headers.set('Accept', 'application/json');
      final response = await request.close().timeout(_responseTimeout);

      if (response.statusCode != 200) {
        throw HttpException('Frankfurter returned ${response.statusCode}');
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as List<dynamic>;

      final rates = <String, double>{};
      rates[base] = 1.0;
      for (final entry in data) {
        final item = entry as Map<String, dynamic>;
        final quote = item['quote'] as String;
        final rate = (item['rate'] as num).toDouble();
        rates[quote] = rate;
      }
      return rates;
    } finally {
      client.close();
    }
  }

  /// Fetches the complete list of supported currencies from Frankfurter v2.
  ///
  /// Returns a list of maps with `iso_code`, `name`, and `symbol` keys.
  /// Throws on network failure or non-200 response.
  static Future<List<Map<String, String>>> fetchCurrencies() async {
    final url = Uri.parse('$_apiBase/currencies');
    final client = HttpClient();
    client.connectionTimeout = _connectionTimeout;
    try {
      final request = await client.getUrl(url);
      request.headers.set('Accept', 'application/json');
      final response = await request.close().timeout(_responseTimeout);

      if (response.statusCode != 200) {
        throw HttpException('Frankfurter returned ${response.statusCode}');
      }

      final body = await response.transform(utf8.decoder).join();
      final data = jsonDecode(body) as List<dynamic>;

      return data.map((entry) {
        final item = entry as Map<String, dynamic>;
        return {
          'code': item['iso_code'] as String,
          'name': item['name'] as String,
          'symbol': (item['symbol'] as String?) ?? '',
        };
      }).toList();
    } finally {
      client.close();
    }
  }

  /// Caches the parsed currency list to [SharedPreferences].
  static Future<void> saveCachedCurrencies(
    List<Map<String, String>> currencies,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(currencies);
    await prefs.setString(_cacheKeyCurrencies, encoded);
  }

  /// Loads cached currencies from [SharedPreferences], or `null` if absent.
  static Future<List<Map<String, String>>?> loadCachedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyCurrencies);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) {
        final item = e as Map<String, dynamic>;
        return {
          'code': item['code'] as String,
          'name': item['name'] as String,
          'symbol': (item['symbol'] as String?) ?? '',
        };
      }).toList();
    } catch (_) {
      return null;
    }
  }

  /// Saves [rates] and the current timestamp to [SharedPreferences].
  static Future<void> saveRates(Map<String, double> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(rates.map((k, v) => MapEntry(k, v.toString())));
    await prefs.setString(_cacheKeyRates, encoded);
    await prefs.setString(_cacheKeyTimestamp, DateTime.now().toIso8601String());
  }

  /// Loads cached rates from [SharedPreferences], or `null` if absent.
  static Future<Map<String, double>?> loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyRates);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, double.parse(v as String)));
    } catch (_) {
      return null;
    }
  }

  /// Loads the timestamp of the last successful cache write, or `null`.
  static Future<DateTime?> loadLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKeyTimestamp);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Converts [amount] from a currency with [fromRate] to one with [toRate].
  ///
  /// Both rates must be relative to the same base currency.
  static double convert(double amount, double fromRate, double toRate) {
    return amount * toRate / fromRate;
  }

  /// Returns fallback rates from SQLite via [CurrencyRepository].
  static Future<Map<String, double>> getFallbackRates() async {
    try {
      final dbRates = await CurrencyRepository.instance.getFallbackRates();
      if (dbRates.isNotEmpty) return dbRates;
    } catch (_) {}
    return Map.from(fallbackRatesToUsd);
  }
}
