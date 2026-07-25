/// Data model for Unit Companion offline search results.
library;

import 'package:flutter/material.dart';

/// Categories of offline search results.
enum CompanionResultType {
  intent,
  guide,
  unit,
  category,
  definition,
  formula,
  currency,
  collection,
  customConverter,
  note,
  favorite,
  pinned,
  recent,
  fact,
}

/// Unified offline search result object.
class CompanionSearchResult {
  final String id;
  final CompanionResultType type;
  final String title;
  final String categoryName;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String? formula;
  final List<String> relatedUnits;
  final String? matchingSnippet;
  final double score;
  final VoidCallback onTap;

  const CompanionSearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.categoryName,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.formula,
    this.relatedUnits = const [],
    this.matchingSnippet,
    required this.score,
    required this.onTap,
  });

  /// Group display label and icon for section headers.
  static String groupTitle(CompanionResultType type) {
    switch (type) {
      case CompanionResultType.intent:
        return '🎯 Direct Smart Conversion';
      case CompanionResultType.guide:
        return '🧭 Measurement & Everyday Guide';
      case CompanionResultType.unit:
        return '📏 Units';
      case CompanionResultType.category:
        return '📂 Categories';
      case CompanionResultType.definition:
        return '📘 Unit Information & Definitions';
      case CompanionResultType.formula:
        return '🧮 Conversion Formulas';
      case CompanionResultType.currency:
        return '💱 Currency Database';
      case CompanionResultType.collection:
        return '📚 Curated Collections';
      case CompanionResultType.customConverter:
        return '📦 Custom Converters';
      case CompanionResultType.note:
        return '📝 Conversion Notes';
      case CompanionResultType.favorite:
        return '⭐ Favorites';
      case CompanionResultType.pinned:
        return '📌 Pinned Converters';
      case CompanionResultType.recent:
        return '🕒 Recent Conversions';
      case CompanionResultType.fact:
        return '💡 Did You Know?';
    }
  }
}
