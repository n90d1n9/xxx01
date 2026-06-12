import 'package:flutter/material.dart';

import '../services/project_custom_attribute_editor_context_service.dart';
import '../services/project_custom_attribute_extension_suggestion_service.dart';
import 'project_custom_attribute_extension_suggestion_strip.dart';
import 'project_domain_extension_action_queue_strip.dart';
import 'project_domain_extension_intake_plan_strip.dart';
import 'project_domain_extension_next_action_card.dart';
import 'project_domain_extension_readiness_panel.dart';

class ProjectCustomAttributesEditorGuidance extends StatelessWidget {
  const ProjectCustomAttributesEditorGuidance({
    required this.editorContext,
    required this.onFocusField,
    required this.onAddSuggestion,
    super.key,
  });

  final ProjectCustomAttributeEditorContext editorContext;
  final ValueChanged<String> onFocusField;
  final ValueChanged<ProjectCustomAttributeExtensionSuggestion> onAddSuggestion;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('project-custom-attributes-editor-guidance'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProjectDomainExtensionReadinessPanel(summary: editorContext.readiness),
        const SizedBox(height: 10),
        ProjectDomainExtensionIntakePlanStrip(
          plan: editorContext.intakePlan,
          onFocusField: onFocusField,
        ),
        if (editorContext.nextAction.hasField) ...[
          const SizedBox(height: 12),
          ProjectDomainExtensionNextActionCard(
            action: editorContext.nextAction,
            onFocusField: () => onFocusField(editorContext.nextAction.fieldKey),
          ),
        ],
        if (editorContext.actionQueue.hasActions) ...[
          const SizedBox(height: 10),
          ProjectDomainExtensionActionQueueStrip(
            queue: editorContext.actionQueue,
            onFocusField: onFocusField,
          ),
        ],
        if (editorContext.extensionSuggestions.hasSuggestions) ...[
          const SizedBox(height: 10),
          ProjectCustomAttributeExtensionSuggestionStrip(
            suggestionSet: editorContext.extensionSuggestions,
            onAddSuggestion: onAddSuggestion,
          ),
        ],
      ],
    );
  }
}
