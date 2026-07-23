/// Unit Converter Screen — Enhanced interactions matching Google Stitch specifications.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/decimal_precision_bar.dart';
import '../widgets/stitch_card.dart';

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
  Timer? _historyDebounce;
  String _lastHistorySignature = '';
  double _swapRotationAngle = 0.0;
  bool _isSwapPressed = false;

  static IconData _getCategoryIcon(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return Icons.straighten_rounded;
      case UnitCategory.weight:
        return Icons.monitor_weight_rounded;
      case UnitCategory.temperature:
        return Icons.thermostat_rounded;
      case UnitCategory.area:
        return Icons.area_chart_rounded;
      case UnitCategory.volume:
        return Icons.opacity_rounded;
      case UnitCategory.speed:
        return Icons.speed_rounded;
      case UnitCategory.data:
        return Icons.sd_card_rounded;
      case UnitCategory.time:
        return Icons.schedule_rounded;
      case UnitCategory.angle:
        return Icons.explore_rounded;
      case UnitCategory.energy:
        return Icons.bolt_rounded;
      case UnitCategory.power:
        return Icons.electric_bolt_rounded;
      case UnitCategory.pressure:
        return Icons.compress_rounded;
      case UnitCategory.force:
        return Icons.fitness_center_rounded;
      case UnitCategory.frequency:
        return Icons.graphic_eq_rounded;
      case UnitCategory.fuelEconomy:
        return Icons.local_gas_station_rounded;
      case UnitCategory.cooking:
        return Icons.soup_kitchen_rounded;
      case UnitCategory.shoeSize:
        return Icons.roller_skating_rounded;
      case UnitCategory.clothingSize:
        return Icons.checkroom_rounded;
      case UnitCategory.numberBase:
        return Icons.numbers_rounded;
      case UnitCategory.typography:
        return Icons.text_fields_rounded;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _inputFocusNode.requestFocus();
      }
    });
  }

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
        _inputFocusNode.requestFocus();
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

  void _copyToClipboard(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareResult(ConverterProvider converter) {
    final result = converter.result;
    if (result == null || !result.isValid) return;
    final from = converter.fromUnit;
    final to = converter.toUnit;
    if (from == null || to == null) return;

    final text =
        '${converter.inputValue} ${from.symbol} = ${result.formattedResult} ${to.symbol} (${converter.selectedCategory.displayName})';
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _showUnitPicker(
    BuildContext context,
    ConverterProvider converter,
    bool isFromUnit,
  ) {
    final units = converter.currentUnits;
    final selectedUnit = isFromUnit ? converter.fromUnit : converter.toUnit;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    isFromUnit ? 'Select Source Unit' : 'Select Target Unit',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: units.length,
                itemBuilder: (ctx, i) {
                  final unit = units[i];
                  final isSelected = unit == selectedUnit;

                  return ListTile(
                    title: Text(
                      unit.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                    trailing: Text(
                      unit.symbol,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isFromUnit) {
                        converter.setFromUnit(unit);
                      } else {
                        converter.setToUnit(unit);
                      }
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final converter = context.watch<ConverterProvider>();
    _autoSaveHistory(converter);

    final fromUnit = converter.fromUnit;
    final toUnit = converter.toUnit;
    final result = converter.result;
    final resultStr = result != null && result.isValid
        ? result.formattedResult
        : '0.00';

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          converter.selectedCategory.displayName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MAIN CONVERSION GLASS CARD
              StitchCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 20,
                child: Stack(
                  children: [
                    Positioned(
                      top: -10,
                      right: -10,
                      child: Opacity(
                        opacity: 0.06,
                        child: Icon(
                          _getCategoryIcon(converter.selectedCategory),
                          size: 140,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FROM SECTION HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'FROM',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.outlineVariant.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(Icons.language_rounded, size: 13, color: AppColors.onSurfaceVariant),
                                  SizedBox(width: 4),
                                  Text(
                                    'Standard',
                                    style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // FROM INPUT ROW — PROMINENT AUTO-FOCUSED 48px INPUT
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: screenWidth * 0.5,
                                  child: TextField(
                                    controller: _inputController,
                                    focusNode: _inputFocusNode,
                                    autofocus: true,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                      height: 1.1,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.outlineVariant,
                                        height: 1.1,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      filled: false,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    onChanged: (text) => converter.setInput(text),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ALIGNED RESPONSIVE UNIT SELECTOR
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.42,
                              ),
                              child: GestureDetector(
                                onTap: () => _showUnitPicker(context, converter, true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: const Border(
                                      bottom: BorderSide(color: AppColors.primary, width: 2),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          fromUnit?.name ?? 'Select',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.expand_more_rounded, color: AppColors.primary, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // SWAP BUTTON WITH HAPTIC & SCALE ANIMATION
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Divider(
                              color: AppColors.outlineVariant.withValues(alpha: 0.3),
                              thickness: 1,
                            ),
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isSwapPressed = true),
                              onTapUp: (_) => setState(() => _isSwapPressed = false),
                              onTapCancel: () => setState(() => _isSwapPressed = false),
                              onTap: () {
                                setState(() {
                                  _swapRotationAngle += 3.14159;
                                });
                                HapticFeedback.mediumImpact();
                                converter.swapUnits();
                                _inputController.text = converter.inputValue;
                              },
                              child: AnimatedScale(
                                scale: _isSwapPressed ? 0.90 : 1.0,
                                duration: const Duration(milliseconds: 150),
                                curve: Curves.easeOut,
                                child: AnimatedRotation(
                                  turns: _swapRotationAngle / (2 * 3.14159),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x40000000),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.swap_vert_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // TO SECTION HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'TO',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurfaceVariant,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // TO RESULT ROW — ANIMATED FADE & SCALE TRANSITION ON RESULT CHANGE
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (child, anim) {
                                    return FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(
                                        scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim),
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    resultStr,
                                    key: ValueKey(resultStr),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      height: 1.1,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // ALIGNED RESPONSIVE UNIT SELECTOR
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth * 0.42,
                              ),
                              child: GestureDetector(
                                onTap: () => _showUnitPicker(context, converter, false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          toUnit?.name ?? 'Select',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // COMPACT ACTION BUTTONS GRID WITH HAPTIC FEEDBACK (COPY, SHARE, SWAP, SAVE)
              Row(
                children: [
                  Expanded(
                    child: StitchCard(
                      onTap: () => _copyToClipboard(resultStr),
                      backgroundColor: AppColors.primaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.content_copy_rounded, color: AppColors.primary, size: 18),
                          SizedBox(width: 0, height: 3),
                          Text(
                            'Copy',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StitchCard(
                      onTap: () => _shareResult(converter),
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.share_rounded, color: AppColors.onSurfaceVariant, size: 18),
                          SizedBox(width: 0, height: 3),
                          Text(
                            'Share',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StitchCard(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        converter.swapUnits();
                        _inputController.text = converter.inputValue;
                      },
                      backgroundColor: AppColors.surface,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.swap_horiz_rounded, color: AppColors.onSurfaceVariant, size: 18),
                          SizedBox(width: 0, height: 3),
                          Text(
                            'Swap',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<FavoritesProvider>(
                    builder: (context, favProv, _) {
                      final isFav = favProv.isFavorite(converter.selectedCategory);
                      return Expanded(
                        child: StitchCard(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            favProv.toggleFavorite(converter.selectedCategory);
                          },
                          backgroundColor: AppColors.surface,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFav ? Colors.amber : AppColors.onSurfaceVariant,
                                size: 18,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isFav ? 'Saved' : 'Save',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isFav ? Colors.amber : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // REFINED FORMULA CARD
              StitchCard(
                backgroundColor: AppColors.surfaceContainerLow,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FORMULA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      converter.selectedCategory.formulaExplanation,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // RESPONSIVE DECIMAL PRECISION SELECTOR
              const DecimalPrecisionBar(),
            ],
          ),
        ),
      ),
    );
  }
}
