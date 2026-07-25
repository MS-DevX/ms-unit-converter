/// Screen allowing the user to drag-and-drop reorder and toggle visibility of home screen sections.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/home_layout_provider.dart';

class HomeCustomizationScreen extends StatelessWidget {
  const HomeCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final layoutProv = context.watch<HomeLayoutProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Home Screen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Drag handles to reorder home sections. Use switches to hide or show sections.',
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: layoutProv.sections.length,
              onReorderItem: (oldIndex, newIndex) {
                HapticFeedback.lightImpact();
                layoutProv.reorder(oldIndex, newIndex);
              },
              itemBuilder: (context, index) {
                final sec = layoutProv.sections[index];
                return Card(
                  key: ValueKey(sec.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: SwitchListTile(
                    title: Text(sec.title, style: const TextStyle(fontWeight: FontWeight.w500)),
                    value: sec.isVisible,
                    onChanged: (_) {
                      HapticFeedback.selectionClick();
                      layoutProv.toggleSection(sec.id);
                    },
                    secondary: const Icon(Icons.drag_handle_rounded),
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
