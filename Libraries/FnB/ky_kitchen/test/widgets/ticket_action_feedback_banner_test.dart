import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets(
    'ticket action feedback banner renders undo and dismiss actions',
    (tester) async {
      final events = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KitchenTicketActionFeedbackBanner(
              result: KitchenTicketActionResult(
                action: KitchenTicketAction.startFiring,
                outcome: KitchenTicketActionOutcome.applied,
                ticketId: 'ticket-1',
                previousTicket: _ticket(),
                updatedTicket: KitchenTicketAction.startFiring.applyTo(
                  _ticket(),
                ),
              ),
              onUndo: () => events.add('undo'),
              onDismissed: () => events.add('dismiss'),
            ),
          ),
        ),
      );

      expect(find.text('Start firing applied to Table 12.'), findsOneWidget);
      expect(find.byTooltip('Undo last ticket action'), findsOneWidget);
      expect(find.byTooltip('Dismiss ticket action feedback'), findsOneWidget);

      await tester.tap(find.byTooltip('Undo last ticket action'));
      await tester.pump();
      await tester.tap(find.byTooltip('Dismiss ticket action feedback'));
      await tester.pump();

      expect(events, ['undo', 'dismiss']);
    },
  );

  testWidgets('ticket action feedback banner renders unavailable outcomes', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: KitchenTicketActionFeedbackBanner(
            result: KitchenTicketActionResult(
              action: KitchenTicketAction.serve,
              outcome: KitchenTicketActionOutcome.unavailable,
              ticketId: 'ticket-1',
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Serve is not available for this ticket.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Undo last ticket action'), findsNothing);
  });
}

KitchenTicket _ticket() {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: DateTime(2026, 6, 9, 18, 30),
    stage: KitchenTicketStage.queued,
    items: const [
      KitchenTicketItem(
        menuItemId: 'rib',
        name: 'Short Rib Rendang',
        quantity: 2,
      ),
    ],
  );
}
