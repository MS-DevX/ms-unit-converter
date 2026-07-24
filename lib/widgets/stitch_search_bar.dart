/// Google Stitch Material 3 Search Bar component.
library;

import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: colorScheme.outline.withValues(alpha: 0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: colorScheme.outline,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear!();
                  },
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
