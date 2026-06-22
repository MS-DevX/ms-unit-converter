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
    test('initial state is false / system / auto', () {
      final settings = SettingsProvider();
      expect(settings.isPremium, false);
      expect(settings.isLoaded, false);
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.decimalPrecision, DecimalPrecision.auto);
    });

    test(
      'loadSettings sets isLoaded true and uses defaults when empty',
      () async {
        final settings = SettingsProvider();
        expect(settings.isLoaded, false);
        await settings.loadSettings();
        expect(settings.isLoaded, true);
        expect(settings.isPremium, false);
        expect(settings.themeMode, ThemeMode.system);
      },
    );

    test('loadSettings reads premium flag from storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.premiumStorageKey, true);

      final settings = SettingsProvider();
      await settings.loadSettings();
      expect(settings.isPremium, true);
      expect(settings.isLoaded, true);
    });

    test('loadSettings reads themeMode from storage', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.themeModeStorageKey, 'dark');

      final settings = SettingsProvider();
      await settings.loadSettings();
      expect(settings.themeMode, ThemeMode.dark);
    });

    test('setPremium updates in-memory state and notifies listeners', () async {
      final settings = SettingsProvider();
      int notifyCount = 0;
      settings.addListener(() => notifyCount++);

      await settings.setPremium(true);
      expect(settings.isPremium, true);
      expect(notifyCount, 1);

      // Verify it persists to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(AppConstants.premiumStorageKey), true);
    });

    test('setPremium false works correctly', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.premiumStorageKey, true);

      final settings = SettingsProvider();
      await settings.loadSettings();
      expect(settings.isPremium, true);

      await settings.setPremium(false);
      expect(settings.isPremium, false);
      final stored = await SharedPreferences.getInstance();
      expect(stored.getBool(AppConstants.premiumStorageKey), false);
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
    test('adCooldownHours is 4', () {
      expect(AppConstants.adCooldownHours, 4);
    });

    test('splashDurationMs is 1500', () {
      expect(AppConstants.splashDurationMs, 1500);
    });

    test('cooldown in milliseconds equals 4 hours', () {
      expect(AppConstants.adCooldownHours * 3600000, 14400000);
    });

    test('premiumStorageKey has correct value', () {
      expect(AppConstants.premiumStorageKey, 'is_premium');
    });
  });
}
