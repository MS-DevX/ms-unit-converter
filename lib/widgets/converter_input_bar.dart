import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/colors.dart';
import '../models/unit_model.dart';
import 'unit_search_dialog.dart';

class ConverterInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final UnitModel? sourceUnit;
  final List<UnitModel> units;
  final ValueChanged<String> onInputChanged;
  final ValueChanged<UnitModel> onUnitChanged;
  final TextInputType? keyboardType;

  const ConverterInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.sourceUnit,
    required this.units,
    required this.onInputChanged,
    required this.onUnitChanged,
    this.keyboardType,
  });

  Future<void> _openUnitSearch(BuildContext context) async {
    final selected = await showDialog<UnitModel>(
      context: context,
      useSafeArea: false,
      builder: (_) => UnitSearchDialog(units: units, selectedUnit: sourceUnit),
    );
    if (selected != null && context.mounted) {
      onUnitChanged(selected);
      HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasInput = controller.text.isNotEmpty;
    final Color borderColor = isDark
        ? AppColors.borderDark
        : AppColors.borderLight;
    final bgColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType:
                  keyboardType ??
                  const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
              textCapitalization: keyboardType == TextInputType.text
                  ? TextCapitalization.characters
                  : TextCapitalization.none,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
                height: 1.2,
              ),
              decoration: InputDecoration(
                filled: false,
                hintText: '0',
                hintStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color:
                      (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          .withValues(alpha: 0.35),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                isDense: true,
                suffixIcon: hasInput
                    ? GestureDetector(
                        onTap: () {
                          controller.clear();
                          onInputChanged('');
                          focusNode.requestFocus();
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      )
                    : null,
              ),
              textInputAction: TextInputAction.done,
              onChanged: onInputChanged,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Semantics(
              label: 'Select unit, currently ${sourceUnit?.name ?? 'none'}',
              button: true,
              child: GestureDetector(
                onTap: () => _openUnitSearch(context),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          sourceUnit?.symbol ?? '\u2014',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
