/// Converter Screen — High precision unit conversion screen with Material 3 polish.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/usage_provider.dart';
import '../utils/formatters.dart';
import '../widgets/stitch_card.dart';

class ConverterScreen extends StatefulWidget {
  final UnitCategory? initialCategory;
  final double? presetValue;
  final String? presetFromUnitName;
  final String? presetToUnitName;
  final bool isCompanion;

  const ConverterScreen({
    super.key,
    this.initialCategory,
    this.presetValue,
    this.presetFromUnitName,
    this.presetToUnitName,
    this.isCompanion = false,
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ConverterProvider>().addListener(_onConverterChanged);
      }
    });
  }

  void _onConverterChanged() {
    if (!mounted) return;
    _autoSaveHistory(context.read<ConverterProvider>());
  }

  @override
  void dispose() {
    _historyDebounce?.cancel();
    _inputController.dispose();
    _inputFocusNode.dispose();
    try {
      context.read<ConverterProvider>().removeListener(_onConverterChanged);
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.initialCategory != null) {
      _initialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final converter = context.read<ConverterProvider>();
        converter.setCategory(widget.initialCategory!);
        context.read<UsageProvider>().trackCategoryUsage(widget.initialCategory!);

        if (widget.presetValue != null) {
          _applyPreset(converter, widget.presetValue!, widget.presetFromUnitName, widget.presetToUnitName);
        } else {
          _inputController.text = converter.inputValue;
        }
      });
    }
  }

  void _applyPreset(
    ConverterProvider converter,
    double value,
    String? fromName,
    String? toName,
  ) {
    final units = converter.currentUnits;
    if (units.isEmpty) return;

    final matchedFrom = fromName != null
        ? units.where((u) => u.name.toLowerCase() == fromName.toLowerCase()).toList()
        : <dynamic>[];
    if (matchedFrom.isNotEmpty) converter.setFromUnit(matchedFrom.first);

    final matchedTo = toName != null
        ? units.where((u) => u.name.toLowerCase() == toName.toLowerCase()).toList()
        : <dynamic>[];
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
          category: widget.isCompanion ? 'Unit Companion' : converter.selectedCategory.displayName,
          fromUnit: fromUnit.name,
          fromSymbol: fromUnit.symbol,
          toUnit: toUnit.name,
          toSymbol: toUnit.symbol,
          inputValue: inputDouble,
          result: result.result,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  void _showUnitPicker(
    BuildContext context,
    ConverterProvider converter,
    bool isFromUnit,
  ) {
    final units = converter.currentUnits;
    final selectedUnit = isFromUnit ? converter.fromUnit : converter.toUnit;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
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
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    isFromUnit ? 'Select Source Unit' : 'Select Target Unit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
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
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                    ),
                    trailing: Text(
                      unit.symbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
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

  void _copyToClipboard(String text) {
    if (text.isEmpty || text == '—') return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied "$text" to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareResult(ConverterProvider converter) {
    final res = converter.result;
    if (res == null || !res.isValid) return;
    HapticFeedback.lightImpact();

    final fromSymbol = converter.fromUnit?.symbol ?? '';
    final toSymbol = converter.toUnit?.symbol ?? '';
    final text =
        '${converter.inputValue} $fromSymbol = ${Formatters.formatResult(res.result)} $toSymbol (${converter.selectedCategory.displayName}) via Unit Converter';

    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final converter = context.watch<ConverterProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    final fromUnit = converter.fromUnit;
    final toUnit = converter.toUnit;
    final res = converter.result;
    final resultStr = res != null && res.isValid
        ? Formatters.formatResult(res.result)
        : res != null && !res.isValid
            ? 'Invalid'
            : '0.00';

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: colorScheme.primary),
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: Text(
          converter.selectedCategory.displayName,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // MAIN CONVERSION CARD (FORMER STITCH CARD)
              StitchCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FROM SECTION HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'FROM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.language_rounded, size: 13, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                'Standard',
                                style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // FROM INPUT ROW
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            focusNode: _inputFocusNode,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                              height: 1.1,
                            ),
                            decoration: InputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.outline.withValues(alpha: 0.4),
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

                        const SizedBox(width: 12),

                        // ALIGNED UNIT SELECTOR BUTTON
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showUnitPicker(context, converter, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border(
                                  bottom: BorderSide(color: colorScheme.primary, width: 2),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      fromUnit?.name ?? 'Select',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.expand_more_rounded, color: colorScheme.primary, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // SWAP BUTTON
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          converter.swapUnits();
                          _inputController.text = converter.inputValue;
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.swap_vert_rounded,
                            color: colorScheme.onPrimary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TO SECTION HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // TO RESULT ROW
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
                                key: ValueKey(resultStr),
                                resultStr,
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // TO UNIT SELECTOR BUTTON
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showUnitPicker(context, converter, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.outlineVariant,
                                    width: 2,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.shadow.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      toUnit?.name ?? 'Select',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.expand_more_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ACTION BUTTONS GRID (COPY, SHARE, SWAP, SAVE)
              Row(
                children: [
                  Expanded(
                    child: StitchCard(
                      onTap: () => _copyToClipboard(resultStr),
                      backgroundColor: colorScheme.primaryContainer,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.content_copy_rounded, color: colorScheme.primary, size: 18),
                          const SizedBox(height: 3),
                          Text(
                            'Copy',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StitchCard(
                      onTap: () => _shareResult(converter),
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.share_rounded, color: colorScheme.onSurfaceVariant, size: 18),
                          const SizedBox(height: 3),
                          Text(
                            'Share',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
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
                      backgroundColor: colorScheme.surfaceContainerHigh,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.swap_horiz_rounded, color: colorScheme.onSurfaceVariant, size: 18),
                          const SizedBox(height: 3),
                          Text(
                            'Swap',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
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
                          backgroundColor: colorScheme.surfaceContainerHigh,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                color: isFav ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isFav ? 'Saved' : 'Save',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isFav ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
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

              // FORMULA CARD
              StitchCard(
                backgroundColor: colorScheme.surfaceContainerLow,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FORMULA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      res?.formula ?? '1 ${fromUnit?.symbol ?? ''} = ... ${toUnit?.symbol ?? ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QUICK PRESETS
              const Text(
                'Quick Presets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _PresetChip(
                      label: '1 ${fromUnit?.symbol ?? 'unit'}',
                      onTap: () {
                        _inputController.text = '1';
                        converter.setInput('1');
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetChip(
                      label: '10 ${fromUnit?.symbol ?? 'units'}',
                      onTap: () {
                        _inputController.text = '10';
                        converter.setInput('10');
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetChip(
                      label: '50 ${fromUnit?.symbol ?? 'units'}',
                      onTap: () {
                        _inputController.text = '50';
                        converter.setInput('50');
                      },
                    ),
                    const SizedBox(width: 8),
                    _PresetChip(
                      label: '100 ${fromUnit?.symbol ?? 'units'}',
                      onTap: () {
                        _inputController.text = '100';
                        converter.setInput('100');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      label: Text(label),
      onPressed: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
