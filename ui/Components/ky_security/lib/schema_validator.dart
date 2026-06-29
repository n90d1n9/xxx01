class SchemaValidator {
  /// Validates survey data against a defined schema
  Future<ValidationResult> validateData({
    required List<Map<String, dynamic>> data,
    required SurveySchema schema,
    bool strict = false,
  }) async {
    final validator = DataValidator(schema, strict: strict);
    final results = await validator.validate(data);
    
    return ValidationResult(
      isValid: results.every((r) => r.isValid),
      errors: results.where((r) => !r.isValid).map((r) => r.error).toList(),
      warnings: results.where((r) => r.hasWarnings).map((r) => r.warnings).toList(),
    );
  }
}
