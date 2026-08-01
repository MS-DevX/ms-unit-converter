import 'package:flutter_test/flutter_test.dart';
import '../tools/database_health.dart' as db_health;

void main() {
  test('Runs tools/database_health.dart CLI audit tool', () async {
    db_health.main();
  });
}
