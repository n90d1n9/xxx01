import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('handoff audit entry summarizes archived verification records', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final entry = KitchenHandoffAuditEntry.fromTicket(
      ticket: _ticket(now: now, stage: KitchenTicketStage.served),
      archivedAt: now.add(const Duration(minutes: 2)),
      records: [
        KitchenHandoffVerificationRecord.fromOperator(
          stepId: 'service-alerts',
          verifiedAt: now,
          operatorContext: const KitchenOperatorContext(
            id: 'staff-7',
            displayName: 'Dimas',
            roleLabel: 'Expo lead',
          ),
        ),
        KitchenHandoffVerificationRecord.fromOperator(
          stepId: 'service-notes',
          verifiedAt: now.add(const Duration(minutes: 1)),
          operatorContext: const KitchenOperatorContext(
            id: 'staff-8',
            displayName: 'Ayu',
            roleLabel: 'Runner',
          ),
        ),
      ],
    );

    expect(entry.ticketId, 'ticket-1');
    expect(entry.closedStage, KitchenTicketStage.served);
    expect(entry.verifiedStepCount, 2);
    expect(entry.verifierLabels, ['Dimas', 'Ayu']);
    expect(entry.checkCountLabel, '2 checks verified');
    expect(entry.verifierSummaryLabel, 'Dimas + 1');
    expect(entry.summaryLabel, '2 checks verified by Dimas + 1');
    expect(entry.archivedAtClockLabel, '18:32');
    expect(entry.closedLabel, 'Served at 18:32');
  });
}

KitchenTicket _ticket({
  required DateTime now,
  required KitchenTicketStage stage,
}) {
  return KitchenTicket(
    id: 'ticket-1',
    orderId: 'order-1',
    stationId: 'bar',
    stationName: 'Bar',
    customerLabel: 'Table 4',
    dueAt: now,
    stage: stage,
    items: const [
      KitchenTicketItem(
        menuItemId: 'spritz',
        name: 'Pandan Spritz',
        quantity: 2,
      ),
    ],
  );
}
