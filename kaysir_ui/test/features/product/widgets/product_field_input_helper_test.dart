import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/widgets/product_field_input_helper.dart';

void main() {
  testWidgets('product field input helper renders description and chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductFieldInputHelper(
            data: ProductFieldInputHelperData(
              description: 'Base selling price used by POS and catalog.',
              requirementLabel: 'Required',
              requirementTone: ProductFieldInputRequirementTone.required,
              typeLabel: 'Money',
              typeIcon: Icons.payments_rounded,
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Base selling price used by POS and catalog.'),
      findsOneWidget,
    );
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Money'), findsOneWidget);
  });

  testWidgets('product field input helper renders locked and unit chips', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProductFieldInputHelper(
            data: ProductFieldInputHelperData(
              description: 'Locked after creation.',
              requirementLabel: 'Locked',
              requirementTone: ProductFieldInputRequirementTone.locked,
              typeLabel: 'Number',
              typeIcon: Icons.pin_rounded,
              unitLabel: 'units',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Locked'), findsOneWidget);
    expect(find.text('Number'), findsOneWidget);
    expect(find.text('units'), findsOneWidget);
  });
}
