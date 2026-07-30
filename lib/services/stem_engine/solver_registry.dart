/// Registry of specialized solvers for complex, multi-root, or iterative algorithms.
library;

import 'dart:math' as math;
import '../../models/stem_calculation_result.dart';

typedef SolverHandler = StemCalculationResult Function(Map<String, double> inputs);

class SolverRegistry {
  SolverRegistry._();

  static final Map<String, SolverHandler> _solvers = {
    'quadratic_formula': _solveQuadratic,
    'combinations': _solveCombinations,
    'law_of_sines': _solveLawOfSines,
    'distance_formula': _solveDistance,
    'pythagorean_theorem': _solvePythagoras,
    'circle_area': _solveCircleArea,
  };

  /// Returns whether a solver ID is registered.
  static bool hasSolver(String solverId) => _solvers.containsKey(solverId);

  /// Executes a registered solver algorithm.
  static StemCalculationResult solve(String solverId, Map<String, double> inputs) {
    final handler = _solvers[solverId];
    if (handler == null) {
      return StemCalculationResult.failure('Unknown solver algorithm: "$solverId"');
    }
    try {
      return handler(inputs);
    } catch (e) {
      return StemCalculationResult.failure(e.toString());
    }
  }

  // ── 1. Quadratic Formula Solver ───────────────────────────────────────────
  static StemCalculationResult _solveQuadratic(Map<String, double> inputs) {
    final a = inputs['a'] ?? 0.0;
    final b = inputs['b'] ?? 0.0;
    final c = inputs['c'] ?? 0.0;

    if (a == 0.0) {
      return StemCalculationResult.failure('Quadratic coefficient "a" cannot be 0.');
    }

    final delta = (b * b) - (4 * a * c);
    final steps = <String>[
      'Identify coefficients: a = $a, b = $b, c = $c',
      'Calculate discriminant Δ = b² - 4ac = ($b)² - 4($a)($c) = $delta',
    ];

    final outputs = <CalculatorOutputResult>[];

    if (delta > 0) {
      final sqrtDelta = math.sqrt(delta);
      final x1 = (-b + sqrtDelta) / (2 * a);
      final x2 = (-b - sqrtDelta) / (2 * a);
      steps.add('Δ > 0 → 2 distinct real roots');
      steps.add('x₁ = (-b + √Δ) / 2a = (-($b) + $sqrtDelta) / ${2 * a} = ${x1.toStringAsFixed(4)}');
      steps.add('x₂ = (-b - √Δ) / 2a = (-($b) - $sqrtDelta) / ${2 * a} = ${x2.toStringAsFixed(4)}');

      outputs.add(CalculatorOutputResult(
        symbol: 'x₁',
        label: 'First Root',
        formattedValue: x1.toStringAsFixed(4),
        numericValue: x1,
      ));
      outputs.add(CalculatorOutputResult(
        symbol: 'x₂',
        label: 'Second Root',
        formattedValue: x2.toStringAsFixed(4),
        numericValue: x2,
      ));
    } else if (delta == 0) {
      final x = -b / (2 * a);
      steps.add('Δ = 0 → 1 repeated real root');
      steps.add('x = -b / 2a = -($b) / ${2 * a} = ${x.toStringAsFixed(4)}');

      outputs.add(CalculatorOutputResult(
        symbol: 'x',
        label: 'Repeated Root',
        formattedValue: x.toStringAsFixed(4),
        numericValue: x,
      ));
    } else {
      final realPart = -b / (2 * a);
      final imagPart = math.sqrt(-delta) / (2 * a);
      steps.add('Δ < 0 → 2 complex conjugate roots');
      steps.add('x₁ = ${realPart.toStringAsFixed(4)} + ${imagPart.abs().toStringAsFixed(4)}i');
      steps.add('x₂ = ${realPart.toStringAsFixed(4)} - ${imagPart.abs().toStringAsFixed(4)}i');

      outputs.add(CalculatorOutputResult(
        symbol: 'x₁',
        label: 'First Complex Root',
        formattedValue: '${realPart.toStringAsFixed(4)} + ${imagPart.abs().toStringAsFixed(4)}i',
      ));
      outputs.add(CalculatorOutputResult(
        symbol: 'x₂',
        label: 'Second Complex Root',
        formattedValue: '${realPart.toStringAsFixed(4)} - ${imagPart.abs().toStringAsFixed(4)}i',
      ));
    }

    outputs.add(CalculatorOutputResult(
      symbol: 'Δ',
      label: 'Discriminant',
      formattedValue: delta.toStringAsFixed(4),
      numericValue: delta,
    ));

    return StemCalculationResult.success(outputs: outputs, steps: steps);
  }

  // ── 2. Combinations nCr Solver ────────────────────────────────────────────
  static StemCalculationResult _solveCombinations(Map<String, double> inputs) {
    final n = (inputs['n'] ?? 0.0).round();
    final r = (inputs['r'] ?? 0.0).round();

    if (n < 0 || r < 0) {
      return StemCalculationResult.failure('Total items (n) and selected items (r) must be non-negative.');
    }
    if (r > n) {
      return StemCalculationResult.failure('Selected items (r = $r) cannot exceed total items (n = $n).');
    }

    final nFact = _factorial(n);
    final rFact = _factorial(r);
    final nrFact = _factorial(n - r);
    final result = nFact / (rFact * nrFact);

    final steps = <String>[
      'Formula: nCr = n! / (r! × (n - r)!)',
      'n! = $n! = $nFact',
      'r! = $r! = $rFact',
      '(n - r)! = ${n - r}! = $nrFact',
      'nCr = $nFact / ($rFact × $nrFact) = ${result.toStringAsFixed(0)}',
    ];

    return StemCalculationResult.success(
      outputs: [
        CalculatorOutputResult(
          symbol: 'nCr',
          label: 'Combinations',
          formattedValue: result.toStringAsFixed(0),
          numericValue: result,
        ),
      ],
      steps: steps,
    );
  }

  static double _factorial(int n) {
    if (n <= 1) return 1.0;
    double fact = 1.0;
    for (int i = 2; i <= n; i++) {
      fact *= i;
    }
    return fact;
  }

  // ── 3. Law of Sines Solver ───────────────────────────────────────────────
  static StemCalculationResult _solveLawOfSines(Map<String, double> inputs) {
    final a = inputs['a'] ?? 0.0;
    final degA = inputs['A'] ?? 0.0;
    final degB = inputs['B'] ?? 0.0;

    if (a <= 0) return StemCalculationResult.failure('Side length a must be positive.');
    if (degA <= 0 || degA >= 180) return StemCalculationResult.failure('Angle A must be between 0° and 180°.');
    if (degB <= 0 || degB >= 180) return StemCalculationResult.failure('Angle B must be between 0° and 180°.');

    final radA = degA * math.pi / 180;
    final radB = degB * math.pi / 180;

    final sinA = math.sin(radA);
    final sinB = math.sin(radB);

    final b = (a * sinB) / sinA;
    final degC = 180 - (degA + degB);

    final steps = <String>[
      'Law of Sines: a / sin(A) = b / sin(B)',
      'Convert angles: A = $degA°, B = $degB°',
      'b = (a × sin(B)) / sin(A) = ($a × ${sinB.toStringAsFixed(4)}) / ${sinA.toStringAsFixed(4)}',
      'b = ${b.toStringAsFixed(4)}',
    ];

    return StemCalculationResult.success(
      outputs: [
        CalculatorOutputResult(
          symbol: 'b',
          label: 'Side B',
          formattedValue: b.toStringAsFixed(4),
          numericValue: b,
        ),
        CalculatorOutputResult(
          symbol: 'C',
          label: 'Angle C',
          formattedValue: '${degC.toStringAsFixed(1)}°',
          numericValue: degC,
        ),
      ],
      steps: steps,
    );
  }

  // ── 4. Distance Solver ───────────────────────────────────────────────────
  static StemCalculationResult _solveDistance(Map<String, double> inputs) {
    final x1 = inputs['x1'] ?? 0.0;
    final y1 = inputs['y1'] ?? 0.0;
    final x2 = inputs['x2'] ?? 0.0;
    final y2 = inputs['y2'] ?? 0.0;

    final dx = x2 - x1;
    final dy = y2 - y1;
    final d = math.sqrt((dx * dx) + (dy * dy));

    final steps = <String>[
      'Point 1: ($x1, $y1), Point 2: ($x2, $y2)',
      'Δx = x₂ - x₁ = $x2 - $x1 = $dx',
      'Δy = y₂ - y₁ = $y2 - $y1 = $dy',
      'd = √((Δx)² + (Δy)²) = √(${dx * dx} + ${dy * dy}) = ${d.toStringAsFixed(4)}',
    ];

    return StemCalculationResult.success(
      outputs: [
        CalculatorOutputResult(
          symbol: 'd',
          label: 'Distance',
          formattedValue: d.toStringAsFixed(4),
          numericValue: d,
        ),
      ],
      steps: steps,
    );
  }

  // ── 5. Pythagoras Solver ─────────────────────────────────────────────────
  static StemCalculationResult _solvePythagoras(Map<String, double> inputs) {
    final a = inputs['a'] ?? 0.0;
    final b = inputs['b'] ?? 0.0;

    if (a <= 0 || b <= 0) return StemCalculationResult.failure('Leg lengths a and b must be positive.');

    final c = math.sqrt((a * a) + (b * b));
    final steps = <String>[
      'a² = ${a * a}, b² = ${b * b}',
      'c² = a² + b² = ${a * a} + ${b * b} = ${(a * a) + (b * b)}',
      'c = √${(a * a) + (b * b)} = ${c.toStringAsFixed(4)}',
    ];

    return StemCalculationResult.success(
      outputs: [
        CalculatorOutputResult(
          symbol: 'c',
          label: 'Hypotenuse',
          formattedValue: c.toStringAsFixed(4),
          numericValue: c,
        ),
      ],
      steps: steps,
    );
  }

  // ── 6. Circle Area Solver ────────────────────────────────────────────────
  static StemCalculationResult _solveCircleArea(Map<String, double> inputs) {
    final r = inputs['r'] ?? 0.0;
    if (r < 0) return StemCalculationResult.failure('Radius cannot be negative.');

    final area = math.pi * r * r;
    final circumference = 2 * math.pi * r;

    final steps = <String>[
      'r² = ${r * r}',
      'Area A = π × r² = 3.14159 × ${r * r} = ${area.toStringAsFixed(4)}',
      'Circumference C = 2 × π × r = ${circumference.toStringAsFixed(4)}',
    ];

    return StemCalculationResult.success(
      outputs: [
        CalculatorOutputResult(
          symbol: 'A',
          label: 'Area',
          formattedValue: area.toStringAsFixed(4),
          numericValue: area,
        ),
        CalculatorOutputResult(
          symbol: 'C',
          label: 'Circumference',
          formattedValue: circumference.toStringAsFixed(4),
          numericValue: circumference,
        ),
      ],
      steps: steps,
    );
  }
}
