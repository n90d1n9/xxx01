import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_empty_state.dart';

void main() {
  testWidgets('BillingEmptyState renders a compact message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BillingEmptyState(message: 'No launch actions available.'),
        ),
      ),
    );

    expect(find.text('No launch actions available.'), findsOneWidget);
  });

  testWidgets('BillingEmptyState renders optional title icon and action', (
    tester,
  ) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BillingEmptyState(
            title: 'No tasks queued',
            message: 'Create a launch task to continue.',
            icon: Icons.queue_outlined,
            action: TextButton(
              onPressed: () {
                tapped = true;
              },
              child: const Text('Create task'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('No tasks queued'), findsOneWidget);
    expect(find.text('Create a launch task to continue.'), findsOneWidget);
    expect(find.byIcon(Icons.queue_outlined), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Create task'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Create task'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
