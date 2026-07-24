/// Settings Screen — Compact Material 3 implementation matching Google Stitch design tokens.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../providers/settings_provider.dart';
import '../providers/usage_provider.dart';
import '../services/in_app_update_service.dart';
import '../utils/formatters.dart';
import '../widgets/stitch_card.dart';
import '../widgets/user_avatar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmResetUsage(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Usage History?', style: TextStyle(color: AppColors.onSurface)),
        content: const Text(
          'This will clear your frequently used categories and usage statistics.',
          style: TextStyle(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.read<UsageProvider>().resetUsage();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usage statistics reset successfully.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _shareApp() {
    SharePlus.instance.share(ShareParams(text: AppConstants.shareMessage));
  }

  Future<void> _showAvatarOptions(BuildContext context, SettingsProvider settings) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final picker = ImagePicker();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.onSurface)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    settings.setUserAvatarPath(image.path);
                  }
                } catch (e) {
                  debugPrint('[AvatarPicker] Error: $e');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Take a Photo', style: TextStyle(color: AppColors.onSurface)),
              onTap: () async {
                Navigator.pop(ctx);
                try {
                  final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    settings.setUserAvatarPath(photo.path);
                  }
                } catch (e) {
                  debugPrint('[AvatarPicker] Error: $e');
                }
              },
            ),
            if (settings.userAvatarPath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                title: const Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                onTap: () {
                  settings.removeUserAvatar();
                  Navigator.pop(ctx);
                },
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
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

  void _showThemeSelector(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto_rounded, color: AppColors.primary),
              title: const Text('System Default', style: TextStyle(color: AppColors.onSurface)),
              trailing: settings.themeMode == ThemeMode.system
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.light_mode_rounded, color: AppColors.primary),
              title: const Text('Light', style: TextStyle(color: AppColors.onSurface)),
              trailing: settings.themeMode == ThemeMode.light
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
              title: const Text('Dark', style: TextStyle(color: AppColors.onSurface)),
              trailing: settings.themeMode == ThemeMode.dark
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setThemeMode(ThemeMode.dark);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  void _showPrecisionSelector(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Default Precision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            ...DecimalPrecision.values.map((precision) {
              final selected = settings.decimalPrecision == precision;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? AppColors.primary : AppColors.outline,
                ),
                title: Text(
                  precision.label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.onSurface,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  HapticFeedback.selectionClick();
                  settings.setDecimalPrecision(precision);
                  Navigator.pop(ctx);
                },
              );
            }),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
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
            // PROFILE SECTION CARD WITH USER AVATAR
            StitchCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(
                    size: 56,
                    showEditBadge: true,
                    onTap: () => _showAvatarOptions(context, settings),
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
              child: _SettingsListTile(
                icon: Icons.dark_mode_rounded,
                title: 'Theme',
                subtitle: _getThemeLabel(settings.themeMode),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getThemeLabel(settings.themeMode),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                  ],
                ),
                onTap: () => _showThemeSelector(context, settings),
              ),
            ),

            const SizedBox(height: 24),

            // CONVERTER & PRECISION SECTION
            const _SectionHeader(title: 'CONVERTER & PRECISION'),
            const SizedBox(height: 8),
            StitchCard(
              padding: EdgeInsets.zero,
              child: _SettingsListTile(
                icon: Icons.tune_rounded,
                title: 'Default Precision',
                subtitle: settings.decimalPrecision.label,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      settings.decimalPrecision.label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                  ],
                ),
                onTap: () => _showPrecisionSelector(context, settings),
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
                    icon: Icons.system_update_rounded,
                    title: 'Check for Updates',
                    subtitle: 'Google Play In-App Updates',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      InAppUpdateService.instance.checkForUpdate(context: context);
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  _SettingsListTile(
                    icon: Icons.restart_alt_rounded,
                    title: 'Reset Usage Statistics',
                    subtitle: 'Clear category usage history',
                    onTap: () => _confirmResetUsage(context),
                  ),
                  const Divider(height: 1, indent: 56),
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
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsListTile({
    required this.icon,
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
        color: AppColors.onSurfaceVariant,
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
