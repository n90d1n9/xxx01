import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('dispatch summary ranks ready tickets and counts handoff pressure', () {
    final queue = _testQueue();

    final summary = KitchenDispatchSummary.fromQueue(queue);

    expect(summary.readyTickets.map((ticket) => ticket.id), [
      'late-ready',
      'soon-ready',
    ]);
    expect(summary.productionTickets.map((ticket) => ticket.id), [
      'firing-ticket',
    ]);
    expect(summary.readyCount, 2);
    expect(summary.lateReadyCount, 1);
    expect(summary.productionCount, 1);
    expect(summary.readyItemCount, 3);
    expect(summary.nextReadyTicket?.id, 'late-ready');
    expect(summary.serviceStatus, FnbServiceStatus.critical);
    expect(summary.readyCountLabel, '2 ready');
    expect(summary.lateReadyLabel, '1 late');
    expect(summary.productionCountLabel, '1 in production');
    expect(summary.readyItemCountLabel, '3 items');
  });

  test('dispatch summary can scope tickets to one station', () {
    final summary = KitchenDispatchSummary.fromQueue(
      _testQueue(),
      stationId: 'bar',
    );

    expect(summary.readyTickets.map((ticket) => ticket.id), ['soon-ready']);
    expect(summary.productionCount, 0);
    expect(summary.serviceStatus, FnbServiceStatus.busy);
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
