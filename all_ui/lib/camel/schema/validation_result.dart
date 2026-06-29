import 'validation_issue.dart';

class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;

  const ValidationResult({required this.isValid, required this.issues});

  List<ValidationIssue> get errors =>
      issues.where((i) => i.severity == IssueSeverity.error).toList();

  List<ValidationIssue> get warnings =>
      issues.where((i) => i.severity == IssueSeverity.warning).toList();

  List<ValidationIssue> get infos =>
      issues.where((i) => i.severity == IssueSeverity.info).toList();
}
