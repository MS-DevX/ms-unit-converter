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
                    // FROM CURRENCY
                    const Text(
                      'From',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, true),
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
                                    fromCurr.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fromCurr.code,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      fromCurr.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.expand_more_rounded, color: AppColors.primary),
                              ],
                            ),
                          ),

                          const Spacer(),

                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _amountController,
                              focusNode: _amountFocusNode,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                              decoration: const InputDecoration(
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
                        ],
                      ),
                    ),

                    // SWAP BUTTON
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
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
                    ),

                    // TO CURRENCY
                    const Text(
                      'To',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showCurrencyPicker(context, currencyProv, false),
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
                                    _targetCurrency.flag,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _targetCurrency.code,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _targetCurrency.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.expand_more_rounded, color: AppColors.onSurfaceVariant),
                              ],
                            ),
                          ),

                          const Spacer(),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                targetRow.formattedResult,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ALL CURRENCY RESULTS LIST
              const Text(
                'All Currencies',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              ...allResults.map((row) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: StitchCard(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _targetCurrency = row.currency;
                      });
                    },
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          '${row.currency.flag} ${row.currency.code}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          row.currency.name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              row.formattedResult,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Rate: ${row.formattedRate}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
