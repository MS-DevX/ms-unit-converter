/// Persistence service for user learning state in STEM Academy.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages bookmarked formula IDs and recently viewed lesson IDs.
class AcademyUserService {
  static const String _bookmarksKey = 'academy_bookmarked_formula_ids';
  static const String _recentKey = 'academy_recently_viewed_formula_ids';
  static const int _maxRecentItems = 50;

  /// Loads bookmarked formula IDs.
  static Future<Set<int>> loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_bookmarksKey) ?? [];
      return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
    } catch (e) {
      debugPrint('[AcademyUserService] Error loading bookmarks: $e');
      return {};
    }
  }

  /// Saves bookmarked formula IDs.
  static Future<void> saveBookmarks(Set<int> bookmarkIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_bookmarksKey, bookmarkIds.map((e) => e.toString()).toList());
    } catch (e) {
      debugPrint('[AcademyUserService] Error saving bookmarks: $e');
    }
  }

  /// Loads recently viewed formula IDs.
  static Future<List<int>> loadRecentlyViewed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_recentKey) ?? [];
      return list.map((e) => int.tryParse(e)).whereType<int>().toList();
    } catch (e) {
      debugPrint('[AcademyUserService] Error loading recently viewed: $e');
      return [];
    }
  }

  /// Adds a formula ID to recently viewed (newest first, max 50).
  static Future<List<int>> addRecentlyViewed(int formulaId) async {
    try {
      final current = await loadRecentlyViewed();
      current.remove(formulaId);
      current.insert(0, formulaId);
      if (current.length > _maxRecentItems) {
        current.removeRange(_maxRecentItems, current.length);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentKey, current.map((e) => e.toString()).toList());
      return current;
    } catch (e) {
      debugPrint('[AcademyUserService] Error saving recently viewed: $e');
      return [];
    }
  }
}
