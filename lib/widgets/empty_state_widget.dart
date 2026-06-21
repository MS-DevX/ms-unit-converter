import 'package:flutter/material.dart';

import '../core/colors.dart';

/// Reusable empty state widget with an icon and message.
///
/// Used throughout the app to display placeholder content when no
/// data is available (e.g. empty search results, empty history).
class EmptyStateWidget extends StatelessWidget {
  /// The icon to display (defaults to a search icon).
  final IconData icon;

  /// The primary message.
  final String message;

  /// Optional secondary text shown below the message.
  final String? subtitle;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.message = 'No results found',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: isDark
                  ? AppColors.darkTextSecondary.withValues(alpha: 0.4)
                  : AppColors.lightTextSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.6)
                      : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
