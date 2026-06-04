/// Core UI-state provider for the converter screen.
///
/// Connects [ConversionService], [unitsData], and [Formatters] into a
/// single [ChangeNotifier] that the widget tree observes. All conversion
/// logic is deterministic and synchronous — no I/O, no ads, no history
/// writes (those are handled by the UI layer after observing [result]).
library;

import 'package:flutter/foundation.dart';

import '../data/units_data.dart';
import '../models/conversion_result.dart';
import '../models/unit_model.dart';
import '../services/conversion_service.dart';
import '../utils/formatters.dart';

/// Exposes the full converter state to the widget tree.
///
/// Lifecycle:
/// 1. Instantiated once and registered as a [ChangeNotifier] provider.
/// 2. The UI calls [setCategory], [setFromUnit], [setToUnit], [setInput],
///    and [swapUnits] to mutate state.
/// 3. Every mutation ends with [_recalculate] → [notifyListeners].
class ConverterProvider extends ChangeNotifier {
  // ─── State (private, exposed via getters) ──────────────────────────────────

  UnitCategory _selectedCategory = UnitCategory.length;
  UnitModel? _fromUnit;
  UnitModel? _toUnit;
  String _inputValue = '';
  ConversionResult? _result;

  /// The currently selected conversion category.
  UnitCategory get selectedCategory => _selectedCategory;

  /// The unit being converted *from*.
  UnitModel? get fromUnit => _fromUnit;

  /// The unit being converted *to*.
  UnitModel? get toUnit => _toUnit;

  /// Raw string value entered by the user (already sanitised).
  String get inputValue => _inputValue;

  /// The result of the most recent conversion, or `null` when the input
  /// field is empty.
  ConversionResult? get result => _result;

  // ─── Constructor ──────────────────────────────────────────────────────────

  /// Initialises the provider with the default [selectedCategory] (length)
  /// and pre-selects the first two units in that category.
  ConverterProvider() {
    _initUnitsForCategory(_selectedCategory);
  }

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Changes the active category, resets both unit dropdowns to the first
  /// two units of the new category, clears [inputValue] and [result], then
  /// calls [notifyListeners].
  void setCategory(UnitCategory category) {
    _selectedCategory = category;
    _inputValue = '';
    _result = null;
    _initUnitsForCategory(category);
    notifyListeners();
  }

  /// Updates [fromUnit] and re-runs the conversion.
  void setFromUnit(UnitModel unit) {
    _fromUnit = unit;
    _recalculate();
  }

  /// Updates [toUnit] and re-runs the conversion.
  void setToUnit(UnitModel unit) {
    _toUnit = unit;
    _recalculate();
  }

  /// Sanitises [value] via [Formatters.formatInput], stores it in
  /// [inputValue], and re-runs the conversion.
  ///
  /// History writes are intentionally absent here — the UI layer should
  /// observe [result] and call [HistoryProvider.addEntry] when appropriate.
  void setInput(String value) {
    _inputValue = Formatters.formatInput(value);
    _recalculate();
  }

  /// Swaps [fromUnit] and [toUnit] and re-runs the conversion.
  void swapUnits() {
    final temp = _fromUnit;
    _fromUnit = _toUnit;
    _toUnit = temp;
    _recalculate();
  }

  // ─── Computed properties ──────────────────────────────────────────────────

  /// `true` when [inputValue] represents a valid, finite [double].
  bool get isValidInput {
    if (_inputValue.isEmpty) return false;
    final parsed = double.tryParse(_inputValue);
    return parsed != null && !parsed.isNaN && !parsed.isInfinite;
  }

  /// Returns [inputValue] if non-empty, otherwise `"0"`.
  String get formattedInput => _inputValue.isEmpty ? '0' : _inputValue;

  /// Convenience accessor: the units available for [selectedCategory].
  List<UnitModel> get currentUnits => getUnits(_selectedCategory);

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Pre-selects units when the category is first set or changed.
  ///
  /// - [fromUnit] → index 0
  /// - [toUnit]   → index 1 if it exists, otherwise index 0
  void _initUnitsForCategory(UnitCategory category) {
    final units = getUnits(category);
    _fromUnit = units.isNotEmpty ? units[0] : null;
    _toUnit = units.length > 1 ? units[1] : units.isNotEmpty ? units[0] : null;
  }

  /// Core conversion engine called after every state mutation.
  ///
  /// - Returns early (result stays `null`) when either unit is unset.
  /// - Sets `result = null` when [inputValue] is empty.
  /// - On parse failure, stores a [ConversionResult.failure].
  void _recalculate() {
    final from = _fromUnit;
    final to = _toUnit;

    if (from == null || to == null) {
      _result = null;
      notifyListeners();
      return;
    }

    if (_inputValue.isEmpty) {
      _result = null;
      notifyListeners();
      return;
    }

    final parsed = double.tryParse(_inputValue);
    if (parsed == null || parsed.isNaN || parsed.isInfinite) {
      _result = ConversionResult.failure('Invalid input');
      notifyListeners();
      return;
    }

    _result = ConversionService.convert(parsed, from, to, _selectedCategory);
    notifyListeners();
  }
}
