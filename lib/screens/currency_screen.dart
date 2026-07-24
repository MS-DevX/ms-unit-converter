/// Currency Exchange Screen — Pixel-perfect implementation of Google Stitch Material Design 3 export.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../providers/currency_provider.dart';
import '../widgets/stitch_card.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  CurrencyModel _targetCurrency = CurrenciesData.getByCode('EUR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CurrencyProvider>();
      _amountController.text = provider.inputValue;
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _showCurrencyPicker(
    BuildContext context,
    CurrencyProvider provider,
    bool isFromCurrency,
  ) {
    final currencies = provider.currencies.isNotEmpty
        ? provider.currencies
        : CurrenciesData.supportedCurrencies;
    final selectedCode = isFromCurrency
        ? (provider.fromCurrency?.code ?? 'USD')
        : _targetCurrency.code;

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
                    isFromCurrency ? 'Select Base Currency' : 'Select Target Currency',
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
                itemCount: currencies.length,
                itemBuilder: (ctx, i) {
                  final curr = currencies[i];
                  final isSelected = curr.code == selectedCode;

                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        curr.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(
                      '${curr.code} - ${curr.name}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected ? AppColors.primary : AppColors.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      curr.symbol,
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      if (isFromCurrency) {
                        provider.setFromCurrency(curr);
                      } else {
                        setState(() {
                          _targetCurrency = curr;
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
  }

  @override
  Widget build(BuildContext context) {
    final currencyProv = context.watch<CurrencyProvider>();
    final fromCurr = currencyProv.fromCurrency ?? CurrenciesData.getByCode('USD');
    final allResults = currencyProv.getAllResults();

    final targetRow = allResults.firstWhere(
      (r) => r.currency.code == _targetCurrency.code,
      orElse: () => allResults.isNotEmpty
          ? allResults.first
          : CurrencyResultRow(
              currency: _targetCurrency,
              rate: 1.0,
              convertedValue: 1.0,
              formattedResult: '1.00',
              formattedRate: '1.00',
            ),
    );

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        title: const Text(
          'Currency Exchange',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.onSurface),
            onPressed: () {
              HapticFeedback.mediumImpact();
              currencyProv.refreshRates();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // OFFLINE / SYNC STATUS HEADER CARD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.3),
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            currencyProv.isUsingCached
                                ? 'Using cached rates'
                                : 'Rates refreshed',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        currencyProv.refreshRates();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surfaceVariant,
                        foregroundColor: AppColors.onSurface,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Refresh'),
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
                      children: const [
                        Text(
                          'FROM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // FROM CURRENCY INPUT ROW — PROMINENT LEFT-ALIGNED INPUT
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
                                textAlign: TextAlign.start,
                                style: const TextStyle(
                                  fontSize: 44,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                  height: 1.1,
                                ),
                                decoration: const InputDecoration(
                                  hintText: '1.00',
                                  hintStyle: TextStyle(
                                    fontSize: 44,
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
                                onChanged: (text) {
                                  currencyProv.setInput(text);
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ALIGNED CURRENCY SELECTOR BUTTON ON RIGHT
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, true),
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
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x33000000),
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

                    // TO CURRENCY RESULT ROW — PROMINENT LEFT-ALIGNED RESULT
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
                              child: Column(
                                key: ValueKey(targetRow.formattedResult),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    targetRow.formattedResult,
                                    style: const TextStyle(
                                      fontSize: 44,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    '1 ${fromCurr.code} = ${targetRow.formattedRate} ${_targetCurrency.code}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // ALIGNED CURRENCY SELECTOR BUTTON ON RIGHT
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: screenWidth * 0.42,
                          ),
                          child: GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, false),
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
              ),

              const SizedBox(height: 24),

              // ALL LIVE RATES LIST HEADER
              const Text(
                'LIVE FX RATES',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 12),

              // LIST OF ALL OTHER CURRENCIES
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: allResults.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final row = allResults[i];
                  final isSelectedTarget = row.currency.code == _targetCurrency.code;

                  return StitchCard(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _targetCurrency = row.currency;
                      });
                    },
                    backgroundColor: isSelectedTarget
                        ? AppColors.primaryContainer.withValues(alpha: 0.5)
                        : AppColors.surfaceContainerLow,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceVariant,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            row.currency.flag,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${row.currency.code} — ${row.currency.name}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelectedTarget ? FontWeight.w700 : FontWeight.w500,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              Text(
                                '1 ${fromCurr.code} = ${row.formattedRate} ${row.currency.symbol}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${row.currency.symbol} ${row.formattedResult}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelectedTarget ? AppColors.primary : AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
