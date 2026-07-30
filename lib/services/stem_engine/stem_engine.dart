/// Generic, decoupled STEM Engine for offline interactive calculations.
library;

import '../../models/formula_model.dart';
import '../../models/stem_calculation_result.dart';
import 'expression_evaluator.dart';
import 'solver_registry.dart';

class StemEngine {
  StemEngine._();

  /// Calculates interactive formula outputs from calculator definition and user inputs.
  static StemCalculationResult calculate({
    required CalculatorDefinitionModel calculator,
    required Map<String, double> userInputs,
  }) {
    // 1. Domain Input Validation
    for (final inputDef in calculator.inputs) {
      final val = userInputs[inputDef.symbol] ?? inputDef.defaultValue;
      final rules = inputDef.validation;

      if (!rules.allowZero && val == 0.0) {
        return StemCalculationResult.failure(
          rules.errorMessage ?? '${inputDef.label} (${inputDef.symbol}) cannot be zero.',
        );
      }

      if (!rules.allowNegative && val < 0.0) {
        return StemCalculationResult.failure(
          rules.errorMessage ?? '${inputDef.label} (${inputDef.symbol}) cannot be negative.',
        );
      }

      if (rules.integerOnly && val != val.roundToDouble()) {
        return StemCalculationResult.failure(
          rules.errorMessage ?? '${inputDef.label} (${inputDef.symbol}) must be an integer.',
        );
      }

      if (rules.min != null && val < rules.min!) {
        return StemCalculationResult.failure(
          rules.errorMessage ?? '${inputDef.label} (${inputDef.symbol}) cannot be less than ${rules.min}.',
        );
      }

      if (rules.max != null && val > rules.max!) {
        return StemCalculationResult.failure(
          rules.errorMessage ?? '${inputDef.label} (${inputDef.symbol}) cannot be greater than ${rules.max}.',
        );
      }
    }

    // 2. Delegate to Solver Registry if algorithm solver specified
    if (calculator.engineType == 'solver' && calculator.solverId != null) {
      return SolverRegistry.solve(calculator.solverId!, userInputs);
    }

    // 3. Dynamic Expression Evaluation
    try {
      final outputs = <CalculatorOutputResult>[];
      final steps = <String>[];

      steps.add('Inputs: ${userInputs.entries.map((e) => '${e.key} = ${e.value}').join(', ')}');

      for (final outDef in calculator.outputs) {
        final expr = outDef.expression ?? calculator.expression;
        if (expr == null || expr.isEmpty) continue;

        final numericVal = ExpressionEvaluator.evaluate(expr, userInputs);
        final formatted = numericVal.abs() < 0.0001 || numericVal.abs() > 999999
            ? numericVal.toStringAsPrecision(4)
            : numericVal.toStringAsFixed(4).replaceAll(RegExp(r'\.?0+$'), '');

        steps.add('${outDef.symbol} = $expr = $formatted${outDef.unit != null ? ' ${outDef.unit}' : ''}');

        outputs.add(CalculatorOutputResult(
          symbol: outDef.symbol,
          label: outDef.label,
          formattedValue: formatted,
          numericValue: numericVal,
          unit: outDef.unit,
        ));
      }

      if (outputs.isEmpty) {
        return StemCalculationResult.failure('No valid expression outputs defined.');
      }

      return StemCalculationResult.success(outputs: outputs, steps: steps);
    } catch (e) {
      return StemCalculationResult.failure('Calculation error: $e');
    }
  }
}
