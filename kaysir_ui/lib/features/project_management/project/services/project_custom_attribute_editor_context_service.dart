import '../models/project_custom_attribute.dart';
import 'project_custom_attribute_extension_suggestion_service.dart';
import 'project_domain_attribute_metadata_service.dart';
import 'project_domain_extension_action_queue_service.dart';
import 'project_domain_extension_intake_plan_service.dart';
import 'project_domain_extension_next_action_service.dart';
import 'project_domain_extension_readiness_service.dart';

class ProjectCustomAttributeEditorContext {
  const ProjectCustomAttributeEditorContext({
    required this.attributes,
    required this.rows,
    required this.readiness,
    required this.nextAction,
    required this.actionQueue,
    required this.intakePlan,
    required this.extensionSuggestions,
  });

  final List<ProjectCustomAttribute> attributes;
  final List<ProjectCustomAttributeEditorRowContext> rows;
  final ProjectDomainExtensionReadinessSummary readiness;
  final ProjectDomainExtensionNextAction nextAction;
  final ProjectDomainExtensionActionQueue actionQueue;
  final ProjectDomainExtensionIntakePlan intakePlan;
  final ProjectCustomAttributeExtensionSuggestionSet extensionSuggestions;

  bool get canAddAttribute => attributes.length < projectCustomAttributeLimit;
}

class ProjectCustomAttributeEditorRowContext {
  const ProjectCustomAttributeEditorRowContext({
    required this.attribute,
    required this.metadata,
  });

  final ProjectCustomAttribute attribute;
  final ProjectDomainAttributeMetadata metadata;
}

class ProjectCustomAttributeEditorContextService {
  const ProjectCustomAttributeEditorContextService({
    this.readinessService = const ProjectDomainExtensionReadinessService(),
    this.nextActionService = const ProjectDomainExtensionNextActionService(),
    this.actionQueueService = const ProjectDomainExtensionActionQueueService(),
    this.intakePlanService = const ProjectDomainExtensionIntakePlanService(),
    this.suggestionService =
        const ProjectCustomAttributeExtensionSuggestionService(),
    this.metadataService = const ProjectDomainAttributeMetadataService(),
  });

  final ProjectDomainExtensionReadinessService readinessService;
  final ProjectDomainExtensionNextActionService nextActionService;
  final ProjectDomainExtensionActionQueueService actionQueueService;
  final ProjectDomainExtensionIntakePlanService intakePlanService;
  final ProjectCustomAttributeExtensionSuggestionService suggestionService;
  final ProjectDomainAttributeMetadataService metadataService;

  ProjectCustomAttributeEditorContext build({
    required String businessDomain,
    required Iterable<ProjectCustomAttribute> attributes,
  }) {
    final normalizedAttributes = normalizeProjectCustomAttributes(
      attributes,
      keepEmpty: true,
    );
    final readiness = readinessService.build(
      businessDomain: businessDomain,
      attributes: normalizedAttributes,
    );
    final metadata = metadataService.build(
      businessDomain: businessDomain,
      attributes: normalizedAttributes,
    );

    return ProjectCustomAttributeEditorContext(
      attributes: normalizedAttributes,
      rows: List.unmodifiable([
        for (var index = 0; index < normalizedAttributes.length; index++)
          ProjectCustomAttributeEditorRowContext(
            attribute: normalizedAttributes[index],
            metadata: metadata[index],
          ),
      ]),
      readiness: readiness,
      nextAction: nextActionService.build(readiness),
      actionQueue: actionQueueService.build(summary: readiness),
      intakePlan: intakePlanService.build(summary: readiness),
      extensionSuggestions: suggestionService.build(
        businessDomain: businessDomain,
        attributes: normalizedAttributes,
      ),
    );
  }
}
