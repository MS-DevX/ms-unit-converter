/// Settings screen — theme, premium, app info and action links.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../providers/favorites_provider.dart';
import '../providers/history_provider.dart';
import '../providers/settings_provider.dart';
import '../services/iap_service.dart';
import '../utils/formatters.dart';

/// Shows appearance, premium, about, and action settings.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Opens [url] in the default browser; silently ignores failures.
  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // No crash on launch failure.
    }
  }

  /// Shares [AppConstants.shareMessage] via the system share sheet.
  void _shareApp() {
    Share.share(AppConstants.shareMessage);
  }

  /// Maps a [ThemeMode] to a short display label.
  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Maps a [ThemeMode] to a descriptive icon.
  IconData _themeModeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.brightness_5_rounded;
      case ThemeMode.dark:
        return Icons.brightness_3_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  /// Shows a confirmation dialog before clearing all history.
  Future<void> _confirmClearHistory(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear History?'),
        content: const Text('This will remove all conversion history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      await context.read<HistoryProvider>().clearHistory();
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // ── Appearance ───────────────────────────────────────
              _SectionHeader(label: 'Appearance'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: _themeModeIcon(settings.themeMode),
                    iconColor: AppColors.primary,
                    title: 'Theme',
                    trailing: _ThemeChip(
                      label: _themeModeLabel(settings.themeMode),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      settings.toggleTheme();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Converter ─────────────────────────────────────────
              _SectionHeader(label: 'Converter'),
              _SettingsCard(
                children: [
                  ...DecimalPrecision.values.map((precision) {
                    final selected = settings.decimalPrecision == precision;
                    return Column(
                      children: [
                        if (precision != DecimalPrecision.values.first)
                          _Divider(),
                        _SettingsTile(
                          icon: selected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          iconColor: selected
                              ? AppColors.primary
                              : AppColors.lightTextSecondary,
                          title: precision.label,
                          subtitle: precision == DecimalPrecision.auto
                              ? 'Automatically choose decimal places'
                              : null,
                          trailing: selected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            settings.setDecimalPrecision(precision);
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 20),

              // ── Premium / Support ─────────────────────────────────
              _SectionHeader(label: 'Premium'),
              _SettingsCard(
                children: [
                  if (settings.isPremium)
                    _SettingsTile(
                      icon: Icons.verified_rounded,
                      iconColor: AppColors.success,
                      title: '\u2713 Premium \u2014 Ad Free',
                      subtitle: 'Thank you for your support!',
                      trailing: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                    )
                  else ...[
                    _SettingsTile(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.warning,
                      title: 'Remove Ads',
                      subtitle:
                          'One-time purchase \u2014 ${AppConstants.removeAdsPrice}',
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        IapService.instance.purchase();
                      },
                    ),
                    _Divider(),
                  ],
                  _SettingsTile(
                    icon: Icons.restore_rounded,
                    iconColor: AppColors.primary,
                    title: 'Restore Purchases',
                    subtitle: 'Already purchased? Tap to restore.',
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      IapService.instance.restore();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Privacy ───────────────────────────────────────────
              _SectionHeader(label: 'Privacy'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.lightTextSecondary,
                    title: 'Privacy Policy',
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: AppColors.lightTextSecondary,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(AppConstants.privacyPolicyUrl);
                    },
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.lightTextSecondary,
                    title: 'How your data is used',
                    subtitle:
                        'All conversions happen on-device. No data is collected, '
                        'shared, or sent to servers. Exchange rates are fetched '
                        'from a free public API.',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── About ────────────────────────────────────────────
              _SectionHeader(label: 'About'),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '—';
                  final build = snapshot.data?.buildNumber ?? '';
                  final versionLabel = build.isNotEmpty
                      ? '$version ($build)'
                      : version;

                  return _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        iconColor: AppColors.primary,
                        title: AppConstants.appName,
                        subtitle: 'Version $versionLabel',
                      ),
                      _Divider(),
                      _SettingsTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.lightTextSecondary,
                        title: 'Package',
                        subtitle: AppConstants.packageId,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // ── Actions ──────────────────────────────────────────
              _SectionHeader(label: 'Actions'),
              _SettingsCard(
                children: [
                  _SettingsTile(
                    icon: Icons.delete_outline_rounded,
                    iconColor: AppColors.error,
                    title: 'Clear History',
                    subtitle: 'Remove all conversion history',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _confirmClearHistory(context);
                    },
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.star_border_rounded,
                    iconColor: AppColors.warning,
                    title: 'Clear Favorites',
                    subtitle: 'Remove all favorite categories',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.read<FavoritesProvider>().clearFavorites();
                    },
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.star_border_rounded,
                    iconColor: AppColors.warning,
                    title: 'Rate the App',
                    subtitle: 'Enjoying it? Leave a review!',
                    trailing: const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: AppColors.lightTextSecondary,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(AppConstants.playStoreUrl);
                    },
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.share_rounded,
                    iconColor: AppColors.secondary,
                    title: 'Share the App',
                    subtitle: 'Recommend to friends',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _shareApp();
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Private components ────────────────────────────────────────────────────────

/// Small uppercase section heading rendered above a card.
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}

/// Rounded card container grouping related settings tiles.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color border = isDark ? AppColors.borderDark : AppColors.borderLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        // Material provides the ink-splash surface that ListTile requires.
        child: Material(
          color: bg,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

/// A single settings row with icon, title, optional subtitle and trailing.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  size: 20,
                )
              : null),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 0,
    );
  }
}

/// Thin divider used between tiles inside a card.
class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 0,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

/// Small pill badge showing the active theme name.
class _ThemeChip extends StatelessWidget {
  final String label;
  const _ThemeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.30)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
