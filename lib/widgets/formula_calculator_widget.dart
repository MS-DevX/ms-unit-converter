/// Premium interactive calculator widget for STEM Academy formula lessons.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/colors.dart';
import '../models/formula_model.dart';
import '../models/stem_calculation_result.dart';
import '../services/stem_engine/stem_engine.dart';
import 'stitch_card.dart';

class FormulaCalculatorWidget extends StatefulWidget {
  final CalculatorDefinitionModel calculator;
  final WorkedExampleModel? workedExample;

  const FormulaCalculatorWidget({
    super.key,
    required this.calculator,
    this.workedExample,
  });

  @override
  State<FormulaCalculatorWidget> createState() => _FormulaCalculatorWidgetState();
}

class _FormulaCalculatorWidgetState extends State<FormulaCalculatorWidget> {
  final Map<String, TextEditingController> _controllers = {};
  StemCalculationResult? _result;
  bool _showSteps = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
    _recalculate();
  }

  void _initControllers() {
    for (final input in widget.calculator.inputs) {
      _controllers[input.symbol] = TextEditingController(
        text: (input.exampleValue ?? input.defaultValue).toString().replaceAll(RegExp(r'\.?0+$'), ''),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _recalculate() {
    final inputs = <String, double>{};
    for (final input in widget.calculator.inputs) {
      final text = _controllers[input.symbol]?.text.trim() ?? '';
      final parsed = double.tryParse(text) ?? input.defaultValue;
      inputs[input.symbol] = parsed;
    }

    setState(() {
      _result = StemEngine.calculate(
        calculator: widget.calculator,
        userInputs: inputs,
      );
    });
  }

  void _autofillExample() {
    HapticFeedback.selectionClick();
    for (final input in widget.calculator.inputs) {
      final val = input.exampleValue ?? input.defaultValue;
      _controllers[input.symbol]?.text = val.toString().replaceAll(RegExp(r'\.?0+$'), '');
    }
    _recalculate();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Auto-filled with example values'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _resetInputs() {
    HapticFeedback.selectionClick();
    for (final input in widget.calculator.inputs) {
      _controllers[input.symbol]?.text = input.defaultValue.toString().replaceAll(RegExp(r'\.?0+$'), '');
    }
    _recalculate();
  }

  void _copyResult(String text) {
    HapticFeedback.mediumImpact();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StitchCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Bar ─────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🧮 ', style: TextStyle(fontSize: 13)),
                    Text(
                      'Interactive Calculator v${widget.calculator.version}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.auto_fix_high, size: 20),
                tooltip: 'Auto-fill example values',
                onPressed: _autofillExample,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Reset inputs',
                onPressed: _resetInputs,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Dynamic Input Fields ────────────────────────────────────────────
          ...widget.calculator.inputs.map((input) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TextField(
                controller: _controllers[input.symbol],
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                onChanged: (_) => _recalculate(),
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: '${input.label} (${input.symbol})',
                  hintText: 'Enter ${input.symbol}',
                  suffixText: input.unit,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // ── Validation Error Banner ─────────────────────────────────────────
          if (_result != null && !_result!.isValid)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha:0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.error.withValues(alpha:0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: theme.colorScheme.error, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _result!.errorMessage ?? 'Invalid inputs',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ── Calculation Results Section ─────────────────────────────────────
          if (_result != null && _result!.isValid && _result!.outputs.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryContainer.withValues(alpha:0.6),
                    theme.colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha:0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Calculation Output',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        tooltip: 'Copy primary output',
                        onPressed: () {
                          final out = _result!.outputs.first;
                          _copyResult('${out.symbol} = ${out.formattedValue}${out.unit != null ? ' ${out.unit}' : ''}');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ..._result!.outputs.map((out) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Text(
                            '${out.symbol} = ',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontFamily: 'monospace',
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${out.formattedValue}${out.unit != null ? ' ${out.unit}' : ''}',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Step-by-Step Solution Expandable Trace ────────────────────────
            if (_result!.steps.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  setState(() => _showSteps = !_showSteps);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: Row(
                    children: [
                      Icon(
                        _showSteps ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _showSteps ? 'Hide Step-by-Step Solution' : 'View Step-by-Step Solution',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_showSteps)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh.withValues(alpha:0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _result!.steps.map((step) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                step,
                                style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }
}
