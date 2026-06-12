import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_editor_context_service.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_extension_suggestion_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attributes_editor_guidance.dart';

void main() {
  testWidgets(
    'custom attributes editor guidance emits field and suggestion actions',
    (tester) async {
      final focusedFields = <String>[];
      ProjectCustomAttributeExtensionSuggestion? addedSuggestion;
      final editorContext = const ProjectCustomAttributeEditorContextService()
          .build(
            businessDomain: 'Retail Operations',
            attributes:
                defaultProjectCustomAttributesForDomain('Retail Operations')
                    .map(
                      (attribute) =>
                          attribute.key == 'store-cluster'
                              ? attribute.copyWith(value: 'Jakarta Flagships')
                              : attribute,
                    )
                    .toList(),
          );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 720,
                child: ProjectCustomAttributesEditorGuidance(
                  editorContext: editorContext,
                  onFocusField: focusedFields.add,
                  onAddSuggestion: (suggestion) => addedSuggestion = suggestion,
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('project-custom-attributes-editor-guidance')),
        findsOneWidget,
      );
      expect(find.text('Next: Launch Wave'), findsOneWidget);
      expect(find.text('Risk Watch'), findsOneWidget);
      expect(find.text('Add Rollout Support'), findsOneWidget);

      await tester.tap(
        find.byKey(
          const ValueKey('project-domain-extension-next-action-launch-wave'),
        ),
      );
      expect(focusedFields.last, 'launch-wave');

      await tester.tap(
        find.byKey(const ValueKey('project-domain-extension-queue-sku-scope')),
      );
      expect(focusedFields.last, 'sku-scope');

      final rolloutSupportSuggestion = find.byKey(
        const ValueKey('project-custom-attribute-suggestion-rollout-support'),
      );
      await tester.ensureVisible(rolloutSupportSuggestion);
      await tester.tap(rolloutSupportSuggestion);
      expect(addedSuggestion?.key, 'rollout-support');
    },
  );

  testWidgets(
    'custom attributes editor guidance hides next action when complete',
    (tester) async {
      final editorContext = const ProjectCustomAttributeEditorContextService()
          .build(
            businessDomain: 'Wedding Organizer',
            attributes: [
              for (final attribute in defaultProjectCustomAttributesForDomain(
                'Wedding Organizer',
              ))
                attribute.copyWith(value: _completeValue(attribute)),
            ],
          );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                width: 720,
                child: ProjectCustomAttributesEditorGuidance(
                  editorContext: editorContext,
                  onFocusField: (_) {},
                  onAddSuggestion: (_) {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(
        find.byKey(
          const ValueKey('project-domain-extension-next-action-vendor-package'),
        ),
        findsNothing,
      );
      expect(find.textContaining('Required:'), findsNothing);
      expect(find.textContaining('Risk:'), findsNothing);
    },
  );
}

String _completeValue(ProjectCustomAttribute attribute) {
  switch (attribute.type) {
    case ProjectCustomAttributeType.number:
      return '120';
    case ProjectCustomAttributeType.boolean:
      return 'Yes';
    case ProjectCustomAttributeType.date:
      return '2026-06-12';
    case ProjectCustomAttributeType.choice:
      return attribute.options.isEmpty ? 'Ready' : attribute.options.first;
    case ProjectCustomAttributeType.text:
    case ProjectCustomAttributeType.url:
      return 'Ready';
  }
}
