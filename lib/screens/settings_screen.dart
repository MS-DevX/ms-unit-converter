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
import '../utils/formatters.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
    }
  }

  void _shareApp() {
    SharePlus.instance.share(ShareParams(text: AppConstants.shareMessage));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
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
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFFA855F7),
                    title: 'Cosmic Space UI',
                    subtitle: 'Glassmorphic 3D tiles & animated starfield',
                    trailing: Switch.adaptive(
                      value: settings.isCosmicTheme,
                      activeThumbColor: const Color(0xFFA855F7),
                      onChanged: (_) {
                        HapticFeedback.lightImpact();
                        settings.toggleCosmicTheme();
                      },
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      settings.toggleCosmicTheme();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

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

              _SectionHeader(label: 'Data'),
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
                ],
              ),

              const SizedBox(height: 20),

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

              _SectionHeader(label: 'Actions'),
              _SettingsCard(
                children: [
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
        child: Material(
          color: bg,
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );
  }
}

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
