/// Screen for managing user-created conversion notes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/conversion_note.dart';
import '../providers/notes_provider.dart';
import '../services/refresh_service.dart';
import '../widgets/empty_state_widget.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  void _showNoteDialog(BuildContext context, [ConversionNote? note]) {
    final titleCtrl = TextEditingController(text: note?.title ?? '');
    final bodyCtrl = TextEditingController(text: note?.body ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(note == null ? 'New Conversion Note' : 'Edit Note'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Steel beam calculation',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. 10m rod = 32.8ft for frame #2',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleCtrl.text.trim();
              if (title.isEmpty) return;
              final notesProv = context.read<NotesProvider>();
              if (note == null) {
                notesProv.addNote(title: title, body: bodyCtrl.text);
              } else {
                notesProv.updateNote(note.id, title: title, body: bodyCtrl.text);
              }
              Navigator.pop(ctx);
            },
            child: Text(note == null ? 'Save' : 'Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final notesProv = context.watch<NotesProvider>();
    final notes = notesProv.notes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversion Notes'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Note'),
      ),
      body: RefreshIndicator(
        onRefresh: () => RefreshService.refreshApp(context),
        child: notes.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: const EmptyStateWidget(
                    icon: Icons.note_alt_outlined,
                    message: 'No Notes Saved Yet',
                    subtitle: 'Tap the button below to add a reminder or formula note.',
                  ),
                ),
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final note = notes[index];
                return Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.delete_rounded, color: colorScheme.onErrorContainer),
                  ),
                  onDismissed: (_) {
                    HapticFeedback.mediumImpact();
                    notesProv.deleteNote(note.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        note.title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      subtitle: note.body.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                note.body,
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                              ),
                            )
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: 'Edit note',
                        onPressed: () => _showNoteDialog(context, note),
                      ),
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
