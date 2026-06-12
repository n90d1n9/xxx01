import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/product/models/management_pack.dart';
import 'package:kaysir/features/product/widgets/management_pack_field_input.dart';

void main() {
  testWidgets('management pack field input validates required text fields', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: ProductManagementPackFieldInput(
              field: groceryFreshGoodsFields.first,
              controller: controller,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Date'), findsOneWidget);
    expect(find.text('Please enter expiry date'), findsOneWidget);
  });

  testWidgets('management pack field input updates select controllers', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Fresh');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackFieldInput(
            field: groceryFreshGoodsFields.last,
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('product-pack-field-freshness_status')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monitor').last);
    await tester.pumpAndSettle();

    expect(controller.text, 'Monitor');
  });

  testWidgets('management pack field input picks date values', (tester) async {
    final controller = TextEditingController(text: '2026-07-01');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackFieldInput(
            field: groceryFreshGoodsFields.first,
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Pick Expiry date'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15').last);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(controller.text, '2026-07-15');
  });

  testWidgets('management pack field input adjusts number values', (
    tester,
  ) async {
    final controller = TextEditingController(text: '5');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackFieldInput(
            field: groceryFreshGoodsFields[3],
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Increase Shelf life'));
    await tester.pump();
    expect(controller.text, '6');

    await tester.tap(find.byTooltip('Decrease Shelf life'));
    await tester.pump();
    expect(controller.text, '5');
  });

  testWidgets('management pack field input reports toggle changes', (
    tester,
  ) async {
    bool? changedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductManagementPackFieldInput(
            field: groceryFreshGoodsFields[2],
            value: false,
            onToggleChanged: (value) {
              changedValue = value;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Weighted unit'));
    await tester.pump();

    expect(changedValue, isTrue);
  });
}
