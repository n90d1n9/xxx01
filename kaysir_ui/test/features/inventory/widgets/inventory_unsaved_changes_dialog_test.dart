import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_unsaved_changes_dialog.dart';

void main() {
  testWidgets('unsaved changes dialog wires cancel and discard actions', (
    tester,
  ) async {
    var canceled = false;
    var confirmed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryUnsavedChangesDialog(
            title: 'Switch warehouse?',
            subtitle: 'Switching warehouses will discard current edits.',
            confirmLabel: 'Switch warehouse',
            onCancel: () => canceled = true,
            onConfirm: () => confirmed = true,
          ),
        ),
      ),
    );

    expect(find.text('Unsaved Changes'), findsOneWidget);
    expect(find.text('Switch warehouse?'), findsOneWidget);
    expect(find.text('Keep editing'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Keep editing'));
    await tester.tap(find.widgetWithText(FilledButton, 'Switch warehouse'));

    expect(canceled, isTrue);
    expect(confirmed, isTrue);
  });
}
