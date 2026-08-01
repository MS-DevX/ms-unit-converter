import 'package:flutter_test/flutter_test.dart';

import '../tools/content_quality.dart' as content_quality;

void main() {
  test('Runs tools/content_quality.dart CLI quality audit tool', () async {
    content_quality.main();
  });
}
