import 'node_execution_result.dart';

class NodeExecutionContext {
  final String nodeId;
  final String workflowId;
  final String executionId;
  final Map<String, dynamic> inputs;
  final Map<String, dynamic> config;
  final Map<String, String> secrets;
  final Map<String, dynamic> variables;

  final ExecutionMode mode;

  NodeExecutionContext({
    required this.nodeId,
    required this.workflowId,
    required this.executionId,
    required this.inputs,
    required this.config,
    required this.secrets,
    required this.variables,
    this.mode = ExecutionMode.normal,
  });
}
