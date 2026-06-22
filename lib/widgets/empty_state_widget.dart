import 'package:flutter/material.dart';

import '../core/colors.dart';

/// Reusable empty state widget with an icon, message, optional subtitle,
/// and optional action button.
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

  /// Optional label for an action button below the subtitle.
  final String? actionLabel;

  /// Optional callback for the action button.
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.search_off_rounded,
    this.message = 'No results found',
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: color.withValues(alpha: 0.3)),
            const SizedBox(height: 20),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: color.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: onAction,
                icon: Icon(icon, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
