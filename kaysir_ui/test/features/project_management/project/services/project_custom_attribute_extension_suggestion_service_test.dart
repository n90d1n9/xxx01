import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_extension_suggestion_service.dart';

void main() {
  test('custom attribute extension suggestions adapt to business domain', () {
    final suggestions = const ProjectCustomAttributeExtensionSuggestionService()
        .build(
          businessDomain: 'Retail Operations',
          attributes: defaultProjectCustomAttributesForDomain(
            'Retail Operations',
          ),
        );

    expect(suggestions.businessDomain, 'Retail Operations');
    expect(suggestions.totalSuggestionCount, greaterThan(4));
    expect(suggestions.visibleSuggestions.map((suggestion) => suggestion.key), [
      'rollout-support',
      'sales-lift-target',
      'approval-owner',
      'success-metric',
    ]);
    expect(
      suggestions.visibleSuggestions.first.toAttribute(),
      const ProjectCustomAttribute(
        key: 'rollout-support',
        label: 'Rollout Support',
        type: ProjectCustomAttributeType.text,
        isPinned: true,
      ),
    );
  });

  test('custom attribute extension suggestions skip existing fields', () {
    final attributes = [
      ...defaultProjectCustomAttributesForDomain('Retail Operations'),
      const ProjectCustomAttribute(
        key: 'rollout-support',
        label: 'Rollout Support',
        type: ProjectCustomAttributeType.text,
      ),
    ];

    final suggestions = const ProjectCustomAttributeExtensionSuggestionService()
        .build(
          businessDomain: 'Retail Operations',
          attributes: attributes,
          maxVisibleSuggestions: 2,
        );

    expect(suggestions.visibleSuggestions.map((suggestion) => suggestion.key), [
      'sales-lift-target',
      'approval-owner',
    ]);
    expect(suggestions.hasHiddenSuggestions, isTrue);
  });

  test('custom attribute extension suggestions respect attribute limit', () {
    final attributes = [
      for (var index = 0; index < projectCustomAttributeLimit; index++)
        ProjectCustomAttribute(
          key: 'custom-$index',
          label: 'Custom $index',
          type: ProjectCustomAttributeType.text,
        ),
    ];

    final suggestions = const ProjectCustomAttributeExtensionSuggestionService()
        .build(businessDomain: 'Custom Logistics', attributes: attributes);

    expect(suggestions.businessDomain, 'General Business');
    expect(suggestions.hasSuggestions, isFalse);
    expect(suggestions.visibleSuggestions, isEmpty);
  });
}
