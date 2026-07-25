/// Home screen insights banner widget.
///
/// Displays total conversions, favorite category, most used unit
/// and last used time — all computed locally from stored data.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/history_provider.dart';
import '../providers/usage_provider.dart';
import '../services/insights_service.dart';

/// A compact banner showing user conversion statistics.
///
/// Tapping expands to show the full stats row.
/// All values are computed offline from [UsageProvider] + [HistoryProvider].
class InsightsBanner extends StatelessWidget {
  const InsightsBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usageProv = context.watch<UsageProvider>();
    final historyProv = context.watch<HistoryProvider>();

    final insights = InsightsService.compute(
      usageCounts: usageProv.usageCounts,
      history: historyProv.entries,
    );

    if (insights.totalConversions == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Your Conversion Stats',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                label: 'Total',
                value: _formatCount(insights.totalConversions),
                icon: Icons.swap_horiz_rounded,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 8),
              if (insights.favoriteCategoryName != null)
                Expanded(
                  child: _StatChip(
                    label: 'Favorite',
                    value: insights.favoriteCategoryName!,
                    icon: Icons.favorite_rounded,
                    colorScheme: colorScheme,
                  ),
                ),
              const SizedBox(width: 8),
              if (insights.lastUsed != null)
                _StatChip(
                  label: 'Last used',
                  value: InsightsService.relativeTime(insights.lastUsed!),
                  icon: Icons.history_rounded,
                  colorScheme: colorScheme,
                ),
            ],
          ),
          if (insights.mostUsedUnit != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Most used unit: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  insights.mostUsedUnit!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ColorScheme colorScheme;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
