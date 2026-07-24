/// Conversion History Screen — Material 3 filtering, search, and local SharedPreferences persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/history_provider.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';
import 'converter_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedFilterIndex = 0; // 0: All, 1: Units, 2: Currency

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openConverterForEntry(BuildContext context, HistoryEntry entry) {
    if (entry.categoryEnum == UnitCategory.length) {
      // Find matching category enum
      UnitCategory? matchedCategory;
      for (final cat in UnitCategory.values) {
        if (cat.displayName.toLowerCase() == entry.category.toLowerCase()) {
          matchedCategory = cat;
          break;
        }
      }

      if (matchedCategory != null) {
        final converter = context.read<ConverterProvider>();
        converter.setCategory(matchedCategory);

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ConverterScreen(
              initialCategory: matchedCategory,
              presetValue: entry.inputValue,
              presetFromUnitName: entry.fromUnit,
              presetToUnitName: entry.toUnit,
            ),
          ),
        );
      }
    }
  }

  void _confirmClearHistory(BuildContext context, HistoryProvider historyProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear History?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'This will delete all saved conversion history entries from local storage.',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              historyProv.clearHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyProv = context.watch<HistoryProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final searchQuery = _searchController.text.trim().toLowerCase();

    List<HistoryEntry> entries = historyProv.entries;

    if (searchQuery.isNotEmpty) {
      entries = entries.where((e) {
        return e.category.toLowerCase().contains(searchQuery) ||
            e.fromUnit.toLowerCase().contains(searchQuery) ||
            e.toUnit.toLowerCase().contains(searchQuery) ||
            e.fromSymbol.toLowerCase().contains(searchQuery) ||
            e.toSymbol.toLowerCase().contains(searchQuery);
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
        actions: [
          if (historyProv.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _confirmClearHistory(context, historyProv),
            ),
        ],
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
                    focusNode: _searchFocusNode,
                    onClear: () => setState(() {}),
                    hintText: 'Search conversion history...',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _FilterChip(
                        label: 'All (${historyProv.entries.length})',
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
                    ],
                  ),
                ],
              ),
            ),

            // HISTORY LIST OR EMPTY STATE
            Expanded(
              child: entries.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.history_rounded,
                      message: historyProv.entries.isEmpty
                          ? 'No Conversion History'
                          : 'No Matching History',
                      subtitle: historyProv.entries.isEmpty
                          ? 'Conversions you perform will automatically appear here.'
                          : 'Try searching with a different unit or category name.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final entry = entries[index];

                        return Dismissible(
                          key: Key(entry.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_rounded, color: Colors.white, size: 24),
                          ),
                          onDismissed: (_) {
                            HapticFeedback.lightImpact();
                            historyProv.removeEntry(entry.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: StitchCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => _openConverterForEntry(context, entry),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history_rounded,
                                      color: colorScheme.primary,
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
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: colorScheme.outline,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                '${Formatters.cleanFloatingPoint(entry.result)} ${entry.toSymbol}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: colorScheme.primary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${entry.category} • ${Formatters.formatTimestamp(entry.timestamp)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline_rounded,
                                      color: colorScheme.outlineVariant,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      historyProv.removeEntry(entry.id);
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
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
