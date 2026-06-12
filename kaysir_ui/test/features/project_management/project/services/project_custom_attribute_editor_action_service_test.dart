import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_editor_action_service.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_extension_suggestion_service.dart';

void main() {
  test('custom attribute editor action adds focused generic fields', () {
    final result = const ProjectCustomAttributeEditorActionService()
        .addCustomField(
          defaultProjectCustomAttributesForDomain('Retail Operations'),
        );

    expect(result.didChange, isTrue);
    expect(result.hasFocusTarget, isTrue);
    expect(result.focusedAttributeKey, 'custom-field-5');
    expect(
      result.attributes.last,
      const ProjectCustomAttribute(
        key: 'custom-field-5',
        label: 'Custom Field',
        type: ProjectCustomAttributeType.text,
      ),
    );
  });

  test('custom attribute editor action keeps generic field keys unique', () {
    final result = const ProjectCustomAttributeEditorActionService()
        .addCustomField(const [
          ProjectCustomAttribute(
            key: 'custom-field-2',
            label: 'Custom Field 2',
            type: ProjectCustomAttributeType.text,
          ),
        ]);

    expect(result.didChange, isTrue);
    expect(result.focusedAttributeKey, 'custom-field-2-2');
    expect(result.attributes.map((attribute) => attribute.key), [
      'custom-field-2',
      'custom-field-2-2',
    ]);
  });

  test('custom attribute editor action adds suggested fields', () {
    final suggestionSet =
        const ProjectCustomAttributeExtensionSuggestionService().build(
          businessDomain: 'Retail Operations',
          attributes: defaultProjectCustomAttributesForDomain(
            'Retail Operations',
          ),
        );
    final result = const ProjectCustomAttributeEditorActionService()
        .addSuggestedField(
          attributes: defaultProjectCustomAttributesForDomain(
            'Retail Operations',
          ),
          suggestion: suggestionSet.visibleSuggestions.first,
        );

    expect(result.didChange, isTrue);
    expect(result.focusedAttributeKey, 'rollout-support');
    expect(result.attributes.last.label, 'Rollout Support');
  });

  test('custom attribute editor action respects limits and duplicates', () {
    final fullAttributes = [
      for (var index = 0; index < projectCustomAttributeLimit; index++)
        ProjectCustomAttribute(
          key: 'custom-$index',
          label: 'Custom $index',
          type: ProjectCustomAttributeType.text,
        ),
    ];

    final limited = const ProjectCustomAttributeEditorActionService()
        .addCustomField(fullAttributes);

    expect(limited.didChange, isFalse);
    expect(limited.attributes, hasLength(projectCustomAttributeLimit));

    const suggestion = ProjectCustomAttributeExtensionSuggestion(
      kind: ProjectCustomAttributeExtensionSuggestionKind.operations,
      key: 'rollout-support',
      label: 'Rollout Support',
      type: ProjectCustomAttributeType.text,
      reason: 'Capture rollout support.',
    );
    final duplicate = const ProjectCustomAttributeEditorActionService()
        .addSuggestedField(
          attributes: const [
            ProjectCustomAttribute(
              key: 'rollout-support',
              label: 'Rollout Support',
              type: ProjectCustomAttributeType.text,
            ),
          ],
          suggestion: suggestion,
        );

    expect(duplicate.didChange, isFalse);
    expect(duplicate.attributes, hasLength(1));
    expect(duplicate.focusedAttributeKey, 'rollout-support');
  });

  test('custom attribute editor action replaces and normalizes fields', () {
    final result = const ProjectCustomAttributeEditorActionService()
        .replaceField(
          attributes: const [
            ProjectCustomAttribute(
              key: 'launch-wave',
              label: 'Launch Wave',
              type: ProjectCustomAttributeType.text,
            ),
          ],
          index: 0,
          attribute: const ProjectCustomAttribute(
            key: 'launch-wave',
            label: 'Launch Wave',
            type: ProjectCustomAttributeType.text,
            value: ' Wave 2 ',
          ),
        );

    expect(result.didChange, isTrue);
    expect(result.focusedAttributeKey, isEmpty);
    expect(result.attributes.single.value, 'Wave 2');
  });

  test(
    'custom attribute editor action removes fields and ignores stale indexes',
    () {
      const service = ProjectCustomAttributeEditorActionService();
      final removed = service.removeField(
        attributes: const [
          ProjectCustomAttribute(
            key: 'store-cluster',
            label: 'Store Cluster',
            type: ProjectCustomAttributeType.text,
          ),
          ProjectCustomAttribute(
            key: 'launch-wave',
            label: 'Launch Wave',
            type: ProjectCustomAttributeType.text,
          ),
        ],
        index: 0,
      );

      expect(removed.didChange, isTrue);
      expect(removed.attributes.map((attribute) => attribute.key), [
        'launch-wave',
      ]);

      final stale = service.removeField(
        attributes: removed.attributes,
        index: 4,
      );

      expect(stale.didChange, isFalse);
      expect(stale.attributes.map((attribute) => attribute.key), [
        'launch-wave',
      ]);
    },
  );
}
