import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';

void main() {
  test('summary counts review coverage, owners, and overdue exposure', () {
    final items = [
      _timingItem(reference: 'OVD-OPEN', ageDays: 40, clearByDays: 35),
      _timingItem(reference: 'IN-REVIEW', ageDays: 12, clearByDays: 18),
      _timingItem(reference: 'CLEARED', ageDays: 8, clearByDays: 20),
      _timingItem(reference: 'DEFERRED', ageDays: 4, clearByDays: 20),
    ];

    final summary = BankReconciliationTimingReviewSummary.fromItems(
      items: items,
      reviews: {
        'IN-REVIEW': BankReconciliationTimingReview(
          reference: 'IN-REVIEW',
          status: BankReconciliationTimingReviewStatus.inReview,
          owner: 'Controller',
          note: 'Waiting for next bank statement',
          reviewedAt: DateTime(2026, 2, 1),
        ),
        'CLEARED': BankReconciliationTimingReview(
          reference: 'CLEARED',
          status: BankReconciliationTimingReviewStatus.cleared,
          owner: 'Treasury',
          note: 'Cleared in subsequent statement',
          reviewedAt: DateTime(2026, 2, 2),
        ),
        'DEFERRED': BankReconciliationTimingReview(
          reference: 'DEFERRED',
          status: BankReconciliationTimingReviewStatus.deferred,
          owner: '',
          note: 'Vendor confirmation pending',
          reviewedAt: DateTime(2026, 2, 3),
        ),
      },
    );

    expect(summary.itemCount, 4);
    expect(summary.documentedCount, 3);
    expect(summary.openCount, 1);
    expect(summary.inReviewCount, 1);
    expect(summary.clearedCount, 1);
    expect(summary.deferredCount, 1);
    expect(summary.resolvedCount, 1);
    expect(summary.unresolvedCount, 3);
    expect(summary.unresolvedOverdueCount, 1);
    expect(summary.needsOwnerCount, 1);
    expect(summary.coverageLabel, '3/4');
    expect(summary.nextActionLabel, 'Resolve 1 overdue review(s)');
  });
}

BankReconciliationTimingRegisterItem _timingItem({
  required String reference,
  required int ageDays,
  required int clearByDays,
}) {
  final date = DateTime(2026, 1, 1);

  return BankReconciliationTimingRegisterItem(
    reference: reference,
    date: date,
    description: 'Timing difference $reference',
    amount: 100,
    ageDays: ageDays,
    clearByDate: date.add(Duration(days: clearByDays)),
    bucket: BankReconciliationTimingBucket.watch,
    type: BankReconciliationResolutionType.depositInTransit,
    clearanceStatus: BankReconciliationTimingClearanceStatus.monitor,
    suggestedAction: 'Review clearing evidence',
  );
}
