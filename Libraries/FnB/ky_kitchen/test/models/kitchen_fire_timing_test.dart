import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('fire timing reports upcoming fire window', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final ticket = _ticket(dueAt: now.add(const Duration(minutes: 20)));

    final timing = KitchenFireTiming(
      ticket: ticket,
      now: now,
      averageFireMinutes: 12,
    );

    expect(timing.fireAt, now.add(const Duration(minutes: 8)));
    expect(timing.minutesUntilFire, 8);
    expect(timing.minutesUntilDue, 20);
    expect(timing.shouldFireNow, isFalse);
    expect(timing.isLateToFire, isFalse);
    expect(timing.serviceStatus, FnbServiceStatus.calm);
    expect(timing.primaryLabel, 'Fire in 8m');
    expect(timing.secondaryLabel, '12m fire window');
  });

  test('fire timing reports due-to-fire and late-to-fire states', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final fireNow = KitchenFireTiming(
      ticket: _ticket(dueAt: now.add(const Duration(minutes: 12))),
      now: now,
      averageFireMinutes: 12,
    );
    final lateToFire = KitchenFireTiming(
      ticket: _ticket(dueAt: now.add(const Duration(minutes: 8))),
      now: now,
      averageFireMinutes: 12,
    );

    expect(fireNow.shouldFireNow, isTrue);
    expect(fireNow.serviceStatus, FnbServiceStatus.busy);
    expect(fireNow.primaryLabel, 'Fire now');
    expect(lateToFire.isLateToFire, isTrue);
    expect(lateToFire.serviceStatus, FnbServiceStatus.critical);
    expect(lateToFire.primaryLabel, '4m late to fire');
  });

  test('fire timing reports production and closed stages', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final firing = KitchenFireTiming(
      ticket: _ticket(
        dueAt: now.add(const Duration(minutes: 8)),
        stage: KitchenTicketStage.firing,
      ),
      now: now,
      averageFireMinutes: 12,
    );
    final served = KitchenFireTiming(
      ticket: _ticket(
        dueAt: now.subtract(const Duration(minutes: 2)),
        stage: KitchenTicketStage.served,
      ),
      now: now,
      averageFireMinutes: 12,
    );

    expect(firing.isInProduction, isTrue);
    expect(firing.serviceStatus, FnbServiceStatus.busy);
    expect(firing.primaryLabel, 'Firing');
    expect(served.serviceStatus, FnbServiceStatus.calm);
    expect(served.primaryLabel, 'Served');
    expect(served.secondaryLabel, 'Closed ticket');
  });
}

KitchenTicket _ticket({
  required DateTime dueAt,
  KitchenTicketStage stage = KitchenTicketStage.queued,
}) {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: dueAt,
    stage: stage,
    items: const [
      KitchenTicketItem(
        menuItemId: 'rib',
        name: 'Short Rib Rendang',
        quantity: 2,
      ),
    ],
  );
}
