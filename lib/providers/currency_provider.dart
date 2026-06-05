/// UI-state provider for the Currency converter tab.
///
/// Manages source and target currencies, the input value, the computed
/// result, and the lifecycle of fetching / caching exchange rates.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../services/currency_service.dart';
import '../utils/formatters.dart';

/// Exposes the full currency-converter state to the widget tree.
class CurrencyProvider extends ChangeNotifier {
  // ─── Currency lists ────────────────────────────────────────────────

  /// All supported currencies (immutable, ~30 entries).
  List<CurrencyModel> get currencies => allCurrencies;

  // ─── Mutable state ─────────────────────────────────────────────────

  CurrencyModel? _fromCurrency;
  CurrencyModel? _toCurrency;
  String _inputValue = '';
  String _resultDisplay = '\u2014';
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdated;

  // Internal rates map: code → rate relative to USD.
  Map<String, double> _rates = {};

  // ─── Getters ───────────────────────────────────────────────────────

  CurrencyModel? get fromCurrency => _fromCurrency;
  CurrencyModel? get toCurrency => _toCurrency;
  String get inputValue => _inputValue;
  String get resultDisplay => _resultDisplay;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  /// True when the user has entered a valid numeric input.
  bool get hasValidInput {
    if (_inputValue.isEmpty) return false;
    final parsed = double.tryParse(_inputValue);
    return parsed != null && parsed.isFinite;
  }

  /// True when both currencies are set and rates are loaded.
  bool get isReady =>
      _fromCurrency != null &&
      _toCurrency != null &&
      _rates.containsKey(_fromCurrency!.code) &&
      _rates.containsKey(_toCurrency!.code);

  // ─── Constructor ───────────────────────────────────────────────────

  /// Loads cached rates immediately, then fetches fresh ones in the
  /// background. Selects USD → EUR as defaults.
  CurrencyProvider() {
    _fromCurrency = currencyByCode('USD');
    _toCurrency = currencyByCode('EUR');
    _init();
  }

  Future<void> _init() async {
    // 1. Try cached rates first.
    final cached = await CurrencyService.loadCachedRates();
    if (cached != null) {
      _rates = cached;
      _lastUpdated = await CurrencyService.loadLastUpdated();
      _isLoading = false;
      notifyListeners();
    }

    // 2. Fetch fresh rates in background.
    await refreshRates();
  }

  // ─── Public API ────────────────────────────────────────────────────

  /// Sets the source currency and recalculates.
  void setFromCurrency(CurrencyModel currency) {
    _fromCurrency = currency;
    _recalculate();
  }

  /// Sets the target currency and recalculates.
  void setToCurrency(CurrencyModel currency) {
    _toCurrency = currency;
    _recalculate();
  }

  /// Sanitises [value] and recomputes the result.
  void setInput(String value) {
    _inputValue = Formatters.formatInput(value);
    _recalculate();
  }

  /// Swaps source and target currencies, then recalculates.
  void swap() {
    final temp = _fromCurrency;
    _fromCurrency = _toCurrency;
    _toCurrency = temp;
    _recalculate();
  }

  /// Fetches live rates from Frankfurter.app.
  ///
  /// Falls back to cached rates, then to hardcoded fallback rates.
  /// Sets [_error] on failure and [notifyListeners].
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
      _recalculate();
    } catch (_) {
      // Try cached again (may have been loaded on init but lost).
      final cached = await CurrencyService.loadCachedRates();
      if (cached != null && cached.isNotEmpty) {
        _rates = cached;
        _lastUpdated = await CurrencyService.loadLastUpdated();
      } else if (_rates.isEmpty) {
        // Last resort: hardcoded fallback.
        _rates = CurrencyService.getFallbackRates();
        _error = 'Could not fetch rates. Using approximate rates.';
      }
      _isLoading = false;
      _recalculate();
    }
  }

  /// Formats the source amount with the source currency symbol.
  String get formattedInputDisplay {
    if (_inputValue.isEmpty) return '';
    final currency = _fromCurrency;
    if (currency == null) return _inputValue;
    return '${currency.symbol} $_inputValue';
  }

  /// Returns the rate of the source currency relative to USD.
  double? get sourceRate {
    if (_fromCurrency == null) return null;
    return _rates[_fromCurrency!.code];
  }

  /// Returns the rate of the target currency relative to USD.
  double? get targetRate {
    if (_toCurrency == null) return null;
    return _rates[_toCurrency!.code];
  }

  // ─── Private ───────────────────────────────────────────────────────

  void _recalculate() {
    if (_inputValue.isEmpty) {
      _resultDisplay = '\u2014';
      notifyListeners();
      return;
    }

    final amount = double.tryParse(_inputValue);
    if (amount == null || amount.isNaN || amount.isInfinite) {
      _resultDisplay = 'Invalid';
      notifyListeners();
      return;
    }

    if (!isReady) {
      _resultDisplay = '\u2014';
      notifyListeners();
      return;
    }

    final fromRate = _rates[_fromCurrency!.code]!;
    final toRate = _rates[_toCurrency!.code]!;
    final result = CurrencyService.convert(amount, fromRate, toRate);

    _resultDisplay = Formatters.formatResult(result);
    notifyListeners();
  }
}
