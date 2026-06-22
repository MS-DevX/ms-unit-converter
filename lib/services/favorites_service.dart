/// Persistent storage layer for favorite categories.
///
/// Uses [SharedPreferences] to store a JSON-serialisable list of
/// integer indices (each corresponding to [UnitCategory.index]).
/// All methods are safe — errors are caught internally and return
/// sensible defaults.
library;

import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

/// Manages read/write of the user's favourite conversion categories.
///
/// Favourites are stored locally only — no cloud, no account, no
/// personal data leaves the device.
class FavoritesService {
  FavoritesService._();

  /// Returns the stored set of category indices, or an empty set.
  static Future<Set<int>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(AppConstants.favoritesStorageKey);
      if (raw == null) return {};
      return raw.map((e) => int.parse(e)).toSet();
    } catch (_) {
      return {};
    }
  }

  /// Persists [favorites] as a list of integer-index strings.
  static Future<void> saveFavorites(Set<int> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        AppConstants.favoritesStorageKey,
        favorites.map((e) => e.toString()).toList(),
      );
    } catch (_) {
      // Silently degrade — storage is best-effort.
    }
  }

  /// Removes all stored favourites.
  ///
  /// Other preferences (theme, history, premium) are unaffected.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.favoritesStorageKey);
    } catch (_) {
      // Silently degrade.
    }
  }
}
