/// Home screen — 2026 Material 3 Dashboard featuring personalized greeting,
/// search bar, privacy & offline status card, favorite categories, neutral category cards
/// with Material Symbols Rounded icons, and recent conversions.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../data/units_data.dart';
import '../models/history_entry.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/conversion_service.dart';
import '../services/smart_parse_service.dart';
import '../utils/formatters.dart';
import '../utils/responsive_helper.dart';
import '../utils/search_helper.dart';
import '../widgets/conversion_bar.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/glassmorphic_tile.dart';
import '../widgets/performance_monitor.dart';
import 'converter_screen.dart';

/// Preset conversion model for quick tap-to-convert actions.
class _PresetConversion {
  final UnitCategory category;
  final double value;
  final String fromUnitName;
  final String toUnitName;

  const _PresetConversion({
    required this.category,
    required this.value,
    required this.fromUnitName,
    required this.toUnitName,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _refreshKey = 0;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  static const List<QuickConversionItem> _cosmicBarItems = [
    QuickConversionItem(
      category: UnitCategory.length,
      fromSymbol: 'cm',
      toSymbol: 'in',
      sampleValue: 10,
      fromUnitName: 'Centimeter',
      toUnitName: 'Inch',
    ),
    QuickConversionItem(
      category: UnitCategory.weight,
      fromSymbol: 'kg',
      toSymbol: 'lb',
      sampleValue: 1,
      fromUnitName: 'Kilogram',
      toUnitName: 'Pound',
    ),
    QuickConversionItem(
      category: UnitCategory.temperature,
      fromSymbol: '°C',
      toSymbol: '°F',
      sampleValue: 25,
      fromUnitName: 'Celsius',
      toUnitName: 'Fahrenheit',
    ),
    QuickConversionItem(
      category: UnitCategory.volume,
      fromSymbol: 'l',
      toSymbol: 'gal',
      sampleValue: 1,
      fromUnitName: 'Liter',
      toUnitName: 'Gallon (US)',
    ),
  ];

  static IconData _getCategoryIcon(UnitCategory category) {
    switch (category) {
      case UnitCategory.length:
        return Icons.straighten_rounded;
      case UnitCategory.weight:
        return Icons.scale_rounded;
      case UnitCategory.temperature:
        return Icons.thermostat_rounded;
      case UnitCategory.area:
        return Icons.square_foot_rounded;
      case UnitCategory.volume:
        return Icons.science_rounded;
      case UnitCategory.speed:
        return Icons.speed_rounded;
      case UnitCategory.data:
        return Icons.storage_rounded;
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
        return AppColors.lengthIcon;
      case UnitCategory.weight:
        return AppColors.weightIcon;
      case UnitCategory.temperature:
        return AppColors.tempIcon;
      case UnitCategory.area:
        return AppColors.areaIcon;
      case UnitCategory.volume:
        return AppColors.volumeIcon;
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

  Future<void> _onRefresh() async {
    setState(() => _refreshKey++);
    await Future.delayed(const Duration(milliseconds: 400));
  }

  void _openConverter(
    BuildContext context,
    UnitCategory category, {
    String? presetFromUnitName,
    String? presetToUnitName,
    double? presetInputValue,
  }) {
    final converterProv = context.read<ConverterProvider>();

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
      converterProv.setInput(presetInputValue.toString());
    }

    if (ResponsiveHelper.isExpanded(context)) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ConverterScreen(
            initialCategory: category,
            presetFromUnitName: presetFromUnitName,
            presetToUnitName: presetToUnitName,
            presetValue: presetInputValue,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _openConverterWithPreset(
    BuildContext context,
    _PresetConversion preset,
  ) {
    _openConverter(
      context,
      preset.category,
      presetFromUnitName: preset.fromUnitName,
      presetToUnitName: preset.toUnitName,
      presetInputValue: preset.value,
    );
  }

  void _onSmartResultTap(SmartParseResult result) {
    if (!result.isRecognized) return;
    HapticFeedback.lightImpact();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    final query = _searchController.text.trim();
    final settings = context.watch<SettingsProvider>();
    final isCosmic = settings.isCosmicTheme;

    return PerformanceMonitor(
      enabled: false,
      child: CosmicBackground(
        scrollController: _scrollController,
        opacity: isCosmic ? 0.08 : 0.0,
        child: Consumer2<FavoritesProvider, HistoryProvider>(
          builder: (context, favProv, historyProv, _) {
            final favoriteList = favProv.favorites.toList();
            final recentEntries = historyProv.entries.take(5).toList();
            final smartResult = query.isNotEmpty
                ? SmartParseService.parse(query)
                : null;
            final showSmart = smartResult?.isRecognized == true;
            final detailedResults = query.isNotEmpty
                ? SearchHelper.searchDetailed(query)
                : <CategorySearchResult>[];

            return RefreshIndicator(
              onRefresh: _onRefresh,
              displacement: 60,
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                key: ValueKey(_refreshKey),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // 1, 2, 3: HEADER SECTION (Greeting, App Title, Subtitle)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  settings.getGreeting(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderDark,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.calculate_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Unit Converter',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '250+ Units • Fast • Accurate • Offline',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4: FULL-WIDTH SEARCH BAR
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search units or categories...',
                          hintStyle: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.borderDark),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: AppColors.borderDark),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // 5: PRIVACY & OFFLINE CARD
                  if (query.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _PrivacyOfflineCard(),
                      ),
                    ),

                  if (query.isEmpty)
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // SEARCH RESULTS VIEW
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
                          subtitle: 'Try another keyword or category name',
                        ),
                      ),
                    if (detailedResults.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final res = detailedResults[index];
                              return _SearchResultCard(
                                result: res,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _openConverter(context, res.category);
                                },
                              );
                            },
                            childCount: detailedResults.length,
                          ),
                        ),
                      ),
                  ] else ...[
                    // 6: FAVORITE CATEGORIES
                    if (favoriteList.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 12)),
                      SliverToBoxAdapter(
                        child: _buildFavoritesSection(favoriteList),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],

                    // 7: BROWSE CATEGORIES
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            const Text(
                              'Browse Categories',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${UnitCategory.values.length} Total',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600
                              ? 4
                              : 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: MediaQuery.of(context).size.width > 600
                              ? 1.25
                              : 1.15,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final category = UnitCategory.values[index];
                          if (isCosmic) {
                            return GlassmorphicCategoryTile(
                              category: category,
                              isFavorite: favProv.isFavorite(category),
                              onFavoriteToggle: (_) =>
                                  favProv.toggleFavorite(category),
                              onTap: () => _openConverter(context, category),
                            );
                          }
                          return _CategoryCard(
                            category: category,
                            isFavorite: favProv.isFavorite(category),
                            onFavoriteToggle: () =>
                                favProv.toggleFavorite(category),
                            onTap: () => _openConverter(context, category),
                          );
                        }, childCount: UnitCategory.values.length),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 28)),

                    // 8: RECENT CONVERSIONS
                    if (recentEntries.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Text(
                            'Recent Conversions',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
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
                            return _RecentConversionCard(
                              entry: entry,
                              onRepeatTap: () {
                                HapticFeedback.lightImpact();
                                _openConverter(
                                  context,
                                  entry.categoryEnum,
                                  presetFromUnitName: entry.fromUnit,
                                  presetToUnitName: entry.toUnit,
                                  presetInputValue: entry.inputValue,
                                );
                              },
                            );
                          }, childCount: recentEntries.length),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    ],

                    if (isCosmic)
                      SliverToBoxAdapter(
                        child: QuickConversionBar(
                          items: _cosmicBarItems,
                          onItemTap: (item) {
                            _openConverterWithPreset(
                              context,
                              _PresetConversion(
                                category: item.category,
                                value: item.sampleValue,
                                fromUnitName: item.fromUnitName,
                                toUnitName: item.toUnitName,
                              ),
                            );
                          },
                        ),
                      ),

                    // 9: VIEW ALL CATEGORIES BUTTON
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _scrollController.animateTo(
                              300,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            side: const BorderSide(color: AppColors.borderDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            foregroundColor: AppColors.primary,
                          ),
                          icon: const Icon(Icons.grid_view_rounded, size: 20),
                          label: const Text(
                            'View All Categories',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildFavoritesSection(List<UnitCategory> favorites) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final cat = favorites[index];
          final iconData = _getCategoryIcon(cat);
          final iconColor = _getCategoryIconColor(cat);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _openConverter(context, cat);
            },
            child: Container(
              width: 140,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat.displayName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${cat.unitSymbols.length} Units',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Subtle Privacy & Offline experience status card.
class _PrivacyOfflineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Private & Offline',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: const [
              _StatusCheck(label: '250+ converters'),
              _StatusCheck(label: 'Works without internet'),
              _StatusCheck(label: 'No account required'),
              _StatusCheck(label: 'Free forever'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusCheck extends StatelessWidget {
  final String label;
  const _StatusCheck({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_rounded, color: AppColors.success, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Category Card using neutral `#1E293B` container with a colorful Material Symbols icon.
class _CategoryCard extends StatelessWidget {
  final UnitCategory category;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _HomeScreenState._getCategoryIcon(category);
    final iconColor = _HomeScreenState._getCategoryIconColor(category);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onFavoriteToggle();
                  },
                  child: Icon(
                    isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: isFavorite
                        ? Colors.amber
                        : AppColors.textMuted,
                    size: 20,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${category.unitSymbols.length} Units',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent Conversion Item Card.
class _RecentConversionCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onRepeatTap;

  const _RecentConversionCard({
    required this.entry,
    required this.onRepeatTap,
  });

  @override
  Widget build(BuildContext context) {
    final cat = entry.categoryEnum;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _HomeScreenState._getCategoryIcon(cat),
              color: _HomeScreenState._getCategoryIconColor(cat),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Formatters.cleanFloatingPoint(entry.inputValue)} ${entry.fromSymbol} → ${entry.toSymbol}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${Formatters.cleanFloatingPoint(entry.result)} ${entry.toSymbol}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primary, size: 20),
            onPressed: onRepeatTap,
          ),
        ],
      ),
    );
  }
}

/// Search result card widget.
class _SearchResultCard extends StatelessWidget {
  final CategorySearchResult result;
  final VoidCallback onTap;

  const _SearchResultCard({
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _HomeScreenState._getCategoryIcon(result.category);
    final iconColor = _HomeScreenState._getCategoryIconColor(result.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: iconColor, size: 20),
        ),
        title: Text(
          result.category.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${result.category.unitSymbols.length} Units supported',
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

/// Smart conversion instant card widget.
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${Formatters.cleanFloatingPoint(inputVal)} ${fromUnit.symbol} = $outputStr ${toUnit.symbol}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to open ${category.displayName} converter',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
