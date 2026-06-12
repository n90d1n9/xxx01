import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/project_management/project/widgets/project_custom_attributes_editor_header.dart';

void main() {
  testWidgets('custom attributes editor header renders actions', (
    tester,
  ) async {
    var didApplyDefaults = false;
    var didAddAttribute = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: ProjectCustomAttributesEditorHeader(
              businessDomain: 'Retail Operations',
              canAddAttribute: true,
              onApplyDomainDefaults: () => didApplyDefaults = true,
              onAddAttribute: () => didAddAttribute = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Domain Extensions'), findsOneWidget);
    expect(
      find.text('Retail Operations fields and custom attributes'),
      findsOneWidget,
    );

    await tester.tap(find.text('Domain Defaults'));
    await tester.tap(find.text('Add Field'));

    expect(didApplyDefaults, isTrue);
    expect(didAddAttribute, isTrue);
  });

  testWidgets('custom attributes editor header disables add action at limit', (
    tester,
  ) async {
    var didAddAttribute = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: ProjectCustomAttributesEditorHeader(
              businessDomain: 'Software Development',
              canAddAttribute: false,
              onApplyDomainDefaults: () {},
              onAddAttribute: () => didAddAttribute = true,
            ),
          ),
        ),
      ),
    );

    final addButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Add Field'),
        matching: find.byType(OutlinedButton),
      ),
    );

    expect(addButton.onPressed, isNull);

    await tester.tap(find.text('Add Field'), warnIfMissed: false);

    expect(didAddAttribute, isFalse);
  });
}
