/// Dashboard / Home Screen — Production Material Design 3 Toolkit Home Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/collections_data.dart';
import '../data/converter_config.dart';
import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/home_layout_provider.dart';
import '../providers/pinned_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/usage_provider.dart';
import '../services/conversion_service.dart';
import '../services/refresh_service.dart';
import '../services/smart_parse_service.dart';
import '../utils/formatters.dart';
import '../utils/responsive_helper.dart';
import '../utils/search_helper.dart';
import '../widgets/did_you_know_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/insights_banner.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';
import '../widgets/user_avatar.dart';
import 'collection_screen.dart';
import 'converter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  /// Default filter is Browse All (index 0).
  /// Order: 0: Browse All, 1: Favorites, 2: Recent, 3: Popular
  int _activeFilterIndex = 0;

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
    HapticFeedback.lightImpact();
    final converterProv = context.read<ConverterProvider>();

    context.read<UsageProvider>().trackCategoryUsage(category);
    converterProv.setCategory(category);

    if (presetFromUnitName != null) {
      final units = unitsData[category] ?? [];
      final matched = units
          .where((u) => u.name.toLowerCase() == presetFromUnitName.toLowerCase())
          .toList();
      if (matched.isNotEmpty) converterProv.setFromUnit(matched.first);
    }

    if (presetToUnitName != null) {
      final units = unitsData[category] ?? [];
      final matched = units
          .where((u) => u.name.toLowerCase() == presetToUnitName.toLowerCase())
          .toList();
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

  void _showCategoryContextMenu(
      BuildContext context, UnitCategory category, bool isFav, bool isPinned) {
    HapticFeedback.mediumImpact();
    final favProv = context.read<FavoritesProvider>();
    final pinnedProv = context.read<PinnedProvider>();
    final config = configFor(category);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(config.icon, color: config.primaryColor),
              title: Text(
                config.displayName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('${(unitsData[category] ?? []).length} units available'),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                color: isFav ? Theme.of(context).colorScheme.tertiary : null,
              ),
              title: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(ctx);
                favProv.toggleFavorite(category);
              },
            ),
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: isPinned ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(isPinned ? 'Unpin from Top' : 'Pin to Top'),
              onTap: () {
                Navigator.pop(ctx);
                if (isPinned) {
                  pinnedProv.unpin(category);
                } else {
                  pinnedProv.pin(category);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow_rounded),
              title: const Text('Open Converter'),
              onTap: () {
                Navigator.pop(ctx);
                _openConverter(context, category);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final query = _searchController.text.trim();
    final settings = context.watch<SettingsProvider>();
    final layoutProv = context.watch<HomeLayoutProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Consumer3<FavoritesProvider, HistoryProvider, PinnedProvider>(
          builder: (context, favProv, historyProv, pinnedProv, _) {
            final recentEntries = historyProv.entries.take(5).toList();
            final smartResult = query.isNotEmpty ? SmartParseService.parse(query) : null;
            final showSmart = smartResult?.isRecognized == true;
            final detailedResults =
                query.isNotEmpty ? SearchHelper.searchDetailed(query) : <CategorySearchResult>[];

            List<UnitCategory> displayCategories;
            String filterSectionTitle;

            switch (_activeFilterIndex) {
              case 1: // Favorites
                filterSectionTitle = 'Favorite Categories (${favProv.favorites.length})';
                displayCategories =
                    UnitCategory.values.where((cat) => favProv.isFavorite(cat)).toList();
                break;
              case 2: // Recent
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
              case 3: // Popular
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
              case 0: // Browse All (Default)
              default:
                filterSectionTitle = 'Browse Categories';
                displayCategories = UnitCategory.values;
                break;
            }

            return RefreshIndicator(
              onRefresh: () => RefreshService.refreshApp(context),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _scrollController,
                slivers: [
                // ── 1. HEADER / GREETING (24dp MARGINS) ─────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                                '300+ Units • 60 Categories • Offline',
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

                // ── 2. SEARCH BAR (24dp MARGINS) ──────────────────────────
                const SliverToBoxAdapter(child: SizedBox(height: 4)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: StitchSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onClear: () => setState(() {}),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // ── SEARCH MODE ACTIVE ────────────────────────────────────
                if (query.isNotEmpty) ...[
                  if (showSmart)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        subtitle: 'Try searching by unit symbol, name, or category',
                      ),
                    ),
                  if (detailedResults.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final res = detailedResults[index];
                            final config = configFor(res.category);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: StitchCard(
                                onTap: () => _openConverter(context, res.category),
                                padding: const EdgeInsets.all(16),
                                borderRadius: 16,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: config.primaryColor.withValues(alpha: 0.15),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        config.icon,
                                        color: config.primaryColor,
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
                  ..._buildDynamicSections(
                    context,
                    layoutProv: layoutProv,
                    favProv: favProv,
                    historyProv: historyProv,
                    pinnedProv: pinnedProv,
                    recentEntries: recentEntries,
                    displayCategories: displayCategories,
                    filterSectionTitle: filterSectionTitle,
                    colorScheme: colorScheme,
                  ),

                  // ── 11. PRIVACY & OFFLINE CARD ────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
            ),
          );
        },
      ),
    ),
  );
}

  /// Builds home screen slivers dynamically based on [HomeLayoutProvider] section configuration.
  List<Widget> _buildDynamicSections(
    BuildContext context, {
    required HomeLayoutProvider layoutProv,
    required FavoritesProvider favProv,
    required HistoryProvider historyProv,
    required PinnedProvider pinnedProv,
    required List<HistoryEntry> recentEntries,
    required List<UnitCategory> displayCategories,
    required String filterSectionTitle,
    required ColorScheme colorScheme,
  }) {
    final slivers = <Widget>[];

    for (final sec in layoutProv.sections) {
      if (!sec.isVisible) continue;

      switch (sec.id) {
        case 'did_you_know':
          slivers.add(const SliverToBoxAdapter(child: DidYouKnowCard()));
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          break;

        case 'insights':
          slivers.add(const SliverToBoxAdapter(child: InsightsBanner()));
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          break;

        case 'collections':
          slivers.add(
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Curated Collections',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: predefinedCollections.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final col = predefinedCollections[index];
                        return _CollectionChipCard(collection: col);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          break;

        case 'pinned':
          if (pinnedProv.pinned.isNotEmpty) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Icon(
                        Icons.push_pin_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pinned Converters',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isExpanded(context) ? 4 : 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: ResponsiveHelper.isExpanded(context) ? 2.2 : 1.9,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cat = pinnedProv.pinned[index];
                      final config = configFor(cat);
                      return _CategoryTile(
                        category: cat,
                        config: config,
                        isFav: favProv.isFavorite(cat),
                        isPinned: true,
                        onTap: () => _openConverter(context, cat),
                        onLongPress: () =>
                            _showCategoryContextMenu(context, cat, favProv.isFavorite(cat), true),
                      );
                    },
                    childCount: pinnedProv.pinned.length,
                  ),
                ),
              ),
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          }
          break;

        case 'frequently_used':
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      'Frequently Used',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        _scrollController.animateTo(
                          360,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Text(
                        'See More',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
          slivers.add(
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final usageProv = context.watch<UsageProvider>();
                  final topCategories = usageProv.getTopCategories(limit: 6);

                  if (topCategories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
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
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.12),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No frequently used converters yet.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'When you start converting, your favorite categories will appear here.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
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
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: topCategories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final entry = topCategories[index];
                        final category = entry.key;
                        final count = entry.value;
                        final config = configFor(category);

                        return _FrequentlyUsedCard(
                          key: ValueKey(category.name),
                          category: category,
                          title: config.displayName,
                          unitCount: count == 1 ? 'Used 1 time' : 'Used $count times',
                          borderColor: config.primaryColor,
                          icon: config.icon,
                          onTap: () => _openConverter(context, category),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          break;

        case 'categories':
          slivers.add(
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterHeaderDelegate(
                child: SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _QuickFilterChip(
                        label: 'Browse All',
                        icon: Icons.grid_view_rounded,
                        isSelected: _activeFilterIndex == 0,
                        onTap: () => setState(() => _activeFilterIndex = 0),
                      ),
                      const SizedBox(width: 10),
                      _QuickFilterChip(
                        label: 'Favorites',
                        icon: Icons.star_rounded,
                        isSelected: _activeFilterIndex == 1,
                        onTap: () => setState(() => _activeFilterIndex = 1),
                      ),
                      const SizedBox(width: 10),
                      _QuickFilterChip(
                        label: 'Recent',
                        icon: Icons.history_rounded,
                        isSelected: _activeFilterIndex == 2,
                        onTap: () => setState(() => _activeFilterIndex = 2),
                      ),
                      const SizedBox(width: 10),
                      _QuickFilterChip(
                        label: 'Popular',
                        icon: Icons.bolt_rounded,
                        isSelected: _activeFilterIndex == 3,
                        onTap: () => setState(() => _activeFilterIndex = 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  filterSectionTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
          );
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
          if (displayCategories.isEmpty) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: EmptyStateWidget(
                    icon: _activeFilterIndex == 1
                        ? Icons.star_border_rounded
                        : Icons.history_rounded,
                    message: _activeFilterIndex == 1
                        ? 'No Favorites Saved Yet'
                        : 'No Recent Conversions',
                    subtitle: _activeFilterIndex == 1
                        ? 'Tap the star icon or long-press any category to add it to your favorites.'
                        : 'Conversions you perform will automatically appear here.',
                  ),
                ),
              ),
            );
          } else {
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    final isPinned = pinnedProv.isPinned(category);
                    final config = configFor(category);

                    return _CategoryTile(
                      category: category,
                      config: config,
                      isFav: isFav,
                      isPinned: isPinned,
                      onTap: () => _openConverter(context, category),
                      onLongPress: () =>
                          _showCategoryContextMenu(context, category, isFav, isPinned),
                    );
                  }, childCount: displayCategories.length),
                ),
              ),
            );
          }
          slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          break;

        case 'recent':
          if (recentEntries.isNotEmpty) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Recent Conversions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 12)));
            slivers.add(
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final entry = recentEntries[index];
                    final cat = entry.categoryEnum;
                    final config = configFor(cat);
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
                                color: config.primaryColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                config.icon,
                                color: config.primaryColor,
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
                              tooltip: 'Refresh conversion',
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
            );
            slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 24)));
          }
          break;
      }
    }

    return slivers;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _StickyFilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _StickyFilterHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _CategoryTile extends StatelessWidget {
  final UnitCategory category;
  final ConverterConfig config;
  final bool isFav;
  final bool isPinned;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CategoryTile({
    required this.category,
    required this.config,
    required this.isFav,
    required this.isPinned,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPress: onLongPress,
      child: StitchCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        borderRadius: 12,
        child: Row(
          children: [
            Icon(
              config.icon,
              color: isFav ? Theme.of(context).colorScheme.tertiary : config.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    config.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${(unitsData[category] ?? []).length} Units',
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
                context.read<FavoritesProvider>().toggleFavorite(category);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  isFav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFav ? colorScheme.tertiary : colorScheme.outline,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectionChipCard extends StatelessWidget {
  final Collection collection;

  const _CollectionChipCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CollectionScreen(collection: collection),
          ),
        );
      },
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  collection.emoji,
                  style: const TextStyle(fontSize: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${collection.categories.length} converters',
                  style: TextStyle(
                    fontSize: 11,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : (isDark
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.surfaceContainerLow),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    final fromUnit = units.firstWhere(
        (u) => u.name.toLowerCase() == fromName.toLowerCase(),
        orElse: () => units.first);
    final toUnit = units.firstWhere(
        (u) => u.name.toLowerCase() == toName.toLowerCase(),
        orElse: () => units.length > 1 ? units[1] : units.first);
    final inputVal = result.amount ?? 0.0;
    final convertedResult =
        ConversionService.convert(inputVal, fromUnit, toUnit, category);
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
