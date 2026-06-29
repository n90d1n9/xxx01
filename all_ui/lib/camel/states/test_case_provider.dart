// Testing Framework
import 'package:flutter_riverpod/legacy.dart';

class TestCase {
  final String id;
  final String name;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic> expectedOutput;
  final List<String> nodeIdsToTest;
  final bool passed;
  final String? errorMessage;

  TestCase({
    required this.id,
    required this.name,
    required this.inputData,
    required this.expectedOutput,
    required this.nodeIdsToTest,
    this.passed = false,
    this.errorMessage,
  });

  TestCase copyWith({
    String? id,
    String? name,
    Map<String, dynamic>? inputData,
    Map<String, dynamic>? expectedOutput,
    List<String>? nodeIdsToTest,
    bool? passed,
    String? errorMessage,
  }) {
    return TestCase(
      id: id ?? this.id,
      name: name ?? this.name,
      inputData: inputData ?? this.inputData,
      expectedOutput: expectedOutput ?? this.expectedOutput,
      nodeIdsToTest: nodeIdsToTest ?? this.nodeIdsToTest,
      passed: passed ?? this.passed,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final testCasesProvider = StateProvider<List<TestCase>>((ref) => []);
