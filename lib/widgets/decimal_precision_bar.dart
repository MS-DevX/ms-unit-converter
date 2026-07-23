/// Widget providing an interactive Material 3 decimal precision selector.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';

class DecimalPrecisionBar extends StatelessWidget {
  const DecimalPrecisionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final current = settings.decimalPrecision;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.tune_rounded,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                SizedBox(width: 6),
                Text(
                  'DECIMAL PRECISION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: DecimalPrecision.values.map((option) {
                final isSelected = option == current;

                return ChoiceChip(
                  selected: isSelected,
                  label: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (selected) {
                    if (selected) {
                      HapticFeedback.selectionClick();
                      settings.setDecimalPrecision(option);
                    }
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
