/// Provider for user conversion notes.
library;

import 'package:flutter/foundation.dart';
import '../models/conversion_note.dart';
import '../services/notes_service.dart';

/// Exposes [notes] list and CRUD operations to the widget tree.
class NotesProvider extends ChangeNotifier {
  List<ConversionNote> _notes = [];

  /// All notes, newest first.
  List<ConversionNote> get notes => List.unmodifiable(_notes);

  /// Loads notes from storage. Call once at startup.
  Future<void> loadNotes() async {
    try {
      _notes = await NotesService.getNotes();
    } catch (_) {
      _notes = [];
    }
    notifyListeners();
  }

  /// Creates a new note and persists it.
  Future<void> addNote({required String title, String body = ''}) async {
    final note = ConversionNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      body: body.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, note);
    notifyListeners();
    try {
      await NotesService.saveNote(note);
    } catch (_) {}
  }

  /// Updates an existing note by [id].
  Future<void> updateNote(
      String id, {required String title, String body = ''}) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx < 0) return;
    final updated = _notes[idx].copyWith(title: title, body: body);
    _notes[idx] = updated;
    notifyListeners();
    try {
      await NotesService.saveNote(updated);
    } catch (_) {}
  }

  /// Deletes the note with [id].
  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
    try {
      await NotesService.deleteNote(id);
    } catch (_) {}
  }

  /// Clears all notes.
  Future<void> clearAll() async {
    _notes.clear();
    notifyListeners();
    try {
      await NotesService.clearAll();
    } catch (_) {}
  }
}
