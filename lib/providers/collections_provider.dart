/// Provider that manages collection state (pin/unpin) for the home screen.
library;

import 'package:flutter/foundation.dart';
import '../data/collections_data.dart';
import '../services/collections_service.dart';

/// Exposes [allCollections], [pinnedCollections], and [togglePin] to the UI.
///
/// Pinned state is persisted via [CollectionsService] — fully offline,
/// no account required, no data leaves the device.
class CollectionsProvider extends ChangeNotifier {
  Set<String> _pinnedIds = {};
  bool _isLoaded = false;

  /// All predefined collections in display order.
  List<Collection> get allCollections => predefinedCollections;

  /// Collections the user has pinned, in original definition order.
  List<Collection> get pinnedCollections => predefinedCollections
      .where((c) => _pinnedIds.contains(c.id))
      .toList();

  /// Returns `true` if the collection with [id] is pinned.
  bool isPinned(String id) => _pinnedIds.contains(id);

  /// Whether the initial load from SharedPreferences has completed.
  bool get isLoaded => _isLoaded;

  /// Loads persisted pin state from storage. Call once at startup.
  Future<void> loadCollections() async {
    try {
      _pinnedIds = await CollectionsService.getPinnedIds();
    } catch (_) {
      _pinnedIds = {};
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Pins the collection if unpinned, unpins it if pinned.
  Future<void> togglePin(String collectionId) async {
    if (_pinnedIds.contains(collectionId)) {
      _pinnedIds.remove(collectionId);
    } else {
      _pinnedIds.add(collectionId);
    }
    notifyListeners();
    try {
      await CollectionsService.savePinnedIds(_pinnedIds);
    } catch (_) {}
  }

  /// Removes all pinned collections.
  Future<void> clearPinned() async {
    _pinnedIds.clear();
    notifyListeners();
    try {
      await CollectionsService.clearAll();
    } catch (_) {}
  }
}
