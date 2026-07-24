/// Provider that manages UI-facing category usage statistics.
library;

import 'package:flutter/foundation.dart';
import '../data/units_data.dart';
import '../services/usage_service.dart';

class UsageProvider extends ChangeNotifier {
  final Map<UnitCategory, int> _usageCounts = {};

  /// Returns unmodifiable map of category usage counts.
  Map<UnitCategory, int> get usageCounts => Map.unmodifiable(_usageCounts);

  /// Returns `true` if any category has been used at least once.
  bool get hasUsageData => _usageCounts.values.any((count) => count > 0);

  /// Loads persisted usage statistics from storage.
  Future<void> loadUsage() async {
    try {
      final rawMap = await UsageService.getUsageMap();
      _usageCounts.clear();

      for (final category in UnitCategory.values) {
        final count = rawMap[category.name] ?? 0;
        if (count > 0) {
          _usageCounts[category] = count;
        }
      }
    } catch (_) {
    } finally {
      notifyListeners();
    }
  }

  /// Increments usage count for [category] and persists changes.
  Future<void> trackCategoryUsage(UnitCategory category) async {
    final current = _usageCounts[category] ?? 0;
    _usageCounts[category] = current + 1;
    notifyListeners();

    try {
      final stringMap = _usageCounts.map((key, val) => MapEntry(key.name, val));
      await UsageService.saveUsageMap(stringMap);
    } catch (_) {}
  }

  /// Gets top used categories sorted by usage count descending.
  List<MapEntry<UnitCategory, int>> getTopCategories({int limit = 4}) {
    final entries = _usageCounts.entries
        .where((e) => e.value > 0)
        .toList();

    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  /// Clears all usage counts from memory and storage.
  Future<void> resetUsage() async {
    _usageCounts.clear();
    notifyListeners();

    try {
      await UsageService.clearUsage();
    } catch (_) {}
  }
}
