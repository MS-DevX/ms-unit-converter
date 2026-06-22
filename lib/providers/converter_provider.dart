/// Core UI-state provider for the converter screen.
///
/// Connects [ConversionService], [unitsData], and [Formatters] into a
/// single [ChangeNotifier] that the widget tree observes.
library;

import 'package:flutter/foundation.dart';

import '../data/units_data.dart';
import '../models/conversion_result.dart';
import '../models/unit_model.dart';
import '../services/conversion_service.dart';
import '../utils/formatters.dart';

/// Exposes the full converter state to the widget tree.
class ConverterProvider extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────

  UnitCategory _selectedCategory = UnitCategory.length;
  UnitModel? _fromUnit;
  UnitModel? _toUnit;
  String _inputValue = '';
  ConversionResult? _result;

  // ── Category-specific extras ─────────────────────────────────────────
  String _rawInput = ''; // raw text (Number Base accepts hex)
  double _baseFontSize = 16.0; // em/rem base (Typography)
  bool _isMenSize = true; // men/women toggle (Clothing)

  // ─── Getters ──────────────────────────────────────────────────────────

  UnitCategory get selectedCategory => _selectedCategory;
  UnitModel? get fromUnit => _fromUnit;
  UnitModel? get toUnit => _toUnit;
  String get inputValue => _inputValue;
  ConversionResult? get result => _result;
  String get rawInput => _rawInput;
  double get baseFontSize => _baseFontSize;
  bool get isMenSize => _isMenSize;

  // ─── Constructor ──────────────────────────────────────────────────────

  ConverterProvider() {
    _initUnitsForCategory(_selectedCategory);
  }

  // ─── Public API ───────────────────────────────────────────────────────

  void setCategory(UnitCategory category) {
    _selectedCategory = category;
    _inputValue = '';
    _rawInput = '';
    _result = null;
    _baseFontSize = 16.0;
    _isMenSize = true;
    _initUnitsForCategory(category);
    notifyListeners();
  }

  void setFromUnit(UnitModel unit) {
    _fromUnit = unit;
    _recalculate();
  }

  void setToUnit(UnitModel unit) {
    _toUnit = unit;
    _recalculate();
  }

  void setInput(String value) {
    _inputValue = Formatters.formatInput(value);
    _rawInput = value;
    _recalculate();
  }

  void setRawInput(String value) {
    _rawInput = value;
    _recalculate();
  }

  void swapUnits() {
    final temp = _fromUnit;
    _fromUnit = _toUnit;
    _toUnit = temp;
    _recalculate();
  }

  void setBaseFontSize(double size) {
    _baseFontSize = size;
    _recalculate();
  }

  void setIsMenSize(bool isMen) {
    _isMenSize = isMen;
    _recalculate();
  }

  // ─── Computed properties ──────────────────────────────────────────────

  bool get isValidInput {
    if (_inputValue.isEmpty) return false;
    final parsed = double.tryParse(_inputValue);
    return parsed != null && !parsed.isNaN && !parsed.isInfinite;
  }

  String get formattedInput => _inputValue.isEmpty ? '0' : _inputValue;

  List<UnitModel> get currentUnits => getUnits(_selectedCategory);

  // ─── Private helpers ──────────────────────────────────────────────────

  void _initUnitsForCategory(UnitCategory category) {
    final units = getUnits(category);
    _fromUnit = units.isNotEmpty ? units[0] : null;
    _toUnit = units.length > 1
        ? units[1]
        : units.isNotEmpty
        ? units[0]
        : null;
  }

  void _recalculate() {
    final from = _fromUnit;
    final to = _toUnit;

    if (from == null || to == null) {
      _result = null;
      notifyListeners();
      return;
    }

    final input = _selectedCategory == UnitCategory.numberBase
        ? _rawInput
        : _inputValue;

    if (input.isEmpty) {
      _result = null;
      notifyListeners();
      return;
    }

    // ── Number Base: parse int with radix ─────────────────────────────
    if (_selectedCategory == UnitCategory.numberBase) {
      _result = _convertNumberBase(input, from, to);
      notifyListeners();
      return;
    }

    // ── Standard: parse as double ────────────────────────────────────
    final parsed = double.tryParse(_inputValue);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      _result = ConversionResult.failure('Invalid input');
      notifyListeners();
      return;
    }

    _result = ConversionService.convert(parsed, from, to, _selectedCategory);
    notifyListeners();
  }

  /// Handles Number Base conversion with radix-based integer parsing.
  ConversionResult _convertNumberBase(
    String input,
    UnitModel from,
    UnitModel to,
  ) {
    final int? fromRadix = _radixForUnit(from.name);
    final int? toRadix = _radixForUnit(to.name);
    if (fromRadix == null || toRadix == null) {
      return ConversionResult.failure('Invalid unit');
    }

    final int? parsedValue = int.tryParse(input, radix: fromRadix);
    if (parsedValue == null) {
      return ConversionResult.failure('Invalid input');
    }

    // Convert to decimal integer, then to target base
    final decimal = int.parse(parsedValue.toRadixString(10));
    final resultStr = decimal.toRadixString(toRadix).toUpperCase();

    // Build a readable result
    final formatted = '$resultStr (base $toRadix)';
    return ConversionResult.success(
      result: decimal.toDouble(),
      formattedResult: formatted,
      formula: '$input (base $fromRadix) = $formatted',
    );
  }

  /// Returns the radix for a Number Base unit name.
  int? _radixForUnit(String name) {
    switch (name) {
      case 'Binary':
        return 2;
      case 'Octal':
        return 8;
      case 'Decimal':
        return 10;
      case 'Hexadecimal':
        return 16;
      default:
        return null;
    }
  }
}
