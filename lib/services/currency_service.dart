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

/// Cache key for the rates JSON map.
const String _cacheKeyRates = 'currency_rates';

/// Cache key for the ISO-8601 timestamp of the last successful fetch.
const String _cacheKeyTimestamp = 'currency_rates_timestamp';

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

  /// Returns fallback (hardcoded) rates as a last resort.
  static Map<String, double> getFallbackRates() {
    return Map.from(fallbackRatesToUsd);
  }
}
