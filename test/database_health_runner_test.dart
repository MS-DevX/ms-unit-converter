import 'package:flutter_test/flutter_test.dart';

import '../tools/database_health.dart' as database_health;

void main() {
  test('Runs tools/database_health.dart CLI health diagnostic tool', () async {
    database_health.main();
  });
}
