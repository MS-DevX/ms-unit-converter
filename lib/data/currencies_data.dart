/// Currency data helpers — builds [CurrencyModel] lists from the Frankfurter
/// API response, with fallbacks for offline use.
library;

import '../models/currency_model.dart';

/// Set of currency codes that appear first in sorted lists.
const Set<String> pinnedCurrencyCodes = {
  'PKR',
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'AED',
  'SAR',
  'INR',
};

/// Order in which pinned currencies are displayed.
const List<String> pinnedCurrencyOrder = [
  'PKR',
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'AED',
  'SAR',
  'INR',
];

/// Currencies whose decimal digits differ from the default of 2.
const Map<String, int> decimalDigitsOverride = {
  'BHD': 3,
  'BYN': 0,
  'CLP': 0,
  'CUP': 0,
  'HUF': 0,
  'IDR': 0,
  'ISK': 0,
  'JMD': 0,
  'JPY': 0,
  'KES': 0,
  'KRW': 0,
  'KWD': 3,
  'LKR': 0,
  'MRO': 0,
  'MRU': 0,
  'NGN': 0,
  'NPR': 0,
  'OMR': 3,
  'PKR': 0,
  'PYG': 0,
  'RSD': 0,
  'RWF': 0,
  'SLE': 0,
  'STN': 0,
  'TWD': 0,
  'UGX': 0,
  'VND': 0,
  'XAF': 0,
  'XOF': 0,
  'XPF': 0,
};

/// Manual flag overrides for currencies whose code doesn't map to a country.
const Map<String, String> flagOverrides = {
  'EUR': '\u{1F1EA}\u{1F1FA}', // 🇪🇺 European Union
  'XAG': '\u{1F30D}', // 🌐 Silver (commodity)
  'XAU': '\u{1F30D}', // 🌐 Gold (commodity)
  'XCD': '\u{1F30D}', // 🌐 East Caribbean Dollar (shared)
  'XCG': '\u{1F30D}', // 🌐 Caribbean Guilder (shared)
  'XDR': '\u{1F30D}', // 🌐 Special Drawing Rights (IMF)
  'XOF': '\u{1F30D}', // 🌐 West African CFA Franc (shared)
  'XPD': '\u{1F30D}', // 🌐 Palladium (commodity)
  'XPF': '\u{1F30D}', // 🌐 CFP Franc (shared)
  'XPT': '\u{1F30D}', // 🌐 Platinum (commodity)
};

/// Builds a sorted [CurrencyModel] list from raw API data.
///
/// [apiCurrencies] is a list of maps with `code`, `name`, and `symbol` keys.
/// Pinned currencies appear first in the defined order, then alphabetical.
List<CurrencyModel> buildCurrencyList(List<Map<String, String>> apiCurrencies) {
  final models = <CurrencyModel>[];
  final seen = <String>{};

  // Pinned currencies first, in defined order.
  for (final code in pinnedCurrencyOrder) {
    final match = _findByCode(apiCurrencies, code);
    if (match != null) {
      models.add(_toModel(match));
      seen.add(code);
    }
  }

  // Remaining currencies sorted alphabetically by code.
  final remaining = <Map<String, String>>[];
  for (final entry in apiCurrencies) {
    if (!seen.contains(entry['code'])) {
      remaining.add(entry);
    }
  }
  remaining.sort((a, b) => a['code']!.compareTo(b['code']!));
  for (final entry in remaining) {
    models.add(_toModel(entry));
  }

  return models;
}

/// Converts a raw API map into a [CurrencyModel].
CurrencyModel _toModel(Map<String, String> entry) {
  final code = entry['code']!;
  return CurrencyModel(
    code: code,
    name: entry['name']!,
    symbol: entry['symbol'] ?? code,
    flag: _deriveFlag(code),
    decimalDigits: decimalDigitsOverride[code] ?? 2,
    isPinned: pinnedCurrencyCodes.contains(code),
  );
}

/// Derives a flag emoji for [code].
///
/// Checks manual overrides first, then attempts to build a regional indicator
/// flag from the first two characters. Falls back to 🌐.
String _deriveFlag(String code) {
  // Manual override takes priority.
  if (flagOverrides.containsKey(code)) return flagOverrides[code]!;

  // Try building a regional-indicator flag from the first 2 characters.
  // ISO 4217 codes often (but not always) overlap with ISO 3166-1 alpha-2.
  if (code.length >= 2) {
    final a = code.codeUnitAt(0);
    final b = code.codeUnitAt(1);
    // Regional Indicator Symbols are A-Z (U+1F1E6–U+1F1FF).
    // Convert 'A' (65) → 0x1F1E6, etc.
    if (_isAsciiLetter(a) && _isAsciiLetter(b)) {
      return String.fromCharCodes([0x1F1E6 + (a - 0x41), 0x1F1E6 + (b - 0x41)]);
    }
  }

  return '\u{1F30D}'; // 🌐 globe
}

/// Returns true if [c] is an ASCII letter.
bool _isAsciiLetter(int c) =>
    (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);

/// Finds a map by [code] in [apiCurrencies].
Map<String, String>? _findByCode(List<Map<String, String>> list, String code) {
  for (final entry in list) {
    if (entry['code'] == code) return entry;
  }
  return null;
}

/// Fallback currency names for offline / first-launch use.
///
/// This mirrors the old hardcoded list so the app is never blank when
/// the network is unavailable.
const Map<String, String> fallbackCurrencyNames = {
  'PKR': 'Pakistani Rupee',
  'USD': 'US Dollar',
  'EUR': 'Euro',
  'GBP': 'British Pound',
  'JPY': 'Japanese Yen',
  'AED': 'UAE Dirham',
  'SAR': 'Saudi Riyal',
  'INR': 'Indian Rupee',
  'ARS': 'Argentine Peso',
  'AUD': 'Australian Dollar',
  'BDT': 'Bangladeshi Taka',
  'BGN': 'Bulgarian Lev',
  'BHD': 'Bahraini Dinar',
  'BRL': 'Brazilian Real',
  'CAD': 'Canadian Dollar',
  'CHF': 'Swiss Franc',
  'CLP': 'Chilean Peso',
  'CNY': 'Chinese Yuan',
  'COP': 'Colombian Peso',
  'CZK': 'Czech Koruna',
  'DKK': 'Danish Krone',
  'EGP': 'Egyptian Pound',
  'HKD': 'Hong Kong Dollar',
  'HUF': 'Hungarian Forint',
  'IDR': 'Indonesian Rupiah',
  'ILS': 'Israeli Shekel',
  'ISK': 'Icelandic Krona',
  'JMD': 'Jamaican Dollar',
  'KES': 'Kenyan Shilling',
  'KRW': 'South Korean Won',
  'KWD': 'Kuwaiti Dinar',
  'LKR': 'Sri Lankan Rupee',
  'MAD': 'Moroccan Dirham',
  'MXN': 'Mexican Peso',
  'MYR': 'Malaysian Ringgit',
  'NGN': 'Nigerian Naira',
  'NOK': 'Norwegian Krone',
  'NPR': 'Nepalese Rupee',
  'NZD': 'New Zealand Dollar',
  'OMR': 'Omani Rial',
  'PEN': 'Peruvian Sol',
  'PHP': 'Philippine Peso',
  'PLN': 'Polish Zloty',
  'QAR': 'Qatari Riyal',
  'RON': 'Romanian Leu',
  'RSD': 'Serbian Dinar',
  'SEK': 'Swedish Krona',
  'SGD': 'Singapore Dollar',
  'THB': 'Thai Baht',
  'TRY': 'Turkish Lira',
  'TWD': 'Taiwan Dollar',
  'VND': 'Vietnamese Dong',
  'ZAR': 'South African Rand',
};

/// Fallback symbols for the same set of currencies.
const Map<String, String> fallbackCurrencySymbols = {
  'PKR': '\u{20A8}',
  'USD': r'$',
  'EUR': '\u{20AC}',
  'GBP': '\u{00A3}',
  'JPY': '\u{00A5}',
  'AED': '\u{062F}\u{002E}\u{0625}',
  'SAR': '\u{FDFC}',
  'INR': '\u{20B9}',
  'ARS': r'$',
  'AUD': r'A$',
  'BDT': '\u{09F3}',
  'BGN': '\u{043B}\u{0432}',
  'BHD': '\u{002E}\u{062F}\u{002E}\u{0628}',
  'BRL': r'R$',
  'CAD': r'C$',
  'CHF': 'CHF',
  'CLP': r'$',
  'CNY': '\u{00A5}',
  'COP': r'$',
  'CZK': 'K\u{010D}',
  'DKK': 'kr',
  'EGP': '\u{00A3}',
  'HKD': r'HK$',
  'HUF': 'Ft',
  'IDR': 'Rp',
  'ILS': '\u{20AA}',
  'ISK': 'kr',
  'JMD': r'J$',
  'KES': 'KSh',
  'KRW': '\u{20A9}',
  'KWD': '\u{062F}\u{002E}\u{0643}',
  'LKR': '\u{20A8}',
  'MAD': '\u{062F}\u{002E}\u{0645}\u{002E}',
  'MXN': r'Mex$',
  'MYR': 'RM',
  'NGN': '\u{20A6}',
  'NOK': 'kr',
  'NPR': '\u{20A8}',
  'NZD': r'NZ$',
  'OMR': '\u{FDFC}',
  'PEN': 'S/',
  'PHP': '\u{20B1}',
  'PLN': 'z\u{0142}',
  'QAR': '\u{FDFC}',
  'RON': 'lei',
  'RSD': '\u{0434}\u{0438}\u{043D}',
  'SEK': 'kr',
  'SGD': r'S$',
  'THB': '\u{0E3F}',
  'TRY': '\u{20BA}',
  'TWD': r'NT$',
  'VND': '\u{20AB}',
  'ZAR': 'R',
};

/// Builds a fallback currency list (offline / first launch) from hardcoded
/// name and symbol maps.
List<CurrencyModel> buildFallbackCurrencies() {
  final models = <CurrencyModel>[];
  final seen = <String>{};

  // Pinned currencies first.
  for (final code in pinnedCurrencyOrder) {
    if (fallbackCurrencyNames.containsKey(code)) {
      models.add(
        CurrencyModel(
          code: code,
          name: fallbackCurrencyNames[code]!,
          symbol: fallbackCurrencySymbols[code] ?? code,
          flag: _deriveFlag(code),
          decimalDigits: decimalDigitsOverride[code] ?? 2,
          isPinned: true,
        ),
      );
      seen.add(code);
    }
  }

  // Remaining, sorted alphabetically.
  final codes =
      fallbackCurrencyNames.keys.where((c) => !seen.contains(c)).toList()
        ..sort();
  for (final code in codes) {
    models.add(
      CurrencyModel(
        code: code,
        name: fallbackCurrencyNames[code]!,
        symbol: fallbackCurrencySymbols[code] ?? code,
        flag: _deriveFlag(code),
        decimalDigits: decimalDigitsOverride[code] ?? 2,
        isPinned: false,
      ),
    );
  }

  return models;
}

/// Returns the [CurrencyModel] for [code] from [currencies], or `null`.
CurrencyModel? currencyByCode(String code, List<CurrencyModel> currencies) {
  for (final c in currencies) {
    if (c.code == code) return c;
  }
  return null;
}

/// Approximate rates to USD used as fallback on first launch / offline.
///
/// These are rough market rates for development only. Live rates are
/// fetched from Frankfurter.app on app start.
const Map<String, double> fallbackRatesToUsd = {
  'PKR': 278.4,
  'USD': 1.0,
  'EUR': 0.87,
  'GBP': 0.76,
  'JPY': 149.50,
  'AED': 3.67,
  'SAR': 3.75,
  'INR': 83.50,
  'ARS': 1453.0,
  'AUD': 1.54,
  'BDT': 123.0,
  'BGN': 1.80,
  'BHD': 0.376,
  'BRL': 5.05,
  'CAD': 1.36,
  'CHF': 0.88,
  'CLP': 899.0,
  'CNY': 7.24,
  'COP': 3456.0,
  'CZK': 23.10,
  'DKK': 6.88,
  'EGP': 49.94,
  'HKD': 7.82,
  'HUF': 362.0,
  'IDR': 15650.0,
  'ILS': 3.68,
  'ISK': 125.7,
  'JMD': 156.9,
  'KES': 129.4,
  'KRW': 1320.0,
  'KWD': 0.308,
  'LKR': 333.8,
  'MAD': 9.32,
  'MXN': 17.20,
  'MYR': 4.72,
  'NGN': 1365.0,
  'NOK': 10.60,
  'NPR': 151.3,
  'NZD': 1.63,
  'OMR': 0.384,
  'PEN': 3.39,
  'PHP': 56.20,
  'PLN': 4.02,
  'QAR': 3.64,
  'RON': 4.58,
  'RSD': 102.4,
  'SEK': 10.45,
  'SGD': 1.34,
  'THB': 35.50,
  'TRY': 30.20,
  'TWD': 31.65,
  'VND': 26251.0,
  'ZAR': 18.80,
};

/// Returns a [CurrencyModel] for [code] from the fallback currency list.
CurrencyModel getFallbackCurrency(String code) {
  final list = buildFallbackCurrencies();
  return list.firstWhere((c) => c.code == code, orElse: () => list.first);
}

/// Backward-compatible class API for currency dataset access.
class CurrenciesData {
  CurrenciesData._();

  /// List of all built-in currencies.
  static List<CurrencyModel> get supportedCurrencies => buildFallbackCurrencies();

  /// Returns a [CurrencyModel] for [code] (e.g. "USD", "EUR").
  static CurrencyModel getByCode(String code) => getFallbackCurrency(code);
}
