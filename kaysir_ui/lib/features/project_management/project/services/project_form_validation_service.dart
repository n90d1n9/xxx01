import '../models/project_form_draft.dart';
import '../models/project_custom_attribute.dart';
import 'project_custom_attribute_value_validation_service.dart';

/// Validation issue emitted for a single project form field or section.
class ProjectFormIssue {
  const ProjectFormIssue({required this.field, required this.message});

  final String field;
  final String message;
}

/// Validates required, scheduling, summary, and custom project form fields.
class ProjectFormValidationService {
  const ProjectFormValidationService({
    this.attributeValueValidationService =
        const ProjectCustomAttributeValueValidationService(),
  });

  final ProjectCustomAttributeValueValidationService
  attributeValueValidationService;

  List<ProjectFormIssue> validate(ProjectFormDraft draft) {
    final issues = <ProjectFormIssue>[];

    void requireText(String field, String value, String label) {
      if (value.trim().isEmpty) {
        issues.add(
          ProjectFormIssue(field: field, message: '$label is required.'),
        );
      }
    }

    requireText('name', draft.name, 'Project name');
    requireText('client', draft.client, 'Client or business unit');
    requireText('owner', draft.owner, 'Owner');
    requireText('sponsor', draft.sponsor, 'Sponsor');
    requireText('summary', draft.summary, 'Summary');

    if (draft.endDate.isBefore(draft.startDate)) {
      issues.add(
        const ProjectFormIssue(
          field: 'endDate',
          message: 'End date must be after the start date.',
        ),
      );
    }

    if (draft.summary.trim().isNotEmpty && draft.summary.trim().length < 24) {
      issues.add(
        const ProjectFormIssue(
          field: 'summary',
          message: 'Summary should explain the business outcome.',
        ),
      );
    }

    issues.addAll(_validateCustomAttributes(draft));

    return issues;
  }

  bool canSubmit(ProjectFormDraft draft) => validate(draft).isEmpty;

  List<ProjectFormIssue> _validateCustomAttributes(ProjectFormDraft draft) {
    final issues = <ProjectFormIssue>[];
    final activeAttributes =
        draft.customAttributes
            .where(
              (attribute) =>
                  attribute.label.trim().isNotEmpty ||
                  attribute.value.trim().isNotEmpty,
            )
            .toList();
    if (activeAttributes.length > projectCustomAttributeLimit) {
      issues.add(
        const ProjectFormIssue(
          field: 'customAttributes',
          message: 'Use 12 or fewer custom attributes.',
        ),
      );
    }

    final labels = <String>{};
    for (final attribute in activeAttributes) {
      final label = attribute.label.trim();
      if (label.isEmpty) {
        issues.add(
          const ProjectFormIssue(
            field: 'customAttributes',
            message: 'Custom attribute label is required.',
          ),
        );
        continue;
      }

      final normalizedLabel = label.toLowerCase();
      if (!labels.add(normalizedLabel)) {
        issues.add(
          ProjectFormIssue(
            field: 'customAttributes',
            message: 'Custom attribute "$label" is duplicated.',
          ),
        );
      }
    }

    for (final issue in attributeValueValidationService.validate(
      activeAttributes,
    )) {
      issues.add(
        ProjectFormIssue(
          field: 'customAttributes.${issue.key}',
          message: issue.message,
        ),
      );
    }

    return issues;
  }
}
