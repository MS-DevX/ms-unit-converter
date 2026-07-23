import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../core/colors.dart';
import '../models/conversion_result.dart';
import '../models/unit_model.dart';

/// Single unit result row with explicit Copy and Share buttons, haptic feedback,
/// and TalkBack semantics.
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
      null =>
        isDark
            ? AppColors.darkTextSecondary.withValues(alpha: 0.35)
            : AppColors.lightTextSecondary.withValues(alpha: 0.35),
      final r when !r.isValid => AppColors.error,
      _ => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    };
  }

  void _onCopy(BuildContext context) {
    if (result == null || !result!.isValid) return;
    onResultTapped?.call();
    HapticFeedback.lightImpact();
    final text = '$_displayValue ${unit.symbol}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Copied $text to clipboard',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
  }

  void _onShare(BuildContext context) {
    if (result == null || !result!.isValid) return;
    HapticFeedback.lightImpact();
    final text = '$_displayValue ${unit.symbol} (${unit.name})';
    SharePlus.instance.share(
      ShareParams(text: text, subject: 'Unit Conversion Result'),
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
    final Color unitColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final bool isValid = result?.isValid == true;

    return Semantics(
      label: '${unit.name}: $_displayValue ${unit.symbol}',
      value: _displayValue,
      button: isValid,
      onTap: isValid ? () => _onCopy(context) : null,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        color: bgColor,
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      _displayValue,
                      key: ValueKey('${unit.name}_$_displayValue'),
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
                  Text(
                    '${unit.name} (${unit.symbol})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: unitColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isValid) ...[
              const SizedBox(width: 8),

              // One-Tap Copy Button
              Semantics(
                label: 'Copy $_displayValue ${unit.symbol}',
                button: true,
                child: IconButton(
                  icon: Icon(
                    Icons.content_copy_rounded,
                    size: 18,
                    color: unitColor.withValues(alpha: 0.8),
                  ),
                  tooltip: 'Copy result',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _onCopy(context),
                ),
              ),

              // Native Share Button
              Semantics(
                label: 'Share $_displayValue ${unit.symbol}',
                button: true,
                child: IconButton(
                  icon: Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: unitColor.withValues(alpha: 0.8),
                  ),
                  tooltip: 'Share result',
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                  padding: EdgeInsets.zero,
                  onPressed: () => _onShare(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
