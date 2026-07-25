/// Provider managing home screen layout section ordering and visibility.
library;

import 'package:flutter/foundation.dart';
import '../services/home_layout_service.dart';

class HomeLayoutProvider extends ChangeNotifier {
  List<HomeSectionConfig> _sections = [];

  List<HomeSectionConfig> get sections => List.unmodifiable(_sections);

  Future<void> load() async {
    try {
      _sections = await HomeLayoutService.getSections();
    } catch (_) {
      _sections = HomeLayoutService.defaultSections;
    }
    notifyListeners();
  }

  Future<void> toggleSection(String id) async {
    final idx = _sections.indexWhere((s) => s.id == id);
    if (idx < 0) return;
    _sections[idx] = _sections[idx].copyWith(isVisible: !_sections[idx].isVisible);
    notifyListeners();
    await _persist();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _sections.removeAt(oldIndex);
    _sections.insert(newIndex, item);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await HomeLayoutService.saveSections(_sections);
    } catch (_) {}
  }
}
