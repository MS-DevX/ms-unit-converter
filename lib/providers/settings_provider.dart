library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/ui_constants.dart';
import '../utils/formatters.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  DecimalPrecision decimalPrecision = DecimalPrecision.auto;

  bool isCosmicTheme = false;

  String userName = '';

  bool isLoaded = false;

  static const String userNameStorageKey = 'user_profile_name';

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

  /// Calculates dynamic time-based greeting for local profile (e.g. Good Afternoon, Shahzad 👋)
  String getGreeting() {
    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    final name = userName.trim();
    if (name.isNotEmpty) {
      return '$timeGreeting, $name 👋';
    }
    return '$timeGreeting 👋';
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeMode = _modeFromString(
        prefs.getString(AppConstants.themeModeStorageKey),
      );

      final precisionIndex =
          prefs.getInt(AppConstants.decimalPrecisionKey) ?? 0;
      decimalPrecision = DecimalPrecision.values[precisionIndex];
      Formatters.setPrecision(decimalPrecision);

      isCosmicTheme =
          prefs.getBool(CosmicUIConstants.cosmicThemeStorageKey) ?? false;

      userName = prefs.getString(userNameStorageKey) ?? '';
    } catch (_) {
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setUserName(String name) async {
    userName = name.trim();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userNameStorageKey, userName);
    } catch (_) {}
  }

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

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.themeModeStorageKey,
        _modeToString(mode),
      );
    } catch (_) {}
  }

  Future<void> setDecimalPrecision(DecimalPrecision precision) async {
    decimalPrecision = precision;
    Formatters.setPrecision(precision);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppConstants.decimalPrecisionKey, precision.index);
    } catch (_) {}
  }

  Future<void> toggleCosmicTheme() async {
    isCosmicTheme = !isCosmicTheme;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        CosmicUIConstants.cosmicThemeStorageKey,
        isCosmicTheme,
      );
    } catch (_) {}
  }
}
