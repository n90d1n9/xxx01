import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets(
    'activity group list switches between ticket and station groups',
    (tester) async {
      final selectedKeys = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KitchenActivityGroupList(
              grouping: KitchenActivityGrouping(results: _results()),
              onGroupSelected: (group) => selectedKeys.add(group.key),
            ),
          ),
        ),
      );

      expect(find.text('Activity groups'), findsOneWidget);
      expect(find.text('Ticket'), findsOneWidget);
      expect(find.text('Station'), findsOneWidget);
      expect(find.text('Table 12'), findsOneWidget);
      expect(find.text('2 actions - 1 issue'), findsOneWidget);

      await tester.tap(find.text('Table 12'));
      await tester.pump();

      expect(selectedKeys, ['ticket-1']);

      await tester.tap(find.text('Station'));
      await tester.pump();

      expect(find.text('Grill'), findsOneWidget);
      expect(find.text('Table 12'), findsNothing);
    },
  );
}

List<KitchenTicketActionResult> _results() {
  final ticket = _ticket();

  return [
    KitchenTicketActionResult(
      action: KitchenTicketAction.serve,
      outcome: KitchenTicketActionOutcome.unavailable,
      ticketId: ticket.id,
      previousTicket: ticket,
    ),
    KitchenTicketActionResult(
      action: KitchenTicketAction.startFiring,
      outcome: KitchenTicketActionOutcome.applied,
      ticketId: ticket.id,
      previousTicket: ticket,
      updatedTicket: KitchenTicketAction.startFiring.applyTo(ticket),
    ),
  ];
}

KitchenTicket _ticket() {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: DateTime(2026, 6, 10, 18, 30),
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
