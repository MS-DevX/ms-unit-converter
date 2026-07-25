/// CRUD persistence for conversion notes via SharedPreferences.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_note.dart';

/// Service layer for [ConversionNote] persistence.
class NotesService {
  NotesService._();

  static const String _key = 'conversion_notes_v1';

  /// Returns all stored notes, newest first.
  static Future<List<ConversionNote>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final notes = <ConversionNote>[];
    for (final s in raw) {
      try {
        notes.add(ConversionNote.fromJson(
            jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    // Sort newest first
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  /// Adds or replaces a note (matched by [id]).
  static Future<void> saveNote(ConversionNote note) async {
    final all = await getNotes();
    final idx = all.indexWhere((n) => n.id == note.id);
    if (idx >= 0) {
      all[idx] = note;
    } else {
      all.insert(0, note);
    }
    await _persist(all);
  }

  /// Deletes the note with [id]. No-op if not found.
  static Future<void> deleteNote(String id) async {
    final all = await getNotes();
    all.removeWhere((n) => n.id == id);
    await _persist(all);
  }

  /// Clears all notes.
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _persist(List<ConversionNote> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = notes.map((n) => jsonEncode(n.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}
