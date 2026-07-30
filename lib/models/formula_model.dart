/// Generalized lesson and formula models for STEM Academy.
library;

import 'dart:convert';

/// Lesson difficulty rating.
enum LessonDifficulty {
  beginner,
  intermediate,
  advanced;

  static LessonDifficulty parse(dynamic value) {
    if (value is int) {
      if (value == 1) return LessonDifficulty.beginner;
      if (value == 2) return LessonDifficulty.intermediate;
      if (value == 3) return LessonDifficulty.advanced;
    }
    final str = value?.toString().toLowerCase() ?? '';
    if (str.contains('3') || str.contains('adv')) return LessonDifficulty.advanced;
    if (str.contains('2') || str.contains('inter')) return LessonDifficulty.intermediate;
    return LessonDifficulty.beginner;
  }

  String get label {
    switch (this) {
      case LessonDifficulty.beginner:
        return '🟢 Beginner';
      case LessonDifficulty.intermediate:
        return '🟡 Intermediate';
      case LessonDifficulty.advanced:
        return '🔴 Advanced';
    }
  }
}

/// Variable descriptor for formulas and concepts.
class VariableModel {
  final String symbol;
  final String name;
  final String description;

  const VariableModel({
    required this.symbol,
    required this.name,
    required this.description,
  });

  factory VariableModel.fromJson(Map<String, dynamic> json) {
    return VariableModel(
      symbol: json['symbol'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

/// Step-by-step worked example.
class WorkedExampleModel {
  final String problem;
  final List<String> steps;
  final String solution;

  const WorkedExampleModel({
    required this.problem,
    required this.steps,
    required this.solution,
  });

  factory WorkedExampleModel.fromJson(Map<String, dynamic> json) {
    final stepsList = (json['steps'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return WorkedExampleModel(
      problem: json['problem'] as String? ?? '',
      steps: stepsList,
      solution: json['solution'] as String? ?? '',
    );
  }
}

/// Generalized linkage for related STEM content (formulas, diagrams, calculators, constants, guides).
class RelatedContentModel {
  final String targetType;
  final String targetId;
  final String title;
  final String relationshipType;

  const RelatedContentModel({
    required this.targetType,
    required this.targetId,
    required this.title,
    required this.relationshipType,
  });

  factory RelatedContentModel.fromRow(Map<String, dynamic> row) {
    return RelatedContentModel(
      targetType: row['target_type'] as String? ?? 'formula',
      targetId: row['target_id'] as String? ?? '',
      title: row['title'] as String? ?? 'Related Topic',
      relationshipType: row['relationship_type'] as String? ?? 'related',
    );
  }
}

/// Formula Category Model.
class FormulaCategoryModel {
  final String id;
  final String name;
  final int subjectId;
  final String emoji;
  final String description;
  final int displayOrder;

  const FormulaCategoryModel({
    required this.id,
    required this.name,
    required this.subjectId,
    required this.emoji,
    required this.description,
    required this.displayOrder,
  });

  factory FormulaCategoryModel.fromRow(Map<String, dynamic> row) {
    return FormulaCategoryModel(
      id: row['id'] as String,
      name: row['name'] as String,
      subjectId: row['subject_id'] as int? ?? 1,
      emoji: row['emoji'] as String? ?? '📐',
      description: row['description'] as String? ?? '',
      displayOrder: row['display_order'] as int? ?? 0,
    );
  }
}

/// Generalized STEM Formula / Lesson Model.
class FormulaModel {
  final int id;
  final int subjectId;
  final String categoryId;
  final String topic;
  final String name;
  final String formula;
  final String description;
  final List<VariableModel> variables;
  final WorkedExampleModel? workedExample;
  final LessonDifficulty difficulty;
  final int estimatedReadMinutes;
  final List<RelatedContentModel> relatedContent;
  final String? calculatorTemplate;
  final List<String> searchKeywords;
  final List<String> tags;

  const FormulaModel({
    required this.id,
    required this.subjectId,
    required this.categoryId,
    required this.topic,
    required this.name,
    required this.formula,
    required this.description,
    this.variables = const [],
    this.workedExample,
    required this.difficulty,
    required this.estimatedReadMinutes,
    this.relatedContent = const [],
    this.calculatorTemplate,
    this.searchKeywords = const [],
    this.tags = const [],
  });

  factory FormulaModel.fromRow(
    Map<String, dynamic> row, {
    List<RelatedContentModel> related = const [],
  }) {
    List<VariableModel> vars = [];
    if (row['variables'] != null) {
      try {
        final decoded = jsonDecode(row['variables'] as String) as List<dynamic>;
        vars = decoded.map((e) => VariableModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    WorkedExampleModel? ex;
    if (row['example'] != null) {
      try {
        final decoded = jsonDecode(row['example'] as String) as Map<String, dynamic>;
        if (decoded.isNotEmpty) {
          ex = WorkedExampleModel.fromJson(decoded);
        }
      } catch (_) {}
    }

    final readMins = int.tryParse(row['units']?.toString() ?? '3') ?? 3;

    return FormulaModel(
      id: row['id'] as int,
      subjectId: row['subject_id'] as int? ?? 1,
      categoryId: row['category_id'] as String? ?? 'algebra',
      topic: row['chapter'] as String? ?? 'General',
      name: row['title'] as String? ?? 'Formula Lesson',
      formula: row['expression'] as String? ?? '',
      description: row['description'] as String? ?? '',
      variables: vars,
      workedExample: ex,
      difficulty: LessonDifficulty.parse(row['difficulty']),
      estimatedReadMinutes: readMins,
      relatedContent: related,
      calculatorTemplate: row['calculator_template'] as String?,
      searchKeywords: [],
      tags: [],
    );
  }
}
