import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog_surface.dart';

void main() {
  testWidgets('inventory dialog surface renders shared modal constraints', (
    tester,
  ) async {
    var didClose = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDialogSurface(
            maxWidth: 420,
            maxHeight: 280,
            child: InventoryDialogHeader(
              eyebrow: 'Inventory Setup',
              title: 'Create Stock Line',
              subtitle: 'Assign a product to a warehouse.',
              closeTooltip: 'Close create stock line',
              onClose: () {
                didClose = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Inventory Setup'), findsOneWidget);
    expect(find.text('Create Stock Line'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    final surfaceConstraint = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox &&
          widget.constraints.maxWidth == 420 &&
          widget.constraints.maxHeight == 280,
    );
    expect(surfaceConstraint, findsOneWidget);

    await tester.tap(find.byTooltip('Close create stock line'));
    expect(didClose, isTrue);
  });

  testWidgets('inventory dialog header can omit close affordance', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InventoryDialogHeader(
            eyebrow: 'Confirm Delete',
            title: 'Delete product?',
            subtitle: 'This removes the product from the catalog.',
            showCloseButton: false,
          ),
        ),
      ),
    );

    expect(find.text('Confirm Delete'), findsOneWidget);
    expect(find.text('Delete product?'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
  });
}
