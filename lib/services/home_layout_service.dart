/// Persists home screen section layout preferences.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeSectionConfig {
  final String id;
  final String title;
  final bool isVisible;

  const HomeSectionConfig({
    required this.id,
    required this.title,
    this.isVisible = true,
  });

  HomeSectionConfig copyWith({bool? isVisible}) => HomeSectionConfig(
        id: id,
        title: title,
        isVisible: isVisible ?? this.isVisible,
      );

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'isVisible': isVisible};

  factory HomeSectionConfig.fromJson(Map<String, dynamic> json) => HomeSectionConfig(
        id: json['id'] as String,
        title: json['title'] as String,
        isVisible: json['isVisible'] as bool? ?? true,
      );
}

class HomeLayoutService {
  HomeLayoutService._();

  static const String _key = 'home_layout_config_v1';

  static const List<HomeSectionConfig> defaultSections = [
    HomeSectionConfig(id: 'insights', title: 'Conversion Insights'),
    HomeSectionConfig(id: 'collections', title: 'Curated Collections'),
    HomeSectionConfig(id: 'pinned', title: 'Pinned Converters'),
    HomeSectionConfig(id: 'frequently_used', title: 'Frequently Used'),
    HomeSectionConfig(id: 'categories', title: 'Category Bento Grid'),
    HomeSectionConfig(id: 'did_you_know', title: 'Did You Know (Educational)'),
    HomeSectionConfig(id: 'recent', title: 'Recent Conversions'),
  ];

  static Future<List<HomeSectionConfig>> getSections() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return List.from(defaultSections);
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      final saved = list.map((e) => HomeSectionConfig.fromJson(e as Map<String, dynamic>)).toList();
      final savedIds = saved.map((s) => s.id).toSet();
      for (final def in defaultSections) {
        if (!savedIds.contains(def.id)) {
          saved.add(def);
        }
      }
      return saved;
    } catch (_) {
      return List.from(defaultSections);
    }
  }

  static Future<void> saveSections(List<HomeSectionConfig> sections) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(sections.map((s) => s.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> clearSections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
