import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/services/favorites_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FavoritesService', () {
    test('getFavorites returns empty set initially', () async {
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('saveFavorites and getFavorites round-trip', () async {
      await FavoritesService.saveFavorites({1, 3, 5});
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, {1, 3, 5});
    });

    test('saveFavorites preserves the exact set', () async {
      await FavoritesService.saveFavorites({0, 2, 4, 6});
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, {0, 2, 4, 6});
    });

    test('clearAll removes all favorites', () async {
      await FavoritesService.saveFavorites({0, 1, 2});
      await FavoritesService.clearAll();
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('clearAll preserves other preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('other_key', 'preserved');
      await FavoritesService.saveFavorites({3});
      await FavoritesService.clearAll();
      expect(prefs.getString('other_key'), 'preserved');
    });

    test('adding a favorite and removing it returns empty', () async {
      await FavoritesService.saveFavorites({7});
      var favorites = await FavoritesService.getFavorites();
      expect(favorites, {7});

      await FavoritesService.saveFavorites({});
      favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });

    test('corrupted data returns empty set', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.favoritesStorageKey, [
        'abc',
        'def',
      ]);
      final favorites = await FavoritesService.getFavorites();
      expect(favorites, isEmpty);
    });
  });
}
