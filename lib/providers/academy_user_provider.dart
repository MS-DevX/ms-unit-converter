/// ChangeNotifier provider managing STEM Academy user state (bookmarks, recently viewed, study progress).
library;

import 'package:flutter/material.dart';
import '../services/academy_user_service.dart';

/// Central provider for STEM Academy user learning state.
class AcademyUserProvider extends ChangeNotifier {
  Set<int> _bookmarkedIds = {};
  List<int> _recentlyViewedIds = [];
  bool _isLoaded = false;

  Set<int> get bookmarkedIds => _bookmarkedIds;
  List<int> get recentlyViewedIds => _recentlyViewedIds;
  bool get isLoaded => _isLoaded;

  /// Initializes user learning state from SharedPreferences.
  Future<void> load() async {
    if (_isLoaded) return;
    _bookmarkedIds = await AcademyUserService.loadBookmarks();
    _recentlyViewedIds = await AcademyUserService.loadRecentlyViewed();
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns true if the formula ID is bookmarked.
  bool isBookmarked(int formulaId) => _bookmarkedIds.contains(formulaId);

  /// Toggles bookmark state for a formula ID.
  Future<void> toggleBookmark(int formulaId) async {
    if (_bookmarkedIds.contains(formulaId)) {
      _bookmarkedIds.remove(formulaId);
    } else {
      _bookmarkedIds.add(formulaId);
    }
    notifyListeners();
    await AcademyUserService.saveBookmarks(_bookmarkedIds);
  }

  /// Records a formula as recently viewed.
  Future<void> recordViewed(int formulaId) async {
    _recentlyViewedIds.remove(formulaId);
    _recentlyViewedIds.insert(0, formulaId);
    if (_recentlyViewedIds.length > 50) {
      _recentlyViewedIds.removeRange(50, _recentlyViewedIds.length);
    }
    notifyListeners();
    await AcademyUserService.addRecentlyViewed(formulaId);
  }
}
