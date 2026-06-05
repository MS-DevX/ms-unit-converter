/// Currency converter screen — real-time exchange rate conversion.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/currencies_data.dart';
import '../models/currency_model.dart';
import '../providers/currency_provider.dart';

/// Full-screen currency converter with live rate fetching.
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

  void _onTargetChanged(CurrencyModel? currency) {
    if (currency != null) {
      context.read<CurrencyProvider>().setToCurrency(currency);
    }
    HapticFeedback.selectionClick();
  }

  String _formatLastUpdated(DateTime? dt) {
    if (dt == null) return 'Not yet updated';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Updated just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Consumer<CurrencyProvider>(
      builder: (context, provider, _) {
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
                // ── Input row: amount + source ──────────────────────
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
                              color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.3) : AppColors.lightTextSecondary.withValues(alpha: 0.3),
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
                        child: _CurrencyDropdown(
                          value: provider.fromCurrency,
                          currencies: provider.currencies,
                          onChanged: _onSourceChanged,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Gradient connector bar with swap ───────────────
                _CurrencyConnectorBar(
                  onSwap: () {
                    provider.swap();
                    HapticFeedback.mediumImpact();
                  },
                ),

                // ── Result row: amount + target ─────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          child: Text(
                            provider.isLoading
                                ? '\u2014'
                                : '${provider.toCurrency?.symbol ?? ''} ${provider.resultDisplay}',
                            key: ValueKey('${provider.toCurrency?.code}_${provider.resultDisplay}'),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              color: provider.resultDisplay == '\u2014' || provider.resultDisplay == 'Invalid'
                                  ? (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.4) : AppColors.lightTextSecondary.withValues(alpha: 0.4))
                                  : AppColors.success,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _CurrencyDropdown(
                          value: provider.toCurrency,
                          currencies: provider.currencies,
                          onChanged: _onTargetChanged,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Info row: last updated + error ─────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      if (provider.isLoading)
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                        )
                      else ...[
                        Icon(
                          Icons.check_circle_rounded,
                          size: 12,
                          color: AppColors.success.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                      ],
                      const SizedBox(width: 4),
                      Text(
                        provider.isLoading ? 'Updating...' : _formatLastUpdated(provider.lastUpdated),
                        style: TextStyle(
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                      if (provider.error != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.warning,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Quick currency pairs ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Icon(
                          Icons.flash_on_rounded,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Quick Pairs',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickPairChip(
                        label: 'USD → EUR',
                        isDark: isDark,
                        onTap: () => _setPair('USD', 'EUR'),
                      ),
                      _QuickPairChip(
                        label: 'EUR → USD',
                        isDark: isDark,
                        onTap: () => _setPair('EUR', 'USD'),
                      ),
                      _QuickPairChip(
                        label: 'USD → GBP',
                        isDark: isDark,
                        onTap: () => _setPair('USD', 'GBP'),
                      ),
                      _QuickPairChip(
                        label: 'USD → JPY',
                        isDark: isDark,
                        onTap: () => _setPair('USD', 'JPY'),
                      ),
                      _QuickPairChip(
                        label: 'GBP → EUR',
                        isDark: isDark,
                        onTap: () => _setPair('GBP', 'EUR'),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── Refresh prompt ─────────────────────────────────
                if (!provider.isLoading && provider.lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      'Swipe down to refresh',
                      style: TextStyle(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.35),
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

  void _setPair(String fromCode, String toCode) {
    final provider = context.read<CurrencyProvider>();
    final from = currencyByCode(fromCode);
    final to = currencyByCode(toCode);
    if (from != null) provider.setFromCurrency(from);
    if (to != null) provider.setToCurrency(to);
    HapticFeedback.selectionClick();
  }
}

// ── Currency Dropdown ──────────────────────────────────────────────────

/// A compact dropdown for selecting a currency from the full list.
class _CurrencyDropdown extends StatelessWidget {
  final CurrencyModel? value;
  final List<CurrencyModel> currencies;
  final ValueChanged<CurrencyModel?> onChanged;
  final bool isDark;

  const _CurrencyDropdown({
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

// ── Connector Bar ─────────────────────────────────────────────────────

/// Gradient bar with swap button, styled to match the converter pattern.
class _CurrencyConnectorBar extends StatelessWidget {
  final VoidCallback onSwap;

  const _CurrencyConnectorBar({required this.onSwap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFFD97706)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.currency_exchange_rounded,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Exchange rate',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSwap,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.swap_vert_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Pair Chip ───────────────────────────────────────────────────

/// Tappable chip for a popular currency pair.
class _QuickPairChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _QuickPairChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.swap_horiz_rounded,
              size: 12,
              color: AppColors.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
