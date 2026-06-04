library;

import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/unit_model.dart';

class UnitDropdown extends StatelessWidget {
  final String label;
  final UnitModel value;
  final List<UnitModel> items;
  final ValueChanged<UnitModel> onChanged;

  const UnitDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final Color borderColor =
        isDark ? AppColors.borderDark : AppColors.borderLight;
    final Color labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color iconColor = AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: labelColor,
              ),
            ),
          ),
        ],
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<UnitModel>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: iconColor,
                size: 22,
              ),
              dropdownColor: bgColor,
              borderRadius: BorderRadius.circular(12),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              onChanged: (UnitModel? selected) {
                if (selected != null) onChanged(selected);
              },
              items: items.map((unit) {
                return DropdownMenuItem<UnitModel>(
                  value: unit,
                  child: Text(
                    '${unit.name} (${unit.symbol})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
