/// Provider for user-created custom converter groups.
library;

import 'package:flutter/foundation.dart';
import '../models/custom_converter.dart';
import '../services/custom_converter_service.dart';

/// Exposes the list of [CustomConverter] objects and CRUD operations.
class CustomConverterProvider extends ChangeNotifier {
  List<CustomConverter> _converters = [];

  /// All user-created custom converters.
  List<CustomConverter> get converters => List.unmodifiable(_converters);

  /// Returns the converter with [id], or null.
  CustomConverter? find(String id) {
    try {
      return _converters.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Loads persisted converters from storage.
  Future<void> load() async {
    try {
      _converters = await CustomConverterService.getAll();
    } catch (_) {
      _converters = [];
    }
    notifyListeners();
  }

  /// Creates and saves a new [CustomConverter].
  Future<void> create({
    required String name,
    required String emoji,
    required List<CustomUnit> units,
  }) async {
    final converter = CustomConverter(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      emoji: emoji,
      units: units,
    );
    _converters.add(converter);
    notifyListeners();
    try {
      await CustomConverterService.save(converter);
    } catch (_) {}
  }

  /// Updates an existing converter by [id].
  Future<void> update(CustomConverter updated) async {
    final idx = _converters.indexWhere((c) => c.id == updated.id);
    if (idx < 0) return;
    _converters[idx] = updated;
    notifyListeners();
    try {
      await CustomConverterService.save(updated);
    } catch (_) {}
  }

  /// Deletes the converter with [id].
  Future<void> delete(String id) async {
    _converters.removeWhere((c) => c.id == id);
    notifyListeners();
    try {
      await CustomConverterService.delete(id);
    } catch (_) {}
  }
}
