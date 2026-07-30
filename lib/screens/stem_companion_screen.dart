/// STEM Companion — 100% Offline STEM Knowledge & Discovery Search Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/companion_result.dart';
import '../services/companion_search_service.dart';
import '../widgets/did_you_know_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/stitch_card.dart';
import '../widgets/stitch_search_bar.dart';

class StemCompanionScreen extends StatefulWidget {
  const StemCompanionScreen({super.key});

  @override
  State<StemCompanionScreen> createState() => _StemCompanionScreenState();
}

class _StemCompanionScreenState extends State<StemCompanionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<CompanionSearchResult> _results = [];
  bool _isSearching = false;
  String _activeQuery = '';

  static const List<String> _suggestionChips = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Units',
    'Conversions',
    'Constants',
    'Engineering',
    'Recently Viewed',
    'Bookmarks',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query == _activeQuery) return;
    _activeQuery = query;

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    _performSearch(query);
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    final searchResults = await CompanionSearchService.search(
      context: context,
      query: query,
    );
    if (mounted && _searchController.text == query) {
      setState(() {
        _results = searchResults;
        _isSearching = false;
      });
    }
  }

  void _selectSuggestion(String suggestion) {
    HapticFeedback.selectionClick();
    _searchController.text = suggestion;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
  }

  Map<CompanionResultType, List<CompanionSearchResult>> _groupResults() {
    final grouped = <CompanionResultType, List<CompanionSearchResult>>{};
    for (final res in _results) {
      grouped.putIfAbsent(res.type, () => []).add(res);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final query = _searchController.text.trim();
    final groupedResults = _groupResults();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 1. HEADER & TITLE ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bolt_rounded,
                                size: 14,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '100% Offline STEM Hub',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'STEM Companion',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Search your offline STEM library.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 2. STITCH SEARCH BAR ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: StitchSearchBar(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  hintText: 'Search units, formulas, constants, topics...',
                  horizontalMargin: 24,
                  onChanged: (_) {},
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _results = [];
                      _isSearching = false;
                    });
                  },
                ),
              ),
            ),

            // ── 3. SUGGESTION CHIPS HORIZONTAL BAR ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _suggestionChips.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final chip = _suggestionChips[index];
                      final isSelected = query.toLowerCase() == chip.toLowerCase();
                      return FilterChip(
                        label: Text(chip),
                        selected: isSelected,
                        onSelected: (_) => _selectSuggestion(chip),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                        ),
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        selectedColor: colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide.none,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── 4. CONTENT AREA (SEARCHING / RESULTS / DEFAULT) ─────────────
            if (_isSearching)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (query.isNotEmpty && _results.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: EmptyStateWidget(
                    icon: Icons.manage_search_rounded,
                    message: 'No Matching STEM Results Found',
                    subtitle:
                        'No matching content was found in your offline library for "$query". Try searching another keyword or select one of the STEM quick topic chips above.',
                  ),
                ),
              )
            else if (query.isEmpty) ...[
              // ── DEFAULT LANDING VIEW WHEN NO SEARCH TYPED ─────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore STEM Topics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _QuickCategoryCard(
                            icon: Icons.straighten_rounded,
                            label: 'Units',
                            color: const Color(0xFF4F8CFF),
                            onTap: () => _selectSuggestion('Units'),
                          ),
                          _QuickCategoryCard(
                            icon: Icons.functions_rounded,
                            label: 'Mathematics',
                            color: const Color(0xFFA855F7),
                            onTap: () => _selectSuggestion('Mathematics'),
                          ),
                          _QuickCategoryCard(
                            icon: Icons.science_rounded,
                            label: 'Physics',
                            color: const Color(0xFF06B6D4),
                            onTap: () => _selectSuggestion('Physics'),
                          ),
                          _QuickCategoryCard(
                            icon: Icons.biotech_rounded,
                            label: 'Chemistry',
                            color: const Color(0xFFEC4899),
                            onTap: () => _selectSuggestion('Chemistry'),
                          ),
                          _QuickCategoryCard(
                            icon: Icons.compress_rounded,
                            label: 'Constants',
                            color: const Color(0xFFFFB77B),
                            onTap: () => _selectSuggestion('Constants'),
                          ),
                          _QuickCategoryCard(
                            icon: Icons.precision_manufacturing_rounded,
                            label: 'Engineering',
                            color: const Color(0xFF22C55E),
                            onTap: () => _selectSuggestion('Engineering'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const DidYouKnowCard(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── GROUPED SEARCH RESULTS LIST ──────────────────────────────
              for (final entry in groupedResults.entries) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Text(
                          CompanionSearchResult.groupTitle(entry.key),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${entry.value.length}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = entry.value[index];
                        return _StemResultTile(item: item);
                      },
                      childCount: entry.value.length,
                    ),
                  ),
                ),
              ],
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickCategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickCategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StemResultTile extends StatelessWidget {
  final CompanionSearchResult item;

  const _StemResultTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: StitchCard(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            item.onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.accentColor,
                      size: 20,
                    ),
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                item.categoryName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Formula preview box
              if (item.formula != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.functions_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.formula!,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Related units chips
              if (item.relatedUnits.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Related:',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.outline,
                      ),
                    ),
                    for (final rel in item.relatedUnits)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rel,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
