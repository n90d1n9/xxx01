enum TestResult { success, failure, warning }

class TestCase {
  final String name;
  final String fieldId;
  final dynamic input;
  final TestResult expectedResult;
  final String? expectedMessage;

  const TestCase({
    required this.name,
    required this.fieldId,
    required this.input,
    required this.expectedResult,
    this.expectedMessage,
  });
}
