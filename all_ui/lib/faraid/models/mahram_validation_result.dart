import 'mahram_relationship.dart';

class MahramValidationResult {
  final List<MahramRelationship> mahramRelationships;
  final List<String> forbiddenMarriages;
  final List<String> validationErrors;
  final List<String> recommendations;
  final List<String> executionLog;
  final bool hasCriticalErrors;

  MahramValidationResult({
    required this.mahramRelationships,
    required this.forbiddenMarriages,
    required this.validationErrors,
    required this.recommendations,
    required this.executionLog,
    required this.hasCriticalErrors,
  });
}
