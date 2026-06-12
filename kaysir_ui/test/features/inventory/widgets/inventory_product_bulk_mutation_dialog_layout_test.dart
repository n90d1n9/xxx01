import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_bulk_mutation_dialog_layout.dart';

void main() {
  testWidgets('bulk mutation dialog layout wires form status and actions', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    var cancelled = false;
    var validated = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkMutationDialogLayout(
            formKey: formKey,
            eyebrow: 'Bulk Pricing',
            title: 'Update selected prices',
            subtitle: 'Apply a pricing rule to 2 selected products.',
            statusLabel: '2 selected',
            statusIcon: Icons.library_add_check_rounded,
            confirmLabel: 'Apply prices',
            confirmIcon: Icons.price_change_rounded,
            closeTooltip: 'Close bulk price dialog',
            onCancel: () => cancelled = true,
            onConfirm:
                () => validated = formKey.currentState?.validate() ?? false,
            children: [
              TextFormField(
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Enter a price value'
                            : null,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bulk Pricing'), findsOneWidget);
    expect(find.text('Update selected prices'), findsOneWidget);
    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Close bulk price dialog'));
    expect(cancelled, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply prices'));
    await tester.pump();
    expect(validated, isFalse);
    expect(find.text('Enter a price value'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '12');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply prices'));
    await tester.pump();
    expect(validated, isTrue);
  });
}
