/// Persists the ordered list of pinned converter categories.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Service layer for pinned converter persistence.
///
/// Order is preserved as a comma-separated list of category names.
class PinnedService {
  PinnedService._();

  static const String _key = 'pinned_converters_v1';

  /// Returns ordered list of pinned category names.
  static Future<List<String>> getPinned() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '';
    if (raw.isEmpty) return [];
    return raw.split(',').where((s) => s.isNotEmpty).toList();
  }

  /// Persists [categoryNames] in order.
  static Future<void> savePinned(List<String> categoryNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, categoryNames.join(','));
  }

  /// Clears all pinned converters.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
