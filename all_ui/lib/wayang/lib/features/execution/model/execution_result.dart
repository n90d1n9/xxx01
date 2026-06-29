import 'execution_event.dart';
import 'node_execution_result.dart';

class ExecutionResult {
  final String executionId;
  final String workflowId;
  final ExecutionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Map<String, dynamic> input;
  final Map<String, dynamic> output;
  final List<NodeExecutionResult> nodeResults;
  final String? error;
  ExecutionResult({
    required this.executionId,
    required this.workflowId,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.input,
    required this.output,
    required this.nodeResults,
    this.error,
  });
  Duration? get duration =>
      endTime != null ? endTime!.difference(startTime) : null;
}
