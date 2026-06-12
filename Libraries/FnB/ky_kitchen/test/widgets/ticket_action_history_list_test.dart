import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('ticket action history list renders recent activity', (
    tester,
  ) async {
    var cleared = false;
    final filterChanges = <KitchenTicketActionHistoryFilter>[];
    final history = KitchenTicketActionHistory(
      results: [
        _result(
          action: KitchenTicketAction.startFiring,
          outcome: KitchenTicketActionOutcome.applied,
          updatedStage: KitchenTicketStage.firing,
        ),
        _result(
          action: KitchenTicketAction.serve,
          outcome: KitchenTicketActionOutcome.unavailable,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketActionHistoryList(
            history: history,
            filter: KitchenTicketActionHistoryFilter.all,
            ticketId: 'ticket-1',
            onFilterChanged: filterChanges.add,
            onCleared: () => cleared = true,
          ),
        ),
      ),
    );

    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('All 2'), findsOneWidget);
    expect(find.text('Applied 1'), findsOneWidget);
    expect(find.text('Issues 1'), findsOneWidget);
    expect(find.text('Ticket 2'), findsOneWidget);
    expect(find.text('Activity groups'), findsOneWidget);
    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('2 actions - 1 issue'), findsOneWidget);
    expect(find.text('Start firing applied to Table 12.'), findsOneWidget);
    expect(
      find.text('Serve is not available for this ticket.'),
      findsOneWidget,
    );
    expect(find.text('18:30 - Queued to Firing - ticket-1'), findsOneWidget);

    await tester.tap(find.text('Issues 1'));
    await tester.pump();

    expect(filterChanges, [KitchenTicketActionHistoryFilter.issues]);

    await tester.tap(find.byTooltip('Clear kitchen activity'));
    await tester.pump();

    expect(cleared, isTrue);
  });

  testWidgets('ticket action history list renders empty state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketActionHistoryList(
            history: KitchenTicketActionHistory(),
          ),
        ),
      ),
    );

    expect(find.text('No recent kitchen activity.'), findsOneWidget);
  });

  testWidgets('ticket action history list renders filtered empty state', (
    tester,
  ) async {
    final history = KitchenTicketActionHistory(
      results: [
        _result(
          action: KitchenTicketAction.startFiring,
          outcome: KitchenTicketActionOutcome.applied,
          updatedStage: KitchenTicketStage.firing,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketActionHistoryList(
            history: history,
            filter: KitchenTicketActionHistoryFilter.issues,
            ticketId: 'ticket-1',
          ),
        ),
      ),
    );

    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('Issues 0'), findsOneWidget);
    expect(find.text('No issues activity in this view.'), findsOneWidget);
    expect(find.text('Start firing applied to Table 12.'), findsNothing);
  });
}

KitchenTicketActionResult _result({
  required KitchenTicketAction action,
  required KitchenTicketActionOutcome outcome,
  KitchenTicketStage? updatedStage,
}) {
  final ticket = _ticket();

  return KitchenTicketActionResult(
    action: action,
    outcome: outcome,
    ticketId: ticket.id,
    occurredAt: DateTime(2026, 6, 9, 18, 30),
    previousTicket: ticket,
    updatedTicket: updatedStage == null
        ? null
        : ticket.copyWith(stage: updatedStage),
  );
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
