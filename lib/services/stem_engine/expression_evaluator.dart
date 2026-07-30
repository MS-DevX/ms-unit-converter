/// Pure Dart Expression Evaluator for STEM Academy interactive formulas.
library;

import 'dart:math' as math;

class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Evaluates an algebraic string expression with substituted variable values.
  static double evaluate(String expression, Map<String, double> variables) {
    var expr = expression.trim();
    if (expr.isEmpty) throw FormatException('Expression is empty');

    // Substitute mathematical constants
    expr = expr.replaceAll('π', 'pi').replaceAll('pi', '${math.pi}').replaceAll('e', '${math.e}');

    // Substitute variables (longest symbols first to prevent partial replacements)
    final sortedKeys = variables.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    for (final key in sortedKeys) {
      final val = variables[key]!;
      // Replace whole identifier or wrapped symbol
      final valStr = val < 0 ? '($val)' : '$val';
      expr = expr.replaceAll(key, valStr);
    }

    return _parseExpression(expr);
  }

  static double _parseExpression(String expr) {
    expr = expr.replaceAll(' ', '');
    if (expr.isEmpty) return 0.0;

    // Handle parentheses
    while (expr.contains('(')) {
      final lastOpen = expr.lastIndexOf('(');
      final nextClose = expr.indexOf(')', lastOpen);
      if (nextClose == -1) throw FormatException('Unmatched parenthesis in expression');

      final prefix = expr.substring(0, lastOpen);
      final inner = expr.substring(lastOpen + 1, nextClose);
      final suffix = expr.substring(nextClose + 1);

      // Check function prefix
      if (prefix.endsWith('sqrt')) {
        final val = _parseExpression(inner);
        if (val < 0) throw FormatException('Square root of negative number ($val)');
        final funcStart = prefix.length - 4;
        expr = expr.substring(0, funcStart) + math.sqrt(val).toString() + suffix;
      } else if (prefix.endsWith('abs')) {
        final val = _parseExpression(inner);
        final funcStart = prefix.length - 3;
        expr = expr.substring(0, funcStart) + val.abs().toString() + suffix;
      } else if (prefix.endsWith('sin')) {
        final val = _parseExpression(inner);
        final funcStart = prefix.length - 3;
        expr = expr.substring(0, funcStart) + math.sin(val).toString() + suffix;
      } else if (prefix.endsWith('cos')) {
        final val = _parseExpression(inner);
        final funcStart = prefix.length - 3;
        expr = expr.substring(0, funcStart) + math.cos(val).toString() + suffix;
      } else if (prefix.endsWith('tan')) {
        final val = _parseExpression(inner);
        final funcStart = prefix.length - 3;
        expr = expr.substring(0, funcStart) + math.tan(val).toString() + suffix;
      } else if (prefix.endsWith('ln')) {
        final val = _parseExpression(inner);
        if (val <= 0) throw FormatException('Logarithm of non-positive number ($val)');
        final funcStart = prefix.length - 2;
        expr = expr.substring(0, funcStart) + math.log(val).toString() + suffix;
      } else if (prefix.endsWith('log')) {
        final val = _parseExpression(inner);
        if (val <= 0) throw FormatException('Logarithm of non-positive number ($val)');
        final funcStart = prefix.length - 3;
        expr = expr.substring(0, funcStart) + (math.log(val) / math.ln10).toString() + suffix;
      } else {
        final val = _parseExpression(inner);
        expr = prefix + val.toString() + suffix;
      }
    }

    // Addition & Subtraction
    return _parseAddSub(expr);
  }

  static double _parseAddSub(String expr) {
    var i = expr.length - 1;
    var opIndex = -1;
    var opChar = '';

    while (i > 0) {
      final c = expr[i];
      if ((c == '+' || c == '-') && expr[i - 1] != '*' && expr[i - 1] != '/' && expr[i - 1] != '^' && expr[i - 1] != '+' && expr[i - 1] != '-') {
        opIndex = i;
        opChar = c;
        break;
      }
      i--;
    }

    if (opIndex != -1) {
      final left = _parseAddSub(expr.substring(0, opIndex));
      final right = _parseMulDiv(expr.substring(opIndex + 1));
      return opChar == '+' ? left + right : left - right;
    }

    return _parseMulDiv(expr);
  }

  static double _parseMulDiv(String expr) {
    var i = expr.length - 1;
    var opIndex = -1;
    var opChar = '';

    while (i > 0) {
      final c = expr[i];
      if (c == '*' || c == '/') {
        opIndex = i;
        opChar = c;
        break;
      }
      i--;
    }

    if (opIndex != -1) {
      final left = _parseMulDiv(expr.substring(0, opIndex));
      final right = _parsePow(expr.substring(opIndex + 1));
      if (opChar == '/') {
        if (right == 0.0) throw FormatException('Division by zero');
        return left / right;
      }
      return left * right;
    }

    return _parsePow(expr);
  }

  static double _parsePow(String expr) {
    final opIndex = expr.indexOf('^');
    if (opIndex != -1) {
      final left = _parseAtom(expr.substring(0, opIndex));
      final right = _parsePow(expr.substring(opIndex + 1));
      return math.pow(left, right).toDouble();
    }
    return _parseAtom(expr);
  }

  static double _parseAtom(String expr) {
    final clean = expr.trim();
    if (clean.isEmpty) return 0.0;
    final parsed = double.tryParse(clean);
    if (parsed == null) {
      throw FormatException('Invalid numeric atom "$clean"');
    }
    return parsed;
  }
}
