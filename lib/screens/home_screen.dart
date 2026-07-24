/// Dashboard / Home Screen — Pixel-perfect implementation of Google Stitch Material Design 3 export.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/usage_provider.dart';
import '../services/conversion_service.dart';
import '../services/smart_parse_service.dart';
import '../utils/formatters.dart';
import '../utils/responsive_helper.dart';
import '../utils/search_helper.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';
import '../widgets/user_avatar.dart';
import 'converter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  int _activeFilterIndex = 0; // 0: Favorites, 1: Recent, 2: Popular, 3: Browse All

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

  static Color _getCategoryIconColor(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return AppColors.primary;
      case UnitCategory.weight:
        return AppColors.tertiary;
      case UnitCategory.temperature:
        return AppColors.error;
      case UnitCategory.area:
        return AppColors.areaIcon;
      case UnitCategory.volume:
        return AppColors.secondary;
      case UnitCategory.speed:
        return AppColors.speedIcon;
      case UnitCategory.data:
        return AppColors.dataIcon;
      case UnitCategory.time:
        return AppColors.timeIcon;
      case UnitCategory.angle:
        return AppColors.angleIcon;
      case UnitCategory.energy:
        return AppColors.energyIcon;
      case UnitCategory.power:
        return AppColors.powerIcon;
      case UnitCategory.pressure:
        return AppColors.pressureIcon;
      default:
        return AppColors.primary;
    }
  }

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
    _scrollController.dispose();
    super.dispose();
  }

  void _openConverter(
    BuildContext context,
    UnitCategory category, {
    String? presetFromUnitName,
    String? presetToUnitName,
    double? presetInputValue,
  }) {
    final converterProv = context.read<ConverterProvider>();

    context.read<UsageProvider>().trackCategoryUsage(category);

    converterProv.setCategory(category);

    if (presetFromUnitName != null) {
      final units = unitsData[category] ?? [];
      final matched = units.where((u) => u.name.toLowerCase() == presetFromUnitName.toLowerCase()).toList();
      if (matched.isNotEmpty) converterProv.setFromUnit(matched.first);
    }

    if (presetToUnitName != null) {
      final units = unitsData[category] ?? [];
      final matched = units.where((u) => u.name.toLowerCase() == presetToUnitName.toLowerCase()).toList();
      if (matched.isNotEmpty) converterProv.setToUnit(matched.first);
    }

    if (presetInputValue != null) {
      final text = presetInputValue == presetInputValue.roundToDouble()
          ? presetInputValue.toInt().toString()
          : presetInputValue.toString();
      converterProv.setInput(text);
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConverterScreen(
          initialCategory: category,
          presetValue: presetInputValue,
          presetFromUnitName: presetFromUnitName,
          presetToUnitName: presetToUnitName,
        ),
      ),
    );
  }

  void _onSmartResultTap(SmartParseResult? result) {
    if (result == null || !result.isRecognized || result.category == null) return;
    HapticFeedback.mediumImpact();

    _openConverter(
      context,
      result.category!,
      presetFromUnitName: result.fromUnitName,
      presetToUnitName: result.toUnitName,
      presetInputValue: result.amount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim();
    final settings = context.watch<SettingsProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer2<FavoritesProvider, HistoryProvider>(
          builder: (context, favProv, historyProv, _) {
            final recentEntries = historyProv.entries.take(5).toList();
            final smartResult = query.isNotEmpty
                ? SmartParseService.parse(query)
                : null;
            final showSmart = smartResult?.isRecognized == true;
            final detailedResults = query.isNotEmpty
                ? SearchHelper.searchDetailed(query)
                : <CategorySearchResult>[];

            List<UnitCategory> displayCategories;
            String filterSectionTitle;

            switch (_activeFilterIndex) {
              case 0: // Favorites
                filterSectionTitle = 'Favorite Categories (${favProv.favorites.length})';
                displayCategories = UnitCategory.values
                    .where((cat) => favProv.isFavorite(cat))
                    .toList();
                break;
              case 1: // Recent
                filterSectionTitle = 'Recently Opened';
                final recentCatEnums = <UnitCategory>[];
                for (final entry in historyProv.entries) {
                  final cat = entry.categoryEnum;
                  if (!recentCatEnums.contains(cat)) {
                    recentCatEnums.add(cat);
                  }
                }
                displayCategories = recentCatEnums;
                break;
              case 2: // Popular
                filterSectionTitle = 'Popular Converters';
                displayCategories = const [
                  UnitCategory.length,
                  UnitCategory.weight,
                  UnitCategory.temperature,
                  UnitCategory.area,
                  UnitCategory.volume,
                  UnitCategory.speed,
                  UnitCategory.data,
                  UnitCategory.time,
                ];
                break;
              case 3: // Browse All
              default:
                filterSectionTitle = 'Browse Categories';
                displayCategories = UnitCategory.values;
                break;
            }

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. TOP APP BAR / HEADER
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                settings.getGreeting(),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Unit Converter',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.primary,
                                  height: 1.1,
                                  letterSpacing: -0.72,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '250+ Units • Fast • Accurate • Offline',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const UserAvatar(size: 48),
                      ],
                    ),
                  ),
                ),

                // 2. SEARCH BAR
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: StitchSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onClear: () => setState(() {}),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // SEARCH MODE ACTIVE
                if (query.isNotEmpty) ...[
                  if (showSmart)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _SmartConvertCard(
                          result: smartResult!,
                          onTap: () => _onSmartResultTap(smartResult),
                        ),
                      ),
                    ),
                  if (!showSmart && detailedResults.isEmpty)
                    const SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        message: 'No matching converters found.',
                        subtitle: 'Try searching by unit symbol or category',
                      ),
                    ),
                  if (detailedResults.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final res = detailedResults[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: StitchCard(
                                onTap: () => _openConverter(context, res.category),
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: _getCategoryIconColor(res.category).withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(res.category),
                                        color: _getCategoryIconColor(res.category),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            res.category.displayName,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            '${res.category.unitSymbols.length} Units supported',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: colorScheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: detailedResults.length,
                        ),
                      ),
                    ),
                ] else ...[
                  // 3. QUICK ACTION HORIZONTAL CHIPS
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 44,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _QuickFilterChip(
                            label: 'Favorites',
                            icon: Icons.star_rounded,
                            isSelected: _activeFilterIndex == 0,
                            onTap: () => setState(() => _activeFilterIndex = 0),
                          ),
                          const SizedBox(width: 10),
                          _QuickFilterChip(
                            label: 'Recent',
                            icon: Icons.history_rounded,
                            isSelected: _activeFilterIndex == 1,
                            onTap: () => setState(() => _activeFilterIndex = 1),
                          ),
                          const SizedBox(width: 10),
                          _QuickFilterChip(
                            label: 'Popular',
                            icon: Icons.bolt_rounded,
                            isSelected: _activeFilterIndex == 2,
                            onTap: () => setState(() => _activeFilterIndex = 2),
                          ),
                          const SizedBox(width: 10),
                          _QuickFilterChip(
                            label: 'Browse All',
                            icon: Icons.grid_view_rounded,
                            isSelected: _activeFilterIndex == 3,
                            onTap: () => setState(() => _activeFilterIndex = 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // 4. FREQUENTLY USED CAROUSEL
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Text(
                            'Frequently Used',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              _scrollController.animateTo(
                                320,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: Text(
                              'See More',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  SliverToBoxAdapter(
                    child: Builder(
                      builder: (context) {
                        final usageProv = context.watch<UsageProvider>();
                        final topCategories = usageProv.getTopCategories(limit: 4);

                        if (topCategories.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: StitchCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_graph_rounded,
                                      color: colorScheme.primary,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      'Start converting units and your most-used categories will appear here.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: topCategories.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 14),
                            itemBuilder: (context, index) {
                              final entry = topCategories[index];
                              final category = entry.key;
                              final count = entry.value;

                              return _FrequentlyUsedCard(
                                key: ValueKey(category.name),
                                category: category,
                                title: category.displayName,
                                unitCount: count == 1 ? 'Used 1 time' : 'Used $count times',
                                borderColor: _getCategoryIconColor(category),
                                icon: _getCategoryIcon(category),
                                onTap: () => _openConverter(context, category),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // 5. FILTERED CATEGORIES (BENTO GRID STYLE)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        filterSectionTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  if (displayCategories.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: EmptyStateWidget(
                          icon: _activeFilterIndex == 0
                              ? Icons.star_border_rounded
                              : Icons.history_rounded,
                          message: _activeFilterIndex == 0
                              ? 'No Favorites Saved Yet'
                              : 'No Recent Conversions',
                          subtitle: _activeFilterIndex == 0
                              ? 'Tap the star icon on any category to add it to your favorites.'
                              : 'Conversions you perform will automatically appear here.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isExpanded(context) ? 4 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: ResponsiveHelper.isExpanded(context) ? 2.2 : 1.9,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final category = displayCategories[index];
                          final isFav = favProv.isFavorite(category);

                          return StitchCard(
                            onTap: () => _openConverter(context, category),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            borderRadius: 12,
                            child: Row(
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  color: isFav ? Colors.amber : colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category.displayName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${category.unitSymbols.length} Units',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    favProv.toggleFavorite(category);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Icon(
                                      isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                                      color: isFav ? Colors.amber : colorScheme.outline,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }, childCount: displayCategories.length),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // 6. RECENT CONVERSIONS
                  if (recentEntries.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Recent Conversions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = recentEntries[index];
                          final cat = entry.categoryEnum;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: StitchCard(
                              padding: const EdgeInsets.all(16),
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
                                      _getCategoryIcon(cat),
                                      color: _getCategoryIconColor(cat),
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
                                                fontWeight: FontWeight.w500,
                                                color: colorScheme.onSurface,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 14,
                                              color: colorScheme.outline,
                                            ),
                                            const SizedBox(width: 4),
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
                                          '${entry.category} • Saved',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      _openConverter(
                                        context,
                                        cat,
                                        presetFromUnitName: entry.fromUnit,
                                        presetToUnitName: entry.toUnit,
                                        presetInputValue: entry.inputValue,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }, childCount: recentEntries.length),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],

                  // 7. PRIVACY & OFFLINE CARD
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Container(
                        padding: const EdgeInsets.all(16),
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
                              Icons.shield_outlined,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '100% Offline • No Tracking • Instant Results',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterChip({
    required this.label,
    required this.icon,
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequentlyUsedCard extends StatelessWidget {
  final UnitCategory category;
  final String title;
  final String unitCount;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onTap;

  const _FrequentlyUsedCard({
    super.key,
    required this.category,
    required this.title,
    required this.unitCount,
    required this.borderColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 160,
      child: StitchCard(
        onTap: onTap,
        leftBorderColor: borderColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: borderColor, size: 22),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  unitCount,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartConvertCard extends StatelessWidget {
  final SmartParseResult result;
  final VoidCallback onTap;

  const _SmartConvertCard({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!result.isRecognized || result.category == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final category = result.category!;
    final units = unitsData[category] ?? [];
    final fromName = result.fromUnitName ?? '';
    final toName = result.toUnitName ?? '';
    final fromUnit = units.firstWhere((u) => u.name.toLowerCase() == fromName.toLowerCase(), orElse: () => units.first);
    final toUnit = units.firstWhere((u) => u.name.toLowerCase() == toName.toLowerCase(), orElse: () => units.length > 1 ? units[1] : units.first);
    final inputVal = result.amount ?? 0.0;
    final convertedResult = ConversionService.convert(inputVal, fromUnit, toUnit, category);
    final outputStr = Formatters.formatResult(convertedResult.result);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.bolt_rounded, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Formatters.cleanFloatingPoint(inputVal)} ${fromUnit.symbol} = $outputStr ${toUnit.symbol}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to open ${category.displayName} converter',
                    style: TextStyle(fontSize: 12, color: colorScheme.primary),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
