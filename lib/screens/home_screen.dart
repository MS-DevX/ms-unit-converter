/// Home screen — premium category grid with animated cards and quick presets.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../data/units_data.dart';
import 'converter_screen.dart';

/// A premium grid showing all conversion categories as styled cards
/// with quick conversion presets below.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Map<UnitCategory, List<Color>> _categoryGradients = {
    UnitCategory.length: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    UnitCategory.weight: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.temperature: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    UnitCategory.area: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
    UnitCategory.volume: [Color(0xFFF59E0B), Color(0xFFD97706)],
    UnitCategory.speed: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.data: [Color(0xFFEC4899), Color(0xFFBE185D)],
    UnitCategory.time: [Color(0xFF6366F1), Color(0xFF4338CA)],
    UnitCategory.angle: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    UnitCategory.energy: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.power: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.pressure: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    UnitCategory.force: [Color(0xFF84CC16), Color(0xFF4D7C0F)],
    UnitCategory.frequency: [Color(0xFFEC4899), Color(0xFF9D174D)],
    UnitCategory.fuelEconomy: [Color(0xFF22D3EE), Color(0xFF0E7490)],
  };

  static const List<_PresetConversion> _quickPresets = [
    _PresetConversion(category: UnitCategory.length, value: 1, fromUnitName: 'Kilometer', toUnitName: 'Mile'),
    _PresetConversion(category: UnitCategory.length, value: 1, fromUnitName: 'Meter', toUnitName: 'Foot'),
    _PresetConversion(category: UnitCategory.weight, value: 1, fromUnitName: 'Kilogram', toUnitName: 'Pound'),
    _PresetConversion(category: UnitCategory.temperature, value: 0, fromUnitName: 'Celsius', toUnitName: 'Fahrenheit'),
    _PresetConversion(category: UnitCategory.volume, value: 1, fromUnitName: 'Liter', toUnitName: 'Gallon (US)'),
    _PresetConversion(category: UnitCategory.speed, value: 1, fromUnitName: 'Kilometers per Hour', toUnitName: 'Miles per Hour'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
          final childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.1;

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = UnitCategory.values[index];
                      return _CategoryCard(
                        category: category,
                        gradients: _categoryGradients[category]!,
                        onTap: () => _openConverter(context, category),
                        onLongPress: () => _showCategoryPresets(context, category),
                      );
                    },
                    childCount: UnitCategory.values.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _QuickConversions(
                  presets: _quickPresets,
                  onPresetTapped: (preset) => _openConverterWithPreset(context, preset),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openConverter(BuildContext context, UnitCategory category) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ConverterScreen(initialCategory: category);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showCategoryPresets(BuildContext context, UnitCategory category) {
    HapticFeedback.mediumImpact();
    final presets = category.commonConversions;
    final gradients = _categoryGradients[category]!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  alignment: Alignment.center,
                ),
                Row(
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Long-press a conversion to jump in',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ...presets.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _openConverterWithPreset(
                        context,
                        _PresetConversion(
                          category: category,
                          value: p.value,
                          fromUnitName: p.fromUnitName,
                          toUnitName: p.toUnitName,
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradients,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Text(
                            '${p.value == p.value.roundToDouble() ? p.value.toInt() : p.value} ${p.fromUnitName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 16,
                            ),
                          ),
                          Text(
                            p.toUnitName,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white.withValues(alpha: 0.4),
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openConverterWithPreset(BuildContext context, _PresetConversion preset) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ConverterScreen(
            initialCategory: preset.category,
            presetValue: preset.value,
            presetFromUnitName: preset.fromUnitName,
            presetToUnitName: preset.toUnitName,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _PresetConversion {
  final UnitCategory category;
  final double value;
  final String fromUnitName;
  final String toUnitName;

  const _PresetConversion({
    required this.category,
    required this.value,
    required this.fromUnitName,
    required this.toUnitName,
  });

  String get label => '${value == value.roundToDouble() ? value.toInt() : value} $fromUnitName → $toUnitName';
}

class _QuickConversions extends StatelessWidget {
  final List<_PresetConversion> presets;
  final ValueChanged<_PresetConversion> onPresetTapped;

  const _QuickConversions({
    required this.presets,
    required this.onPresetTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                size: 16,
                color: AppColors.warning,
              ),
              const SizedBox(width: 6),
              Text(
                'Quick Conversions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...presets.map((preset) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _PresetChip(
              preset: preset,
              onTap: () => onPresetTapped(preset),
            ),
          )),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final _PresetConversion preset;
  final VoidCallback onTap;

  const _PresetChip({
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradients = HomeScreen._categoryGradients[preset.category]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradients.last.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Text(
              preset.category.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                preset.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 12,
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

/// A single premium category card with gradient, icon, name, and unit count.
class _CategoryCard extends StatelessWidget {
  final UnitCategory category;
  final List<Color> gradients;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryCard({
    required this.category,
    required this.gradients,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradients,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradients.last.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
            child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              onLongPress: onLongPress,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.icon,
                        style: const TextStyle(fontSize: 26),
                      ),
                      const Spacer(),
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          ...category.unitSymbols.take(4).map(
                                (s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          if (category.unitSymbols.length > 4)
                            Text(
                              '+${category.unitSymbols.length - 4}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }
}
