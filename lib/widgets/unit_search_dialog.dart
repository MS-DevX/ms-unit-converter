import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/unit_model.dart';

class UnitSearchDialog extends StatefulWidget {
  final List<UnitModel> units;
  final UnitModel? selectedUnit;

  const UnitSearchDialog({super.key, required this.units, this.selectedUnit});

  @override
  State<UnitSearchDialog> createState() => _UnitSearchDialogState();
}

class _UnitSearchDialogState extends State<UnitSearchDialog> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UnitModel> get _filteredUnits {
    if (_query.isEmpty) return widget.units;
    final q = _query.toLowerCase();
    return widget.units.where((u) {
      return u.name.toLowerCase().contains(q) ||
          u.symbol.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final Color surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final Color textColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark
                ? Theme.of(context).colorScheme.surfaceContainerHigh
                : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                hintText: 'Search units\u2026',
                hintStyle: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? AppColors.darkTextSecondary.withValues(alpha: 0.5)
                      : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              style: TextStyle(fontSize: 15, color: textColor),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _filteredUnits.length,
        separatorBuilder: (_, _) => Divider(
          height: 0.5,
          thickness: 0.5,
          indent: 16,
          endIndent: 16,
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
        itemBuilder: (context, index) {
          final unit = _filteredUnits[index];
          final isSelected = unit == widget.selectedUnit;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context, unit),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: isSelected
                    ? (isDark
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.08))
                    : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        unit.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      unit.symbol,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
