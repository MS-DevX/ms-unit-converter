/// Currency converter screen — shows all supported currencies as a scrollable
/// list with search, pinned quick pairs, data-source attribution, and share.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/colors.dart';
import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../providers/currency_provider.dart';
import '../widgets/empty_state_widget.dart';

/// Full-screen currency converter with real-time rates for all currencies.
class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _inputController.text = '1';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
  }

  void _shareValue(CurrencyResultRow row, double amount, String sourceCode) {
    HapticFeedback.lightImpact();
    final text =
        '$amount $sourceCode = ${row.formattedResult} ${row.currency.code}';
    Share.share(text, subject: 'Currency conversion');
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await context.read<CurrencyProvider>().refreshRates();
  }

  String _formatLastUpdated(DateTime? dt) {
    if (dt == null) return 'Never';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// Quick preset conversion pairs shown as chips.
  static const List<(String source, String target)> _quickPairs = [
    ('USD', 'PKR'),
    ('PKR', 'USD'),
    ('AED', 'PKR'),
    ('SAR', 'PKR'),
    ('GBP', 'PKR'),
    ('EUR', 'PKR'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<CurrencyProvider>(
      builder: (context, provider, _) {
        final allResults = provider.getAllResults();
        final query = _searchController.text.toLowerCase().trim();
        final results = query.isEmpty
            ? allResults
            : allResults.where((r) {
                final c = r.currency;
                return c.code.toLowerCase().contains(query) ||
                    c.name.toLowerCase().contains(query) ||
                    c.symbol.toLowerCase().contains(query);
              }).toList();

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
            body: Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  displacement: 60,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // ── Input row: amount + source dropdown ────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _inputController,
                                      focusNode: _inputFocusNode,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      onChanged: _onInputChanged,
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                        height: 1.2,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        hintStyle: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                                    .withValues(alpha: 0.3)
                                              : AppColors.lightTextSecondary
                                                    .withValues(alpha: 0.3),
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
                                      currencies: provider.currencies,
                                      onChanged: _onSourceChanged,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Status row ────────────────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                              child: Row(
                                children: [
                                  if (provider.isLoading)
                                    SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color:
                                            (isDark
                                                    ? AppColors
                                                          .darkTextSecondary
                                                    : AppColors
                                                          .lightTextSecondary)
                                                .withValues(alpha: 0.7),
                                      ),
                                    )
                                  else if (provider.isOffline)
                                    Icon(
                                      Icons.wifi_off_rounded,
                                      size: 12,
                                      color: AppColors.warning.withValues(
                                        alpha: 0.7,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.check_circle_rounded,
                                      size: 12,
                                      color: AppColors.success.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider.isLoading
                                        ? 'Updating\u2026'
                                        : provider.isUsingCached
                                        ? 'Using cached rates'
                                        : 'Updated ${_formatLastUpdated(provider.lastUpdated)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          provider.isOffline &&
                                              !provider.isLoading
                                          ? AppColors.warning.withValues(
                                              alpha: 0.8,
                                            )
                                          : (isDark
                                                    ? AppColors
                                                          .darkTextSecondary
                                                    : AppColors
                                                          .lightTextSecondary)
                                                .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  if (!provider.isLoading &&
                                      !provider.isOffline &&
                                      provider.baseRateDisplay != '\u2014') ...[
                                    Text(
                                      '  \u00b7  ${provider.baseRateDisplay}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            (isDark
                                                    ? AppColors
                                                          .darkTextSecondary
                                                    : AppColors
                                                          .lightTextSecondary)
                                                .withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                  if (!provider.isLoading &&
                                      provider.isOffline &&
                                      provider.baseRateDisplay != '\u2014') ...[
                                    Text(
                                      '  \u00b7  ${provider.baseRateDisplay}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.warning.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (provider.error != null) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        provider.error!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.warning,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // ── Data source label ─────────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    size: 10,
                                    color:
                                        (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.lightTextSecondary)
                                            .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Powered by Frankfurter API',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                        .lightTextSecondary)
                                              .withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Search field ──────────────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                              child: SizedBox(
                                height: 36,
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search currencies…',
                                    hintStyle: TextStyle(
                                      fontSize: 13,
                                      color:
                                          (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                        .lightTextSecondary)
                                              .withValues(alpha: 0.5),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 18,
                                      color:
                                          (isDark
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                        .lightTextSecondary)
                                              .withValues(alpha: 0.5),
                                    ),
                                    suffixIcon:
                                        _searchController.text.isNotEmpty
                                        ? GestureDetector(
                                            onTap: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            child: Icon(
                                              Icons.clear_rounded,
                                              size: 18,
                                              color:
                                                  (isDark
                                                          ? AppColors
                                                                .darkTextSecondary
                                                          : AppColors
                                                                .lightTextSecondary)
                                                      .withValues(alpha: 0.5),
                                            ),
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkSurface
                                        : AppColors.lightSurface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.borderDark
                                            : AppColors.borderLight,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 0,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ),

                            // ── Quick conversion pairs ────────────────
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                              child: SizedBox(
                                height: 32,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: _quickPairs.map((pair) {
                                    final (source, target) = pair;
                                    final cSource = currencyByCode(source);
                                    final isSelected =
                                        provider.fromCurrency?.code == source;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: GestureDetector(
                                        onTap: cSource == null
                                            ? null
                                            : () => _onSourceChanged(cSource),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.primary
                                                : (isDark
                                                      ? AppColors.darkSurface
                                                      : AppColors.lightSurface),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : (isDark
                                                        ? AppColors.borderDark
                                                        : AppColors
                                                              .borderLight),
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? Colors.white
                                                    : (isDark
                                                          ? AppColors
                                                                .darkTextSecondary
                                                          : AppColors
                                                                .lightTextSecondary),
                                              ),
                                              children: [
                                                TextSpan(text: source),
                                                TextSpan(
                                                  text: ' → ',
                                                  style: TextStyle(
                                                    color: isSelected
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.7,
                                                              )
                                                        : (isDark
                                                                  ? AppColors
                                                                        .darkTextSecondary
                                                                  : AppColors
                                                                        .lightTextSecondary)
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: target,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: isSelected
                                                        ? Colors.white
                                                              .withValues(
                                                                alpha: 0.85,
                                                              )
                                                        : (isDark
                                                                  ? AppColors
                                                                        .darkTextSecondary
                                                                  : AppColors
                                                                        .lightTextSecondary)
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),

                      // ── Results list ───────────────────────────────────
                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: results.isEmpty
                            ? EmptyStateWidget(
                                icon: provider.isLoading
                                    ? Icons.hourglass_empty_rounded
                                    : query.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.currency_exchange_rounded,
                                message: provider.isLoading
                                    ? 'Loading rates\u2026'
                                    : query.isNotEmpty
                                    ? 'No currency found'
                                    : 'Enter an amount to convert',
                                subtitle: provider.isLoading
                                    ? 'Fetching live exchange rates'
                                    : query.isNotEmpty
                                    ? 'Try a different search term'
                                    : provider.error ??
                                        'Type an amount above to see conversions',
                              )
                            : _CurrencyResultsList(
                                results: results,
                                sourceCode: provider.fromCurrency?.code,
                                inputAmount: () {
                                  final parsed = double.tryParse(
                                    provider.inputValue,
                                  );
                                  return parsed ?? 0;
                                }(),
                                isDark: isDark,
                                onRowTapped: _copyValue,
                                onShareTapped: _shareValue,
                              ),
                      ),
                    ],
                  ),
                ),
                if (provider.isLoading && results.isEmpty)
                  const Positioned(
                    top: 120,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
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
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
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
  final double inputAmount;
  final bool isDark;
  final void Function(CurrencyResultRow row) onRowTapped;
  final void Function(CurrencyResultRow row, double amount, String sourceCode)
  onShareTapped;

  const _CurrencyResultsList({
    required this.results,
    required this.sourceCode,
    required this.inputAmount,
    required this.isDark,
    required this.onRowTapped,
    required this.onShareTapped,
  });

  @override
  Widget build(BuildContext context) {
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

        return Semantics(
          label:
              '${row.currency.code}: ${row.formattedResult} ${row.currency.symbol}',
          button: true,
          onTap: () => onRowTapped(row),
          child: GestureDetector(
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
                  Text(row.currency.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 42,
                    child: Text(
                      row.currency.code,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      row.currency.name,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary)
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
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    row.currency.symbol,
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Share button ──────────────────────────────
                  Semantics(
                    label: 'Share ${row.currency.code}',
                    button: true,
                    child: GestureDetector(
                      onTap: () =>
                          onShareTapped(row, inputAmount, sourceCode ?? ''),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkTextSecondary.withValues(
                                  alpha: 0.15,
                                )
                              : AppColors.lightTextSecondary.withValues(
                                  alpha: 0.12,
                                ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.share_outlined,
                          size: 14,
                          color:
                              (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary)
                                  .withValues(alpha: 0.7),
                        ),
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
}
