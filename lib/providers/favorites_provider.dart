/// Provider that wraps [FavoritesService] and exposes UI-facing state
/// for the user's favourite conversion categories.
///
/// Favorites are stored locally via [SharedPreferences] — no account,
/// no cloud sync, no personal data collected.
library;

import 'package:flutter/foundation.dart';

import '../data/units_data.dart';
import '../services/favorites_service.dart';

/// Exposes [favorites] and [isFavorite] to the widget tree.
///
/// Call [loadFavorites] once at startup, then use [toggleFavorite] and
/// [clearFavorites] to mutate state.
class FavoritesProvider extends ChangeNotifier {
  Set<UnitCategory> _favorites = {};

  /// Read-only snapshot of the current favourite categories.
  Set<UnitCategory> get favorites => Set.unmodifiable(_favorites);

  /// Loads persisted favourites from [FavoritesService].
  Future<void> loadFavorites() async {
    final indices = await FavoritesService.getFavorites();
    _favorites = indices.map((i) => UnitCategory.values[i]).toSet();
    notifyListeners();
  }

  /// Returns `true` when [category] is in the user's favourites.
  bool isFavorite(UnitCategory category) => _favorites.contains(category);

  /// Adds [category] if absent, removes it if present.
  ///
  /// Persists the updated set on every call. Storage failure does not
  /// revert the in-memory state.
  Future<void> toggleFavorite(UnitCategory category) async {
    if (_favorites.contains(category)) {
      _favorites.remove(category);
    } else {
      _favorites.add(category);
    }
    notifyListeners();

    try {
      await FavoritesService.saveFavorites(
        _favorites.map((c) => c.index).toSet(),
      );
    } catch (_) {
      // Storage failure — in-memory list is already updated.
    }
  }

  /// Removes all favourites from memory and storage.
  Future<void> clearFavorites() async {
    _favorites.clear();
    notifyListeners();

    try {
      await FavoritesService.clearAll();
    } catch (_) {
      // Storage failure — in-memory set is already cleared.
    }
  }
}
