import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/data/project_custom_attribute_templates.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attributes_editor.dart';

void main() {
  testWidgets('custom attributes editor focuses requested attribute row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 260,
            child: SingleChildScrollView(
              child: ProjectCustomAttributesEditor(
                businessDomain: 'Software Development',
                attributes: defaultProjectCustomAttributesForDomain(
                  'Software Development',
                ),
                focusedAttributeKey: 'Repository',
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final row = find.byKey(
      const ValueKey('project-custom-attribute-row-repository'),
    );
    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-repository'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(row, findsOneWidget);
    expect(valueField, findsOneWidget);
    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attributes editor focuses next domain action field', (
    tester,
  ) async {
    final retailAttributes =
        defaultProjectCustomAttributesForDomain('Retail Operations')
            .map(
              (attribute) =>
                  attribute.key == 'store-cluster'
                      ? attribute.copyWith(value: 'Jakarta Flagships')
                      : attribute,
            )
            .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: SingleChildScrollView(
              child: ProjectCustomAttributesEditor(
                businessDomain: 'Retail Operations',
                attributes: retailAttributes,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Next: Launch Wave'), findsOneWidget);
    expect(find.textContaining('Launch Wave is required'), findsOneWidget);

    final nextAction = find.byKey(
      const ValueKey('project-domain-extension-next-action-launch-wave'),
    );
    await tester.ensureVisible(nextAction);
    await tester.tap(nextAction);
    await tester.pumpAndSettle();

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-launch-wave'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attributes editor focuses domain queue fields', (
    tester,
  ) async {
    final retailAttributes =
        defaultProjectCustomAttributesForDomain('Retail Operations')
            .map(
              (attribute) =>
                  attribute.key == 'store-cluster'
                      ? attribute.copyWith(value: 'Jakarta Flagships')
                      : attribute,
            )
            .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: SingleChildScrollView(
              child: ProjectCustomAttributesEditor(
                businessDomain: 'Retail Operations',
                attributes: retailAttributes,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Risk: SKU Scope'), findsOneWidget);

    final skuScopeQueueAction = find.byKey(
      const ValueKey('project-domain-extension-queue-sku-scope'),
    );

    await tester.ensureVisible(skuScopeQueueAction);
    await tester.tap(skuScopeQueueAction);
    await tester.pumpAndSettle();

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-sku-scope'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attributes editor focuses domain intake lanes', (
    tester,
  ) async {
    final retailAttributes =
        defaultProjectCustomAttributesForDomain('Retail Operations')
            .map(
              (attribute) =>
                  attribute.key == 'store-cluster'
                      ? attribute.copyWith(value: 'Jakarta Flagships')
                      : attribute,
            )
            .toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 420,
            child: SingleChildScrollView(
              child: ProjectCustomAttributesEditor(
                businessDomain: 'Retail Operations',
                attributes: retailAttributes,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Risk Watch'), findsOneWidget);
    expect(find.text('0/3 watched'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('project-domain-extension-intake-lane-risk-watch'),
      ),
    );
    await tester.pumpAndSettle();

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-sku-scope'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attributes editor adds suggested extension fields', (
    tester,
  ) async {
    var retailAttributes =
        defaultProjectCustomAttributesForDomain('Retail Operations').toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 480,
            child: StatefulBuilder(
              builder: (context, setAttributes) {
                return SingleChildScrollView(
                  child: ProjectCustomAttributesEditor(
                    businessDomain: 'Retail Operations',
                    attributes: retailAttributes,
                    onChanged:
                        (next) => setAttributes(() => retailAttributes = next),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    final suggestion = find.byKey(
      const ValueKey('project-custom-attribute-suggestion-rollout-support'),
    );
    expect(find.text('Add Rollout Support'), findsOneWidget);

    await tester.ensureVisible(suggestion);
    await tester.tap(suggestion);
    await tester.pumpAndSettle();

    expect(
      retailAttributes.map((attribute) => attribute.key),
      contains('rollout-support'),
    );

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-rollout-support'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets('custom attributes editor adds and focuses generic fields', (
    tester,
  ) async {
    var retailAttributes =
        defaultProjectCustomAttributesForDomain('Retail Operations').toList();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 480,
            child: StatefulBuilder(
              builder: (context, setAttributes) {
                return SingleChildScrollView(
                  child: ProjectCustomAttributesEditor(
                    businessDomain: 'Retail Operations',
                    attributes: retailAttributes,
                    onChanged:
                        (next) => setAttributes(() => retailAttributes = next),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add Field'));
    await tester.pumpAndSettle();

    expect(
      retailAttributes.map((attribute) => attribute.key),
      contains('custom-field-5'),
    );

    final valueField = find.byKey(
      const ValueKey('project-custom-attribute-value-custom-field-5'),
    );
    final textField = tester.widget<TextField>(
      find.descendant(of: valueField, matching: find.byType(TextField)),
    );

    expect(textField.autofocus, isTrue);
    expect(textField.focusNode?.hasFocus, isTrue);
  });

  testWidgets(
    'custom attributes editor removes fields through action service',
    (tester) async {
      var retailAttributes =
          defaultProjectCustomAttributesForDomain('Retail Operations').toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 480,
              child: StatefulBuilder(
                builder: (context, setAttributes) {
                  return SingleChildScrollView(
                    child: ProjectCustomAttributesEditor(
                      businessDomain: 'Retail Operations',
                      attributes: retailAttributes,
                      onChanged:
                          (next) =>
                              setAttributes(() => retailAttributes = next),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      final removeLaunchWave = find.byTooltip('Remove Launch Wave');
      await tester.ensureVisible(removeLaunchWave);
      await tester.tap(removeLaunchWave);
      await tester.pumpAndSettle();

      expect(
        retailAttributes.map((attribute) => attribute.key),
        isNot(contains('launch-wave')),
      );
      expect(
        find.byKey(const ValueKey('project-custom-attribute-row-launch-wave')),
        findsNothing,
      );
    },
  );

  testWidgets('custom attributes editor hides next action when complete', (
    tester,
  ) async {
    final completeAttributes = [
      for (final attribute in defaultProjectCustomAttributesForDomain(
        'Wedding Organizer',
      ))
        attribute.copyWith(value: _completeValue(attribute)),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectCustomAttributesEditor(
              businessDomain: 'Wedding Organizer',
              attributes: completeAttributes,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Wedding Organizer context ready'), findsNothing);
    expect(
      find.byKey(
        const ValueKey('project-domain-extension-next-action-vendor-package'),
      ),
      findsNothing,
    );
    expect(find.textContaining('Required:'), findsNothing);
    expect(find.textContaining('Risk:'), findsNothing);
  });
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
