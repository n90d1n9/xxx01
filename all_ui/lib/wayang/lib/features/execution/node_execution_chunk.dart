class NodeExecutionChunk {
  final String nodeId;
  final dynamic data;
  final bool isComplete;

  NodeExecutionChunk({
    required this.nodeId,
    required this.data,
    this.isComplete = false,
  });
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.valid() => ValidationResult(isValid: true);

  factory ValidationResult.invalid(
    List<String> errors, [
    List<String> warnings = const [],
  ]) => ValidationResult(isValid: false, errors: errors, warnings: warnings);
}
