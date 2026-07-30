import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/models/formula_model.dart';
import 'package:unit_converter/services/stem_engine/expression_evaluator.dart';
import 'package:unit_converter/services/stem_engine/solver_registry.dart';
import 'package:unit_converter/services/stem_engine/stem_engine.dart';

void main() {
  group('ExpressionEvaluator Unit Tests', () {
    test('Evaluates arithmetic expressions with variables and constants', () {
      final res1 = ExpressionEvaluator.evaluate('a * b + c', {'a': 2.0, 'b': 3.0, 'c': 4.0});
      expect(res1, equals(10.0));

      final res2 = ExpressionEvaluator.evaluate('π * r^2', {'r': 3.0});
      expect(res2, closeTo(28.2743, 0.001));

      final res3 = ExpressionEvaluator.evaluate('sqrt(a^2 + b^2)', {'a': 3.0, 'b': 4.0});
      expect(res3, equals(5.0));
    });

    test('Throws FormatException on division by zero or invalid math', () {
      expect(
        () => ExpressionEvaluator.evaluate('10 / a', {'a': 0.0}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => ExpressionEvaluator.evaluate('sqrt(a)', {'a': -9.0}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('SolverRegistry Unit Tests', () {
    test('Quadratic formula solver calculates two real roots for Δ > 0', () {
      final result = SolverRegistry.solve('quadratic_formula', {'a': 2.0, 'b': -4.0, 'c': -6.0});
      expect(result.isValid, isTrue);
      expect(result.outputs.length, equals(3));
      expect(result.outputs[0].symbol, equals('x₁'));
      expect(result.outputs[0].numericValue, equals(3.0));
      expect(result.outputs[1].symbol, equals('x₂'));
      expect(result.outputs[1].numericValue, equals(-1.0));
      expect(result.steps.length, greaterThanOrEqualTo(3));
    });

    test('Quadratic formula solver fails when a == 0', () {
      final result = SolverRegistry.solve('quadratic_formula', {'a': 0.0, 'b': 2.0, 'c': 3.0});
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('cannot be 0'));
    });

    test('Combinations nCr solver calculates valid combinations', () {
      final result = SolverRegistry.solve('combinations', {'n': 5.0, 'r': 2.0});
      expect(result.isValid, isTrue);
      expect(result.outputs.first.numericValue, equals(10.0));
    });
  });

  group('StemEngine Calculation & Validation Tests', () {
    test('Validates domain rules (allowZero, min, max)', () {
      const calcDef = CalculatorDefinitionModel(
        engineType: 'expression',
        expression: '10 / x',
        inputs: [
          CalculatorInputModel(
            symbol: 'x',
            label: 'Input X',
            defaultValue: 1.0,
            validation: ValidationRuleModel(allowZero: false, min: 0.1),
          )
        ],
        outputs: [
          CalculatorOutputModel(symbol: 'y', label: 'Output Y')
        ],
      );

      final zeroResult = StemEngine.calculate(calculator: calcDef, userInputs: {'x': 0.0});
      expect(zeroResult.isValid, isFalse);
      expect(zeroResult.errorMessage, contains('cannot be zero'));

      final validResult = StemEngine.calculate(calculator: calcDef, userInputs: {'x': 2.0});
      expect(validResult.isValid, isTrue);
      expect(validResult.outputs.first.numericValue, equals(5.0));
    });
  });
}
