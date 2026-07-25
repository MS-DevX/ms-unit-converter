/// Provider for the user's pinned converter categories.
library;

import 'package:flutter/foundation.dart';
import '../data/units_data.dart';
import '../services/pinned_service.dart';

/// Exposes the ordered list of pinned [UnitCategory] values and
/// mutation methods [pin], [unpin], [reorder].
///
/// Drag-and-drop reorder is supported via [reorder].
/// All state is persisted offline via [PinnedService].
class PinnedProvider extends ChangeNotifier {
  List<UnitCategory> _pinned = [];

  /// Ordered list of pinned categories.
  List<UnitCategory> get pinned => List.unmodifiable(_pinned);

  /// Returns `true` if [category] is currently pinned.
  bool isPinned(UnitCategory category) => _pinned.contains(category);

  /// Loads persisted pinned list from storage. Call once at startup.
  Future<void> loadPinned() async {
    try {
      final names = await PinnedService.getPinned();
      _pinned = names
          .map((name) {
            try {
              return UnitCategory.values.firstWhere(
                (c) => c.name == name,
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<UnitCategory>()
          .toList();
    } catch (_) {
      _pinned = [];
    }
    notifyListeners();
  }

  /// Pins [category] at the end of the list (if not already pinned).
  Future<void> pin(UnitCategory category) async {
    if (_pinned.contains(category)) return;
    _pinned.add(category);
    notifyListeners();
    await _persist();
  }

  /// Removes [category] from the pinned list.
  Future<void> unpin(UnitCategory category) async {
    _pinned.remove(category);
    notifyListeners();
    await _persist();
  }

  /// Moves an item from [oldIndex] to [newIndex] (ReorderableListView semantics).
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _pinned.removeAt(oldIndex);
    _pinned.insert(newIndex, item);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await PinnedService.savePinned(_pinned.map((c) => c.name).toList());
    } catch (_) {}
  }
}
