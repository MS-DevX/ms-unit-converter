/// Currency converter screen — shows all 30 currencies as a scrollable list.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../providers/currency_provider.dart';

/// Full-screen currency converter with real-time rates for all currencies.
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String value) {
    context.read<CurrencyProvider>().setInput(value);
  }

  void _onSourceChanged(CurrencyModel? currency) {
    if (currency != null) {
      context.read<CurrencyProvider>().setFromCurrency(currency);
    }
    HapticFeedback.selectionClick();
  }

  void _copyValue(CurrencyResultRow row) {
    final text = '${row.formattedResult} ${row.currency.symbol}';
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied ${row.currency.code} — $text'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
  }

  String _formatLastUpdated(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CurrencyProvider>(
      builder: (context, provider, _) {
        final results = provider.getAllResults();

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Currency',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              centerTitle: false,
              actions: [
                if (!provider.isLoading)
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Refresh rates',
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      provider.refreshRates();
                    },
                  ),
              ],
            ),
            body: Column(
              children: [
                // ── Input row: amount + source dropdown ────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _inputController,
                          focusNode: _inputFocusNode,
                          keyboardType: TextInputType.number,
                          onChanged: _onInputChanged,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                                  : AppColors.lightTextSecondary.withValues(alpha: 0.3),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _SourceDropdown(
                          value: provider.fromCurrency,
                          currencies: allCurrencies,
                          onChanged: _onSourceChanged,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Base rate indicator ────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                  child: Row(
                    children: [
                      if (provider.isLoading)
                        SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                                .withValues(alpha: 0.5),
                          ),
                        )
                      else ...[
                        Icon(
                          Icons.check_circle_rounded,
                          size: 10,
                          color: AppColors.success.withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 3),
                      ],
                      const SizedBox(width: 3),
                      Text(
                        provider.isLoading ? 'Updating...' : 'Updated ${_formatLastUpdated(provider.lastUpdated)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                              .withValues(alpha: 0.45),
                        ),
                      ),
                      if (!provider.isLoading && provider.baseRateDisplay != '\u2014') ...[
                        Text(
                          '  ·  ${provider.baseRateDisplay}',
                          style: TextStyle(
                            fontSize: 10,
                            color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                                .withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                      if (provider.error != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.warning,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Quick source switches ──────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'INR', 'AUD', 'CAD', 'CHF', 'BRL',
                      ].map((code) {
                        final currency = currencyByCode(code);
                        final isSelected = provider.fromCurrency?.code == code;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: currency == null
                                ? null
                                : () => _onSourceChanged(currency),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // ── Results list ───────────────────────────────────
                const SizedBox(height: 12),
                Expanded(
                  child: _CurrencyResultsList(
                    results: results,
                    sourceCode: provider.fromCurrency?.code,
                    isDark: isDark,
                    onRowTapped: _copyValue,
                  ),
                ),
                if (provider.isLoading && results.isEmpty)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Source Dropdown ─────────────────────────────────────────────────

class _SourceDropdown extends StatelessWidget {
  final CurrencyModel? value;
  final List<CurrencyModel> currencies;
  final ValueChanged<CurrencyModel?> onChanged;
  final bool isDark;

  const _SourceDropdown({
    required this.value,
    required this.currencies,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CurrencyModel>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          items: currencies.map((c) {
            return DropdownMenuItem<CurrencyModel>(
              value: c,
              child: Text(
                '${c.flag} ${c.code}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ── Results List ────────────────────────────────────────────────────

/// Scrollable list showing converted values for all currencies.
class _CurrencyResultsList extends StatelessWidget {
  final List<CurrencyResultRow> results;
  final String? sourceCode;
  final bool isDark;
  final void Function(CurrencyResultRow row) onRowTapped;

  const _CurrencyResultsList({
    required this.results,
    required this.sourceCode,
    required this.isDark,
    required this.onRowTapped,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'Enter an amount to convert',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                .withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: results.length,
      separatorBuilder: (_, _) => Divider(
        height: 0.5,
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
        color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
      ),
      itemBuilder: (context, index) {
        final row = results[index];
        final isSource = row.currency.code == sourceCode;

        return GestureDetector(
          onTap: () => onRowTapped(row),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: isSource
                ? (isDark
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.06))
                : Colors.transparent,
            child: Row(
              children: [
                Text(
                  row.currency.flag,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 42,
                  child: Text(
                    row.currency.code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.currency.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                          .withValues(alpha: 0.6),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  row.formattedResult,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isSource
                        ? AppColors.primary
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  row.currency.symbol,
                  style: TextStyle(
                    fontSize: 12,
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        .withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
