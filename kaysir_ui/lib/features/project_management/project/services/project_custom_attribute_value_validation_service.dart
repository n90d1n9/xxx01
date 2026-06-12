import '../models/project_custom_attribute.dart';
import '../models/project_custom_attribute_value.dart';

class ProjectCustomAttributeValueValidationIssue {
  const ProjectCustomAttributeValueValidationIssue({
    required this.key,
    required this.label,
    required this.message,
  });

  final String key;
  final String label;
  final String message;
}

class ProjectCustomAttributeValueValidationService {
  const ProjectCustomAttributeValueValidationService();

  List<ProjectCustomAttributeValueValidationIssue> validate(
    Iterable<ProjectCustomAttribute> attributes,
  ) {
    final issues = <ProjectCustomAttributeValueValidationIssue>[];

    for (final attribute in attributes) {
      final value = attribute.value.trim();
      if (value.isEmpty) continue;

      final label =
          attribute.label.trim().isEmpty
              ? 'Custom attribute'
              : attribute.label.trim();

      switch (attribute.type) {
        case ProjectCustomAttributeType.number:
          if (parseProjectCustomAttributeNumber(value) == null) {
            issues.add(
              _issue(
                attribute,
                label,
                'Custom attribute "$label" must be a valid number.',
              ),
            );
          }
          break;
        case ProjectCustomAttributeType.date:
          if (parseProjectCustomAttributeIsoDate(value) == null) {
            issues.add(
              _issue(
                attribute,
                label,
                'Custom attribute "$label" must use YYYY-MM-DD.',
              ),
            );
          }
          break;
        case ProjectCustomAttributeType.url:
          if (parseProjectCustomAttributeWebUrl(value) == null) {
            issues.add(
              _issue(
                attribute,
                label,
                'Custom attribute "$label" must use an http:// or https:// URL.',
              ),
            );
          }
          break;
        case ProjectCustomAttributeType.boolean:
          if (parseProjectCustomAttributeBool(value) == null) {
            issues.add(
              _issue(
                attribute,
                label,
                'Custom attribute "$label" must be Yes or No.',
              ),
            );
          }
          break;
        case ProjectCustomAttributeType.text:
        case ProjectCustomAttributeType.choice:
          break;
      }
    }

    return List.unmodifiable(issues);
  }

  ProjectCustomAttributeValueValidationIssue _issue(
    ProjectCustomAttribute attribute,
    String label,
    String message,
  ) {
    return ProjectCustomAttributeValueValidationIssue(
      key: attribute.key,
      label: label,
      message: message,
    );
  }
}
