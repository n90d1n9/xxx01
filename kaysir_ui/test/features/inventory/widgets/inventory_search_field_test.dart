import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_search_field.dart';

void main() {
  testWidgets('inventory search field clears query with shared action', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    var query = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return InventorySearchField(
                controller: controller,
                hintText: 'Search inventory',
                onChanged: (value) => setState(() => query = value),
              );
            },
          ),
        ),
      ),
    );

    expect(find.byTooltip('Clear search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'speaker');
    await tester.pump();

    expect(query, 'speaker');
    expect(find.byTooltip('Clear search'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();

    expect(controller.text, isEmpty);
    expect(query, isEmpty);
    expect(find.byTooltip('Clear search'), findsNothing);
  });
}
