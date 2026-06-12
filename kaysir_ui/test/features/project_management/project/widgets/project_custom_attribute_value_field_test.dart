import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attribute_value_field.dart';

void main() {
  testWidgets('custom attribute value field edits typed text values', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCustomAttributeValueField(
            attribute: const ProjectCustomAttribute(
              key: 'sku-scope',
              label: 'SKU Scope',
              type: ProjectCustomAttributeType.number,
              value: '120',
            ),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
    expect(find.text('120'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '240');

    expect(changes.last, '240');
  });

  testWidgets('custom attribute value field normalizes boolean values', (
    tester,
  ) async {
    final changes = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProjectCustomAttributeValueField(
            attribute: const ProjectCustomAttribute(
              key: 'api-contract',
              label: 'API Contract',
              type: ProjectCustomAttributeType.boolean,
              value: 'true',
            ),
            onChanged: changes.add,
          ),
        ),
      ),
    );

    expect(find.text('Yes'), findsOneWidget);

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No').last);
    await tester.pumpAndSettle();

    expect(changes.last, 'No');
  });

  testWidgets(
    'custom attribute value field keeps custom choice values selectable',
    (tester) async {
      final changes = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProjectCustomAttributeValueField(
              attribute: const ProjectCustomAttribute(
                key: 'target-environment',
                label: 'Target Environment',
                type: ProjectCustomAttributeType.choice,
                value: 'Sandbox',
                options: ['Development', 'Staging', 'Production'],
              ),
              onChanged: changes.add,
            ),
          ),
        ),
      );

      expect(find.text('Sandbox (custom)'), findsOneWidget);

      await tester.tap(find.text('Sandbox (custom)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Production').last);
      await tester.pumpAndSettle();

      expect(changes.last, 'Production');
    },
  );
}
