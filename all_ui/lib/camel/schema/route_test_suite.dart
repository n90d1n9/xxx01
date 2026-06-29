class RouteTestSuite {
  final String routeId;
  final String routeName;
  final List<RouteTest> tests;

  const RouteTestSuite({
    required this.routeId,
    required this.routeName,
    required this.tests,
  });
}

class RouteTest {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic>? expectedOutput;
  final List<Assertion> assertions;

  const RouteTest({
    required this.id,
    required this.name,
    required this.description,
    required this.inputData,
    this.expectedOutput,
    required this.assertions,
  });
}

class Assertion {
  final AssertionType type;
  final String field;
  final dynamic expectedValue;
  final String? message;

  const Assertion({
    required this.type,
    required this.field,
    this.expectedValue,
    this.message,
  });
}

enum AssertionType {
  equals,
  notEquals,
  contains,
  notContains,
  greaterThan,
  lessThan,
  isNull,
  isNotNull,
}

class RouteExecutionResult {
  final bool success;
  final Duration executionTime;
  final List<ExecutionStep> steps;
  final Map<String, dynamic>? outputData;
  final String? error;

  const RouteExecutionResult({
    required this.success,
    required this.executionTime,
    required this.steps,
    this.outputData,
    this.error,
  });
}

class ExecutionStep {
  final String nodeId;
  final String nodeName;
  final String nodeType;
  final bool success;
  final Duration executionTime;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic>? outputData;
  final String message;
  final String? error;

  const ExecutionStep({
    required this.nodeId,
    required this.nodeName,
    required this.nodeType,
    required this.success,
    required this.executionTime,
    required this.inputData,
    this.outputData,
    required this.message,
    this.error,
  });
}
