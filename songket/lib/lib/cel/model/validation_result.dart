// Validation Result
class CELValidationResult {
  final bool isValid;
  final String? error;
  final List<String> warnings;

  CELValidationResult({
    required this.isValid,
    this.error,
    List<String>? warnings,
  }) : warnings = warnings ?? [];

  static CELValidationResult success([List<String>? warnings]) =>
      CELValidationResult(isValid: true, warnings: warnings);

  static CELValidationResult failure(String error, [List<String>? warnings]) =>
      CELValidationResult(isValid: false, error: error, warnings: warnings);
}
