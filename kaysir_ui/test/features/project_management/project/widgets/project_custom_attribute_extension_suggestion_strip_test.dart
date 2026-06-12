import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/services/project_custom_attribute_extension_suggestion_service.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_extension_suggestion_strip.dart';

void main() {
  testWidgets('custom attribute extension suggestion strip adds suggestions', (
    tester,
  ) async {
    ProjectCustomAttributeExtensionSuggestion? addedSuggestion;
    final suggestionSet =
        const ProjectCustomAttributeExtensionSuggestionService().build(
          businessDomain: 'Retail Operations',
          attributes: defaultProjectCustomAttributesForDomain(
            'Retail Operations',
          ),
          maxVisibleSuggestions: 2,
        );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCustomAttributeExtensionSuggestionStrip(
            suggestionSet: suggestionSet,
            onAddSuggestion: (suggestion) => addedSuggestion = suggestion,
          ),
        ),
      ),
    );

    expect(find.text('Add Rollout Support'), findsOneWidget);
    expect(find.text('Add Sales Lift Target'), findsOneWidget);
    expect(find.text('+4 more'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-custom-attribute-suggestion-rollout-support'),
      ),
    );

    expect(addedSuggestion?.key, 'rollout-support');
    expect(addedSuggestion?.label, 'Rollout Support');
  });
}
