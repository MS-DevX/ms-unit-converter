/// Premium pill-shaped search bar with consistent styling across all screens.
library;

import 'package:flutter/material.dart';

/// Reusable search bar matching the Google Stitch Material 3 design language.
///
/// Fully rounded pill shape, zero shadows, theme-aware backgrounds,
/// and generous internal padding for a premium feel.
class StitchSearchBar extends StatefulWidget {
  /// Text editing controller for the input field.
  final TextEditingController controller;

  /// Optional focus node for programmatic focus control.
  final FocusNode? focusNode;

  /// Called when the text changes on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the clear button is tapped.
  final VoidCallback? onClear;

  /// Hint text displayed when the field is empty.
  final String hintText;

  /// Horizontal margin outside the search bar container.
  final double horizontalMargin;

  /// Whether to autofocus the field when it appears.
  final bool autofocus;

  /// Optional prefix icon override.
  final IconData? prefixIcon;

  const StitchSearchBar({
    super.key,
    required this.controller,
    this.focusNode,
    this.onChanged,
    this.onClear,
    this.hintText = 'Search units or categories...',
    this.horizontalMargin = 0,
    this.autofocus = false,
    this.prefixIcon,
  });

  @override
  State<StitchSearchBar> createState() => _StitchSearchBarState();
}

class _StitchSearchBarState extends State<StitchSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant StitchSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
      _hasText = widget.controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final nowHasText = widget.controller.text.isNotEmpty;
    if (nowHasText != _hasText) {
      setState(() => _hasText = nowHasText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    final bgColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLow;
    final iconColor = isDark ? Colors.white54 : Colors.black45;
    final hintColor = isDark ? Colors.white38 : Colors.black38;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: widget.horizontalMargin),
      height: 54,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onChanged: widget.onChanged,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: hintColor,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 4),
            child: Icon(
              widget.prefixIcon ?? Icons.search_rounded,
              color: iconColor,
              size: 22,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: _hasText
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                    tooltip: 'Clear search',
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      widget.onChanged?.call('');
                    },
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
