import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  testWidgets('ticket card renders production details and reports taps', (
    tester,
  ) async {
    final queue = _testQueue();
    final ticket = queue.priorityTickets.first;
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketCard(
            ticket: ticket,
            now: queue.now,
            selected: true,
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Table 12'), findsOneWidget);
    expect(find.text('Grill - order-1'), findsOneWidget);
    expect(find.text('Firing'), findsOneWidget);
    expect(find.text('2m late'), findsOneWidget);
    expect(find.text('3 items'), findsOneWidget);
    expect(find.text('4 guests'), findsOneWidget);
    expect(find.text('18:15 reservation'), findsOneWidget);
    expect(find.text('VIP'), findsOneWidget);
    expect(find.text('Allergy: Peanut allergy +1'), findsOneWidget);
    expect(find.text('Short Rib Rendang'), findsOneWidget);
    expect(find.text('Nasi Ulam'), findsOneWidget);
    expect(find.text('No peanuts'), findsOneWidget);
    expect(find.text('Fire together.'), findsOneWidget);

    await tester.tap(find.text('Table 12'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('ticket queue list renders priority order and selection', (
    tester,
  ) async {
    final selectedIds = <String>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KitchenTicketQueueList(
              queue: _testQueue(),
              selectedTicketId: 'bar-ready',
              onTicketSelected: (ticket) => selectedIds.add(ticket.id),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Grill - order-1'), findsOneWidget);
    expect(find.text('Bar - order-3'), findsOneWidget);
    expect(find.text('Pass - order-2'), findsOneWidget);

    final lateTop = tester.getTopLeft(find.text('Grill - order-1')).dy;
    final readyTop = tester.getTopLeft(find.text('Bar - order-3')).dy;
    final queuedTop = tester.getTopLeft(find.text('Pass - order-2')).dy;

    expect(lateTop, lessThan(readyTop));
    expect(readyTop, lessThan(queuedTop));

    await tester.tap(find.text('Bar - order-3'));
    await tester.pump();

    expect(selectedIds, ['bar-ready']);
  });

  testWidgets('ticket queue list can scope tickets to one station', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketQueueList(queue: _testQueue(), stationId: 'pass'),
        ),
      ),
    );

    expect(find.text('Pass - order-2'), findsOneWidget);
    expect(find.text('Grill - order-1'), findsNothing);
    expect(find.text('Bar - order-3'), findsNothing);
  });

  testWidgets('ticket queue list renders empty state without open tickets', (
    tester,
  ) async {
    final now = DateTime(2026, 6, 9, 18, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenTicketQueueList(
            queue: KitchenTicketQueue(
              now: now,
              tickets: [
                KitchenTicket(
                  id: 'served-ticket',
                  orderId: 'order-9',
                  stationId: 'bar',
                  stationName: 'Bar',
                  customerLabel: 'Table 2',
                  dueAt: now.subtract(const Duration(minutes: 8)),
                  stage: KitchenTicketStage.served,
                  items: const [
                    KitchenTicketItem(
                      menuItemId: 'tea',
                      name: 'Iced Tea',
                      quantity: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('No open kitchen tickets right now.'), findsOneWidget);
  });
}

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 9, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'late-grill',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 2)),
        stage: KitchenTicketStage.firing,
        notes: 'Fire together.',
        serviceContext: FnbServiceContext(
          guestName: 'Siti Rahma',
          partySize: 4,
          reservationTime: DateTime(2026, 6, 9, 18, 15),
          vip: true,
          occasion: 'Anniversary',
          notes: 'Window table',
          alerts: const [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              critical: true,
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.dietary,
              label: 'No shellfish',
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'rib',
            name: 'Short Rib Rendang',
            quantity: 2,
          ),
          KitchenTicketItem(
            menuItemId: 'ulam',
            name: 'Nasi Ulam',
            quantity: 1,
            modifiers: ['No peanuts'],
          ),
        ],
      ),
      KitchenTicket(
        id: 'bar-ready',
        orderId: 'order-3',
        stationId: 'bar',
        stationName: 'Bar',
        customerLabel: 'Table 4',
        dueAt: now.add(const Duration(minutes: 1)),
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
        id: 'pass-ticket',
        orderId: 'order-2',
        stationId: 'pass',
        stationName: 'Pass',
        customerLabel: 'Counter',
        dueAt: now.add(const Duration(minutes: 4)),
        stage: KitchenTicketStage.queued,
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
