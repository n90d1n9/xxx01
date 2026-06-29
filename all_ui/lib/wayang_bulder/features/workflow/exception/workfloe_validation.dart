class WorkflowValidationException implements Exception {
  final List<String> errors;
  WorkflowValidationException(this.errors);

  @override
  String toString() => 'Workflow validation failed: ${errors.join(", ")}';
}

class NodeExecutionException implements Exception {
  final String nodeId;
  final String message;
  NodeExecutionException(this.nodeId, this.message);

  @override
  String toString() => 'Node execution failed ($nodeId): $message';
}
