import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('pacing strip renders timing metrics and selects next ticket', (
    tester,
  ) async {
    final selectedIds = <String>[];
    final queue = _testQueue();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenPacingStrip(
            summary: KitchenPacingSummary.fromQueue(queue),
            onNextTicketSelected: (ticket) => selectedIds.add(ticket.id),
          ),
        ),
      ),
    );

    expect(find.text('Kitchen pacing'), findsOneWidget);
    expect(find.text('Behind pace'), findsOneWidget);
    expect(find.text('Next due: Table 12 - 3m late'), findsOneWidget);
    expect(find.text('3 active'), findsOneWidget);
    expect(find.text('1 late'), findsOneWidget);
    expect(find.text('2 ready'), findsOneWidget);
    expect(find.text('3m avg delay'), findsOneWidget);

    await tester.tap(find.byTooltip('Select Table 12'));
    await tester.pump();

    expect(selectedIds, ['late-ready']);
  });

  testWidgets('pacing strip renders clear state without action', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 10, 18, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenPacingStrip(
            summary: KitchenPacingSummary.fromQueue(
              KitchenTicketQueue(now: now, tickets: const []),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Kitchen pacing'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('Next due: No open tickets'), findsOneWidget);
    expect(find.text('0 active'), findsOneWidget);
    expect(find.text('0 late'), findsOneWidget);
    expect(find.text('0 ready'), findsOneWidget);
    expect(find.text('No delay'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });
}

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 10, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'soon-ready',
        orderId: 'order-2',
        stationId: 'bar',
        stationName: 'Bar',
        customerLabel: 'Table 4',
        dueAt: now.add(const Duration(minutes: 2)),
        stage: KitchenTicketStage.ready,
        items: const [
          KitchenTicketItem(
            menuItemId: 'spritz',
            name: 'Pandan Spritz',
            quantity: 2,
          ),
        ],
      ),
      KitchenTicket(
        id: 'late-ready',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 3)),
        stage: KitchenTicketStage.ready,
        items: const [
          KitchenTicketItem(
            menuItemId: 'rib',
            name: 'Short Rib Rendang',
            quantity: 1,
          ),
        ],
      ),
      KitchenTicket(
        id: 'firing-ticket',
        orderId: 'order-3',
        stationId: 'pass',
        stationName: 'Pass',
        customerLabel: 'Counter',
        dueAt: now.add(const Duration(minutes: 7)),
        stage: KitchenTicketStage.firing,
        items: const [
          KitchenTicketItem(
            menuItemId: 'salad',
            name: 'Herb Garden Salad',
            quantity: 1,
          ),
        ],
      ),
    ],
  );
}
