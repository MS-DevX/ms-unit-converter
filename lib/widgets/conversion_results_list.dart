import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/conversion_result.dart';
import '../models/unit_model.dart';
import 'conversion_result_row.dart';

class ConversionResultsList extends StatelessWidget {
  final List<({UnitModel unit, ConversionResult? result})> results;
  final UnitModel? sourceUnit;
  final bool isDark;
  final void Function(UnitModel unit, ConversionResult? result)?
      onResultTapped;

  const ConversionResultsList({
    super.key,
    required this.results,
    required this.sourceUnit,
    required this.isDark,
    this.onResultTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: results.length,
      separatorBuilder: (_, _) => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
      ),
      itemBuilder: (context, index) {
        final item = results[index];
        return ConversionResultRow(
          unit: item.unit,
          result: item.result,
          isSelected: item.unit == sourceUnit,
          isDark: isDark,
          onResultTapped: onResultTapped != null
              ? () => onResultTapped!(item.unit, item.result)
              : null,
        );
      },
    );
  }
}
