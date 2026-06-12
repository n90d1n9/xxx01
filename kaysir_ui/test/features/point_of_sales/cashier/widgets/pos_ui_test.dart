import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/point_of_sales/cashier/widgets/pos_ui.dart';

void main() {
  testWidgets('POSActionButton renders a disabled outlined button', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: POSActionButton(
            icon: Icon(Icons.pause_circle_outline),
            label: 'Hold',
            onPressed: null,
          ),
        ),
      ),
    );

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, 'Hold'),
    );

    expect(button.onPressed, isNull);
  });

  testWidgets('POSActionButton can expose an operator tooltip', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSActionButton(
            icon: const Icon(Icons.qr_code_scanner),
            label: 'Scan',
            tooltip: 'Scan (F4)',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Scan (F4)'), findsOneWidget);
  });

  testWidgets('POSChoicePill reports selection', (tester) async {
    var selected = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSChoicePill(
            label: 'Electronics',
            selected: false,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Electronics'));
    await tester.pumpAndSettle();

    expect(selected, isTrue);
  });

  testWidgets('POSEmptyState supports an optional action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: POSEmptyState(
            icon: Icons.search_off_outlined,
            title: 'No results',
            message: 'Try again',
            action: POSActionButton(
              icon: const Icon(Icons.refresh),
              label: 'Retry',
              onPressed: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('No results'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
