/// Currencies supported by the app — the full set returned by Frankfurter.app.
library;

import '../models/currency_model.dart';

/// All 30 currencies supported by the Frankfurter.app API.
const List<CurrencyModel> allCurrencies = [
  CurrencyModel(code: 'USD', name: 'US Dollar', symbol: r'$', flag: '\u{1F1FA}\u{1F1F8}'),
  CurrencyModel(code: 'EUR', name: 'Euro', symbol: '€', flag: '\u{1F1EA}\u{1F1FA}'),
  CurrencyModel(code: 'GBP', name: 'British Pound', symbol: '£', flag: '\u{1F1EC}\u{1F1E7}'),
  CurrencyModel(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '\u{1F1EF}\u{1F1F5}', decimalDigits: 0),
  CurrencyModel(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', flag: '\u{1F1E6}\u{1F1FA}'),
  CurrencyModel(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', flag: '\u{1F1E8}\u{1F1E6}'),
  CurrencyModel(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '\u{1F1E8}\u{1F1ED}'),
  CurrencyModel(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '\u{1F1E8}\u{1F1F3}'),
  CurrencyModel(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '\u{1F1EE}\u{1F1F3}'),
  CurrencyModel(code: 'BRL', name: 'Brazilian Real', symbol: r'R$', flag: '\u{1F1E7}\u{1F1F7}'),
  CurrencyModel(code: 'MXN', name: 'Mexican Peso', symbol: r'Mex$', flag: '\u{1F1F2}\u{1F1FD}'),
  CurrencyModel(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', flag: '\u{1F1F8}\u{1F1EC}'),
  CurrencyModel(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$', flag: '\u{1F1ED}\u{1F1F0}'),
  CurrencyModel(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$', flag: '\u{1F1F3}\u{1F1FF}'),
  CurrencyModel(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '\u{1F1F0}\u{1F1F7}', decimalDigits: 0),
  CurrencyModel(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flag: '\u{1F1F8}\u{1F1EA}'),
  CurrencyModel(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flag: '\u{1F1F3}\u{1F1F4}'),
  CurrencyModel(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '\u{1F1F9}\u{1F1F7}'),
  CurrencyModel(code: 'ZAR', name: 'South African Rand', symbol: 'R', flag: '\u{1F1FF}\u{1F1E6}'),
  CurrencyModel(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flag: '\u{1F1E9}\u{1F1F0}'),
  CurrencyModel(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', flag: '\u{1F1F5}\u{1F1F1}'),
  CurrencyModel(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '\u{1F1F9}\u{1F1ED}'),
  CurrencyModel(code: 'ILS', name: 'Israeli Shekel', symbol: '₪', flag: '\u{1F1EE}\u{1F1F1}'),
  CurrencyModel(code: 'PHP', name: 'Philippine Peso', symbol: '₱', flag: '\u{1F1F5}\u{1F1ED}'),
  CurrencyModel(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '\u{1F1F2}\u{1F1FE}'),
  CurrencyModel(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '\u{1F1EE}\u{1F1E9}', decimalDigits: 0),
  CurrencyModel(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', flag: '\u{1F1E8}\u{1F1FF}'),
  CurrencyModel(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', flag: '\u{1F1ED}\u{1F1FA}', decimalDigits: 0),
  CurrencyModel(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', flag: '\u{1F1E7}\u{1F1EC}'),
  CurrencyModel(code: 'RON', name: 'Romanian Leu', symbol: 'lei', flag: '\u{1F1F7}\u{1F1F4}'),
];

/// Approximate rates to USD used as fallback on first launch / offline.
///
/// These are rough market rates for development only. Live rates are
/// fetched from Frankfurter.app on app start.
const Map<String, double> fallbackRatesToUsd = {
  'USD': 1.0,
  'EUR': 0.92,
  'GBP': 0.79,
  'JPY': 149.50,
  'AUD': 1.54,
  'CAD': 1.36,
  'CHF': 0.88,
  'CNY': 7.24,
  'INR': 83.50,
  'BRL': 5.05,
  'MXN': 17.20,
  'SGD': 1.34,
  'HKD': 7.82,
  'NZD': 1.63,
  'KRW': 1320.0,
  'SEK': 10.45,
  'NOK': 10.60,
  'TRY': 30.20,
  'ZAR': 18.80,
  'DKK': 6.88,
  'PLN': 4.02,
  'THB': 35.50,
  'ILS': 3.68,
  'PHP': 56.20,
  'MYR': 4.72,
  'IDR': 15650.0,
  'CZK': 23.10,
  'HUF': 362.0,
  'BGN': 1.80,
  'RON': 4.58,
};

/// Returns the currency data for a given ISO [code], or `null` if unknown.
CurrencyModel? currencyByCode(String code) {
  for (final c in allCurrencies) {
    if (c.code == code) return c;
  }
  return null;
}
