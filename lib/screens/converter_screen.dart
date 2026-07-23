import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../providers/favorites_provider.dart';
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
import '../widgets/converter_connector_bar.dart';

class ConverterScreen extends StatefulWidget {
  final UnitCategory? initialCategory;
  final double? presetValue;
  final String? presetFromUnitName;
  final String? presetToUnitName;

  const ConverterScreen({
    super.key,
    this.initialCategory,
    this.presetValue,
    this.presetFromUnitName,
    this.presetToUnitName,
  });

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _initialized = false;
  bool _formulaExpanded = false;

  Timer? _historyDebounce;
  String _lastHistorySignature = '';

  @override
  void dispose() {
    _historyDebounce?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.initialCategory != null) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final converter = context.read<ConverterProvider>();
        converter.setCategory(widget.initialCategory!);
        _applyPreset(converter);
      });
    }
  }

  void _applyPreset(ConverterProvider converter) {
    final value = widget.presetValue;
    final fromName = widget.presetFromUnitName;
    final toName = widget.presetToUnitName;
    if (value == null || fromName == null || toName == null) return;

    final units = converter.currentUnits;
    final matchedFrom = units.where((u) => u.name == fromName).toList();
    final matchedTo = units.where((u) => u.name == toName).toList();

    if (matchedFrom.isNotEmpty) converter.setFromUnit(matchedFrom.first);
    if (matchedTo.isNotEmpty) converter.setToUnit(matchedTo.first);

    final text = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
    _inputController.text = text;
    converter.setInput(text);
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

  void _onRawInputChanged(String value) {
    context.read<ConverterProvider>().setRawInput(value);
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
        fromSymbol: converter.fromUnit!.symbol,
        toSymbol: unit.symbol,
        result: result.result,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _autoSaveHistory(ConverterProvider converter) {
    final result = converter.result;
    if (result == null || !result.isValid) return;

    final inputDouble = double.tryParse(converter.inputValue);
    if (inputDouble == null) return;

    final fromUnit = converter.fromUnit;
    final toUnit = converter.toUnit;
    if (fromUnit == null || toUnit == null) return;

    final signature =
        '${converter.inputValue}|${fromUnit.name}|${toUnit.name}|${converter.selectedCategory.displayName}';
    if (signature == _lastHistorySignature) return;

    _historyDebounce?.cancel();
    _historyDebounce = Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      _lastHistorySignature = signature;
      context.read<HistoryProvider>().addEntry(
        HistoryEntry(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          category: converter.selectedCategory.displayName,
          inputValue: inputDouble,
          fromUnit: fromUnit.name,
          toUnit: toUnit.name,
          fromSymbol: fromUnit.symbol,
          toSymbol: toUnit.symbol,
          result: result.result,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _onBaseFontSizeChanged(String value, ConverterProvider converter) {
    final parsed = double.tryParse(value);
    if (parsed != null && parsed > 0) {
      converter.setBaseFontSize(parsed);
    }
  }

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

  List<({UnitModel unit, ConversionResult? result})> _computeAllResults(
    ConverterProvider converter,
  ) {
    final input = converter.inputValue;
    final rawInput = converter.rawInput;
    final from = converter.fromUnit;
    final category = converter.selectedCategory;
    final units = converter.currentUnits;

    if (input.isEmpty && rawInput.isEmpty || from == null) {
      return units.map((u) => (unit: u, result: null)).toList();
    }

    // ── Number Base: pass raw text ──────────────────────────────────
    if (category == UnitCategory.numberBase) {
      final inputStr = rawInput.isEmpty ? input : rawInput;
      if (inputStr.isEmpty) {
        return units.map((u) => (unit: u, result: null)).toList();
      }
      final fromRadix = _radixForUnit(from.name);
      if (fromRadix == null) {
        return units
            .map((u) => (unit: u, result: ConversionResult.failure('Invalid')))
            .toList();
      }
      final parsedValue = int.tryParse(inputStr, radix: fromRadix);
      if (parsedValue == null) {
        return units
            .map((u) => (unit: u, result: ConversionResult.failure('Invalid')))
            .toList();
      }
      return units.map((u) {
        if (u == from) {
          return (
            unit: u,
            result: ConversionResult.success(
              result: 0,
              formattedResult: inputStr,
              formula: '',
            ),
          );
        }
        final toRadix = _radixForUnit(u.name);
        if (toRadix == null) {
          return (unit: u, result: ConversionResult.failure('Invalid'));
        }
        final resultStr = parsedValue.toRadixString(toRadix).toUpperCase();
        return (
          unit: u,
          result: ConversionResult.success(
            result: parsedValue.toDouble(),
            formattedResult: '$resultStr (base $toRadix)',
            formula: '$inputStr (base $fromRadix) = $resultStr (base $toRadix)',
          ),
        );
      }).toList();
    }

    final value = double.tryParse(input);
    if (value == null || value.isNaN || value.isInfinite) {
      return units
          .map((u) => (unit: u, result: ConversionResult.failure('Invalid')))
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

      // ── Cooking: check cross-group error ────────────────────────
      if (category == UnitCategory.cooking) {
        final err = ConversionService.cookingGroupError(from, u);
        if (err != null) {
          return (unit: u, result: ConversionResult.failure(err));
        }
      }

      // ── Clothing: pass isMenSize ────────────────────────────────
      if (category == UnitCategory.clothingSize) {
        final result = _clothingResult(value, from, u, converter.isMenSize);
        return (unit: u, result: result);
      }

      // ── Typography: pass baseFontSize ────────────────────────────
      if (category == UnitCategory.typography) {
        final result = _typographyResult(
          value,
          from,
          u,
          converter.baseFontSize,
        );
        return (unit: u, result: result);
      }

      return (
        unit: u,
        result: ConversionService.convert(value, from, u, category),
      );
    }).toList();
  }

  ConversionResult _clothingResult(
    double value,
    UnitModel from,
    UnitModel to,
    bool isMen,
  ) {
    if (to.isSpecialCase || from.isSpecialCase) {
      final result = _convertClothingDirect(value, from, to, isMen);
      if (result.isNaN || result.isInfinite) {
        return ConversionResult.failure('Invalid');
      }
      final formatted = Formatters.formatResult(result);
      return ConversionResult.success(
        result: result,
        formattedResult: formatted,
        formula:
            '${Formatters.formatResult(value)} ${from.symbol} = $formatted ${to.symbol}',
      );
    }
    return ConversionService.convert(
      value,
      from,
      to,
      UnitCategory.clothingSize,
    );
  }

  static double _convertClothingDirect(
    double value,
    UnitModel from,
    UnitModel to,
    bool isMen,
  ) {
    if (from.name == to.name) return value;
    double us;
    switch (from.name) {
      case 'US':
        us = value;
        break;
      case 'EU':
        us = isMen ? value - 10 : value - 30;
        break;
      case 'UK':
        us = isMen ? value + 1 : value - 4;
        break;
      case 'Asian':
        us = value - 5;
        break;
      default:
        return double.nan;
    }
    switch (to.name) {
      case 'US':
        return us;
      case 'EU':
        return isMen ? us + 10 : us + 30;
      case 'UK':
        return isMen ? us - 1 : us + 4;
      case 'Asian':
        return us + 5;
      default:
        return double.nan;
    }
  }

  ConversionResult _typographyResult(
    double value,
    UnitModel from,
    UnitModel to,
    double baseFontSize,
  ) {
    if (to.isSpecialCase || from.isSpecialCase) {
      final result = _convertTypographyDirect(value, from, to, baseFontSize);
      if (result.isNaN || result.isInfinite) {
        return ConversionResult.failure('Invalid');
      }
      final formatted = Formatters.formatResult(result);
      return ConversionResult.success(
        result: result,
        formattedResult: formatted,
        formula:
            '${Formatters.formatResult(value)} ${from.symbol} = $formatted ${to.symbol}',
      );
    }
    return ConversionService.convert(value, from, to, UnitCategory.typography);
  }

  static double _convertTypographyDirect(
    double value,
    UnitModel from,
    UnitModel to,
    double baseFontSize,
  ) {
    if (from.name == to.name) return value;
    double px;
    switch (from.name) {
      case 'Pixels':
      case 'DP':
      case 'Points':
      case 'Inch':
      case 'Centimeter':
      case 'Millimeter':
      case 'Pica':
        px = value * from.toBase;
        break;
      case 'EM':
      case 'REM':
        px = value * baseFontSize;
        break;
      case 'Percent':
        px = (value / 100) * baseFontSize;
        break;
      default:
        return double.nan;
    }
    switch (to.name) {
      case 'Pixels':
      case 'DP':
      case 'Points':
      case 'Inch':
      case 'Centimeter':
      case 'Millimeter':
      case 'Pica':
        return px / to.toBase;
      case 'EM':
      case 'REM':
        return px / baseFontSize;
      case 'Percent':
        return (px / baseFontSize) * 100;
      default:
        return double.nan;
    }
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
    UnitCategory.cooking: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.shoeSize: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.clothingSize: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.numberBase: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.typography: [Color(0xFF6366F1), Color(0xFF4338CA)],
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<ConverterProvider>(
      builder: (context, converter, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bool canPop = Navigator.of(context).canPop();
        final results = _computeAllResults(converter);
        _autoSaveHistory(converter);
        final isNumberBase =
            converter.selectedCategory == UnitCategory.numberBase;
        final isClothing =
            converter.selectedCategory == UnitCategory.clothingSize;
        final isTypography =
            converter.selectedCategory == UnitCategory.typography;

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  if (canPop) _buildPremiumHeader(context, converter),

                  if (!canPop)
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 12),
                      child: CategoryChipBar(
                        categories: UnitCategory.values,
                        selected: converter.selectedCategory,
                        onSelected: (cat) => _onCategorySelected(context, cat),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ConverterInputBar(
                      controller: _inputController,
                      focusNode: _inputFocusNode,
                      sourceUnit: converter.fromUnit,
                      units: converter.currentUnits,
                      onInputChanged: isNumberBase
                          ? _onRawInputChanged
                          : _onInputChanged,
                      onUnitChanged: _onUnitChanged,
                      keyboardType: isNumberBase ? TextInputType.text : null,
                    ),
                  ),

                  // ── Clothing: Men/Women toggle ─────────────────────
                  if (isClothing)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildToggleChip('Men', true, converter),
                          const SizedBox(width: 8),
                          _buildToggleChip('Women', false, converter),
                        ],
                      ),
                    ),

                  // ── Typography: base font size input ───────────────
                  if (isTypography)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Base font:',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 60,
                            child: TextField(
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.inputBorderDark
                                        : AppColors.inputBorderLight,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                              controller:
                                  TextEditingController(
                                      text: converter.baseFontSize
                                          .toStringAsFixed(0),
                                    )
                                    ..selection = TextSelection.collapsed(
                                      offset: converter.baseFontSize
                                          .toStringAsFixed(0)
                                          .length,
                                    ),
                              onChanged: (v) =>
                                  _onBaseFontSizeChanged(v, converter),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'px',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                  ConverterConnectorBar(
                    gradientColors:
                        _categoryGradients[converter.selectedCategory] ??
                        [AppColors.primary, AppColors.primaryDark],
                    onSwap: converter.swapUnits,
                  ),

                  _buildFormulaCard(context, converter),

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

  Widget _buildToggleChip(
    String label,
    bool isMen,
    ConverterProvider converter,
  ) {
    final selected = converter.isMenSize == isMen;
    return GestureDetector(
      onTap: () => converter.setIsMenSize(isMen),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.inputBorderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.darkTextSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumHeader(
    BuildContext context,
    ConverterProvider converter,
  ) {
    final category = widget.initialCategory ?? converter.selectedCategory;
    final gradientColors =
        _categoryGradients[category] ??
        [AppColors.primary, AppColors.primaryDark];
    final units = getUnits(category);
    final favProv = context.read<FavoritesProvider>();
    final isFav = favProv.isFavorite(category);

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
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              tooltip: 'Back',
            ),
            const SizedBox(width: 4),
            Text(category.icon, style: const TextStyle(fontSize: 28)),
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
            IconButton(
              icon: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? Colors.amber : Colors.white,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                favProv.toggleFavorite(category);
              },
              tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCard(BuildContext context, ConverterProvider converter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = widget.initialCategory ?? converter.selectedCategory;
    final explanation = category.formulaExplanation;
    final textColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: () {
          setState(() => _formulaExpanded = !_formulaExpanded);
          HapticFeedback.selectionClick();
        },
        child: AnimatedCrossFade(
          firstChild: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: textColor,
                ),
              ],
            ),
          ),
          secondChild: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'How it works',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 18,
                      color: textColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  explanation,
                  style: TextStyle(fontSize: 13, color: textColor, height: 1.5),
                ),
              ],
            ),
          ),
          crossFadeState: _formulaExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ),
    );
  }
}
