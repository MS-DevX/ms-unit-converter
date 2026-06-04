/// Provider that wraps [HistoryService] and exposes UI-facing history state.
///
/// Manages an in-memory list of [HistoryEntry] objects that stays in sync
/// with [SharedPreferences] storage. All service calls are wrapped in
/// try/catch blocks so the app never crashes from a storage error.
library;

import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../models/history_entry.dart';
import '../services/history_service.dart';

/// Exposes [entries] and [isLoading] to the widget tree.
///
/// Call [loadHistory] once at startup, then use [addEntry] and
/// [clearHistory] to mutate state. [refresh] is a convenience alias
/// for [loadHistory].
class HistoryProvider extends ChangeNotifier {
  /// In-memory list of conversion history entries, newest first.
  List<HistoryEntry> entries = [];

  /// `true` while [loadHistory] is in progress.
  bool isLoading = false;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Fetches all persisted entries from [HistoryService] and updates state.
  ///
  /// Sets [isLoading] to `true` before the fetch and `false` after,
  /// notifying listeners at both transitions. On failure the previous
  /// in-memory list is preserved.
  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();

    try {
      final loaded = await HistoryService.getEntries();
      entries = loaded;
    } catch (_) {
      // Keep previous entries on error — never crash.
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Persists [entry] via [HistoryService] and inserts it at the top of
  /// [entries], enforcing [AppConstants.maxHistoryEntries].
  ///
  /// On storage failure the local list is still updated optimistically so
  /// the UI remains responsive.
  Future<void> addEntry(HistoryEntry entry) async {
    try {
      await HistoryService.saveEntry(entry);
    } catch (_) {
      // Storage failure — continue with in-memory update.
    }

    entries.insert(0, entry);
    while (entries.length > AppConstants.maxHistoryEntries) {
      entries.removeLast();
    }
    notifyListeners();
  }

  /// Deletes all history from [HistoryService] and clears the local list.
  Future<void> clearHistory() async {
    try {
      await HistoryService.clearAll();
    } catch (_) {
      // Storage failure — still clear the in-memory list.
    }

    entries.clear();
    notifyListeners();
  }

  /// Removes the entry with the given [id] from both memory and storage.
  ///
  /// The remaining entries are re-persisted by clearing storage and
  /// re-saving each entry in order. On any storage failure the in-memory
  /// list is still updated so the UI stays consistent.
  Future<void> removeEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    notifyListeners();

    // Re-persist the trimmed list.
    try {
      await HistoryService.clearAll();
      // Re-save in reverse order so newest stays first after each insert.
      for (final entry in entries.reversed) {
        await HistoryService.saveEntry(entry);
      }
    } catch (_) {
      // Storage failure — in-memory list is already updated.
    }
  }

  /// Convenience method that delegates to [loadHistory].
  Future<void> refresh() => loadHistory();
}
