/// Reusable local user avatar widget displaying local photo or initials.
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../providers/settings_provider.dart';

/// Renders local user avatar photo or fallback initials circle.
class UserAvatar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final avatarPath = settings.userAvatarPath;
        final hasImage = avatarPath.isNotEmpty && File(avatarPath).existsSync();
        final initials = settings.getInitials();

        Widget avatarCore;

        if (hasImage) {
          avatarCore = Container(
            width: size,
            height: size,
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
          avatarCore = Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          );
        }

        if (showEditBadge) {
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
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          );
        }

        if (onTap != null) {
          return GestureDetector(
            onTap: onTap,
            child: avatarCore,
          );
        }

        return avatarCore;
      },
    );
  }
}
