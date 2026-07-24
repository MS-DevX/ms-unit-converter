/// Pure service for managing category usage counts in local storage.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UsageService {
  UsageService._();

  static const String _usageKey = 'category_usage_counts';

  /// Reads local usage map from [SharedPreferences].
  static Future<Map<String, int>> getUsageMap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_usageKey);
      if (rawJson == null || rawJson.isEmpty) return {};

      final Map<String, dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((key, value) => MapEntry(key, (value as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  /// Saves [usageMap] to [SharedPreferences].
  static Future<void> saveUsageMap(Map<String, int> usageMap) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = jsonEncode(usageMap);
      await prefs.setString(_usageKey, rawJson);
    } catch (_) {}
  }

  /// Clears all usage history from storage.
  static Future<void> clearUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usageKey);
    } catch (_) {}
  }
}
