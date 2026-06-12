import '../models/project_custom_attribute.dart';
import 'project_domain_extension_next_action_service.dart';
import 'project_domain_extension_readiness_service.dart';

class ProjectDomainExtensionActionQueue {
  const ProjectDomainExtensionActionQueue({
    required this.businessDomain,
    required this.visibleItems,
    required this.totalItemCount,
  });

  final String businessDomain;
  final List<ProjectDomainExtensionActionItem> visibleItems;
  final int totalItemCount;

  bool get hasActions => totalItemCount > 0;
  bool get hasHiddenItems => hiddenItemCount > 0;
  int get hiddenItemCount => totalItemCount - visibleItems.length;
}

class ProjectDomainExtensionActionItem {
  const ProjectDomainExtensionActionItem({
    required this.kind,
    required this.fieldKey,
    required this.fieldLabel,
    required this.fieldType,
    required this.importance,
    required this.tooltip,
  });

  final ProjectDomainExtensionNextActionKind kind;
  final String fieldKey;
  final String fieldLabel;
  final ProjectCustomAttributeType fieldType;
  final ProjectCustomAttributeImportance importance;
  final String tooltip;

  String get actionLabel {
    switch (kind) {
      case ProjectDomainExtensionNextActionKind.requiredField:
        return 'Required: $fieldLabel';
      case ProjectDomainExtensionNextActionKind.watchedField:
        return 'Risk: $fieldLabel';
      case ProjectDomainExtensionNextActionKind.recommendedField:
        return 'Recommended: $fieldLabel';
      case ProjectDomainExtensionNextActionKind.complete:
        return fieldLabel;
    }
  }
}

class ProjectDomainExtensionActionQueueService {
  const ProjectDomainExtensionActionQueueService();

  ProjectDomainExtensionActionQueue build({
    required ProjectDomainExtensionReadinessSummary summary,
    int maxVisibleItems = 4,
  }) {
    if (maxVisibleItems <= 0) {
      return ProjectDomainExtensionActionQueue(
        businessDomain: summary.businessDomain,
        visibleItems: const [],
        totalItemCount: 0,
      );
    }

    final items = <ProjectDomainExtensionActionItem>[];
    final queuedKeys = <String>{};

    void addMissingFields(
      Iterable<ProjectDomainExtensionFieldSignal> fields,
      ProjectDomainExtensionNextActionKind kind,
    ) {
      for (final field in fields) {
        if (!queuedKeys.add(field.key)) continue;
        items.add(_itemFor(summary: summary, field: field, kind: kind));
      }
    }

    addMissingFields(
      summary.missingRequiredFields,
      ProjectDomainExtensionNextActionKind.requiredField,
    );
    addMissingFields(
      summary.missingWatchedFields,
      ProjectDomainExtensionNextActionKind.watchedField,
    );
    addMissingFields(
      summary.missingRecommendedFields,
      ProjectDomainExtensionNextActionKind.recommendedField,
    );

    return ProjectDomainExtensionActionQueue(
      businessDomain: summary.businessDomain,
      visibleItems: List.unmodifiable(items.take(maxVisibleItems)),
      totalItemCount: items.length,
    );
  }

  ProjectDomainExtensionActionItem _itemFor({
    required ProjectDomainExtensionReadinessSummary summary,
    required ProjectDomainExtensionFieldSignal field,
    required ProjectDomainExtensionNextActionKind kind,
  }) {
    return ProjectDomainExtensionActionItem(
      kind: kind,
      fieldKey: field.key,
      fieldLabel: field.label,
      fieldType: field.type,
      importance: field.importance,
      tooltip: '${field.label} improves ${summary.businessDomain} readiness.',
    );
  }
}
