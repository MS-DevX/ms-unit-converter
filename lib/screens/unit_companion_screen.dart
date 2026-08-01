/// Unit Companion — 100% Offline Knowledge & Discovery Search Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/converter_config.dart';
import '../data/units_data.dart';
import '../models/companion_result.dart';
import '../services/companion_search_service.dart';
import '../widgets/did_you_know_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';
import 'converter_screen.dart';

class UnitCompanionScreen extends StatefulWidget {
  const UnitCompanionScreen({super.key});

  @override
  State<UnitCompanionScreen> createState() => _UnitCompanionScreenState();
}

class _UnitCompanionScreenState extends State<UnitCompanionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<CompanionSearchResult> _results = [];
  bool _isSearching = false;
  String _activeQuery = '';

  static const List<String> _suggestionChips = [
    'Length',
    'Weight',
    'Temperature',
    'Speed',
    'Area',
    'Volume',
    'Currency',
    'Pressure',
    'Power',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    final trimmed = query.trim();
    setState(() {
      _activeQuery = trimmed;
    });

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    final results = await CompanionSearchService.search(
      context: context,
      query: trimmed,
    );

    if (mounted && _activeQuery == trimmed) {
      setState(() {
        _results = results;
        _isSearching = false;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged('');
    _searchFocusNode.unfocus();
  }

  void _applyChip(String text) {
    HapticFeedback.selectionClick();
    _searchController.text = text;
    _onSearchChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // TOP BAR & HERO HEADER
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unit Companion',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              '100% Offline Knowledge & Discovery',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SEARCH BAR
                    StitchSearchBar(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      hintText:
                          'Search units, formulas, trivia & currencies...',
                      onChanged: _onSearchChanged,
                      onClear: _clearSearch,
                    ),

                    const SizedBox(height: 14),

                    // SUGGESTION CHIPS
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _suggestionChips.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final chip = _suggestionChips[index];
                          final isSelected =
                              _activeQuery.toLowerCase() == chip.toLowerCase();
                          return FilterChip(
                            selected: isSelected,
                            label: Text(
                              chip,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            backgroundColor: isDark
                                ? colorScheme.surfaceContainerHigh
                                : colorScheme.surfaceContainerLow,
                            selectedColor: colorScheme.primary,
                            checkmarkColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.outlineVariant.withValues(
                                        alpha: 0.5,
                                      ),
                              ),
                            ),
                            onSelected: (_) => _applyChip(chip),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // CONTENT AREA
            if (_isSearching)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_activeQuery.isNotEmpty && _results.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  icon: Icons.search_off_rounded,
                  message: 'No Matching Results Found',
                  subtitle:
                      'No matching content was found in your offline unit library for "$_activeQuery". Try searching another keyword or select one of the quick topic chips above.',
                  actionLabel: 'Clear Search',
                  onAction: _clearSearch,
                ),
              )
            else if (_results.isNotEmpty)
              _buildResultsList(context)
            else
              ..._buildDefaultExploreSlivers(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    final grouped = <CompanionResultType, List<CompanionSearchResult>>{};
    for (final res in _results) {
      grouped.putIfAbsent(res.type, () => []).add(res);
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final entry = grouped.entries.elementAt(index);
          final type = entry.key;
          final items = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  CompanionSearchResult.groupTitle(type),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _UnitResultTile(item: item),
                ),
              ),
            ],
          );
        }, childCount: grouped.length),
      ),
    );
  }

  List<Widget> _buildDefaultExploreSlivers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return [
      const SliverPadding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 16),
        sliver: SliverToBoxAdapter(child: DidYouKnowCard()),
      ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(
          child: Text(
            'EXPLORE POPULAR CATEGORIES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: colorScheme.outline,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        sliver: SliverGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _buildCategoryTile(
              context,
              UnitCategory.length,
              Icons.straighten_rounded,
            ),
            _buildCategoryTile(
              context,
              UnitCategory.weight,
              Icons.scale_rounded,
            ),
            _buildCategoryTile(
              context,
              UnitCategory.temperature,
              Icons.thermostat_rounded,
            ),
            _buildCategoryTile(
              context,
              UnitCategory.area,
              Icons.aspect_ratio_rounded,
            ),
            _buildCategoryTile(
              context,
              UnitCategory.volume,
              Icons.water_drop_rounded,
            ),
            _buildCategoryTile(
              context,
              UnitCategory.speed,
              Icons.speed_rounded,
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildCategoryTile(
    BuildContext context,
    UnitCategory category,
    IconData icon,
  ) {
    final config = configFor(category);

    return StitchCard(
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConverterScreen(initialCategory: category),
          ),
        );
      },
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: config.primaryColor, size: 28),
            const SizedBox(height: 6),
            Text(
              config.displayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitResultTile extends StatelessWidget {
  final CompanionSearchResult item;

  const _UnitResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StitchCard(
      padding: const EdgeInsets.all(12),
      leftBorderColor: item.accentColor,
      onTap: item.onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (item.categoryName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.categoryName,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.formula != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.formula!,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right_rounded,
            color: colorScheme.outline,
            size: 20,
          ),
        ],
      ),
    );
  }
}
