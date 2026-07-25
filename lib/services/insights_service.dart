/// Computes conversion insights from locally stored usage and history data.
///
/// No data is sent externally. All computation is in-memory, derived
/// from already-persisted [UsageProvider] and [HistoryProvider] data.
library;

import '../data/units_data.dart';
import '../models/history_entry.dart';

/// Aggregated stats shown on the home screen insights banner.
class ConversionInsights {
  /// Total conversions ever performed (from history).
  final int totalConversions;

  /// Display name of the most-used category, or null if no data.
  final String? favoriteCategoryName;

  /// Name of the most-used unit across all conversions, or null.
  final String? mostUsedUnit;

  /// Timestamp of the last conversion, or null.
  final DateTime? lastUsed;

  const ConversionInsights({
    required this.totalConversions,
    this.favoriteCategoryName,
    this.mostUsedUnit,
    this.lastUsed,
  });
}

/// Pure-computation service — no state, no I/O.
class InsightsService {
  InsightsService._();

  /// Derives [ConversionInsights] from [usageCounts] and [history].
  ///
  /// [usageCounts] — map of category → open count from [UsageProvider].
  /// [history] — full history list from [HistoryProvider].
  static ConversionInsights compute({
    required Map<UnitCategory, int> usageCounts,
    required List<HistoryEntry> history,
  }) {
    // Total conversions = total history entries
    final total = history.length;

    // Favorite category = highest usage count
    String? favCat;
    if (usageCounts.isNotEmpty) {
      final topEntry = usageCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b);
      favCat = topEntry.key.displayName;
    }

    // Most used unit = unit name appearing most in history (from + to)
    final unitFrequency = <String, int>{};
    for (final entry in history) {
      unitFrequency[entry.fromUnit] = (unitFrequency[entry.fromUnit] ?? 0) + 1;
      unitFrequency[entry.toUnit] = (unitFrequency[entry.toUnit] ?? 0) + 1;
    }
    String? mostUsed;
    if (unitFrequency.isNotEmpty) {
      mostUsed = unitFrequency.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // Last used = timestamp of most recent history entry
    DateTime? lastUsed;
    if (history.isNotEmpty) {
      lastUsed = history
          .map((e) => e.timestamp)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return ConversionInsights(
      totalConversions: total,
      favoriteCategoryName: favCat,
      mostUsedUnit: mostUsed,
      lastUsed: lastUsed,
    );
  }

  /// Returns a human-friendly relative time string for [dt].
  static String relativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
