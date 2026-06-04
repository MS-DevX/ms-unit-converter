import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../models/conversion_result.dart';
import '../models/unit_model.dart';

class ConversionResultRow extends StatelessWidget {
  final UnitModel unit;
  final ConversionResult? result;
  final bool isSelected;
  final bool isDark;
  final VoidCallback? onResultTapped;

  const ConversionResultRow({
    super.key,
    required this.unit,
    required this.result,
    required this.isSelected,
    required this.isDark,
    this.onResultTapped,
  });

  String get _displayValue {
    return switch (result) {
      null => '\u2014',
      final r when !r.isValid => r.errorMessage ?? 'Invalid',
      final r => r.formattedResult,
    };
  }

  Color _valueColor(ThemeData theme) {
    return switch (result) {
      null => isDark
          ? AppColors.darkTextSecondary.withValues(alpha: 0.35)
          : AppColors.lightTextSecondary.withValues(alpha: 0.35),
      final r when !r.isValid => AppColors.error,
      _ => isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
    };
  }

  void _onTap(BuildContext context) {
    if (result == null || !result!.isValid) return;
    onResultTapped?.call();
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _displayValue));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Copied ${unit.symbol}',
            style: const TextStyle(fontSize: 13),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected
        ? (isDark
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.08))
        : Colors.transparent;

    final Color valueColor = _valueColor(Theme.of(context));
    final Color unitColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GestureDetector(
      onTap: () => _onTap(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: bgColor,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _displayValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${unit.name} (${unit.symbol})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: unitColor,
                height: 1.2,
              ),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
