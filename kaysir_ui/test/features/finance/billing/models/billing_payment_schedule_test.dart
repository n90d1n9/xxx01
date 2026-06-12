import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_payment_schedule.dart';

void main() {
  test('BillingPaymentSchedule validates balanced immutable schedules', () {
    final schedule = BillingPaymentSchedule(
      strategy: BillingPaymentScheduleStrategy.upfrontAndBalance,
      total: 1000,
      items: [
        BillingPaymentScheduleItem(
          id: 'upfront',
          label: 'Upfront',
          amount: 300,
          amountRatio: 0.3,
          dueDate: DateTime(2026, 6, 1),
        ),
        BillingPaymentScheduleItem(
          id: 'balance',
          label: 'Balance',
          amount: 700,
          amountRatio: 0.7,
          dueDate: DateTime(2026, 6, 30),
        ),
      ],
    );

    expect(schedule.validationErrors, isEmpty);
    expect(schedule.isSinglePayment, isFalse);
    expect(schedule.paymentCount, 2);
    expect(schedule.firstDueDate, DateTime(2026, 6, 1));
    expect(schedule.finalDueDate, DateTime(2026, 6, 30));
    expect(schedule.isBalanced(), isTrue);
    expect(
      () => schedule.items.add(schedule.items.first),
      throwsUnsupportedError,
    );
  });

  test('BillingPaymentSchedule reports duplicate and unbalanced items', () {
    final schedule = BillingPaymentSchedule(
      strategy: BillingPaymentScheduleStrategy.splitEqual,
      total: 1000,
      items: [
        BillingPaymentScheduleItem(
          id: 'installment',
          label: 'Installment 1',
          amount: 400,
          amountRatio: 0.4,
          dueDate: DateTime(2026, 6, 30),
        ),
        BillingPaymentScheduleItem(
          id: 'installment',
          label: 'Installment 2',
          amount: 400,
          amountRatio: 0.4,
          dueDate: DateTime(2026, 7, 30),
        ),
      ],
    );

    expect(schedule.validationErrors, [
      'Duplicate payment schedule item installment.',
      'Payment schedule items must match the invoice total.',
    ]);
  });

  test('BillingPaymentSchedule payload keeps schedule items structured', () {
    final schedule = BillingPaymentSchedule(
      strategy: BillingPaymentScheduleStrategy.singleDueDate,
      total: 500,
      items: [
        BillingPaymentScheduleItem(
          id: 'due',
          label: 'Invoice due',
          amount: 500,
          amountRatio: 1,
          dueDate: DateTime(2026, 6, 30),
          attributes: const {'phase': 'handover'},
        ),
      ],
    );

    final payload = schedule.toPayload();

    expect(payload['strategy'], 'singleDueDate');
    expect(payload['paymentCount'], 1);
    expect(payload['scheduledTotal'], 500);
    expect(payload['finalDueDate'], DateTime(2026, 6, 30).toIso8601String());
    final items = payload['items'] as List<Map<String, Object?>>;
    expect(items.single['attributes'], {'phase': 'handover'});
    expect(() => payload['total'] = 0, throwsUnsupportedError);
  });
}
