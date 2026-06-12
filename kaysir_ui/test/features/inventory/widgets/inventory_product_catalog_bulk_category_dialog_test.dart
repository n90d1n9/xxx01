import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_product_catalog_bulk_actions.dart';

void main() {
  testWidgets('bulk category dialog validates and submits trimmed category', (
    tester,
  ) async {
    var cancelled = false;
    String? submittedCategory;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryProductBulkCategoryDialog(
            selectedCount: 3,
            onCancel: () => cancelled = true,
            onSubmit: (category) => submittedCategory = category,
          ),
        ),
      ),
    );

    expect(find.text('Change category'), findsOneWidget);
    expect(find.text('3 selected'), findsOneWidget);

    await tester.tap(find.byTooltip('Close bulk category dialog'));
    expect(cancelled, isTrue);

    await tester.tap(find.widgetWithText(FilledButton, 'Apply category'));
    await tester.pump();

    expect(submittedCategory, isNull);
    expect(find.text('Enter a category'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '  Accessories  ');
    await tester.tap(find.widgetWithText(FilledButton, 'Apply category'));
    await tester.pump();

    expect(submittedCategory, 'Accessories');
  });
}
