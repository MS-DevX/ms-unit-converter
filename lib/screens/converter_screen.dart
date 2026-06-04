import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../models/conversion_result.dart';
import '../models/history_entry.dart';
import '../models/unit_model.dart';
import '../providers/converter_provider.dart';
import '../providers/history_provider.dart';
import '../services/conversion_service.dart';
import '../utils/formatters.dart';
import '../widgets/category_chip_bar.dart';
import '../widgets/converter_input_bar.dart';
import '../widgets/conversion_results_list.dart';
import '../widgets/swap_button.dart';

class ConverterScreen extends StatefulWidget {
  final UnitCategory? initialCategory;

  const ConverterScreen({super.key, this.initialCategory});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _initialized = false;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.initialCategory != null) {
      _initialized = true;
      context.read<ConverterProvider>().setCategory(widget.initialCategory!);
    }
  }

  void _onCategorySelected(BuildContext context, UnitCategory category) {
    context.read<ConverterProvider>().setCategory(category);
    _inputController.clear();
    HapticFeedback.selectionClick();
    _inputFocusNode.requestFocus();
  }

  void _onInputChanged(String value) {
    context.read<ConverterProvider>().setInput(value);
  }

  void _onUnitChanged(UnitModel unit) {
    context.read<ConverterProvider>().setFromUnit(unit);
  }

  void _onResultTap(
    ConverterProvider converter,
    HistoryProvider historyProvider,
    UnitModel unit,
    ConversionResult? result,
  ) {
    if (result == null || !result.isValid || converter.fromUnit == null) {
      return;
    }
    final inputDouble = double.tryParse(converter.inputValue);
    if (inputDouble == null) return;

    historyProvider.addEntry(
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: converter.selectedCategory.displayName,
        inputValue: inputDouble,
        fromUnit: converter.fromUnit!.name,
        toUnit: unit.name,
        result: result.result,
        timestamp: DateTime.now(),
      ),
    );
  }

  List<({UnitModel unit, ConversionResult? result})> _computeAllResults(
    ConverterProvider converter,
  ) {
    final input = converter.inputValue;
    final from = converter.fromUnit;
    final category = converter.selectedCategory;
    final units = converter.currentUnits;

    if (input.isEmpty || from == null) {
      return units.map((u) => (unit: u, result: null)).toList();
    }

    final value = double.tryParse(input);
    if (value == null || value.isNaN || value.isInfinite) {
      return units
          .map((u) => (
                unit: u,
                result: ConversionResult.failure('Invalid'),
              ))
          .toList();
    }

    return units.map((u) {
      if (u == from) {
        final formatted = Formatters.formatResult(value);
        return (
          unit: u,
          result: ConversionResult.success(
            result: value,
            formattedResult: formatted,
            formula: '',
          ),
        );
      }
      return (
        unit: u,
        result: ConversionService.convert(value, from, u, category),
      );
    }).toList();
  }

  static const Map<UnitCategory, List<Color>> _categoryGradients = {
    UnitCategory.length: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    UnitCategory.weight: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.temperature: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    UnitCategory.area: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
    UnitCategory.volume: [Color(0xFFF59E0B), Color(0xFFD97706)],
    UnitCategory.speed: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.data: [Color(0xFFEC4899), Color(0xFFBE185D)],
    UnitCategory.time: [Color(0xFF6366F1), Color(0xFF4338CA)],
    UnitCategory.angle: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    UnitCategory.energy: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.power: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.pressure: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    UnitCategory.force: [Color(0xFF84CC16), Color(0xFF4D7C0F)],
    UnitCategory.frequency: [Color(0xFFEC4899), Color(0xFF9D174D)],
    UnitCategory.fuelEconomy: [Color(0xFF22D3EE), Color(0xFF0E7490)],
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ConverterProvider>(
      builder: (context, converter, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bool canPop = Navigator.of(context).canPop();
        final results = _computeAllResults(converter);

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // ── Premium gradient header (when pushed) ────────────
                  if (canPop)
                    _buildPremiumHeader(context, converter),

                  // ── Category chip bar (only as tab) ──────────────────
                  if (!canPop)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: CategoryChipBar(
                        categories: UnitCategory.values,
                        selected: converter.selectedCategory,
                        onSelected: (cat) =>
                            _onCategorySelected(context, cat),
                      ),
                    ),

                  // ── Input bar: value + source unit ───────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConverterInputBar(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      sourceUnit: converter.fromUnit,
                      units: converter.currentUnits,
                      onInputChanged: _onInputChanged,
                      onUnitChanged: _onUnitChanged,
                    ),
                  ),

                  // ── Swap button ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Center(
                      child: SwapButton(onSwap: converter.swapUnits),
                    ),
                  ),

                  // ── Results list ─────────────────────────────────────
                  Expanded(
                    child: ConversionResultsList(
                      results: results,
                      sourceUnit: converter.fromUnit,
                      isDark: isDark,
                      onResultTapped: (unit, result) => _onResultTap(
                        converter,
                        context.read<HistoryProvider>(),
                        unit,
                        result,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Premium gradient header bar shown when screen is pushed via Navigator.
  Widget _buildPremiumHeader(BuildContext context, ConverterProvider converter) {
    final category = widget.initialCategory ?? converter.selectedCategory;
    final gradientColors = _categoryGradients[category] ??
        [AppColors.primary, AppColors.primaryDark];
    final units = getUnits(category);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 24),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Text(
              category.icon,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${units.length} units',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
