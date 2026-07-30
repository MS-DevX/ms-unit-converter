/// Generalized section-driven lesson and formula models for STEM Academy.
library;

import 'dart:convert';

/// Formula calculation and content classification type.
enum FormulaType {
  expression,
  solver,
  reference;

  static FormulaType parse(String? value) {
    switch (value?.toLowerCase()) {
      case 'expression':
        return FormulaType.expression;
      case 'solver':
        return FormulaType.solver;
      default:
        return FormulaType.reference;
    }
  }
}

/// Lesson Difficulty rating.
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

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'name': name,
        'description': description,
      };
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

  Map<String, dynamic> toJson() => {
        'problem': problem,
        'steps': steps,
        'solution': solution,
      };
}

/// Validation rules for input parameters.
class ValidationRuleModel {
  final double? min;
  final double? max;
  final bool allowZero;
  final bool allowNegative;
  final bool integerOnly;
  final String? errorMessage;

  const ValidationRuleModel({
    this.min,
    this.max,
    this.allowZero = true,
    this.allowNegative = true,
    this.integerOnly = false,
    this.errorMessage,
  });

  factory ValidationRuleModel.fromJson(Map<String, dynamic> json) {
    return ValidationRuleModel(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      allowZero: json['allow_zero'] as bool? ?? true,
      allowNegative: json['allow_negative'] as bool? ?? true,
      integerOnly: json['integer_only'] as bool? ?? false,
      errorMessage: json['error_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (min != null) 'min': min,
        if (max != null) 'max': max,
        'allow_zero': allowZero,
        'allow_negative': allowNegative,
        'integer_only': integerOnly,
        if (errorMessage != null) 'error_message': errorMessage,
      };
}

/// Input parameter definition for interactive calculators.
class CalculatorInputModel {
  final String symbol;
  final String label;
  final double defaultValue;
  final double? exampleValue;
  final String? unit;
  final ValidationRuleModel validation;

  const CalculatorInputModel({
    required this.symbol,
    required this.label,
    required this.defaultValue,
    this.exampleValue,
    this.unit,
    this.validation = const ValidationRuleModel(),
  });

  factory CalculatorInputModel.fromJson(Map<String, dynamic> json) {
    return CalculatorInputModel(
      symbol: json['symbol'] as String? ?? 'x',
      label: json['label'] as String? ?? 'Input',
      defaultValue: (json['default_value'] as num?)?.toDouble() ?? 0.0,
      exampleValue: (json['example_value'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      validation: json['validation'] != null
          ? ValidationRuleModel.fromJson(json['validation'] as Map<String, dynamic>)
          : const ValidationRuleModel(),
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'label': label,
        'default_value': defaultValue,
        if (exampleValue != null) 'example_value': exampleValue,
        if (unit != null) 'unit': unit,
        'validation': validation.toJson(),
      };
}

/// Output metric definition for interactive calculators.
class CalculatorOutputModel {
  final String symbol;
  final String label;
  final String? unit;
  final String? expression;

  const CalculatorOutputModel({
    required this.symbol,
    required this.label,
    this.unit,
    this.expression,
  });

  factory CalculatorOutputModel.fromJson(Map<String, dynamic> json) {
    return CalculatorOutputModel(
      symbol: json['symbol'] as String? ?? 'y',
      label: json['label'] as String? ?? 'Result',
      unit: json['unit'] as String?,
      expression: json['expression'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'label': label,
        if (unit != null) 'unit': unit,
        if (expression != null) 'expression': expression,
      };
}

/// Calculator definition metadata.
class CalculatorDefinitionModel {
  final String version;
  final String engineType;
  final String? expression;
  final String? solverId;
  final List<CalculatorInputModel> inputs;
  final List<CalculatorOutputModel> outputs;

  const CalculatorDefinitionModel({
    this.version = '1.0',
    required this.engineType,
    this.expression,
    this.solverId,
    required this.inputs,
    required this.outputs,
  });

  factory CalculatorDefinitionModel.fromJson(Map<String, dynamic> json) {
    final inputsList = (json['inputs'] as List<dynamic>?)
            ?.map((e) => CalculatorInputModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    final outputsList = (json['outputs'] as List<dynamic>?)
            ?.map((e) => CalculatorOutputModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
    return CalculatorDefinitionModel(
      version: json['version'] as String? ?? '1.0',
      engineType: json['engine_type'] as String? ?? 'expression',
      expression: json['expression'] as String?,
      solverId: json['solver_id'] as String?,
      inputs: inputsList,
      outputs: outputsList,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': version,
        'engine_type': engineType,
        if (expression != null) 'expression': expression,
        if (solverId != null) 'solver_id': solverId,
        'inputs': inputs.map((e) => e.toJson()).toList(),
        'outputs': outputs.map((e) => e.toJson()).toList(),
      };
}

/// Lesson Section Model for section-driven lesson architecture.
class LessonSectionModel {
  final String type;
  final String title;
  final String content;
  final Map<String, dynamic>? payload;

  const LessonSectionModel({
    required this.type,
    required this.title,
    required this.content,
    this.payload,
  });

  factory LessonSectionModel.fromJson(Map<String, dynamic> json) {
    return LessonSectionModel(
      type: json['type'] as String? ?? 'overview',
      title: json['title'] as String? ?? 'Section',
      content: json['content'] as String? ?? '',
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'content': content,
        if (payload != null) 'payload': payload,
      };
}

/// Generalized linkage for related STEM content.
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
  final FormulaType formulaType;
  final List<VariableModel> variables;
  final WorkedExampleModel? workedExample;
  final LessonDifficulty difficulty;
  final int estimatedReadMinutes;
  final List<RelatedContentModel> relatedContent;
  final CalculatorDefinitionModel? calculator;
  final List<LessonSectionModel> sections;

  const FormulaModel({
    required this.id,
    required this.subjectId,
    required this.categoryId,
    required this.topic,
    required this.name,
    required this.formula,
    required this.description,
    this.formulaType = FormulaType.reference,
    this.variables = const [],
    this.workedExample,
    required this.difficulty,
    required this.estimatedReadMinutes,
    this.relatedContent = const [],
    this.calculator,
    this.sections = const [],
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

    CalculatorDefinitionModel? calc;
    if (row['calculator_json'] != null && (row['calculator_json'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(row['calculator_json'] as String) as Map<String, dynamic>;
        calc = CalculatorDefinitionModel.fromJson(decoded);
      } catch (_) {}
    }

    List<LessonSectionModel> secs = [];
    if (row['sections_json'] != null && (row['sections_json'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(row['sections_json'] as String) as List<dynamic>;
        secs = decoded.map((e) => LessonSectionModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }

    final readMins = int.tryParse(row['units']?.toString() ?? '3') ?? 3;
    final fType = calc != null
        ? (calc.engineType == 'solver' ? FormulaType.solver : FormulaType.expression)
        : FormulaType.reference;

    return FormulaModel(
      id: row['id'] as int,
      subjectId: row['subject_id'] as int? ?? 1,
      categoryId: row['category_id'] as String? ?? 'algebra',
      topic: row['chapter'] as String? ?? 'General',
      name: row['title'] as String? ?? 'Formula Lesson',
      formula: row['expression'] as String? ?? '',
      description: row['description'] as String? ?? '',
      formulaType: fType,
      variables: vars,
      workedExample: ex,
      difficulty: LessonDifficulty.parse(row['difficulty']),
      estimatedReadMinutes: readMins,
      relatedContent: related,
      calculator: calc,
      sections: secs,
    );
  }
}
