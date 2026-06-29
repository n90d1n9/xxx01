class MCPTestResult {
  final String testCaseId;
  final bool passed;
  final DateTime executedAt;
  final int executionTime;
  final Map<String, dynamic>? actualOutput;
  final String? errorMessage;

  MCPTestResult({
    required this.testCaseId,
    required this.passed,
    required this.executedAt,
    required this.executionTime,
    this.actualOutput,
    this.errorMessage,
  });
}
