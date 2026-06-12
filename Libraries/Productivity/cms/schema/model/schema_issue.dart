class SchemaIssue {
  final String severity;
  final String message;
  final String? fieldId;
  final String? fix;
  const SchemaIssue({
    required this.severity,
    required this.message,
    this.fieldId,
    this.fix,
  });
}
