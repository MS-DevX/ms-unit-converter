import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../core/ui_constants.dart';
import '../utils/formatters.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  DecimalPrecision decimalPrecision = DecimalPrecision.auto;

  bool isCosmicTheme = false;

  String userName = '';

  String userAvatarPath = '';

  bool isLoaded = false;

  static const String userNameStorageKey = 'user_profile_name';
  static const String userAvatarPathStorageKey = 'user_profile_avatar_path';

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

  /// Extracts user initials for fallback default avatar representation.
  String getInitials() {
    final name = userName.trim();
    if (name.isEmpty) return 'U';

    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      themeMode = _modeFromString(prefs.getString(AppConstants.themeModeStorageKey));
      final precisionIndex = prefs.getInt(AppConstants.decimalPrecisionKey) ?? 0;
      if (precisionIndex >= 0 && precisionIndex < DecimalPrecision.values.length) {
        decimalPrecision = DecimalPrecision.values[precisionIndex];
      }
      Formatters.setPrecision(decimalPrecision);
      isCosmicTheme = prefs.getBool(CosmicUIConstants.cosmicThemeStorageKey) ?? false;
      userName = prefs.getString(userNameStorageKey) ?? '';
      
      final storedPath = prefs.getString(userAvatarPathStorageKey) ?? '';
      if (storedPath.isNotEmpty && File(storedPath).existsSync()) {
        userAvatarPath = storedPath;
      } else {
        userAvatarPath = '';
      }

      isLoaded = true;
      notifyListeners();
    } catch (_) {
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

  /// Saves the user avatar permanently to Application Documents Directory
  /// ensuring high resolution preservation and long-term persistence across OS cache purges.
  Future<void> setUserAvatarPath(String sourcePath) async {
    final cleanPath = sourcePath.trim();
    if (cleanPath.isEmpty) {
      await removeUserAvatar();
      return;
    }

    try {
      final sourceFile = File(cleanPath);
      if (!await sourceFile.exists()) {
        debugPrint('[SettingsProvider] Source avatar file missing: $cleanPath');
        return;
      }

      final appDocDir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory(path.join(appDocDir.path, 'profile'));
      if (!await avatarDir.exists()) {
        await avatarDir.create(recursive: true);
      }

      // Delete previous avatar file if exists
      if (userAvatarPath.isNotEmpty && userAvatarPath != cleanPath) {
        try {
          final oldFile = File(userAvatarPath);
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
          FileImage(oldFile).evict();
        } catch (e) {
          debugPrint('[SettingsProvider] Error cleaning old avatar file: $e');
        }
      }

      // Determine extension and target permanent destination
      var ext = path.extension(cleanPath);
      if (ext.isEmpty) ext = '.jpg';

      final destPath = path.join(
        avatarDir.path,
        'avatar_${DateTime.now().millisecondsSinceEpoch}$ext',
      );

      final destFile = await sourceFile.copy(destPath);

      // Evict ImageCache for old and new file images
      FileImage(destFile).evict();

      userAvatarPath = destFile.path;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(userAvatarPathStorageKey, userAvatarPath);
      debugPrint('[SettingsProvider] Permanent user avatar saved: $userAvatarPath');
    } catch (e) {
      debugPrint('[SettingsProvider] Error saving permanent avatar: $e');
      userAvatarPath = cleanPath;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(userAvatarPathStorageKey, userAvatarPath);
      } catch (_) {}
    }
  }

  /// Removes the current user avatar and deletes its permanent file from storage.
  Future<void> removeUserAvatar() async {
    if (userAvatarPath.isNotEmpty) {
      try {
        final file = File(userAvatarPath);
        if (await file.exists()) {
          await file.delete();
        }
        FileImage(file).evict();
      } catch (e) {
        debugPrint('[SettingsProvider] Error deleting avatar file: $e');
      }
    }
    userAvatarPath = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(userAvatarPathStorageKey);
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
