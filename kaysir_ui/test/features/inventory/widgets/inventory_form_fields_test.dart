import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/utils/inventory_form_utils.dart';
import 'package:kaysir/features/inventory/widgets/inventory_form_fields.dart';

void main() {
  testWidgets('inventory form text field renders shared chrome', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryFormTextField(
            controller: controller,
            label: 'Notes',
            helperText: 'Optional',
            icon: Icons.notes_rounded,
            alignLabelWithHint: true,
            maxLines: 3,
            textInputAction: TextInputAction.next,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);
    expect(find.byIcon(Icons.notes_rounded), findsOneWidget);
    expect(field.decoration?.alignLabelWithHint, isTrue);
    expect(field.maxLines, 3);
    expect(field.textInputAction, TextInputAction.next);
  });

  testWidgets('inventory form text field supports compact initial values', (
    tester,
  ) async {
    var value = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryFormTextField(
            initialValue: 'Shelf recount',
            isDense: true,
            label: 'Notes',
            onChanged: (text) => value = text,
          ),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byType(TextField));

    expect(find.text('Shelf recount'), findsOneWidget);
    expect(field.decoration?.prefixIcon, isNull);
    expect(field.decoration?.isDense, isTrue);

    await tester.enterText(find.byType(TextFormField), 'Updated note');
    expect(value, 'Updated note');
  });

  testWidgets('inventory integer field validates whole numbers', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: '-1');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InventoryIntegerFormField(
              controller: controller,
              label: 'Opening quantity',
              icon: Icons.inventory_2_rounded,
              allowZero: true,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(inventoryZeroOrMoreError), findsOneWidget);
  });

  testWidgets('inventory integer field accepts custom validator', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: '0');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: InventoryIntegerFormField(
              controller: controller,
              label: 'Quantity',
              icon: Icons.add_rounded,
              validator: validateInventoryPositiveQuantity,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text(inventoryPositiveQuantityError), findsOneWidget);
  });

  testWidgets('inventory form error renders shared error treatment', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryFormError(message: 'Something needs attention'),
        ),
      ),
    );

    expect(find.text('Something needs attention'), findsOneWidget);
    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
  });
}
