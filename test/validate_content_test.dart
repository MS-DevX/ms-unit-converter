import 'package:flutter_test/flutter_test.dart';
import '../tools/validate_content.dart';

void main() {
  test('Content dataset validation pass without errors', () {
    final errors = validateContent(verbose: false);
    expect(errors, isEmpty, reason: 'Content validation failed with errors: $errors');
  });
}
