import '../models/project_custom_attribute.dart';
import 'project_domain_extension_readiness_service.dart';

enum ProjectDomainExtensionNextActionKind {
  requiredField,
  watchedField,
  recommendedField,
  complete,
}

class ProjectDomainExtensionNextAction {
  const ProjectDomainExtensionNextAction({
    required this.kind,
    required this.fieldKey,
    required this.fieldLabel,
    required this.title,
    required this.detail,
    required this.actionLabel,
    this.fieldType,
    this.importance,
  });

  final ProjectDomainExtensionNextActionKind kind;
  final String fieldKey;
  final String fieldLabel;
  final String title;
  final String detail;
  final String actionLabel;
  final ProjectCustomAttributeType? fieldType;
  final ProjectCustomAttributeImportance? importance;

  bool get hasField => fieldKey.isNotEmpty;
  bool get isComplete => kind == ProjectDomainExtensionNextActionKind.complete;
}

class ProjectDomainExtensionNextActionService {
  const ProjectDomainExtensionNextActionService();

  ProjectDomainExtensionNextAction build(
    ProjectDomainExtensionReadinessSummary summary,
  ) {
    final requiredField = _firstOrNull(summary.missingRequiredFields);
    if (requiredField != null) {
      return _fromField(
        kind: ProjectDomainExtensionNextActionKind.requiredField,
        field: requiredField,
        title: 'Next: ${requiredField.label}',
        detail:
            '${requiredField.label} is required for ${summary.businessDomain} readiness before execution.',
      );
    }

    final watchedField = _firstOrNull(summary.missingWatchedFields);
    if (watchedField != null) {
      return _fromField(
        kind: ProjectDomainExtensionNextActionKind.watchedField,
        field: watchedField,
        title: 'Stabilize: ${watchedField.label}',
        detail:
            '${watchedField.label} is watched by ${summary.businessDomain} risk rules and should be completed next.',
      );
    }

    final recommendedField = _firstOrNull(summary.missingRecommendedFields);
    if (recommendedField != null) {
      return _fromField(
        kind: ProjectDomainExtensionNextActionKind.recommendedField,
        field: recommendedField,
        title: 'Next: ${recommendedField.label}',
        detail:
            '${recommendedField.label} improves ${summary.businessDomain} handoff quality and reporting context.',
      );
    }

    return ProjectDomainExtensionNextAction(
      kind: ProjectDomainExtensionNextActionKind.complete,
      fieldKey: '',
      fieldLabel: '',
      title: '${summary.businessDomain} context ready',
      detail:
          'All required and recommended domain fields are complete for handoff and portfolio reporting.',
      actionLabel: 'Ready',
    );
  }

  ProjectDomainExtensionNextAction _fromField({
    required ProjectDomainExtensionNextActionKind kind,
    required ProjectDomainExtensionFieldSignal field,
    required String title,
    required String detail,
  }) {
    return ProjectDomainExtensionNextAction(
      kind: kind,
      fieldKey: field.key,
      fieldLabel: field.label,
      title: title,
      detail: '$detail Capture a ${field.type.label.toLowerCase()} value.',
      actionLabel: 'Focus Field',
      fieldType: field.type,
      importance: field.importance,
    );
  }
}

T? _firstOrNull<T>(List<T> items) => items.isEmpty ? null : items.first;
