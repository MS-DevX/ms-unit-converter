/// Home screen — premium category grid with animated cards, persistent search bar, and quick presets.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../data/currencies_data.dart';
import '../data/units_data.dart';
import '../models/unit_model.dart';
import '../providers/favorites_provider.dart';
import '../services/conversion_service.dart';
import '../services/smart_parse_service.dart';
import '../utils/formatters.dart';
import '../utils/search_helper.dart';
import '../core/ui_constants.dart';
import '../providers/settings_provider.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glassmorphic_tile.dart';
import '../widgets/conversion_bar.dart';
import '../widgets/performance_monitor.dart';
import '../providers/converter_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/empty_state_widget.dart';
import 'converter_screen.dart';
import 'currency_screen.dart';

/// A premium grid showing all conversion categories as styled cards
/// with a persistent smart search bar and quick conversion presets.
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

  static const Map<UnitCategory, List<Color>> _categoryGradients = {
    UnitCategory.length: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    UnitCategory.weight: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.temperature: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    UnitCategory.area: [Color(0xFF8B5CF6), Color(0xFF5B21B6)],
    UnitCategory.volume: [Color(0xFFF59E0B), Color(0xFFD97706)],
    UnitCategory.speed: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.data: [Color(0xFFEC4899), Color(0xFFBE185D)],
    UnitCategory.time: [Color(0xFF6366F1), Color(0xFF4338CA)],
    UnitCategory.angle: [Color(0xFF14B8A6), Color(0xFF0F766E)],
    UnitCategory.energy: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.power: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.pressure: [Color(0xFF0EA5E9), Color(0xFF0369A1)],
    UnitCategory.force: [Color(0xFF84CC16), Color(0xFF4D7C0F)],
    UnitCategory.frequency: [Color(0xFFEC4899), Color(0xFF9D174D)],
    UnitCategory.fuelEconomy: [Color(0xFF22D3EE), Color(0xFF0E7490)],
    UnitCategory.cooking: [Color(0xFFF97316), Color(0xFFC2410C)],
    UnitCategory.shoeSize: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
    UnitCategory.clothingSize: [Color(0xFF06B6D4), Color(0xFF0891B2)],
    UnitCategory.numberBase: [Color(0xFF10B981), Color(0xFF047857)],
    UnitCategory.typography: [Color(0xFF6366F1), Color(0xFF4338CA)],
  };

  static const List<_PresetConversion> _quickPresets = [
    _PresetConversion(
      category: UnitCategory.length,
      value: 1,
      fromUnitName: 'Kilometer',
      toUnitName: 'Mile',
    ),
    _PresetConversion(
      category: UnitCategory.length,
      value: 1,
      fromUnitName: 'Meter',
      toUnitName: 'Foot',
    ),
    _PresetConversion(
      category: UnitCategory.weight,
      value: 1,
      fromUnitName: 'Kilogram',
      toUnitName: 'Pound',
    ),
    _PresetConversion(
      category: UnitCategory.temperature,
      value: 0,
      fromUnitName: 'Celsius',
      toUnitName: 'Fahrenheit',
    ),
    _PresetConversion(
      category: UnitCategory.volume,
      value: 1,
      fromUnitName: 'Liter',
      toUnitName: 'Gallon (US)',
    ),
    _PresetConversion(
      category: UnitCategory.speed,
      value: 1,
      fromUnitName: 'Kilometers per Hour',
      toUnitName: 'Miles per Hour',
    ),
    _PresetConversion(
      category: UnitCategory.cooking,
      value: 1,
      fromUnitName: 'Cup (US)',
      toUnitName: 'Tablespoon',
    ),
    _PresetConversion(
      category: UnitCategory.shoeSize,
      value: 42,
      fromUnitName: 'EU',
      toUnitName: 'US Men',
    ),
    _PresetConversion(
      category: UnitCategory.clothingSize,
      value: 32,
      fromUnitName: 'US',
      toUnitName: 'EU',
    ),
    _PresetConversion(
      category: UnitCategory.numberBase,
      value: 255,
      fromUnitName: 'Decimal',
      toUnitName: 'Hexadecimal',
    ),
    _PresetConversion(
      category: UnitCategory.typography,
      value: 16,
      fromUnitName: 'Pixels',
      toUnitName: 'Points',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  void _openConverter(
    BuildContext context,
    UnitCategory category, {
    String? presetFromUnitName,
    String? presetToUnitName,
  }) {
    HapticFeedback.lightImpact();

    final converter = context.read<ConverterProvider>();
    converter.setCategory(category);

    if (presetFromUnitName != null) {
      final from = converter.currentUnits
          .where((u) => u.name == presetFromUnitName)
          .firstOrNull;
      if (from != null) converter.setFromUnit(from);
    }
    if (presetToUnitName != null) {
      final to = converter.currentUnits
          .where((u) => u.name == presetToUnitName)
          .firstOrNull;
      if (to != null) converter.setToUnit(to);
    }

    if (!ResponsiveHelper.isExpanded(context)) {
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return ConverterScreen(
              initialCategory: category,
              presetFromUnitName: presetFromUnitName,
              presetToUnitName: presetToUnitName,
            );
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    }
  }

  void _showCategoryPresets(BuildContext context, UnitCategory category) {
    HapticFeedback.mediumImpact();
    final presets = category.commonConversions;
    final gradients = _categoryGradients[category]!;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final favProv = context.read<FavoritesProvider>();
            final isFav = favProv.isFavorite(category);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      alignment: Alignment.center,
                    ),
                    Row(
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category.displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            favProv.toggleFavorite(category);
                            setSheetState(() {});
                          },
                          child: Icon(
                            isFav
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: isFav ? Colors.amber : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Long-press a conversion to jump in',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...presets.map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(ctx).pop();
                            _openConverterWithPreset(
                              context,
                              _PresetConversion(
                                category: category,
                                value: p.value,
                                fromUnitName: p.fromUnitName,
                                toUnitName: p.toUnitName,
                              ),
                            );
                          },
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradients,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                Text(
                                  '${p.value == p.value.roundToDouble() ? p.value.toInt() : p.value} ${p.fromUnitName}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    size: 16,
                                  ),
                                ),
                                Text(
                                  p.toUnitName,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openConverterWithPreset(
    BuildContext context,
    _PresetConversion preset,
  ) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return ConverterScreen(
            initialCategory: preset.category,
            presetValue: preset.value,
            presetFromUnitName: preset.fromUnitName,
            presetToUnitName: preset.toUnitName,
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
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Widget _buildBody() {
    final query = _searchController.text.trim();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final isCosmic = settings.isCosmicTheme;

    return PerformanceMonitor(
      enabled: false,
      child: CosmicBackground(
        scrollController: _scrollController,
        opacity: isCosmic ? 0.08 : 0.0,
        child: Consumer<FavoritesProvider>(
          builder: (context, favProv, _) {
            final favoriteList = favProv.favorites.toList();
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
              child: CustomScrollView(
                controller: _scrollController,
                key: ValueKey(_refreshKey),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Persistent Smart Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Search categories or units (e.g. 10 km to miles)',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                                : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                          ),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20),
                          suffixIcon: query.isNotEmpty
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
                            horizontal: 14,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: (isCosmic || isDark)
                              ? AppColors.darkSurface.withValues(alpha: 0.85)
                              : AppColors.lightSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isCosmic
                                  ? CosmicUIConstants.cosmicBorder
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isCosmic
                                  ? CosmicUIConstants.cosmicBorder
                                  : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.borderLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Search results view
                  if (query.isNotEmpty) ...[
                    if (showSmart)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          message: 'No conversions found',
                          subtitle: 'Try searching for a category or unit name',
                        ),
                      ),
                    if (detailedResults.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final res = detailedResults[index];
                              return _SearchResultCard(
                                result: res,
                                gradients: _categoryGradients[res.category]!,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  _openConverter(context, res.category);
                                },
                                onUnitTap: (unit) {
                                  HapticFeedback.lightImpact();
                                  _openConverter(
                                    context,
                                    res.category,
                                    presetFromUnitName: unit.name,
                                  );
                                },
                              );
                            },
                            childCount: detailedResults.length,
                          ),
                        ),
                      ),
                  ] else ...[
                    // Normal view (Favorites + Full Grid + Quick Conversions)
                    if (favoriteList.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildFavoritesSection(favoriteList),
                      ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        favoriteList.isNotEmpty ? 4 : 8,
                        16,
                        12,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600
                              ? 4
                              : 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: MediaQuery.of(context).size.width > 600
                              ? 1.2
                              : 1.1,
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
                              onLongPress: () =>
                                  _showCategoryPresets(context, category),
                            );
                          }
                          return _CategoryCard(
                            category: category,
                            gradients: _categoryGradients[category]!,
                            onTap: () => _openConverter(context, category),
                            onLongPress: () =>
                                _showCategoryPresets(context, category),
                          );
                        }, childCount: UnitCategory.values.length),
                      ),
                    ),

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

                    SliverToBoxAdapter(
                      child: _QuickConversions(
                        presets: _quickPresets,
                        onPresetTapped: (preset) =>
                            _openConverterWithPreset(context, preset),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
              const SizedBox(width: 6),
              Text(
                'Favorites',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final category = favorites[index];
                return GestureDetector(
                  onTap: () => _openConverter(context, category),
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: _categoryGradients[category]!,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          category.icon,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          category.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSmartResultTap(SmartParseResult result) {
    HapticFeedback.lightImpact();
    if (result.isCurrency) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CurrencyScreen()));
    } else if (result.category != null &&
        result.fromUnitName != null &&
        result.toUnitName != null) {
      _openConverterWithPreset(
        context,
        _PresetConversion(
          category: result.category!,
          value: result.amount!,
          fromUnitName: result.fromUnitName!,
          toUnitName: result.toUnitName!,
        ),
      );
    }
  }
}

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

  String get label =>
      '${value == value.roundToDouble() ? value.toInt() : value} $fromUnitName → $toUnitName';
}

class _QuickConversions extends StatelessWidget {
  final List<_PresetConversion> presets;
  final ValueChanged<_PresetConversion> onPresetTapped;

  const _QuickConversions({
    required this.presets,
    required this.onPresetTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on_rounded, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(
                'Quick Conversions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...presets.map(
            (preset) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PresetChip(
                preset: preset,
                onTap: () => onPresetTapped(preset),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final _PresetConversion preset;
  final VoidCallback onTap;

  const _PresetChip({required this.preset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gradients = _HomeScreenState._categoryGradients[preset.category]!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradients.last.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Text(preset.category.icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                preset.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.6),
              size: 12,
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

/// A single premium category card with gradient, icon, name, and unit count.
class _CategoryCard extends StatelessWidget {
  final UnitCategory category;
  final List<Color> gradients;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryCard({
    required this.category,
    required this.gradients,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: gradients,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradients.last.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              onLongPress: onLongPress,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(category.icon, style: const TextStyle(fontSize: 26)),
                    const Spacer(),
                    Text(
                      category.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        ...category.unitSymbols
                            .take(4)
                            .map(
                              (s) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        if (category.unitSymbols.length > 4)
                          Text(
                            '+${category.unitSymbols.length - 4}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
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

/// Smart convert card shown when a natural language conversion query is recognized.
class _SmartConvertCard extends StatelessWidget {
  final SmartParseResult result;
  final VoidCallback onTap;

  const _SmartConvertCard({required this.result, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          result.isCurrency
                              ? Icons.currency_exchange_rounded
                              : Icons.swap_horiz_rounded,
                          color: Colors.white.withValues(alpha: 0.9),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          result.isCurrency
                              ? 'Currency Conversion'
                              : 'Unit Conversion',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _previewLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Tap to open converter',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 12,
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

  String _previewLabel() {
    final amount = result.amount ?? 0;
    final fromLabel = result.isCurrency
        ? (result.fromCurrencyCode ?? '?')
        : (result.fromUnitName ?? '?');
    final toLabel = result.isCurrency
        ? (result.toCurrencyCode ?? '?')
        : (result.toUnitName ?? '?');
    final displayAmount = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toString();

    String converted;
    if (result.isCurrency) {
      converted = _currencyPreview(amount);
    } else if (result.category != null &&
        result.fromUnitName != null &&
        result.toUnitName != null) {
      final units = getUnits(result.category!);
      final from = units
          .where((u) => u.name == result.fromUnitName)
          .firstOrNull;
      final to = units.where((u) => u.name == result.toUnitName).firstOrNull;
      if (from != null && to != null) {
        final conv = ConversionService.convert(
          amount,
          from,
          to,
          result.category!,
        );
        if (conv.isValid) {
          converted = conv.formattedResult;
        } else {
          converted = '?';
        }
      } else {
        converted = '?';
      }
    } else {
      converted = '?';
    }

    return '$displayAmount $fromLabel = $converted $toLabel';
  }

  String _currencyPreview(double amount) {
    final fromCode = result.fromCurrencyCode;
    final toCode = result.toCurrencyCode;
    if (fromCode == null || toCode == null) return '?';
    final fromRate = fallbackRatesToUsd[fromCode];
    final toRate = fallbackRatesToUsd[toCode];
    if (fromRate == null || toRate == null) return '?';
    final converted = amount * (1 / fromRate) * toRate;
    return Formatters.formatResult(converted);
  }
}

/// Detailed search result card highlighting matched units.
class _SearchResultCard extends StatelessWidget {
  final CategorySearchResult result;
  final List<Color> gradients;
  final VoidCallback onTap;
  final ValueChanged<UnitModel> onUnitTap;

  const _SearchResultCard({
    required this.result,
    required this.gradients,
    required this.onTap,
    required this.onUnitTap,
  });

  @override
  Widget build(BuildContext context) {
    final category = result.category;
    final matchedUnits = result.matchingUnits;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: gradients,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: gradients.last.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.icon, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              category.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.5),
                        size: 14,
                      ),
                    ],
                  ),

                  // Matched unit chips
                  if (matchedUnits.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: matchedUnits.take(6).map((unit) {
                        return InkWell(
                          onTap: () => onUnitTap(unit),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  unit.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (unit.symbol.isNotEmpty) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${unit.symbol})',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
