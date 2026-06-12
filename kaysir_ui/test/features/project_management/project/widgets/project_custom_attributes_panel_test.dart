import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/models/project_custom_attribute.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attributes_panel.dart';

void main() {
  testWidgets('custom attributes panel renders domain metadata chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProjectCustomAttributesPanel(
              businessDomain: 'Software Development',
              attributes: [
                ProjectCustomAttribute(
                  key: 'api-contract',
                  label: 'API Contract',
                  type: ProjectCustomAttributeType.boolean,
                  value: 'No',
                  isPinned: true,
                ),
                ProjectCustomAttribute(
                  key: 'customer-segment',
                  label: 'Customer Segment',
                  type: ProjectCustomAttributeType.text,
                  value: 'Enterprise',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('API Contract'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);
    expect(find.text('Yes/No'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Risk signal'), findsOneWidget);
    expect(find.text('Customer Segment'), findsOneWidget);
    expect(find.text('Enterprise'), findsOneWidget);
    expect(find.text('Custom'), findsOneWidget);
  });

  testWidgets('custom attributes panel stays simple without domain metadata', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProjectCustomAttributesPanel(
            attributes: [
              ProjectCustomAttribute(
                key: 'local-note',
                label: 'Local Note',
                type: ProjectCustomAttributeType.text,
                value: 'Field team owns checklist',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Local Note'), findsOneWidget);
    expect(find.text('Field team owns checklist'), findsOneWidget);
    expect(find.text('Custom'), findsNothing);
    expect(find.text('Risk signal'), findsNothing);
  });
}
