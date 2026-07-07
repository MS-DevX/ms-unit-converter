import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/providers/settings_provider.dart';
import 'package:unit_converter/utils/formatters.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsProvider', () {
    test('initial state is system / auto', () {
      final settings = SettingsProvider();
      expect(settings.isLoaded, false);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.decimalPrecision, DecimalPrecision.auto);
    });

    test('loadSettings sets isLoaded true and uses defaults when empty', () async {
      final settings = SettingsProvider();
      expect(settings.isLoaded, false);
      await settings.loadSettings();
      expect(settings.isLoaded, true);
      expect(settings.themeMode, ThemeMode.system);
    });

    test('loadSettings reads themeMode from storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeModeStorageKey, 'dark');

      final settings = SettingsProvider();
      await settings.loadSettings();
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('toggleTheme cycles through system → light → dark → system', () async {
      final settings = SettingsProvider();

      expect(settings.themeMode, ThemeMode.system);
      await settings.toggleTheme();
      expect(settings.themeMode, ThemeMode.light);
      await settings.toggleTheme();
      expect(settings.themeMode, ThemeMode.dark);
      await settings.toggleTheme();
      expect(settings.themeMode, ThemeMode.system);
    });

    test('setDecimalPrecision persists and updates formatter', () async {
      final settings = SettingsProvider();
      await settings.setDecimalPrecision(DecimalPrecision.two);
      expect(settings.decimalPrecision, DecimalPrecision.two);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt(AppConstants.decimalPrecisionKey),
        DecimalPrecision.two.index,
      );
    });
  });

  group('AdCooldown', () {
    test('adCooldownMinutes is 5', () {
      expect(AppConstants.adCooldownMinutes, 5);
    });

    test('splashDurationMs is 1500', () {
      expect(AppConstants.splashDurationMs, 1500);
    });

    test('cooldown in milliseconds equals 5 minutes', () {
      expect(AppConstants.adCooldownMinutes * 60000, 300000);
    });
  });
}
