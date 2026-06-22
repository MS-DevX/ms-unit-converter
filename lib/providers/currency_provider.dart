/// UI-state provider for the Currency converter tab.
///
/// Manages the source currency, input value, exchange rates, and computes
/// results for all currencies in a single list view.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';
import '../utils/formatters.dart';

/// A single row in the all-currencies result list.
class CurrencyResultRow {
  /// The currency being shown.
  final CurrencyModel currency;

  /// The rate of this currency relative to the source currency.
  final double rate;

  /// The converted amount (`inputValue × rate`).
  final double convertedValue;

  /// User-facing formatted string of [convertedValue].
  final String formattedResult;

  /// User-facing formatted rate string (e.g. "1.0923").
  final String formattedRate;

  const CurrencyResultRow({
    required this.currency,
    required this.rate,
    required this.convertedValue,
    required this.formattedResult,
    required this.formattedRate,
  });
}

/// Exposes the full currency-converter state to the widget tree.
class CurrencyProvider extends ChangeNotifier {
  // ─── Currency lists ────────────────────────────────────────────────

  /// All supported currencies (immutable, 53 entries).
  List<CurrencyModel> get currencies => allCurrencies;

  // ─── Mutable state ─────────────────────────────────────────────────

  CurrencyModel? _fromCurrency;
  String _inputValue = '1';
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;
  bool _isOffline = false;
  bool _isUsingCached = false;

  // Internal rates map: code → rate relative to USD.
  Map<String, double> _rates = {};

  // ─── Getters ───────────────────────────────────────────────────────

  CurrencyModel? get fromCurrency => _fromCurrency;
  String get inputValue => _inputValue;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isOffline => _isOffline;
  bool get isUsingCached => _isUsingCached;

  /// True when the user has entered a valid numeric input.
  bool get hasValidInput {
    if (_inputValue.isEmpty) return false;
    final parsed = double.tryParse(_inputValue);
    return parsed != null && parsed.isFinite;
  }

  /// True when the source currency and rates are available.
  bool get isReady =>
      _fromCurrency != null && _rates.containsKey(_fromCurrency!.code);

  // ─── Constructor ───────────────────────────────────────────────────

  /// Loads cached rates immediately, then fetches fresh ones in the
  /// background. Defaults source to USD, input to "1".
  CurrencyProvider() {
    _fromCurrency = currencyByCode('USD');
    // Populate fallback rates synchronously so [isReady] is true
    // instantly, even before cache or network resolves.
    _rates = Map.from(fallbackRatesToUsd);
    _init();
  }

  Future<void> _init() async {
    final cached = await CurrencyService.loadCachedRates();
    // Only use cached rates if they cover every currency in [allCurrencies].
    final bool cachedIsComplete =
        cached != null &&
        allCurrencies.every((c) => cached.containsKey(c.code));
    if (cachedIsComplete) {
      _rates = cached;
      _lastUpdated = await CurrencyService.loadLastUpdated();
      _isLoading = false;
      _isUsingCached = true;
      notifyListeners();
    }

    await refreshRates();
  }

  // ─── Public API ────────────────────────────────────────────────────

  /// Sets the source currency and recalculates.
  void setFromCurrency(CurrencyModel currency) {
    _fromCurrency = currency;
    notifyListeners();
  }

  /// Sanitises [value] and recomputes all results.
  void setInput(String value) {
    _inputValue = Formatters.formatInput(value);
    notifyListeners();
  }

  /// Fetches live rates from Frankfurter.
  Future<void> refreshRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fresh = await CurrencyService.fetchRates();
      _rates = fresh;
      _lastUpdated = DateTime.now();
      await CurrencyService.saveRates(fresh);
      _isLoading = false;
      _isOffline = false;
      _isUsingCached = false;
      notifyListeners();
    } catch (_) {
      final cached = await CurrencyService.loadCachedRates();
      final bool cachedIsComplete =
          cached != null &&
          allCurrencies.every((c) => cached.containsKey(c.code));
      if (cachedIsComplete) {
        _rates = cached;
        _lastUpdated = await CurrencyService.loadLastUpdated();
        _isUsingCached = true;
        _error = null;
      } else {
        _rates = CurrencyService.getFallbackRates();
        _isUsingCached = false;
        _error = 'Could not update rates. Using approximate rates.';
      }
      _isLoading = false;
      _isOffline = true;
      notifyListeners();
    }
  }

  /// Returns all currencies with their converted values for the current
  /// source currency and input amount. Returns an empty list when input
  /// is empty or invalid.
  List<CurrencyResultRow> getAllResults() {
    if (_inputValue.isEmpty || !isReady) return [];

    final amount = double.tryParse(_inputValue);
    if (amount == null || amount.isNaN || amount.isInfinite) return [];

    final sourceCode = _fromCurrency!.code;
    final sourceRate = _rates[sourceCode];
    // Safety: source currency missing from rates — should never happen
    // when [isReady] is true, but guard against corrupted state.
    if (sourceRate == null) return [];

    final List<CurrencyResultRow> results = [];
    for (final currency in allCurrencies) {
      final targetRate = _rates[currency.code];
      if (targetRate == null) continue;

      final rate = targetRate / sourceRate;
      final converted = amount * rate;

      results.add(
        CurrencyResultRow(
          currency: currency,
          rate: rate,
          convertedValue: converted,
          formattedResult: Formatters.formatResult(
            converted,
            currencyDecimals: currency.decimalDigits,
          ),
          formattedRate: Formatters.formatResult(
            rate,
            currencyDecimals: currency.decimalDigits,
          ),
        ),
      );
    }
    return results;
  }

  /// Returns a formatted string showing the base rate of the source
  /// currency relative to a key reference (EUR as the most common
  /// trading pair). Returns "—" when unavailable.
  String get baseRateDisplay {
    if (_fromCurrency == null) return '\u2014';
    final sourceCode = _fromCurrency!.code;
    if (!_rates.containsKey(sourceCode) || !_rates.containsKey('EUR')) {
      return '\u2014';
    }
    final sourceRate = _rates[sourceCode]!;
    final eurRate = _rates['EUR']!;
    final rate = eurRate / sourceRate;
    final formatted = Formatters.formatResult(
      rate,
      currencyDecimals: _fromCurrency!.decimalDigits,
    );
    return '1 ${_fromCurrency!.symbol} = $formatted €';
  }
}
