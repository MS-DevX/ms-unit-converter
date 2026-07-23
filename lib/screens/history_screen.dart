/// History screen — shows all saved conversions with search, category filtering,
/// swipe-to-dismiss, clear-all, and tap-to-reuse (Option B).
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/history_provider.dart';
import '../services/navigation_service.dart';
import '../utils/formatters.dart';

/// Displays the list of past conversions stored by [HistoryProvider].
class HistoryScreen extends StatefulWidget {
  /// Creates a [HistoryScreen].
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Action helpers ────────────────────────────────────────────────────────

  /// Shows a confirmation dialog before clearing all history.
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History?'),
        content: const Text('This will remove all conversion history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await context.read<HistoryProvider>().clearHistory();
    }
  }

  /// Option B: Reuses [entry] by pre-filling [ConverterProvider] and switching
  /// the bottom navigation tab to Home/Converter (index 0).
  void _reuseConversion(BuildContext context, HistoryEntry entry) {
    HapticFeedback.lightImpact();

    // Match category
    final category = UnitCategory.values.firstWhere(
      (cat) => cat.displayName.toLowerCase() == entry.category.toLowerCase(),
      orElse: () => UnitCategory.length,
    );

    final converter = context.read<ConverterProvider>();
    converter.setCategory(category);

    final units = converter.currentUnits;
    final matchedFrom = units.where((u) => u.name == entry.fromUnit).toList();
    final matchedTo = units.where((u) => u.name == entry.toUnit).toList();

    if (matchedFrom.isNotEmpty) converter.setFromUnit(matchedFrom.first);
    if (matchedTo.isNotEmpty) converter.setToUnit(matchedTo.first);

    final text = entry.inputValue == entry.inputValue.roundToDouble()
        ? entry.inputValue.toInt().toString()
        : entry.inputValue.toString();

    converter.setInput(text);

    // Switch tab to Home/Converter (index 0)
    appNavigator.switchTab(0);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text('Loaded ${entry.category} conversion'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      );
  }

  /// Shows a bottom sheet with entry options.
  void _showEntryOptions(BuildContext context, HistoryEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Reuse conversion',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _reuseConversion(context, entry);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Delete this entry',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    HapticFeedback.lightImpact();
                    context.read<HistoryProvider>().removeEntry(entry.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<HistoryEntry> _filterEntries(List<HistoryEntry> allEntries) {
    var result = allEntries;

    // Filter by category
    if (_selectedCategoryFilter != 'All') {
      result = result
          .where(
            (e) =>
                e.category.toLowerCase() ==
                _selectedCategoryFilter.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((e) {
        return e.category.toLowerCase().contains(query) ||
            e.fromUnit.toLowerCase().contains(query) ||
            e.toUnit.toLowerCase().contains(query) ||
            e.fromSymbol.toLowerCase().contains(query) ||
            e.toSymbol.toLowerCase().contains(query) ||
            e.inputValue.toString().contains(query) ||
            e.result.toString().contains(query);
      }).toList();
    }

    return result;
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          Consumer<HistoryProvider>(
            builder: (context, history, _) {
              if (history.entries.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                tooltip: 'Clear all',
                onPressed: () => _confirmClear(context),
              );
            },
          ),
        ],
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, history, _) {
          if (history.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (history.entries.isEmpty) {
            return _EmptyState(isDark: isDark);
          }

          final categories = [
            'All',
            ...{for (final e in history.entries) e.category},
          ];

          final filtered = _filterEntries(history.entries);

          return Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search history\u2026',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                  ),
                ),
              ),

              // Category filter chips
              if (categories.length > 2)
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = cat == _selectedCategoryFilter;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        checkmarkColor: Colors.white,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedCategoryFilter = cat;
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 8),

              // List of history items
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No matching history',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => history.refresh(),
                        displacement: 40,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final entry = filtered[index];
                            return Dismissible(
                              key: ValueKey(entry.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: const Text('Delete entry?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.error,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (_) {
                                HapticFeedback.lightImpact();
                                context
                                    .read<HistoryProvider>()
                                    .removeEntry(entry.id);
                              },
                              child: _HistoryCard(
                                entry: entry,
                                onTap: () => _reuseConversion(context, entry),
                                onLongPress: () =>
                                    _showEntryOptions(context, entry),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Private widgets ──────────────────────────────────────────────────────────

/// Shown when there are no history entries.
class _EmptyState extends StatefulWidget {
  final bool isDark;

  const _EmptyState({required this.isDark});

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _pulseAnimation.value,
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  size: 96,
                  color: color.withValues(alpha: 0.3),
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          Text(
            'No history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Tap or copy a result in the converter to save it here. Start converting to build your history.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: color.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single history item card with tap-to-reuse support.
class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryCard({
    required this.entry,
    required this.onTap,
    required this.onLongPress,
  });

  /// Formats a [DateTime] to a short human-readable string.
  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }

  /// Maps a category display name to an emoji icon.
  static String _categoryIcon(String category) {
    return switch (category) {
      'Length' => '\u{1F4CF}',
      'Weight' => '\u{2696}\u{FE0F}',
      'Temperature' => '\u{1F321}\u{FE0F}',
      'Area' => '\u{1F4D0}',
      'Volume' => '\u{1F9EA}',
      'Speed' => '\u{1F680}',
      'Data' => '\u{1F4BE}',
      'Time' => '\u{23F1}\u{FE0F}',
      'Angle' => '\u{1F4A0}',
      'Energy' => '\u{26A1}',
      'Power' => '\u{1F50B}',
      'Pressure' => '\u{1F4A8}',
      'Force' => '\u{1F4AA}',
      'Frequency' => '\u{1F501}',
      'Fuel Economy' => '\u{26FD}',
      'Cooking' => '\u{1F373}',
      'Shoe Size' => '\u{1F460}',
      'Clothing Size' => '\u{1F455}',
      'Number Base' => '\u{1F522}',
      'Typography' => '\u{1F4D6}',
      _ => '\u{1F504}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final Color borderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final Color primaryText = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final Color secondaryText = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final fromSym = entry.fromSymbol.isNotEmpty ? entry.fromSymbol : entry.fromUnit;
    final toSym = entry.toSymbol.isNotEmpty ? entry.toSymbol : entry.toUnit;

    final String conversionHeadline =
        '${Formatters.formatResult(entry.inputValue)} $fromSym'
        ' \u2192 '
        '${Formatters.formatResult(entry.result)} $toSym';

    final String conversionSubline = '${entry.fromUnit} to ${entry.toUnit}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        label: '$conversionHeadline in ${entry.category}',
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _categoryIcon(entry.category),
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          entry.category,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: AppColors.primary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTimestamp(entry.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: secondaryText.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conversionHeadline,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: primaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                conversionSubline,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Tap to reuse conversion',
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.replay_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
