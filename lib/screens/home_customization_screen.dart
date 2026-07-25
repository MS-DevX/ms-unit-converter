/// Screen allowing the user to drag-and-drop reorder and toggle visibility of home screen sections.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/home_layout_provider.dart';

class HomeCustomizationScreen extends StatelessWidget {
  const HomeCustomizationScreen({super.key});

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 8, animValue)!;
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          child: child,
        );
      },
      child: child,
    );
  }

  IconData _iconForSection(String id) {
    switch (id) {
      case 'insights':
        return Icons.auto_graph_rounded;
      case 'collections':
        return Icons.grid_view_rounded;
      case 'pinned':
        return Icons.push_pin_rounded;
      case 'frequently_used':
        return Icons.bolt_rounded;
      case 'categories':
        return Icons.category_rounded;
      case 'did_you_know':
        return Icons.lightbulb_outline_rounded;
      case 'recent':
        return Icons.history_rounded;
      default:
        return Icons.drag_handle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final layoutProv = context.watch<HomeLayoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'Reset to Default',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Home Layout?'),
                  content: const Text(
                    'Restore default home screen section ordering and visibility?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                HapticFeedback.mediumImpact();
                await layoutProv.resetToDefault();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Press & drag handle to reorder sections. Toggle switches to show or hide sections from your Home dashboard.',
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onSurface,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              buildDefaultDragHandles: false,
              proxyDecorator: _proxyDecorator,
              itemCount: layoutProv.sections.length,
              onReorderItem: (oldIndex, newIndex) {
                HapticFeedback.mediumImpact();
                layoutProv.reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final sec = layoutProv.sections[index];
                final icon = _iconForSection(sec.id);

                return AnimatedOpacity(
                  key: ValueKey(sec.id),
                  duration: const Duration(milliseconds: 200),
                  opacity: sec.isVisible ? 1.0 : 0.55,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: sec.isVisible
                          ? colorScheme.surfaceContainerLow
                          : colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: sec.isVisible
                            ? colorScheme.outlineVariant.withValues(alpha: 0.4)
                            : colorScheme.outlineVariant.withValues(alpha: 0.15),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.drag_handle_rounded,
                            color: sec.isVisible
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.outline,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          Icon(
                            icon,
                            size: 18,
                            color: sec.isVisible
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sec.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: sec.isVisible
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 26, top: 2),
                        child: Text(
                          sec.isVisible
                              ? 'Visible on Home Screen'
                              : 'Hidden from Home Screen',
                          style: TextStyle(
                            fontSize: 12,
                            color: sec.isVisible
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.outline,
                          ),
                        ),
                      ),
                      trailing: Switch(
                        value: sec.isVisible,
                        onChanged: (bool value) {
                          HapticFeedback.selectionClick();
                          layoutProv.toggleSection(sec.id);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
