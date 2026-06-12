import 'package:flutter_test/flutter_test.dart';
import 'package:ky_kitchen/ky_kitchen.dart';

void main() {
  test('handoff verification plan builds steps for ready ticket context', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final plan = KitchenHandoffVerificationPlan.fromTicket(
      ticket: _ticket(
        now: now,
        serviceContext: const FnbServiceContext(
          notes: 'Window table.',
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.allergy,
              label: 'Peanut allergy',
              critical: true,
            ),
            FnbServiceAlert(
              type: FnbServiceAlertType.preference,
              label: 'Low sugar',
            ),
          ],
        ),
      ),
      now: now,
      verifiedStepIds: const {'critical-alerts'},
    );

    expect(plan.hasSteps, isTrue);
    expect(plan.steps.map((step) => step.id), [
      'critical-alerts',
      'service-alerts',
      'service-notes',
    ]);
    expect(plan.steps.first.label, 'Verify critical alert');
    expect(plan.steps.first.description, 'Allergy: Peanut allergy');
    expect(plan.verifiedRequiredCount, 1);
    expect(plan.pendingRequiredCount, 2);
    expect(plan.isComplete, isFalse);
    expect(plan.blocksServing, isTrue);
    expect(plan.serveBlockReason, kitchenHandoffVerificationBlockReason);
    expect(plan.progressLabel, '1 / 3 verified');
    expect(plan.statusLabel, '2 checks remaining');
  });

  test('handoff verification plan includes audit records', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final record = KitchenHandoffVerificationRecord(
      stepId: 'service-alerts',
      verifiedAt: now,
      verifiedBy: 'Expo',
    );
    final plan = KitchenHandoffVerificationPlan.fromTicket(
      ticket: _ticket(
        now: now,
        serviceContext: const FnbServiceContext(
          alerts: [
            FnbServiceAlert(
              type: FnbServiceAlertType.preference,
              label: 'Low sugar',
            ),
          ],
        ),
      ),
      now: now,
      records: [record],
    );

    expect(plan.verifiedStepIds, {'service-alerts'});
    expect(plan.recordFor('service-alerts'), record);
    expect(record.verifiedAtClockLabel, '18:30');
    expect(record.auditLabel, 'Verified: Expo - 18:30');
    expect(plan.isComplete, isTrue);
  });

  test('handoff verification record can be built from operator context', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final record = KitchenHandoffVerificationRecord.fromOperator(
      stepId: 'service-alerts',
      verifiedAt: now,
      operatorContext: const KitchenOperatorContext(
        id: 'staff-7',
        displayName: 'Dimas',
        roleLabel: 'Expo lead',
      ),
    );

    expect(record.verifiedBy, 'Dimas');
    expect(record.verifiedById, 'staff-7');
    expect(record.verifiedByRole, 'Expo lead');
    expect(record.auditLabel, 'Verified: Dimas - 18:30');
  });

  test('handoff verification plan stays empty for non-ready tickets', () {
    final now = DateTime(2026, 6, 10, 18, 30);
    final plan = KitchenHandoffVerificationPlan.fromTicket(
      ticket: _ticket(now: now, stage: KitchenTicketStage.firing),
      now: now,
    );

    expect(plan.hasSteps, isFalse);
    expect(plan.isComplete, isTrue);
    expect(plan.blocksServing, isFalse);
    expect(plan.serveBlockReason, isNull);
    expect(plan.progressLabel, 'No checks needed');
    expect(plan.statusLabel, 'Ready to serve');
  });
}

KitchenTicket _ticket({
  required DateTime now,
  KitchenTicketStage stage = KitchenTicketStage.ready,
  FnbServiceContext? serviceContext,
}) {
  return KitchenTicket(
    id: 'ready-ticket',
    orderId: 'order-1',
    stationId: 'bar',
    stationName: 'Bar',
    customerLabel: 'Table 4',
    dueAt: now.add(const Duration(minutes: 3)),
    stage: stage,
    serviceContext: serviceContext,
    items: const [
      KitchenTicketItem(
        menuItemId: 'spritz',
        name: 'Pandan Spritz',
        quantity: 2,
      ),
    ],
  );
}
