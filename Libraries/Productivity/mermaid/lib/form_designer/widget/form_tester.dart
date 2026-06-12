import '../model/field_config.dart';
import '../model/test_caset.dart';

class FormTester {
  static List<TestCase> generateTestCases(List<FieldConfig> fields) {
    final testCases = <TestCase>[];

    // Required field tests
    for (final field in fields.where((f) => f.required)) {
      testCases.add(
        TestCase(
          name: '${field.label ?? field.name} - Required validation',
          fieldId: field.id,
          input: '',
          expectedResult: TestResult.failure,
          expectedMessage: 'Field is required',
        ),
      );
    }

    // Email validation tests
    for (final field in fields.where((f) => f.type == 'email')) {
      testCases.add(
        TestCase(
          name: '${field.label ?? field.name} - Valid email',
          fieldId: field.id,
          input: 'test@example.com',
          expectedResult: TestResult.success,
        ),
      );

      testCases.add(
        TestCase(
          name: '${field.label ?? field.name} - Invalid email',
          fieldId: field.id,
          input: 'invalid-email',
          expectedResult: TestResult.failure,
        ),
      );
    }

    return testCases;
  }
}
