import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:unit_converter/core/constants.dart';
import 'package:unit_converter/models/history_entry.dart';

/// Persistent storage layer for conversion history.
///
/// Uses [SharedPreferences] to store a capped JSON list of
/// [HistoryEntry] instances. All methods are safe — errors
/// are caught internally and return sensible defaults.
class HistoryService {
  HistoryService._();

  /// Saves [entry] to the top of the history list.
  ///
  /// If the list already contains [AppConstants.maxHistoryEntries]
  /// entries, the oldest one is discarded.
  static Future<void> saveEntry(HistoryEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final entries = _loadRawSync(prefs);
      entries.insert(0, jsonEncode(entry.toJson()));
      while (entries.length > AppConstants.maxHistoryEntries) {
        entries.removeLast();
      }
      await prefs.setStringList(AppConstants.historyStorageKey, entries);
    } catch (_) {
      // Silently degrade — history is best-effort.
    }
  }

  /// Returns all persisted history entries, newest first.
  ///
  /// Corrupted entries are silently skipped. Returns an empty
  /// list when no history exists or when an error occurs.
  static Future<List<HistoryEntry>> getEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = _loadRawSync(prefs);
      final List<HistoryEntry> result = [];
      for (final jsonStr in raw) {
        try {
          final map = jsonDecode(jsonStr) as Map<String, dynamic>;
          result.add(HistoryEntry.fromJson(map));
        } catch (_) {
          // Skip corrupt entries.
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  /// Removes all conversion history entries.
  ///
  /// Only the history storage key is affected; other
  /// preferences (theme, premium status) are preserved.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.historyStorageKey);
    } catch (_) {
      // Silently degrade.
    }
  }

  /// Loads the raw JSON string list from prefs.
  static List<String> _loadRawSync(SharedPreferences prefs) {
    try {
      final list = prefs.getStringList(AppConstants.historyStorageKey);
      return list != null ? List<String>.from(list) : [];
    } catch (_) {
      return [];
    }
  }
}
