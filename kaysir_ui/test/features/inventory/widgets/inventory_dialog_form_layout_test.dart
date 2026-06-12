import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog_form_layout.dart';
import 'package:kaysir/features/inventory/widgets/inventory_form_fields.dart';

void main() {
  testWidgets('inventory dialog form layout wires header error and actions', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    var confirmed = false;
    var cancelled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDialogFormLayout(
            formKey: formKey,
            eyebrow: 'Inventory Catalog',
            title: 'Add Product',
            subtitle: 'Create a reusable product record.',
            formError: 'Product name is required',
            closeTooltip: 'Close product form',
            onCancel: () => cancelled = true,
            confirmLabel: 'Add product',
            confirmIcon: Icons.add_rounded,
            onConfirm: () => confirmed = true,
            children: const [InventoryFormTextField(label: 'Product name')],
          ),
        ),
      ),
    );

    expect(find.text('Inventory Catalog'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);
    expect(find.text('Product name is required'), findsOneWidget);
    expect(find.byType(InventoryFormError), findsOneWidget);

    await tester.tap(find.byTooltip('Close product form'));
    expect(cancelled, isTrue);

    await tester.tap(find.text('Add product'));
    expect(confirmed, isTrue);
  });
}
