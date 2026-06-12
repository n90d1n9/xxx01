import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('service alert summary ranks active ticket alerts', () {
    final summary = KitchenServiceAlertSummary.fromQueue(_testQueue());

    expect(summary.hasAlerts, isTrue);
    expect(summary.alertCount, 3);
    expect(summary.criticalAlertCount, 1);
    expect(summary.ticketCount, 2);
    expect(summary.serviceStatus, FnbServiceStatus.critical);
    expect(summary.actionableAlertCount, 3);
    expect(summary.snoozedAlertCount, 0);
    expect(summary.resolvedAlertCount, 0);
    expect(summary.actionableAlertCountLabel, '3 actionable');
    expect(
      summary.coreSummary.sourceCountLabel(singular: 'ticket'),
      '2 tickets',
    );
    expect(summary.alertCountLabel, '3 alerts');
    expect(summary.criticalAlertLabel, '1 critical');
    expect(summary.ticketCountLabel, '2 tickets');
    expect(summary.topEntry?.ticket.id, 'late-grill');
    expect(summary.topEntry?.signal.subtitleLabel, 'Grill - Table 12');
    expect(summary.topEntry?.titleLabel, 'Allergy: Peanut allergy');
    expect(summary.entries.map((entry) => entry.titleLabel), [
      'Allergy: Peanut allergy',
      'Dietary: No shellfish',
      'Preference: Low sugar',
    ]);
  });

  test('service alert summary scopes alerts by station', () {
    final summary = KitchenServiceAlertSummary.fromQueue(
      _testQueue(),
      stationId: 'bar',
    );

    expect(summary.alertCount, 1);
    expect(summary.criticalAlertCount, 0);
    expect(summary.ticketCount, 1);
    expect(summary.serviceStatus, FnbServiceStatus.busy);
    expect(summary.topEntry?.ticket.id, 'bar-ready');
    expect(summary.topEntry?.titleLabel, 'Preference: Low sugar');
  });

  test('service alert summary exposes ticket lifecycle state', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final ticket = _testQueue().openTickets.first;
    final snoozed = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.snooze,
      at: now,
      snoozeDuration: const Duration(minutes: 15),
    );
    final resolved = const FnbServiceAlertLifecycle().applyAction(
      FnbServiceAlertLifecycleAction.resolve,
      at: now,
    );
    final summary = KitchenServiceAlertSummary(
      now: now,
      entries: [
        KitchenServiceAlertEntry.fromTicket(
          ticket: ticket,
          alert: const FnbServiceAlert(
            type: FnbServiceAlertType.allergy,
            label: 'Peanut allergy',
            critical: true,
          ),
          now: now,
        ),
        KitchenServiceAlertEntry.fromTicket(
          ticket: ticket,
          alert: const FnbServiceAlert(
            type: FnbServiceAlertType.preference,
            label: 'Low sugar',
          ),
          now: now,
          lifecycle: snoozed,
        ),
        KitchenServiceAlertEntry.fromTicket(
          ticket: ticket,
          alert: const FnbServiceAlert(
            type: FnbServiceAlertType.service,
            label: 'Already verified',
          ),
          now: now,
          lifecycle: resolved,
        ),
      ],
    );

    expect(summary.alertCount, 3);
    expect(summary.actionableAlertCount, 1);
    expect(summary.snoozedAlertCount, 1);
    expect(summary.resolvedAlertCount, 1);
    expect(summary.actionableEntries.map((entry) => entry.titleLabel), [
      'Allergy: Peanut allergy',
    ]);
    expect(summary.entries.last.lifecycle.isResolved, isTrue);
  });
}

KitchenTicketQueue _testQueue() {
  final now = DateTime(2026, 6, 10, 18, 30);

  return KitchenTicketQueue(
    now: now,
    tickets: [
      KitchenTicket(
        id: 'late-grill',
        orderId: 'order-1',
        stationId: 'grill',
        stationName: 'Grill',
        customerLabel: 'Table 12',
        dueAt: now.subtract(const Duration(minutes: 3)),
        stage: KitchenTicketStage.firing,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.dietary,
              label: 'No shellfish',
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              description: 'Use clean utensils.',
              critical: true,
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'rib',
            name: 'Short Rib Rendang',
            quantity: 1,
          ),
        ],
      ),
      KitchenTicket(
        id: 'bar-ready',
        orderId: 'order-2',
        stationId: 'bar',
        stationName: 'Bar',
        customerLabel: 'Table 4',
        dueAt: now.add(const Duration(minutes: 2)),
        stage: KitchenTicketStage.ready,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.preference,
              label: 'Low sugar',
            ),
          ],
        ),
        items: const [
          KitchenTicketItem(
            menuItemId: 'spritz',
            name: 'Pandan Spritz',
            quantity: 2,
          ),
        ],
      ),
      KitchenTicket(
        id: 'served-ticket',
        orderId: 'order-3',
        stationId: 'pass',
        stationName: 'Pass',
        customerLabel: 'Counter',
        dueAt: now.subtract(const Duration(minutes: 8)),
        stage: KitchenTicketStage.served,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.service,
              label: 'Already closed',
            ),
          ],
        ),
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
