// Validation Errors
class ValidationError {
  final String nodeId;
  final String message;
  final String severity;

  ValidationError({
    required this.nodeId,
    required this.message,
    required this.severity,
  });
}
