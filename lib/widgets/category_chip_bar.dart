/// Horizontal scrollable category selector chip bar.
///
/// Renders one animated chip per [UnitCategory]. Selecting a chip
/// calls [onSelected]; all state is held externally — this widget is
/// purely presentational and stateless.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../data/units_data.dart';

/// A horizontally scrollable row of animated category chips.
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainerLow;

    final Color borderColor = isSelected
        ? AppColors.primary
        : isDark
            ? AppColors.outlineVariant.withValues(alpha: 0.3)
            : AppColors.outlineVariant.withValues(alpha: 0.4);

    final Color textColor = isSelected
        ? Theme.of(context).colorScheme.onPrimary
        : isDark
            ? AppColors.textSecondary
            : AppColors.lightTextSecondary;

    void handleTap() {
      HapticFeedback.selectionClick();
      onTap();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Semantics(
        label: '${category.displayName} category',
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(category.displayName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
