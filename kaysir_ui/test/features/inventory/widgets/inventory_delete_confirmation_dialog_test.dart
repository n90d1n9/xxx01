import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_delete_confirmation_dialog.dart';

void main() {
  testWidgets(
    'delete confirmation dialog wires body close and confirm actions',
    (tester) async {
      var cancelled = false;
      var confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InventoryDeleteConfirmationDialog(
              title: 'Delete selected products?',
              subtitle: 'This removes selected products from the catalog.',
              confirmLabel: 'Delete selected',
              showCloseButton: true,
              closeTooltip: 'Close delete confirmation',
              onCancel: () => cancelled = true,
              onConfirm: () => confirmed = true,
              children: const [Text('3 selected')],
            ),
          ),
        ),
      );

      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(find.text('Delete selected products?'), findsOneWidget);
      expect(find.text('3 selected'), findsOneWidget);

      await tester.tap(find.byTooltip('Close delete confirmation'));
      expect(cancelled, isTrue);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete selected'));
      expect(confirmed, isTrue);
    },
  );

  testWidgets(
    'delete confirmation dialog supports disabled destructive action',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: InventoryDeleteConfirmationDialog(
              title: 'Delete Jakarta Central?',
              subtitle: 'Move assigned warehouses before deleting this branch.',
              confirmLabel: 'Branch in use',
              confirmIcon: Icons.lock_outline_rounded,
              onConfirm: null,
            ),
          ),
        ),
      );

      final blockedButton = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Branch in use'),
      );

      expect(blockedButton.onPressed, isNull);
    },
  );
}
