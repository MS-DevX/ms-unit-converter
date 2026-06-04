/// Pure-Dart number formatting utilities for MS Unit Converter.
///
/// All methods are stateless and deterministic. No Flutter UI
/// dependency is required, making this file safe for use in
/// the data layer and tests.
class Formatters {
  Formatters._();

  /// Formats [value] for result display.
  ///
  /// Rules:
  /// - Max 8 significant digits.
  /// - Never uses scientific notation.
  /// - Values between 0.000001 and 999999999 get up to 6
  ///   decimal places with trailing zeros stripped.
  /// - Integer values display without a decimal point.
  /// - NaN and Infinity return `"Invalid"`.
  static String formatResult(double value) {
    if (value.isNaN || value.isInfinite) return 'Invalid';
    if (value == 0) return '0';

    // Obtain at most 8 significant digits (may use scientific notation).
    String raw = value.toStringAsPrecision(8);
    if (raw.contains('e') || raw.contains('E')) {
      raw = _expandScientific(raw);
    }

    // Clean up trailing zeros.
    raw = _removeTrailingZeros(raw);
    if (raw.endsWith('.')) {
      raw = raw.substring(0, raw.length - 1);
    }

    final abs = value.abs();

    // For values >= 1 in the normal display range, cap at 6 decimal
    // places. Values below 1 have decimal places that *are* their
    // significant digits, so capping would lose information.
    // Values outside the normal range are extreme and should not be
    // further truncated.
    if (abs >= 1 && abs <= 999999999) {
      final dotIndex = raw.indexOf('.');
      if (dotIndex != -1) {
        final decimals = raw.length - dotIndex - 1;
        if (decimals > 6) {
          raw = raw.substring(0, dotIndex + 7);
          raw = _removeTrailingZeros(raw);
          if (raw.endsWith('.')) {
            raw = raw.substring(0, raw.length - 1);
          }
        }
      }
    }

    return raw;
  }

  /// Sanitizes a raw user-input string for numeric parsing.
  ///
  /// - Keeps only digits (`0-9`) and at most one decimal point (`.`).
  /// - All other characters are removed.
  /// - An empty result returns `""`.
  static String formatInput(String raw) {
    if (raw.isEmpty) return '';
    final buffer = StringBuffer();
    bool dotSeen = false;
    for (int i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == '-' && buffer.isEmpty) {
        buffer.write(ch);
      } else if (ch == '.') {
        if (dotSeen) continue;
        dotSeen = true;
        buffer.write(ch);
      } else if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
        buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Returns a string consisting of [count] zero characters.
  static String _zeroes(int count) {
    if (count <= 0) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write('0');
    }
    return buffer.toString();
  }

  /// Removes trailing zeros after the decimal point.
  static String _removeTrailingZeros(String value) {
    final dotIndex = value.indexOf('.');
    if (dotIndex == -1) return value;
    int end = value.length - 1;
    while (end > dotIndex && value[end] == '0') {
      end--;
    }
    if (end == dotIndex) {
      // All decimals were zeros → drop the decimal point entirely.
      return value.substring(0, dotIndex);
    }
    return value.substring(0, end + 1);
  }

  /// Expands a scientific-notation string to a fixed-point decimal string.
  ///
  /// Accepts lowercase `e` or uppercase `E` and handles optional `+`
  /// in the exponent (e.g. `"1.23e+2"`, `"5E-3"`).
  static String _expandScientific(String value) {
    // Normalise to lowercase for parsing.
    final lower = value.toLowerCase();
    final parts = lower.split('e');
    if (parts.length != 2) return value;

    final bool negative = parts[0].startsWith('-');
    String mantissa = parts[0];
    if (negative) mantissa = mantissa.substring(1);
    final int exponent = int.parse(parts[1]);

    final dotIndex = mantissa.indexOf('.');
    final String digits;
    if (dotIndex == -1) {
      digits = mantissa;
    } else {
      digits = mantissa.replaceAll('.', '');
    }

    String result;
    if (exponent >= 0) {
      // Right shift.
      final int currentDecimals = dotIndex == -1
          ? 0
          : mantissa.length - dotIndex - 1;
      if (exponent >= currentDecimals) {
        result = '$digits${_zeroes(exponent - currentDecimals)}';
      } else {
        final insertAt = dotIndex + exponent;
        result =
            '${digits.substring(0, insertAt)}.${digits.substring(insertAt)}';
      }
    } else {
      // Left shift.
      final int absExp = -exponent;
      if (dotIndex == -1) {
        result = '0.${_zeroes(absExp - 1)}$digits';
      } else {
        final newDotPos = dotIndex - absExp;
        if (newDotPos > 0) {
          result =
              '${digits.substring(0, newDotPos)}.${digits.substring(newDotPos)}';
        } else if (newDotPos == 0) {
          result = '0.$digits';
        } else {
          result = '0.${_zeroes(-newDotPos)}$digits';
        }
      }
    }

    return negative ? '-$result' : result;
  }
}
