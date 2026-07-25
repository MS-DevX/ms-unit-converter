/// Persists the set of pinned collection IDs to SharedPreferences.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Service layer for pinned collection persistence.
///
/// Data is stored as a comma-separated string under [_key].
/// All operations are offline — no network required.
class CollectionsService {
  CollectionsService._();

  static const String _key = 'pinned_collection_ids_v1';

  /// Returns the set of currently pinned collection IDs.
  static Future<Set<String>> getPinnedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '';
    if (raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  /// Persists [ids] as the full set of pinned collection IDs.
  static Future<void> savePinnedIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, ids.join(','));
  }

  /// Clears all pinned collections.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
