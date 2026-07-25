/// Screen showing all converters in a single curated collection.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/collections_data.dart';
import '../data/converter_config.dart';
import '../data/units_data.dart';
import '../providers/converter_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/pinned_provider.dart';
import '../providers/usage_provider.dart';
import '../services/refresh_service.dart';
import 'converter_screen.dart';

/// Displays all [UnitCategory] entries belonging to a [Collection].
class CollectionScreen extends StatelessWidget {
  /// The collection to display.
  final Collection collection;

  const CollectionScreen({super.key, required this.collection});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cats = collection.categories;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => RefreshService.refreshApp(context),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: colorScheme.surfaceTint,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collection.emoji,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    collection.name,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                child: Text(
                  collection.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),

          // ── Category count ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '${cats.length} converters',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ── Grid ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = cats[index];
                  final config = configFor(cat);
                  return _CollectionCategoryCard(
                    category: cat,
                    config: config,
                  );
                },
                childCount: cats.length,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _CollectionCategoryCard extends StatelessWidget {
  final UnitCategory category;
  final ConverterConfig config;

  const _CollectionCategoryCard({
    required this.category,
    required this.config,
  });

  void _open(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<UsageProvider>().trackCategoryUsage(category);
    context.read<ConverterProvider>().setCategory(category);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConverterScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favProv = context.watch<FavoritesProvider>();
    final pinnedProv = context.watch<PinnedProvider>();
    final isFav = favProv.isFavorite(category);
    final isPinned = pinnedProv.isPinned(category);

    return GestureDetector(
      onTap: () => _open(context),
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showContextMenu(context, isFav, isPinned);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: config.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: config.primaryColor.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(config.icon, color: Theme.of(context).colorScheme.onPrimary, size: 26),
            const Spacer(),
            Text(
              config.displayName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${(unitsData[category] ?? []).length} units',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, bool isFav, bool isPinned) {
    final favProv = context.read<FavoritesProvider>();
    final pinnedProv = context.read<PinnedProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded),
              title: Text(isFav ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(ctx);
                favProv.toggleFavorite(category);
              },
            ),
            ListTile(
              leading: Icon(isPinned
                  ? Icons.push_pin_rounded
                  : Icons.push_pin_outlined),
              title: Text(isPinned ? 'Unpin' : 'Pin to Home'),
              onTap: () {
                Navigator.pop(ctx);
                if (isPinned) {
                  pinnedProv.unpin(category);
                } else {
                  pinnedProv.pin(category);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
