/// Home screen — premium category grid with animated cards.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants.dart';
import '../data/units_data.dart';
import 'converter_screen.dart';

/// A premium grid showing all conversion categories as styled cards.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  /// Per-category gradient colours — two-tone for premium depth.
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

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: childAspectRatio,
            ),
            itemCount: UnitCategory.values.length,
            itemBuilder: (context, index) {
              final category = UnitCategory.values[index];
              return _CategoryCard(
                category: category,
                gradients: _categoryGradients[category]!,
                onTap: () => _openConverter(context, category),
              );
            },
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
}

/// A single premium category card with gradient, icon, name, and unit count.
class _CategoryCard extends StatelessWidget {
  final UnitCategory category;
  final List<Color> gradients;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.gradients,
    required this.onTap,
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
