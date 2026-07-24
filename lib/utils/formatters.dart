/// Controls how many decimal places [Formatters.formatResult] displays.
///
/// [auto] preserves smart auto-formatting (trailing zero trimming,
/// scientific notation for extreme magnitudes).
/// The other values enforce a fixed number of decimal places.
enum DecimalPrecision {
  /// Smart auto precision — trims trailing zeros, uses scientific notation for extremes.
  auto('Auto', 0),

  /// Exactly 2 decimal places.
  two('2 dec', 2),

  /// Exactly 4 decimal places.
  four('4 dec', 4),

  /// Exactly 6 decimal places.
  six('6 dec', 6),

  /// Exactly 8 decimal places.
  eight('8 dec', 8);

  /// Human-readable label for UI display.
  final String label;

  /// The number of decimal places for [toStringAsFixed].
  final int decimals;

  const DecimalPrecision(this.label, this.decimals);
}

/// Pure-Dart high-precision number formatting utilities for MS Unit Converter.
///
/// Handles IEEE 754 floating-point artifacts (e.g., 0.1 + 0.2 = 0.30000000000000004),
/// prevents screen overflow on huge magnitudes (e.g. AU to mm), and supports
/// user-selected decimal precision settings.
class Formatters {
  Formatters._();

  static DecimalPrecision? _precision;

  /// Returns the current global precision override, or `null` for auto.
  static DecimalPrecision? get precision => _precision;

  /// Sets the global precision override for [formatResult].
  static void setPrecision(DecimalPrecision? value) {
    _precision = (value == DecimalPrecision.auto) ? null : value;
  }

  /// Formats a [DateTime] timestamp into a user-friendly string (e.g. "Just now", "2m ago", "10:30 AM").
  static String formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// Cleans up IEEE 754 binary floating-point representation artifacts
  /// (e.g. 0.1 + 0.2 = 0.30000000000000004 -> 0.3).
  static double cleanFloatingPoint(double val) {
    if (val.isNaN || val.isInfinite || val == 0) return val;

    // Rounding to 12 significant decimal places strips 64-bit IEEE float noise
    final abs = val.abs();
    if (abs >= 1e-12 && abs <= 1e12) {
      final str = val.toStringAsPrecision(12);
      final parsed = double.tryParse(str);
      if (parsed != null) return parsed;
    }
    return val;
  }

  /// Formats [value] for result display.
  ///
  /// - Removes floating-point noise (`0.1 + 0.2` displays as `0.3`).
  /// - Respects global [DecimalPrecision] if set.
  /// - Handles huge values (e.g., $10^{15}$) with clean scientific notation
  ///   (`1.496 × 10¹⁴`) without crashing or overflowing text containers.
  /// - Returns `"Invalid"` for `NaN` or `Infinity`.
  static String formatResult(double rawValue, {int? currencyDecimals}) {
    if (rawValue.isNaN || rawValue.isInfinite) return 'Invalid';

    final value = cleanFloatingPoint(rawValue);

    // Global fixed precision takes highest priority
    if (_precision != null && _precision != DecimalPrecision.auto) {
      return value.toStringAsFixed(_precision!.decimals);
    }

    // Currency-specific decimals
    if (currencyDecimals != null) {
      return value.toStringAsFixed(currencyDecimals);
    }

    // ── Auto mode (Smart formatting) ──────────────────────────────────────
    if (value == 0) return '0';

    final abs = value.abs();

    // Extreme magnitudes: use clean scientific notation (e.g. 1.496 × 10¹⁴)
    if (abs >= 1e15 || abs < 1e-6) {
      return _formatScientificPretty(value);
    }

    // Standard magnitudes: up to 8 significant digits with trailing zero stripping
    String raw = value.toStringAsPrecision(8);
    if (raw.contains('e') || raw.contains('E')) {
      raw = _expandScientific(raw);
    }

    raw = _removeTrailingZeros(raw);
    if (raw.endsWith('.')) {
      raw = raw.substring(0, raw.length - 1);
    }

    // For values >= 1, cap decimals at 6 max
    if (abs >= 1 && abs < 1e15) {
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

  /// Formats extreme magnitudes into pretty scientific notation (e.g. 1.496 × 10¹⁴).
  static String _formatScientificPretty(double val) {
    final expStr = val.toStringAsExponential(4);
    final parts = expStr.toLowerCase().split('e');
    if (parts.length != 2) return val.toString();

    final mantissa = _removeTrailingZeros(parts[0]);
    final exp = int.tryParse(parts[1]) ?? 0;

    // Convert exponent to superscript string (e.g., 14 -> ¹⁴, -8 -> ⁻⁸)
    final superExp = _toSuperscript(exp);
    return '$mantissa × 10$superExp';
  }

  /// Converts an integer exponent to unicode superscript digits.
  static String _toSuperscript(int exp) {
    final str = exp.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final ch = str[i];
      switch (ch) {
        case '-':
          buffer.write('⁻');
        case '0':
          buffer.write('⁰');
        case '1':
          buffer.write('¹');
        case '2':
          buffer.write('²');
        case '3':
          buffer.write('³');
        case '4':
          buffer.write('⁴');
        case '5':
          buffer.write('⁵');
        case '6':
          buffer.write('⁶');
        case '7':
          buffer.write('⁷');
        case '8':
          buffer.write('⁸');
        case '9':
          buffer.write('⁹');
        default:
          buffer.write(ch);
      }
    }
    return buffer.toString();
  }

  /// Sanitizes user input string for numeric parsing.
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

  static String _zeroes(int count) {
    if (count <= 0) return '';
    final buffer = StringBuffer();
    for (int i = 0; i < count; i++) {
      buffer.write('0');
    }
    return buffer.toString();
  }

  static String _removeTrailingZeros(String value) {
    final dotIndex = value.indexOf('.');
    if (dotIndex == -1) return value;
    int end = value.length - 1;
    while (end > dotIndex && value[end] == '0') {
      end--;
    }
    if (end == dotIndex) {
      return value.substring(0, dotIndex);
    }
    return value.substring(0, end + 1);
  }

  static String _expandScientific(String value) {
    final lower = value.toLowerCase();
    final parts = lower.split('e');
    if (parts.length != 2) return value;

    final bool negative = parts[0].startsWith('-');
    String mantissa = parts[0];
    if (negative) mantissa = mantissa.substring(1);
    final int exponent = int.parse(parts[1]);

    // For exponents >= 15 or <= -15, keep scientific
    if (exponent.abs() >= 15) return value;

    final dotIndex = mantissa.indexOf('.');
    final String digits;
    if (dotIndex == -1) {
      digits = mantissa;
    } else {
      digits = mantissa.replaceAll('.', '');
    }

    String result;
    if (exponent >= 0) {
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
