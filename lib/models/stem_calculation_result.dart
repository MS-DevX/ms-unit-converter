/// Immutable calculation result produced by the StemEngine.
library;

/// Individual output metric calculated by StemEngine.
class CalculatorOutputResult {
  final String symbol;
  final String label;
  final String formattedValue;
  final double? numericValue;
  final String? unit;

  const CalculatorOutputResult({
    required this.symbol,
    required this.label,
    required this.formattedValue,
    this.numericValue,
    this.unit,
  });
}

/// Structured result container returned by StemEngine.
class StemCalculationResult {
  final bool isValid;
  final String? errorMessage;
  final List<CalculatorOutputResult> outputs;
  final List<String> steps;

  const StemCalculationResult({
    required this.isValid,
    this.errorMessage,
    this.outputs = const [],
    this.steps = const [],
  });

  factory StemCalculationResult.failure(String message) {
    return StemCalculationResult(
      isValid: false,
      errorMessage: message,
      outputs: const [],
      steps: const [],
    );
  }

  factory StemCalculationResult.success({
    required List<CalculatorOutputResult> outputs,
    required List<String> steps,
  }) {
    return StemCalculationResult(
      isValid: true,
      errorMessage: null,
      outputs: outputs,
      steps: steps,
    );
  }
}
