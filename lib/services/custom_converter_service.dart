/// CRUD persistence for custom converters.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/custom_converter.dart';

/// Service layer for [CustomConverter] persistence via SharedPreferences.
class CustomConverterService {
  CustomConverterService._();

  static const String _key = 'custom_converters_v1';

  /// Returns all stored custom converters.
  static Future<List<CustomConverter>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final result = <CustomConverter>[];
    for (final s in raw) {
      try {
        result.add(CustomConverter.fromJson(
            jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    return result;
  }

  /// Adds or updates a converter (matched by [id]).
  static Future<void> save(CustomConverter converter) async {
    final all = await getAll();
    final idx = all.indexWhere((c) => c.id == converter.id);
    if (idx >= 0) {
      all[idx] = converter;
    } else {
      all.add(converter);
    }
    await _persist(all);
  }

  /// Deletes the converter with [id].
  static Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((c) => c.id == id);
    await _persist(all);
  }

  /// Clears all custom converters.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _persist(List<CustomConverter> converters) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = converters.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
