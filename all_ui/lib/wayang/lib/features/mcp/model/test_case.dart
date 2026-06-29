import 'test_result.dart';

class MCPTestCase {
  final String id;
  final String name;
  final String description;
  final String toolId;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> expectedOutput;
  final bool isAutomated;
  final DateTime createdAt;
  final MCPTestResult? lastResult;

  MCPTestCase({
    required this.id,
    required this.name,
    required this.description,
    required this.toolId,
    required this.inputData,
    required this.expectedOutput,
    required this.createdAt,
    this.isAutomated = true,
    this.lastResult,
  });
}
