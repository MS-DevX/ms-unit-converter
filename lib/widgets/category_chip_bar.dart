/// Horizontal scrollable category selector chip bar.
///
/// Renders one animated chip per [UnitCategory]. Selecting a chip
/// calls [onSelected]; all state is held externally — this widget is
/// purely presentational and stateless.
library;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../data/units_data.dart';

/// A horizontally scrollable row of animated category chips.
///
/// Example usage:
/// ```dart
/// CategoryChipBar(
///   categories: UnitCategory.values,
///   selected: provider.selectedCategory,
///   onSelected: provider.setCategory,
/// )
/// ```
class CategoryChipBar extends StatelessWidget {
  /// All categories to render as chips.
  final List<UnitCategory> categories;

  /// The currently active category.
  final UnitCategory selected;

  /// Called with the tapped [UnitCategory] when the user selects a chip.
  final ValueChanged<UnitCategory> onSelected;

  /// Creates a [CategoryChipBar].
  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 48,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((category) {
            return _CategoryChip(
              category: category,
              isSelected: category == selected,
              isDark: isDark,
              onTap: () => onSelected(category),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Single animated chip representing one [UnitCategory].
class _CategoryChip extends StatelessWidget {
  final UnitCategory category;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.darkSurface
            : AppColors.lightBackground;

    final Color borderColor = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.borderDark
            : AppColors.borderLight;

    final Color textColor = isSelected
        ? Colors.white
        : isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                category.icon,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: textColor,
                  letterSpacing: 0.1,
                ),
                child: Text(category.displayName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
