/// Model for a user-created conversion note.
library;

import 'package:flutter/foundation.dart';

/// A short text note the user can attach to a conversion for reference.
///
/// Examples: "Steel rod measurement", "Recipe conversion",
/// "Exam formula reminder".
@immutable
class ConversionNote {
  /// Unique identifier (UUID-style timestamp string).
  final String id;

  /// Short title chosen by the user.
  final String title;

  /// Optional free-form body text.
  final String body;

  /// When the note was originally created.
  final DateTime createdAt;

  /// When the note was last modified.
  final DateTime updatedAt;

  const ConversionNote({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns a copy with the given fields replaced. [updatedAt] is refreshed.
  ConversionNote copyWith({
    String? title,
    String? body,
  }) {
    return ConversionNote(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Serialises to JSON.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  /// Deserialises from JSON. Tolerant of missing fields.
  factory ConversionNote.fromJson(Map<String, dynamic> json) {
    return ConversionNote(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversionNote && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ConversionNote(id: $id, title: $title, updatedAt: $updatedAt)';
}
