import 'package:flutter_test/flutter_test.dart';

import '../tools/performance_audit.dart' as performance_audit;

void main() {
  test('Runs tools/performance_audit.dart CLI performance benchmark tool', () async {
    performance_audit.main();
  });
}
