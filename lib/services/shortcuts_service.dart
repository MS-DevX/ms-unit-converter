/// Manages dynamic app icon shortcuts via the quick_actions package.
///
/// Static shortcuts are declared in android/app/src/main/res/xml/shortcuts.xml.
/// Dynamic shortcuts update automatically based on recent usage — top 3
/// most-used categories replace the static shortcut set at runtime.
library;

import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';
import '../data/units_data.dart';

/// Manages static and dynamic app launcher shortcuts.
///
/// Call [init] once after app startup. Call [updateDynamicShortcuts]
/// whenever usage data changes.
class ShortcutsService {
  ShortcutsService._();

  static const QuickActions _quickActions = QuickActions();

  /// Shortcut type strings (must match static shortcuts.xml ids).
  static const String shortcutLength = 'shortcut_length';
  static const String shortcutWeight = 'shortcut_weight';
  static const String shortcutCurrency = 'shortcut_currency';
  static const String shortcutCompass = 'shortcut_compass';

  /// Callback invoked when a shortcut is tapped.
  ///
  /// [onShortcutTapped] receives the shortcut type string. Route to the
  /// appropriate screen based on the value.
  static void init({required void Function(String type) onShortcutTapped}) {
    try {
      _quickActions.initialize(onShortcutTapped);
    } catch (e) {
      debugPrint('ShortcutsService.init error: $e');
    }
  }

  /// Updates dynamic shortcuts based on [topCategories].
  ///
  /// Sets up to 3 dynamic shortcuts for the most-used categories.
  /// Complements the static shortcuts which are always visible.
  static Future<void> updateDynamicShortcuts(
      List<UnitCategory> topCategories) async {
    try {
      final items = <ShortcutItem>[];
      for (final cat in topCategories.take(3)) {
        items.add(ShortcutItem(
          type: 'dynamic_${cat.name}',
          localizedTitle: cat.displayName,
          icon: _iconNameFor(cat),
        ));
      }
      if (items.isNotEmpty) {
        await _quickActions.setShortcutItems(items);
      }
    } catch (e) {
      debugPrint('ShortcutsService.updateDynamicShortcuts error: $e');
    }
  }

  /// Maps a [UnitCategory] to an Android drawable resource name.
  ///
  /// The drawable must exist in android/app/src/main/res/drawable/.
  /// Falls back to 'ic_shortcut_default' for unmapped categories.
  static String _iconNameFor(UnitCategory cat) {
    return switch (cat) {
      UnitCategory.length => 'ic_shortcut_length',
      UnitCategory.weight => 'ic_shortcut_weight',
      UnitCategory.temperature => 'ic_shortcut_temperature',
      UnitCategory.area => 'ic_shortcut_area',
      UnitCategory.volume => 'ic_shortcut_volume',
      UnitCategory.speed => 'ic_shortcut_speed',
      UnitCategory.data => 'ic_shortcut_data',
      UnitCategory.time => 'ic_shortcut_time',
      UnitCategory.energy => 'ic_shortcut_energy',
      _ => 'ic_shortcut_default',
    };
  }

  /// Parses a shortcut type string into a [UnitCategory], or null for
  /// special shortcuts (currency, compass).
  static UnitCategory? categoryFor(String type) {
    if (type.startsWith('dynamic_')) {
      final name = type.substring('dynamic_'.length);
      try {
        return UnitCategory.values.firstWhere((c) => c.name == name);
      } catch (_) {
        return null;
      }
    }
    return switch (type) {
      shortcutLength => UnitCategory.length,
      shortcutWeight => UnitCategory.weight,
      _ => null,
    };
  }

  /// Returns `true` if [type] is the currency shortcut.
  static bool isCurrency(String type) => type == shortcutCurrency;

  /// Returns `true` if [type] is the compass shortcut.
  static bool isCompass(String type) => type == shortcutCompass;
}
