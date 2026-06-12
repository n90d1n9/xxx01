import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_timing_register_service.dart';

void main() {
  group('BankReconciliationTimingRegisterService', () {
    const service = BankReconciliationTimingRegisterService();

    test('builds item-level timing register rows by aging bucket', () {
      final register = service.build(
        resolutionPlan: BankReconciliationResolutionPlan(
          actions: [
            _action(
              reference: 'DEP-001',
              type: BankReconciliationResolutionType.depositInTransit,
              amount: 100,
              date: DateTime(2026, 1, 29),
            ),
            _action(
              reference: 'PAY-001',
              type: BankReconciliationResolutionType.outstandingPayment,
              amount: -200,
              date: DateTime(2026, 1, 5),
            ),
            _action(
              reference: 'PAY-002',
              type: BankReconciliationResolutionType.outstandingPayment,
              amount: -300,
              date: DateTime(2025, 12, 30),
            ),
            _action(
              reference: 'FEE-001',
              type: BankReconciliationResolutionType.bankFee,
              amount: -50,
              date: DateTime(2026, 1, 31),
              suggestsJournal: true,
            ),
          ],
        ),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(register.map((item) => item.reference), [
        'PAY-002',
        'PAY-001',
        'DEP-001',
      ]);
      expect(register[0].bucket, BankReconciliationTimingBucket.stale);
      expect(register[0].ageDays, 32);
      expect(
        register[0].clearanceStatus,
        BankReconciliationTimingClearanceStatus.escalate,
      );
      expect(register[0].typeLabel, 'Outstanding payment');
      expect(register[0].clearByDate, DateTime(2026, 1, 29));
      expect(register[0].deadlineStatusLabel, 'Overdue');
      expect(register[0].daysUntilClearByLabel, 'Overdue');
      expect(register[1].bucket, BankReconciliationTimingBucket.watch);
      expect(
        register[1].clearanceStatus,
        BankReconciliationTimingClearanceStatus.monitor,
      );
      expect(register[1].deadlineStatusLabel, 'Due soon');
      expect(register[1].daysUntilClearByLabel, '4d left');
      expect(register[2].bucket, BankReconciliationTimingBucket.current);
      expect(register[2].typeLabel, 'Deposit in transit');
      expect(register[2].clearanceStatusLabel, 'Open');
      expect(register[2].deadlineStatusLabel, 'On track');

      final summary = BankReconciliationTimingRegisterSummary.fromItems(
        register,
      );
      expect(summary.itemCount, 3);
      expect(summary.depositCount, 1);
      expect(summary.outstandingPaymentCount, 2);
      expect(summary.staleCount, 1);
      expect(summary.overdueCount, 1);
      expect(summary.dueSoonCount, 1);
      expect(summary.deadlineRiskCount, 2);
      expect(summary.hasDeadlineRisk, isTrue);
      expect(summary.nextDeadlineItem?.reference, 'PAY-002');
      expect(summary.nextDeadlineItem?.clearByDate, DateTime(2026, 1, 29));
      expect(summary.oldestAgeDays, 32);
      expect(summary.netAmount, -400);
      expect(summary.depositAmount, 100);
      expect(summary.outstandingPaymentAmount, -500);
      expect(summary.absoluteOutstandingPaymentAmount, 500);
      expect(summary.staleExposureAmount, 300);
      expect(summary.oldestAgeLabel, '32d');
      expect(register[0].matchesSearch('pay-002'), isTrue);
      expect(register[0].matchesSearch('outstanding'), isTrue);
      expect(register[0].matchesSearch('\$300.00'), isTrue);
      expect(register[0].matchesSearch('overdue'), isTrue);
      expect(register[0].matchesSearch('deposit'), isFalse);

      final amountAscending = const BankReconciliationTimingRegisterSort(
        field: BankReconciliationTimingRegisterSortField.amount,
        ascending: true,
      ).apply(register);
      expect(amountAscending.map((item) => item.reference), [
        'DEP-001',
        'PAY-001',
        'PAY-002',
      ]);

      final ageDescending = const BankReconciliationTimingRegisterSort(
        field: BankReconciliationTimingRegisterSortField.age,
        ascending: false,
      ).apply(register);
      expect(ageDescending.map((item) => item.reference), [
        'PAY-002',
        'PAY-001',
        'DEP-001',
      ]);

      final clearByAscending = const BankReconciliationTimingRegisterSort(
        field: BankReconciliationTimingRegisterSortField.clearBy,
        ascending: true,
      ).apply(register);
      expect(clearByAscending.map((item) => item.reference), [
        'PAY-002',
        'PAY-001',
        'DEP-001',
      ]);

      final deadlineAscending = const BankReconciliationTimingRegisterSort(
        field: BankReconciliationTimingRegisterSortField.deadline,
        ascending: true,
      ).apply(register);
      expect(deadlineAscending.map((item) => item.reference), [
        'PAY-002',
        'PAY-001',
        'DEP-001',
      ]);

      final deadlineDescending = const BankReconciliationTimingRegisterSort(
        field: BankReconciliationTimingRegisterSortField.deadline,
        ascending: false,
      ).apply(register);
      expect(deadlineDescending.map((item) => item.reference), [
        'DEP-001',
        'PAY-001',
        'PAY-002',
      ]);
    });

    test('clamps future-dated timing differences to current open items', () {
      final register = service.build(
        resolutionPlan: BankReconciliationResolutionPlan(
          actions: [
            _action(
              reference: 'DEP-002',
              type: BankReconciliationResolutionType.depositInTransit,
              amount: 100,
              date: DateTime(2026, 2, 2),
            ),
          ],
        ),
        asOfDate: DateTime(2026, 1, 31),
      );

      expect(register.single.ageDays, 0);
      expect(register.single.clearByDate, DateTime(2026, 3, 4));
      expect(register.single.deadlineStatusLabel, 'On track');
      expect(register.single.daysUntilClearByLabel, '30d left');
      expect(register.single.bucketLabel, 'Current');
      expect(register.single.clearanceStatusLabel, 'Open');
    });
  });
}

BankReconciliationResolutionAction _action({
  required String reference,
  required BankReconciliationResolutionType type,
  required double amount,
  required DateTime date,
  bool suggestsJournal = false,
}) {
  return BankReconciliationResolutionAction(
    type: type,
    title: type.label,
    description: 'Timing difference $reference',
    suggestedAction: 'Confirm $reference clears on a later bank statement.',
    amount: amount,
    date: date,
    reference: reference,
    suggestsJournal: suggestsJournal,
  );
}
