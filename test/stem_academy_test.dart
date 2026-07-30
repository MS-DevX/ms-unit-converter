import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/models/formula_model.dart';
import 'package:unit_converter/providers/academy_user_provider.dart';
import 'package:unit_converter/repositories/formula_repository.dart';
import 'package:unit_converter/repositories/search_repository.dart';
import 'package:unit_converter/repositories/subject_repository.dart';
import 'package:unit_converter/screens/academy/formula_lesson_screen.dart';
import 'package:unit_converter/screens/academy/stem_academy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    try {
      await DatabaseService.instance.deleteDatabase();
    } catch (_) {}
    await DatabaseService.instance.initialize();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    SubjectRepository.instance.clearCache();
    FormulaRepository.instance.clearCache();
    SearchRepository.instance.resetBackend();
  });

  group('STEM Academy Data Models & Parsing', () {
    test('LessonDifficulty parses values correctly', () {
      expect(LessonDifficulty.parse(1), equals(LessonDifficulty.beginner));
      expect(LessonDifficulty.parse(2), equals(LessonDifficulty.intermediate));
      expect(LessonDifficulty.parse(3), equals(LessonDifficulty.advanced));
      expect(LessonDifficulty.parse('intermediate'), equals(LessonDifficulty.intermediate));
    });

    test('FormulaModel parses from row properly', () {
      final row = {
        'id': 101,
        'subject_id': 1,
        'category_id': 'algebra',
        'chapter': 'Quadratic Equations',
        'title': 'Quadratic Formula',
        'expression': 'x = (-b ± √(b² - 4ac)) / (2a)',
        'description': 'Calculates the roots of ax² + bx + c = 0.',
        'difficulty': '2',
        'units': '3',
        'variables': '[{"symbol":"a","name":"Quadratic Coeff","description":"a != 0"}]',
        'example': '{"problem":"2x² - 4x - 6 = 0","steps":["Step 1"],"solution":"x = 3"}',
      };

      final model = FormulaModel.fromRow(row);
      expect(model.id, equals(101));
      expect(model.name, equals('Quadratic Formula'));
      expect(model.formula, contains('b² - 4ac'));
      expect(model.difficulty, equals(LessonDifficulty.intermediate));
      expect(model.estimatedReadMinutes, equals(3));
      expect(model.variables.length, equals(1));
      expect(model.variables.first.symbol, equals('a'));
      expect(model.workedExample?.solution, equals('x = 3'));
    });
  });

  group('STEM Academy Repositories Tests', () {
    test('SubjectRepository loads subject list', () async {
      await DatabaseService.instance.initialize();
      final subjects = await SubjectRepository.instance.loadSubjects();
      expect(subjects, isNotEmpty);
      expect(subjects.any((s) => s.name == 'Mathematics'), isTrue);
    });

    test('FormulaRepository loads categories and formulas', () async {
      await DatabaseService.instance.initialize();
      final categories = await FormulaRepository.instance.loadCategories(subjectId: 1);
      expect(categories, isNotEmpty);
      expect(categories.any((c) => c.id == 'algebra'), isTrue);

      final formulas = await FormulaRepository.instance.loadFormulasForCategory('algebra');
      expect(formulas, isNotEmpty);
      expect(formulas.any((f) => f.name.contains('Quadratic')), isTrue);
    });

    test('SearchRepository searchFormulas returns math formulas', () async {
      await DatabaseService.instance.initialize();
      final results = await SearchRepository.instance.searchFormulas('quadratic');
      expect(results, isNotEmpty);
      expect(results.first.name, contains('Quadratic'));
    });
  });

  group('AcademyUserProvider State Tests', () {
    test('toggles bookmarks and records viewed history', () async {
      final provider = AcademyUserProvider();
      await provider.load();

      expect(provider.isBookmarked(101), isFalse);

      await provider.toggleBookmark(101);
      expect(provider.isBookmarked(101), isTrue);

      await provider.recordViewed(101);
      expect(provider.recentlyViewedIds, contains(101));
    });
  });

  group('STEM Academy Widget Tests', () {
    testWidgets('StemAcademyScreen mounts cleanly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AcademyUserProvider()..load()),
          ],
          child: const MaterialApp(
            home: StemAcademyScreen(),
          ),
        ),
      );

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      expect(find.text('STEM Academy'), findsWidgets);
      expect(find.text('Bookmarks'), findsOneWidget);
      expect(find.text('Recently Viewed'), findsOneWidget);
      expect(find.text('📐 Mathematics Categories'), findsOneWidget);
    });

    testWidgets('FormulaLessonScreen renders formula, variables, example, and toggles Study Mode', (WidgetTester tester) async {
      const lesson = FormulaModel(
        id: 101,
        subjectId: 1,
        categoryId: 'algebra',
        topic: 'Quadratic Equations',
        name: 'Quadratic Formula',
        formula: 'x = (-b ± √(b² - 4ac)) / (2a)',
        description: 'Calculates the roots of second-degree equation.',
        variables: [
          VariableModel(symbol: 'a', name: 'Coeff A', description: 'x² multiplier'),
        ],
        workedExample: WorkedExampleModel(
          problem: 'Solve x² - 4 = 0',
          steps: ['x² = 4', 'x = ±2'],
          solution: 'x = ±2',
        ),
        difficulty: LessonDifficulty.intermediate,
        estimatedReadMinutes: 3,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AcademyUserProvider()..load()),
          ],
          child: const MaterialApp(
            home: FormulaLessonScreen(formula: lesson),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Quadratic Formula'), findsWidgets);
      expect(find.text('⏱️ 3 min read'), findsOneWidget);
      expect(find.text('Solve x² - 4 = 0'), findsOneWidget);
      expect(find.text('Calculator'), findsOneWidget);

      // Toggle Study Mode
      await tester.tap(find.byTooltip('Study Mode (Revision)'));
      await tester.pumpAndSettle();

      expect(find.text('📖 Study Mode'), findsOneWidget);
      expect(find.text('Calculator'), findsNothing);
    });
  });
}
