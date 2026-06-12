import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_payment_schedule.dart';

void main() {
  test('buildBillingPaymentSchedule creates a single due-date schedule', () {
    final schedule = buildBillingPaymentSchedule(
      total: 900,
      issueDate: DateTime(2026, 6, 10),
      preferences: const BillingTenantPreferences(paymentTermsDays: 14),
    );

    expect(schedule.strategy, BillingPaymentScheduleStrategy.singleDueDate);
    expect(schedule.paymentCount, 1);
    expect(schedule.items.single.amount, 900);
    expect(schedule.items.single.amountRatio, 1);
    expect(schedule.items.single.dueDate, DateTime(2026, 6, 24));
  });

  test('buildBillingPaymentSchedule splits totals into installments', () {
    final schedule = buildBillingPaymentSchedule(
      total: 1200,
      issueDate: DateTime(2026, 6, 10),
      preferences: const BillingTenantPreferences(paymentTermsDays: 10),
      options: BillingPaymentScheduleOptions.splitEqual(
        installments: 3,
        intervalDays: 15,
      ),
    );

    expect(schedule.strategy, BillingPaymentScheduleStrategy.splitEqual);
    expect(schedule.paymentCount, 3);
    expect(schedule.items.map((item) => item.amount), [400, 400, 400]);
    expect(schedule.items.map((item) => item.dueDate), [
      DateTime(2026, 6, 20),
      DateTime(2026, 7, 5),
      DateTime(2026, 7, 20),
    ]);
    expect(schedule.isBalanced(), isTrue);
  });

  test('buildBillingPaymentSchedule creates deposit and balance schedules', () {
    final schedule = buildBillingPaymentSchedule(
      total: 1000,
      issueDate: DateTime(2026, 6, 10),
      preferences: const BillingTenantPreferences(paymentTermsDays: 30),
      options: BillingPaymentScheduleOptions.upfrontAndBalance(
        upfrontRatio: 0.35,
      ),
    );

    expect(schedule.strategy, BillingPaymentScheduleStrategy.upfrontAndBalance);
    expect(schedule.items.map((item) => item.id), ['upfront', 'balance']);
    expect(schedule.items.first.amount, 350);
    expect(schedule.items.first.dueDate, DateTime(2026, 6, 10));
    expect(schedule.items.last.amount, 650);
    expect(schedule.items.last.dueDate, DateTime(2026, 7, 10));
  });

  test('buildBillingPaymentSchedule maps milestone schedules', () {
    final schedule = buildBillingPaymentSchedule(
      total: 5000,
      issueDate: DateTime(2026, 6, 10),
      options: BillingPaymentScheduleOptions.milestones(
        milestones: [
          BillingPaymentScheduleMilestone(
            id: 'mobilization',
            label: 'Mobilization',
            amountRatio: 0.2,
            dueAfterDays: 0,
          ),
          BillingPaymentScheduleMilestone(
            id: 'handover',
            label: 'Handover',
            amountRatio: 0.8,
            dueAfterDays: 45,
            attributes: const {'phase': 'closeout'},
          ),
        ],
      ),
    );

    expect(schedule.strategy, BillingPaymentScheduleStrategy.milestones);
    expect(schedule.paymentCount, 2);
    expect(schedule.items.first.amount, 1000);
    expect(schedule.items.last.amount, 4000);
    expect(schedule.items.last.dueDate, DateTime(2026, 7, 25));
    expect(schedule.items.last.attributes, {'phase': 'closeout'});
  });

  test('buildBillingPaymentSchedule rejects invalid schedule options', () {
    expect(
      () => buildBillingPaymentSchedule(
        total: 1000,
        issueDate: DateTime(2026, 6, 10),
        options: BillingPaymentScheduleOptions.splitEqual(installments: 0),
      ),
      throwsStateError,
    );
    expect(
      () => buildBillingPaymentSchedule(
        total: 1000,
        issueDate: DateTime(2026, 6, 10),
        options: BillingPaymentScheduleOptions.upfrontAndBalance(
          upfrontRatio: 1,
        ),
      ),
      throwsStateError,
    );
    expect(
      () => buildBillingPaymentSchedule(
        total: 1000,
        issueDate: DateTime(2026, 6, 10),
        options: BillingPaymentScheduleOptions.milestones(
          milestones: [
            BillingPaymentScheduleMilestone(
              id: 'phase-1',
              label: 'Phase 1',
              amountRatio: 0.4,
              dueAfterDays: 0,
            ),
          ],
        ),
      ),
      throwsStateError,
    );
  });
}
