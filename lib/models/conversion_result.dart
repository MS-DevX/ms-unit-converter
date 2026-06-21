import 'package:flutter/foundation.dart';

/// Represents the outcome of a unit conversion.
///
/// Provides both the raw numeric [result] and a pre-formatted
/// display string alongside a human-readable [formula] that
/// explains the conversion. Use the [success] and [failure]
/// factory constructors for convenient creation.
@immutable
class ConversionResult {
  /// The numeric conversion result.
  final double result;

  /// A pre-formatted display string of the result.
  final String formattedResult;

  /// A human-readable explanation of the conversion formula.
  final String formula;

  /// Whether the conversion completed without errors.
  final bool isValid;

  /// An optional error message when [isValid] is `false`.
  final String? errorMessage;

  /// Creates a [ConversionResult] with the given properties.
  const ConversionResult({
    required this.result,
    required this.formattedResult,
    required this.formula,
    required this.isValid,
    this.errorMessage,
  });

  /// Creates a successful conversion result.
  ///
  /// [isValid] is `true` and [errorMessage] is `null`.
  factory ConversionResult.success({
    required double result,
    required String formattedResult,
    required String formula,
  }) {
    return ConversionResult(
      result: result,
      formattedResult: formattedResult,
      formula: formula,
      isValid: true,
      errorMessage: null,
    );
  }

  /// Creates a failed conversion result.
  ///
  /// [result] is `0`, [formattedResult] and [formula] are
  /// empty strings, [isValid] is `false`, and [errorMessage]
  /// is the provided message.
  factory ConversionResult.failure(String errorMessage) {
    return ConversionResult(
      result: 0,
      formattedResult: '',
      formula: '',
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  /// Returns a copy of this [ConversionResult] with the given fields replaced.
  ConversionResult copyWith({
    double? result,
    String? formattedResult,
    String? formula,
    bool? isValid,
    String? errorMessage,
  }) {
    return ConversionResult(
      result: result ?? this.result,
      formattedResult: formattedResult ?? this.formattedResult,
      formula: formula ?? this.formula,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  String toString() {
    return 'ConversionResult(\n'
        '  result: $result,\n'
        '  formattedResult: $formattedResult,\n'
        '  formula: $formula,\n'
        '  isValid: $isValid,\n'
        '  errorMessage: $errorMessage\n'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionResult &&
        other.result == result &&
        other.formattedResult == formattedResult &&
        other.formula == formula &&
        other.isValid == isValid &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(result, formattedResult, formula, isValid, errorMessage);
  }
}
