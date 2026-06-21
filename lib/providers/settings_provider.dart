/// Provider controlling theme mode and premium (remove-ads) status.
///
/// Persists all settings through [SharedPreferences] and exposes them
/// via [ChangeNotifier] so the widget tree rebuilds automatically on
/// change. All storage operations are wrapped in try/catch to ensure
/// the app never crashes due to a storage failure.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../utils/formatters.dart';

/// Manages persistent user settings: [themeMode], [isPremium], and
/// [decimalPrecision].
///
/// Call [loadSettings] once at app startup (before rendering the first
/// frame) and then use [setThemeMode], [toggleTheme], and [setPremium]
/// to mutate state.
class SettingsProvider extends ChangeNotifier {
  /// Current [ThemeMode]; defaults to [ThemeMode.system] (follows device).
  ThemeMode themeMode = ThemeMode.system;

  /// Whether the user has purchased the "Remove Ads" upgrade.
  bool isPremium = false;

  /// Current decimal precision; defaults to [DecimalPrecision.auto].
  DecimalPrecision decimalPrecision = DecimalPrecision.auto;

  /// Whether [loadSettings] has completed at least once.
  ///
  /// Use this flag in the UI to defer rendering until defaults are
  /// replaced with the persisted values.
  bool isLoaded = false;

  // ─── Internal helpers ─────────────────────────────────────────────────────

  /// Maps a stored string back to a [ThemeMode].
  ThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  /// Maps a [ThemeMode] to the string stored in [SharedPreferences].
  String _modeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Reads all persisted settings from [SharedPreferences] and populates
  /// [themeMode], [isPremium], and [decimalPrecision].
  ///
  /// Sets [isLoaded] to `true` when done and calls [notifyListeners].
  /// Safe to call multiple times; subsequent calls simply re-sync state.
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeMode = _modeFromString(
        prefs.getString(AppConstants.themeModeStorageKey),
      );
      isPremium = prefs.getBool(AppConstants.premiumStorageKey) ?? false;

      final precisionIndex =
          prefs.getInt(AppConstants.decimalPrecisionKey) ?? 0;
      decimalPrecision = DecimalPrecision.values[precisionIndex];
      Formatters.setPrecision(decimalPrecision);
    } catch (_) {
      // Degrade gracefully — defaults remain in place.
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  /// Cycles the theme: system → light → dark → system.
  ///
  /// Persists the new mode and calls [notifyListeners].
  Future<void> toggleTheme() async {
    final ThemeMode next;
    switch (themeMode) {
      case ThemeMode.system:
        next = ThemeMode.light;
      case ThemeMode.light:
        next = ThemeMode.dark;
      case ThemeMode.dark:
        next = ThemeMode.system;
    }
    await setThemeMode(next);
  }

  /// Sets [themeMode] to [mode], persists it, and calls [notifyListeners].
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.themeModeStorageKey,
        _modeToString(mode),
      );
    } catch (_) {
      // Storage failure does not revert in-memory state.
    }
  }

  /// Sets [isPremium] to [value], persists it, and calls [notifyListeners].
  Future<void> setPremium(bool value) async {
    isPremium = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.premiumStorageKey, value);
    } catch (_) {
      // Storage failure does not revert in-memory state.
    }
  }

  /// Sets [decimalPrecision] to [precision], persists it, updates the
  /// global formatter, and calls [notifyListeners].
  Future<void> setDecimalPrecision(DecimalPrecision precision) async {
    decimalPrecision = precision;
    Formatters.setPrecision(precision);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.decimalPrecisionKey, precision.index);
    } catch (_) {
      // Storage failure does not revert in-memory state.
    }
  }
}
