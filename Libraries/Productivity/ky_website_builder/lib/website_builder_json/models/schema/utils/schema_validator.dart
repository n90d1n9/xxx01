/// Helper for JSON validation
class SchemaValidator {
  static bool validate(Map<String, dynamic> json) {
    // Basic validation - check required fields
    if (!json.containsKey('id') || !json.containsKey('version')) {
      return false;
    }
    if (!json.containsKey('metadata') || !json.containsKey('pages')) {
      return false;
    }
    return true;
  }

  static List<String> getValidationErrors(Map<String, dynamic> json) {
    final errors = <String>[];

    if (!json.containsKey('id')) errors.add('Missing required field: id');
    if (!json.containsKey('version'))
      errors.add('Missing required field: version');
    if (!json.containsKey('metadata'))
      errors.add('Missing required field: metadata');
    if (!json.containsKey('pages')) errors.add('Missing required field: pages');

    return errors;
  }
}
