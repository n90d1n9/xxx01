import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_editor_context_service.dart';
import 'package:kaysir/features/project_management/project/services/project_domain_extension_next_action_service.dart';

void main() {
  test('custom attribute editor context composes adaptive domain state', () {
    const service = ProjectCustomAttributeEditorContextService();
    final attributes =
        defaultProjectCustomAttributesForDomain('Retail Operations')
            .map(
              (attribute) =>
                  attribute.key == 'store-cluster'
                      ? attribute.copyWith(value: 'Jakarta Flagships')
                      : attribute,
            )
            .toList();

    final context = service.build(
      businessDomain: 'Retail Operations',
      attributes: attributes,
    );

    expect(context.attributes, hasLength(4));
    expect(context.rows, hasLength(context.attributes.length));
    expect(
      context.rows.map((row) => row.attribute.key),
      context.rows.map((row) => row.metadata.key),
    );
    expect(context.readiness.businessDomain, 'Retail Operations');
    expect(context.readiness.completedRequiredFieldCount, 1);
    expect(
      context.nextAction.kind,
      ProjectDomainExtensionNextActionKind.requiredField,
    );
    expect(context.nextAction.fieldKey, 'launch-wave');
    expect(context.actionQueue.hasActions, isTrue);
    expect(context.actionQueue.visibleItems.map((item) => item.fieldKey), [
      'launch-wave',
      'sku-scope',
      'omnichannel-impact',
    ]);
    expect(context.intakePlan.hasMissingFields, isTrue);
    expect(context.extensionSuggestions.hasSuggestions, isTrue);
    expect(context.canAddAttribute, isTrue);
  });

  test('custom attribute editor context normalizes rows and add limits', () {
    const service = ProjectCustomAttributeEditorContextService();
    final attributes = [
      const ProjectCustomAttribute(
        key: '',
        label: ' Launch Window ',
        type: ProjectCustomAttributeType.text,
        value: ' Q3 ',
      ),
      for (var index = 1; index < projectCustomAttributeLimit; index++)
        ProjectCustomAttribute(
          key: 'custom-$index',
          label: 'Custom $index',
          type: ProjectCustomAttributeType.text,
        ),
    ];

    final context = service.build(
      businessDomain: 'Custom Logistics',
      attributes: attributes,
    );

    expect(context.attributes, hasLength(projectCustomAttributeLimit));
    expect(context.attributes.first.key, 'launch-window');
    expect(context.attributes.first.label, 'Launch Window');
    expect(context.attributes.first.value, 'Q3');
    expect(context.rows.first.metadata.sourceLabel, 'Custom');
    expect(context.canAddAttribute, isFalse);
    expect(context.extensionSuggestions.hasSuggestions, isFalse);
  });
}
