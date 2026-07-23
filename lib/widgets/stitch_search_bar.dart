/// Google Stitch Material 3 Search Bar component.
library;

import 'package:flutter/material.dart';
import '../core/colors.dart';

class StitchSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String hintText;

  const StitchSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search units or categories...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.outline.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.outline,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear!();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
