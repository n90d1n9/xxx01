import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('handoff readiness prioritizes critical service alerts', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final readiness = KitchenHandoffReadiness(
      ticket: _ticket(
        now: now,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.dietary,
              label: 'No shellfish',
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              critical: true,
            ),
          ],
        ),
      ),
      now: now,
    );

    expect(readiness.alertCount, 2);
    expect(readiness.criticalAlertCount, 1);
    expect(readiness.needsAttention, isTrue);
    expect(readiness.serviceStatus, FnbServiceStatus.critical);
    expect(readiness.primaryLabel, 'Verify 1 critical alert');
    expect(readiness.secondaryLabel, '2 service alerts - 4m');
  });

  test('handoff readiness reports service notes and clear handoffs', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final noteReadiness = KitchenHandoffReadiness(
      ticket: _ticket(now: now, notes: 'Confirm birthday candle.'),
      now: now,
    );
    final clearReadiness = KitchenHandoffReadiness(
      ticket: _ticket(now: now),
      now: now,
    );

    expect(noteReadiness.needsAttention, isTrue);
    expect(noteReadiness.serviceStatus, FnbServiceStatus.busy);
    expect(noteReadiness.primaryLabel, 'Review service note');
    expect(noteReadiness.secondaryLabel, 'service note - 4m');
    expect(clearReadiness.needsAttention, isFalse);
    expect(clearReadiness.serviceStatus, FnbServiceStatus.calm);
    expect(clearReadiness.primaryLabel, 'Ready to handoff');
    expect(clearReadiness.secondaryLabel, '4m');
  });
}

KitchenTicket _ticket({
  required DateTime now,
  FnbServiceContext? serviceContext,
  String? notes,
}) {
  return KitchenTicket(
    id: 'ready-ticket',
    orderId: 'order-1',
    stationId: 'grill',
    stationName: 'Grill',
    customerLabel: 'Table 12',
    dueAt: now.add(const Duration(minutes: 4)),
    stage: KitchenTicketStage.ready,
    serviceContext: serviceContext,
    notes: notes,
    items: const [
      KitchenTicketItem(
        menuItemId: 'rib',
        name: 'Short Rib Rendang',
        quantity: 1,
      ),
    ],
  );
}
