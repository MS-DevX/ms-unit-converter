import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/data/collections_data.dart';
import 'package:unit_converter/database/database_service.dart';
import 'package:unit_converter/repositories/collection_repository.dart';

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

  group('Phase E — Better Collections (30–40 Collections)', () {
    test('predefinedCollections list and database collections table contain 30–40 collections', () async {
      expect(predefinedCollections.length, greaterThanOrEqualTo(30));
      expect(predefinedCollections.length, lessThanOrEqualTo(40));

      final dbCollectionsCount = await CollectionRepository.instance.count();
      expect(dbCollectionsCount, equals(predefinedCollections.length));

      // Test specific new collections exist
      expect(await CollectionRepository.instance.exists('construction'), isTrue);
      expect(await CollectionRepository.instance.exists('aviation'), isTrue);
      expect(await CollectionRepository.instance.exists('electronics'), isTrue);
      expect(await CollectionRepository.instance.exists('quantum'), isTrue);
    });
  });
}
