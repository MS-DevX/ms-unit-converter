/// Live FX Currency Exchange Screen — Real-time offline fallback with Frankfurter.app API.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../models/history_entry.dart';
import '../providers/currency_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/stitch_card.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController(text: '1');
  final FocusNode _amountFocusNode = FocusNode();
  CurrencyModel _targetCurrency = defaultCurrencies.firstWhere((c) => c.code == 'EUR');
  String _lastSavedSignature = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CurrencyProvider>().fetchRates();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _autoSaveHistory(CurrencyProvider currencyProv) {
    final fromCurr = currencyProv.fromCurrency ?? defaultCurrencies.first;
    final toCurr = _targetCurrency;
    final inputVal = double.tryParse(currencyProv.inputValue) ?? 1.0;
    final resultVal = currencyProv.convert(fromCurr, toCurr);

    final signature = '${currencyProv.inputValue}|${fromCurr.code}|${toCurr.code}';
    if (signature == _lastSavedSignature) return;
    _lastSavedSignature = signature;

    context.read<HistoryProvider>().addEntry(
      HistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        category: 'Currency',
        fromUnit: fromCurr.name,
        fromSymbol: fromCurr.symbol,
        toUnit: toCurr.name,
        toSymbol: toCurr.symbol,
        inputValue: inputVal,
        result: resultVal,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _showCurrencyPicker(
    BuildContext context,
    CurrencyProvider currencyProv,
    bool isFromCurrency,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedCode = isFromCurrency ? (currencyProv.fromCurrency?.code ?? 'USD') : _targetCurrency.code;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = defaultCurrencies.where((c) {
              return c.code.toLowerCase().contains(query) ||
                  c.name.toLowerCase().contains(query);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (ctx, scrollController) {
                return Column(
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
                            isFromCurrency ? 'Select Source Currency' : 'Select Target Currency',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setModalState(() {}),
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Search by currency name or code...',
                          hintStyle: TextStyle(color: colorScheme.outline),
                          prefixIcon: Icon(Icons.search_rounded, color: colorScheme.outline),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (ctx, index) {
                          final c = filtered[index];
                          final isSelected = c.code == selectedCode;

                          return ListTile(
                            leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                            title: Text(
                              '${c.code} — ${c.name}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              c.symbol,
                              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                            ),
                            trailing: Text(
                              c.symbol,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (isFromCurrency) {
                                currencyProv.setFromCurrency(c);
                              } else {
                                setState(() {
                                  _targetCurrency = c;
                                });
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProv = context.watch<CurrencyProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final fromCurr = currencyProv.fromCurrency ?? defaultCurrencies.first;
    final targetRow = currencyProv.getConvertedRow(_targetCurrency);

    _autoSaveHistory(currencyProv);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Exchange'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: () {
              HapticFeedback.mediumImpact();
              currencyProv.refreshRates();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // OFFLINE / SYNC STATUS HEADER CARD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      currencyProv.isOffline ? Icons.cloud_off_rounded : Icons.cloud_done_rounded,
                      color: currencyProv.isOffline ? AppColors.tertiary : AppColors.success,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currencyProv.isOffline ? 'Offline Mode' : 'Live FX Rates Active',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            currencyProv.isUsingCached ? 'Using cached rates' : 'Rates refreshed',
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        currencyProv.refreshRates();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // MAIN CURRENCY CONVERSION CARD
              StitchCard(
                borderRadius: 20,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FROM CURRENCY HEADER
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
                      ],
                    ),

                    const SizedBox(height: 12),

                    // FROM CURRENCY INPUT ROW
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
                                controller: _amountController,
                                focusNode: _amountFocusNode,
                                autofocus: true,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                                style: TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                  height: 1.1,
                                ),
                                decoration: InputDecoration(
                                  hintText: '1.00',
                                  hintStyle: TextStyle(
                                    fontSize: 44,
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
                                onChanged: (text) {
                                  currencyProv.setInput(text);
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ALIGNED CURRENCY SELECTOR BUTTON
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(16),
                                border: Border(
                                  bottom: BorderSide(color: colorScheme.primary, width: 2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    fromCurr.flag,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      fromCurr.code,
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
                          final temp = fromCurr;
                          currencyProv.setFromCurrency(_targetCurrency);
                          setState(() {
                            _targetCurrency = temp;
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x25000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // TO CURRENCY HEADER
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

                    // TO CURRENCY RESULT ROW
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
                                key: ValueKey(targetRow.formattedResult),
                                targetRow.formattedResult,
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

                        // TO CURRENCY SELECTOR BUTTON
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, false),
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
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _targetCurrency.flag,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _targetCurrency.code,
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

              const SizedBox(height: 24),

              // POPULAR FX RATES CAROUSEL
              Text(
                'Popular FX Rates',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              Column(
                children: defaultCurrencies
                    .where((c) => c.code != fromCurr.code && c.code != _targetCurrency.code)
                    .take(6)
                    .map((c) {
                  final row = currencyProv.getConvertedRow(c);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: StitchCard(
                      onTap: () {
                        setState(() {
                          _targetCurrency = c;
                        });
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Text(c.flag, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${c.code} — ${c.name}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  '1 ${fromCurr.code} = ${row.formattedRate} ${c.code}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            row.formattedResult,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
