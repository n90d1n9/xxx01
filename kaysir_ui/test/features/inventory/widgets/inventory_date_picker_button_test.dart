import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/inventory/widgets/inventory_date_picker_button.dart';

void main() {
  testWidgets('inventory date picker button emits date action', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InventoryDatePickerButton(
            label: 'Start date',
            valueLabel: '2026-05-01',
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('2026-05-01'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);

    await tester.tap(find.byType(InventoryDatePickerButton));
    await tester.pump();

    expect(pressed, isTrue);
  });
}
