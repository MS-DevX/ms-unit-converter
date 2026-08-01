import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:unit_converter/database/database_service.dart';
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

  group('Phase C — Knowledge Graph Expansion (200–300 Edges)', () {
    test('related_content table contains expanded knowledge graph relationships', () async {
      final totalEdges = await RelatedContentRepository.instance.count();

      expect(totalEdges, greaterThanOrEqualTo(200),
          reason: 'Phase C requires expanding relationships to 200–300 graph edges.');
      expect(totalEdges, lessThanOrEqualTo(300),
          reason: 'Phase C requires expanding relationships to 200–300 graph edges.');

      final meterEdges = await RelatedContentRepository.instance.getRelatedContent('unit', 'Meter');
      expect(meterEdges, isNotEmpty, reason: 'Meter should have related entity graph links.');

      final lengthEdges = await RelatedContentRepository.instance.getRelatedContent('category', 'length');
      expect(lengthEdges, isNotEmpty, reason: 'Length category should have related category/unit links.');
    });
  });
}
