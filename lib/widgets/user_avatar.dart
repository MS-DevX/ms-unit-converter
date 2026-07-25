/// Reusable local user avatar widget displaying local photo or initials.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../providers/settings_provider.dart';

/// Renders local user avatar photo or fallback initials circle.
class UserAvatar extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const UserAvatar({
    super.key,
    this.size = 56,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool? _cachedExists;
  String _cachedPath = '';

  bool _checkFileExists(String path) {
    if (path != _cachedPath) {
      _cachedPath = path;
      _cachedExists = path.isNotEmpty && File(path).existsSync();
    }
    return _cachedExists ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final avatarPath = settings.userAvatarPath;
        final hasImage = _checkFileExists(avatarPath);
        final initials = settings.getInitials();

        Widget avatarCore;

        if (hasImage) {
          avatarCore = Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: FileImage(File(avatarPath)),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
          );
        } else {
          final colorScheme = Theme.of(context).colorScheme;
          avatarCore = Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: widget.size * 0.42,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
          );
        }

        if (widget.showEditBadge) {
          avatarCore = Stack(
            children: [
              avatarCore,
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 14,
                  ),
                ),
              ),
            ],
          );
        }

        if (widget.onTap != null) {
          return GestureDetector(
            onTap: widget.onTap,
            child: avatarCore,
          );
        }

        return avatarCore;
      },
    );
  }
}
