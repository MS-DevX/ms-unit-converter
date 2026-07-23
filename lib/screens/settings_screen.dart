/// Settings Screen — Pixel-perfect implementation of Google Stitch Material Design 3 export.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/stitch_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _shareApp() {
    SharePlus.instance.share(ShareParams(text: AppConstants.shareMessage));
  }

  void _editProfileName(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Your Name', style: TextStyle(color: AppColors.onSurface)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          style: const TextStyle(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
            fillColor: AppColors.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              settings.setUserName(controller.text.trim());
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainer,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // PROFILE SECTION CARD
            StitchCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settings.userName.isNotEmpty ? settings.userName : 'Shahzad',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Local Profile • No Cloud Sync',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _editProfileName(context, settings),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.onSurface,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // APPEARANCE SECTION
            const _SectionHeader(title: 'APPEARANCE'),
            const SizedBox(height: 8),
            StitchCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsListTile(
                    icon: Icons.dark_mode_rounded,
                    title: 'Theme',
                    subtitle: settings.themeMode == ThemeMode.dark ? 'Dark Mode' : 'System Default',
                    trailing: Switch.adaptive(
                      value: settings.themeMode == ThemeMode.dark,
                      activeThumbColor: AppColors.primary,
                      onChanged: (_) {
                        HapticFeedback.lightImpact();
                        settings.toggleTheme();
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsListTile(
                    icon: Icons.palette_rounded,
                    title: 'Accent Color',
                    subtitle: 'Deep Space Blue (#4F8CFF)',
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UNITS & PRECISION SECTION
            const _SectionHeader(title: 'CONVERTER & PRECISION'),
            const SizedBox(height: 8),
            StitchCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ...DecimalPrecision.values.map((precision) {
                    final selected = settings.decimalPrecision == precision;
                    return Column(
                      children: [
                        if (precision != DecimalPrecision.values.first)
                          const Divider(height: 1, indent: 56),
                        _SettingsListTile(
                          icon: selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                          iconColor: selected ? AppColors.primary : AppColors.outline,
                          title: precision.label,
                          subtitle: 'Precision formatting setting',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            settings.setDecimalPrecision(precision);
                          },
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ACTIONS & ABOUT SECTION
            const _SectionHeader(title: 'ACTIONS & ABOUT'),
            const SizedBox(height: 8),
            StitchCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsListTile(
                    icon: Icons.star_border_rounded,
                    title: 'Rate the App',
                    subtitle: 'Enjoying Unit Converter? Leave a review!',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(AppConstants.playStoreUrl);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsListTile(
                    icon: Icons.share_rounded,
                    title: 'Share the App',
                    subtitle: 'Recommend to friends & colleagues',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _shareApp();
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsListTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Version',
                    subtitle: AppConstants.appVersion,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // PRIVACY NOTE FOOTER
            const Center(
              child: Text(
                '🔒 100% Free • Private & Offline • MS DevX',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsListTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsListTile({
    required this.icon,
    this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.outlineVariant,
                )
              : null),
    );
  }
}
