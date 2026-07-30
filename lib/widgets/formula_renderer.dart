/// Standalone mathematical formula and expression renderer widget.
library;

import 'package:flutter/material.dart';
import '../core/colors.dart';

class FormulaRenderer extends StatelessWidget {
  final String formula;
  final TextStyle? style;
  final Color? glowColor;
  final bool showCardBackground;

  const FormulaRenderer({
    super.key,
    required this.formula,
    this.style,
    this.glowColor,
    this.showCardBackground = false,
  });

  /// Pre-processes mathematical symbols, superscripts, and operators into formatted text.
  static String formatMathSymbols(String raw) {
    var text = raw;
    // Superscripts
    text = text.replaceAll('^2', '²').replaceAll('^3', '³').replaceAll('^n', 'ⁿ').replaceAll('^-1', '⁻¹');
    // Subscripts
    text = text.replaceAll('_1', '₁').replaceAll('_2', '₂').replaceAll('_3', '₃').replaceAll('_i', 'ᵢ');
    // Operators & Symbols
    text = text.replaceAll('*', ' · ').replaceAll('<=', ' ≤ ').replaceAll('>=', ' ≥ ').replaceAll('!=', ' ≠ ');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedText = formatMathSymbols(formula);

    final defaultStyle = style ??
        theme.textTheme.headlineMedium?.copyWith(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
          letterSpacing: 0.5,
        );

    final content = SelectableText(
      formattedText,
      textAlign: TextAlign.center,
      style: defaultStyle,
    );

    if (!showCardBackground) {
      return content;
    }

    final glow = glowColor ?? AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: glow.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(child: content),
    );
  }
}
