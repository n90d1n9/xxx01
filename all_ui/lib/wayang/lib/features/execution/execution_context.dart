class ExecutionContext {
  final String workflowId;
  final String executionId;
  final Map<String, dynamic> variables;
  final Map<String, Map<String, dynamic>> nodeOutputs;
  final Map<String, dynamic> metadata;

  ExecutionContext({
    required this.workflowId,
    required this.executionId,
    required this.variables,
    required this.nodeOutputs,
    this.metadata = const {},
  });

  void setVariable(String key, dynamic value) {
    variables[key] = value;
  }

  dynamic getVariable(String key) {
    return variables[key];
  }

  void setNodeOutput(String nodeId, Map<String, dynamic> output) {
    nodeOutputs[nodeId] = output;
  }

  Map<String, dynamic>? getNodeOutput(String nodeId) {
    return nodeOutputs[nodeId];
  }
}
