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
import 'custom_converter_screen.dart';
import 'home_customization_screen.dart';
import 'notes_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _confirmResetUsage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset Usage History?', style: TextStyle(color: colorScheme.onSurface)),
        content: Text(
          'This will clear your frequently used categories and usage statistics.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
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
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Profile Avatar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: colorScheme.primary),
              title: Text('Choose from Gallery', style: TextStyle(color: colorScheme.onSurface)),
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
              leading: Icon(Icons.camera_alt_rounded, color: colorScheme.primary),
              title: Text('Take a Photo', style: TextStyle(color: colorScheme.onSurface)),
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
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Your Name', style: TextStyle(color: colorScheme.onSurface)),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          autofocus: true,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            fillColor: colorScheme.surface,
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: TextStyle(color: colorScheme.onSurfaceVariant)),
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
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
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Theme',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.brightness_auto_rounded, color: colorScheme.primary),
              title: Text('System Default', style: TextStyle(color: colorScheme.onSurface)),
              trailing: settings.themeMode == ThemeMode.system
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setThemeMode(ThemeMode.system);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.light_mode_rounded, color: colorScheme.primary),
              title: Text('Light', style: TextStyle(color: colorScheme.onSurface)),
              trailing: settings.themeMode == ThemeMode.light
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                settings.setThemeMode(ThemeMode.light);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(Icons.dark_mode_rounded, color: colorScheme.primary),
              title: Text('Dark', style: TextStyle(color: colorScheme.onSurface)),
              trailing: settings.themeMode == ThemeMode.dark
                  ? Icon(Icons.check_rounded, color: colorScheme.primary)
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
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surfaceContainer,
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
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Default Precision',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            ...DecimalPrecision.values.map((precision) {
              final selected = settings.decimalPrecision == precision;
              return ListTile(
                leading: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? colorScheme.primary : colorScheme.outline,
                ),
                title: Text(
                  precision.label,
                  style: TextStyle(
                    color: selected ? colorScheme.primary : colorScheme.onSurface,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _editProfileName(context, settings),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      foregroundColor: colorScheme.onSurface,
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down_rounded, color: colorScheme.primary),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down_rounded, color: colorScheme.primary),
                  ],
                ),
                onTap: () => _showPrecisionSelector(context, settings),
              ),
            ),

            const SizedBox(height: 24),

            // TOOLKIT & CUSTOMIZATION SECTION
            const _SectionHeader(title: 'TOOLKIT & CUSTOMIZATION'),
            const SizedBox(height: 8),
            StitchCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsListTile(
                    icon: Icons.dashboard_customize_rounded,
                    title: 'Customize Home Screen',
                    subtitle: 'Reorder sections & toggle visibility',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeCustomizationScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsListTile(
                    icon: Icons.note_alt_rounded,
                    title: 'Conversion Notes',
                    subtitle: 'Manage saved calculation notes',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotesScreen()),
                      );
                    },
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsListTile(
                    icon: Icons.exposure_rounded,
                    title: 'Custom Converters',
                    subtitle: 'Create linear ratio converters',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CustomConverterScreen()),
                      );
                    },
                  ),
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
                    icon: Icons.system_update_rounded,
                    title: 'Check for Updates',
                    subtitle: 'Google Play In-App Updates',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      InAppUpdateService.instance.checkForUpdate(context: context);
                    },
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsListTile(
                    icon: Icons.restart_alt_rounded,
                    title: 'Reset Usage Statistics',
                    subtitle: 'Clear category usage history',
                    onTap: () => _confirmResetUsage(context),
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsListTile(
                    icon: Icons.star_border_rounded,
                    title: 'Rate the App',
                    subtitle: 'Enjoying Unit Converter? Leave a review!',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _launchUrl(AppConstants.playStoreUrl);
                    },
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                  _SettingsListTile(
                    icon: Icons.share_rounded,
                    title: 'Share the App',
                    subtitle: 'Recommend to friends & colleagues',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _shareApp();
                    },
                  ),
                  Divider(height: 1, indent: 56, color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
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
            Center(
              child: Text(
                '🔒 100% Free • Private & Offline • MS DevX',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      onTap: onTap,
      leading: Icon(
        icon,
        color: colorScheme.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.outlineVariant,
                )
              : null),
    );
  }
}
