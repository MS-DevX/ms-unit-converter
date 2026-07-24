/// History Screen — Pixel-perfect implementation of Google Stitch Material Design 3 export.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../providers/history_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedFilterIndex = 0; // 0: All, 1: Units, 2: Currency

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear History?',
          style: TextStyle(color: AppColors.onSurface),
        ),
        content: const Text(
          'This will permanently delete all your stored conversion history.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorContainer,
              foregroundColor: AppColors.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await context.read<HistoryProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProv = context.watch<HistoryProvider>();
    final query = _searchController.text.trim().toLowerCase();

    var entries = historyProv.entries;

    if (query.isNotEmpty) {
      entries = entries.where((e) {
        return e.category.toLowerCase().contains(query) ||
            e.fromUnit.toLowerCase().contains(query) ||
            e.toUnit.toLowerCase().contains(query) ||
            e.fromSymbol.toLowerCase().contains(query) ||
            e.toSymbol.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedFilterIndex == 1) {
      entries = entries.where((e) => e.category != 'Currency').toList();
    } else if (_selectedFilterIndex == 2) {
      entries = entries.where((e) => e.category == 'Currency').toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH & FILTER BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  StitchSearchBar(
                    controller: _searchController,
                    hintText: 'Search conversions...',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedFilterIndex == 0,
                        onTap: () => setState(() => _selectedFilterIndex = 0),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Units',
                        isSelected: _selectedFilterIndex == 1,
                        onTap: () => setState(() => _selectedFilterIndex = 1),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Currency',
                        isSelected: _selectedFilterIndex == 2,
                        onTap: () => setState(() => _selectedFilterIndex = 2),
                      ),
                      const Spacer(),
                      if (historyProv.entries.isNotEmpty)
                        GestureDetector(
                          onTap: () => _confirmClearAll(context),
                          child: Row(
                            children: const [
                              Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // HISTORY LIST / TIMELINE
            Expanded(
              child: entries.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.history_rounded,
                      message: 'No conversion history',
                      subtitle: 'Conversions you perform will appear here.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];
                        final cat = entry.categoryEnum;

                        return Dismissible(
                          key: Key(entry.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) {
                            historyProv.removeEntry(entry.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: AppColors.error,
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: StitchCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(cat),
                                      color: AppColors.onSecondaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${Formatters.cleanFloatingPoint(entry.inputValue)} ${entry.fromSymbol}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: AppColors.outline,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${Formatters.cleanFloatingPoint(entry.result)} ${entry.toSymbol}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${entry.category} • Saved',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      color: AppColors.onSurfaceVariant,
                                      size: 18,
                                    ),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                        text:
                                            '${Formatters.cleanFloatingPoint(entry.inputValue)} ${entry.fromSymbol} = ${Formatters.cleanFloatingPoint(entry.result)} ${entry.toSymbol}',
                                      ));
                                      HapticFeedback.lightImpact();
                                      ScaffoldMessenger.of(context).clearSnackBars();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Copied result to clipboard'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
