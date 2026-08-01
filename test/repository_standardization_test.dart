import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/base_repository.dart';
import 'package:unit_converter/repositories/category_repository.dart';
import 'package:unit_converter/repositories/collection_repository.dart';
import 'package:unit_converter/repositories/currency_repository.dart';
import 'package:unit_converter/repositories/educational_facts_repository.dart';
import 'package:unit_converter/repositories/unit_information_repository.dart';
import 'package:unit_converter/repositories/unit_repository.dart';
import 'package:unit_converter/repositories/search_repository.dart';
import 'package:unit_converter/repositories/tag_repository.dart';
import 'package:unit_converter/repositories/related_content_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    await DatabaseService.instance.initialize();
  });

  tearDownAll(() async {
    await DatabaseService.instance.close();
  });

  group('Phase A.1 — Repository Standardization Tests', () {
    test('CategoryRepository implements BaseRepository contract', () async {
      final repo = CategoryRepository.instance;
      expect(repo, isA<BaseRepository<CategoryRow, String>>());

      final all = await repo.getAll();
      expect(all.length, equals(60));
      expect(await repo.count(), equals(60));

      final first = all.first;
      expect(await repo.getById(first.id), equals(first));
      expect(await repo.exists(first.id), isTrue);
      expect(await repo.exists('non_existent_category'), isFalse);

      final searchResults = await repo.search('length');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('UnitRepository implements BaseRepository contract', () async {
      final repo = UnitRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(480));
      expect(await repo.count(), equals(480));

      expect(await repo.exists('Meter'), isTrue);
      expect(await repo.exists('NonExistentUnit'), isFalse);

      final searchResults = await repo.search('meter');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('CurrencyRepository implements BaseRepository contract', () async {
      final repo = CurrencyRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(151));
      expect(await repo.count(), equals(151));

      expect(await repo.exists('USD'), isTrue);
      expect(await repo.exists('XYZ'), isFalse);

      final searchResults = await repo.search('dollar');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('CollectionRepository implements BaseRepository contract', () async {
      final repo = CollectionRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(32));
      expect(await repo.count(), equals(32));

      expect(await repo.exists('everyday'), isTrue);
      expect(await repo.exists('non_existent_collection'), isFalse);

      final searchResults = await repo.search('science');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('EducationalFactsRepository implements BaseRepository contract', () async {
      final repo = EducationalFactsRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(742));
      expect(await repo.count(), equals(742));

      expect(await repo.getById(0), isNotNull);
      expect(await repo.exists(0), isTrue);

      final searchResults = await repo.search('meter');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('UnitInformationRepository implements BaseRepository contract', () async {
      final repo = UnitInformationRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(480));
      expect(await repo.count(), equals(480));

      expect(await repo.exists('Meter'), isTrue);

      final searchResults = await repo.search('length');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('SearchRepository implements BaseRepository contract', () async {
      final repo = SearchRepository.instance;
      expect(repo, isA<BaseRepository>());

      final count = await repo.count();
      expect(count, equals(779));

      expect(await repo.exists('km'), isTrue);
      expect(await repo.exists('non_existent_alias_xyz'), isFalse);

      final searchResults = await repo.search('km');
      expect(searchResults, isNotEmpty);

      repo.clearCache();
    });

    test('TagRepository implements BaseRepository contract', () async {
      final repo = TagRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(16));
      expect(await repo.count(), equals(16));

      final first = all.first;
      expect(await repo.getById(first.id), equals(first));
      expect(await repo.exists(first.id), isTrue);

      final searchResults = await repo.search('metric');
      expect(searchResults, isNotEmpty);

      final contentTags = await repo.getTagsForContent('category', 'length');
      expect(contentTags, isNotEmpty);

      repo.clearCache();
    });

    test('RelatedContentRepository implements BaseRepository contract', () async {
      final repo = RelatedContentRepository.instance;
      expect(repo, isA<BaseRepository>());

      final all = await repo.getAll();
      expect(all.length, equals(242));
      expect(await repo.count(), equals(242));

      final first = all.first;
      expect(await repo.getById(first.id), equals(first));
      expect(await repo.exists(first.id), isTrue);

      final related = await repo.getRelatedContent('category', 'voltage');
      expect(related, isNotEmpty);

      repo.clearCache();
    });
  });
}
