import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_reset_filters_button.dart';

void main() {
  testWidgets('inventory reset filters button emits reset action', (
    tester,
  ) async {
    var resetCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryResetFiltersButton(
            onPressed: () => resetCalled = true,
          ),
        ),
      ),
    );

    expect(find.text('Reset filters'), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

    await tester.tap(find.text('Reset filters'));
    await tester.pump();

    expect(resetCalled, isTrue);
  });
}
