import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('pacing summary reports delay, next due, and labels', () {
    final queue = _testQueue();

    final summary = KitchenPacingSummary.fromQueue(queue);

    expect(summary.dueTickets.map((ticket) => ticket.id), [
      'late-ready',
      'soon-ready',
      'firing-ticket',
    ]);
    expect(summary.lateTickets.map((ticket) => ticket.id), ['late-ready']);
    expect(summary.activeCount, 3);
    expect(summary.lateCount, 1);
    expect(summary.readyCount, 2);
    expect(summary.averageDelayMinutes, 3);
    expect(summary.nextDueTicket?.id, 'late-ready');
    expect(summary.serviceStatus, FnbServiceStatus.critical);
    expect(summary.statusLabel, 'Behind pace');
    expect(summary.activeCountLabel, '3 active');
    expect(summary.lateCountLabel, '1 late');
    expect(summary.readyCountLabel, '2 ready');
    expect(summary.averageDelayLabel, '3m avg delay');
    expect(summary.nextDueLabel, 'Table 12 - 3m late');
  });

  test('pacing summary scopes to one station', () {
    final summary = KitchenPacingSummary.fromQueue(
      _testQueue(),
      stationId: 'bar',
    );

    expect(summary.dueTickets.map((ticket) => ticket.id), ['soon-ready']);
    expect(summary.activeCount, 1);
    expect(summary.lateCount, 0);
    expect(summary.readyCount, 1);
    expect(summary.averageDelayMinutes, 0);
    expect(summary.serviceStatus, FnbServiceStatus.busy);
    expect(summary.statusLabel, 'On pace');
    expect(summary.averageDelayLabel, 'No delay');
    expect(summary.nextDueLabel, 'Table 4 - 2m');
  });

  test('pacing summary reports clear state without tickets', () {
    final summary = KitchenPacingSummary.fromQueue(
      KitchenTicketQueue(now: DateTime(2026, 6, 10, 18, 30), tickets: const []),
    );

    expect(summary.activeCount, 0);
    expect(summary.nextDueTicket, isNull);
    expect(summary.serviceStatus, FnbServiceStatus.calm);
    expect(summary.statusLabel, 'Clear');
    expect(summary.nextDueLabel, 'No open tickets');
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
