import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_dialog_content_layout.dart';

void main() {
  testWidgets('inventory dialog content layout wires header body and close', (
    tester,
  ) async {
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDialogContentLayout(
            maxWidth: 480,
            maxHeight: 320,
            eyebrow: 'Warehouse Transfer',
            title: 'Transfer Laptop',
            subtitle: 'LT-001 | From Main Warehouse - Jakarta',
            closeTooltip: 'Close stock transfer',
            onClose: () => closed = true,
            child: const Text('Transfer form body'),
          ),
        ),
      ),
    );

    expect(find.text('Warehouse Transfer'), findsOneWidget);
    expect(find.text('Transfer Laptop'), findsOneWidget);
    expect(find.text('Transfer form body'), findsOneWidget);

    final surfaceConstraint = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox &&
          widget.constraints.maxWidth == 480 &&
          widget.constraints.maxHeight == 320,
    );
    expect(surfaceConstraint, findsOneWidget);

    await tester.tap(find.byTooltip('Close stock transfer'));
    expect(closed, isTrue);
  });
}
