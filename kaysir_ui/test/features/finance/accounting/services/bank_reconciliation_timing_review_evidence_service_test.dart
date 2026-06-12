import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_resolution.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_register.dart';
import 'package:kaysir/features/finance/accounting/models/bank_reconciliation_timing_review.dart';
import 'package:kaysir/features/finance/accounting/services/bank_reconciliation_timing_review_evidence_service.dart';

void main() {
  group('BankReconciliationTimingReviewEvidenceService', () {
    const service = BankReconciliationTimingReviewEvidenceService();

    test('builds a compact timing source label with review evidence', () {
      final label = service.sourceLabel(
        item: _timingItem(),
        review: BankReconciliationTimingReview(
          reference: 'PAY-001',
          status: BankReconciliationTimingReviewStatus.cleared,
          owner: 'Controller',
          note: 'Cleared on Feb bank statement.',
          reviewedAt: DateTime(2026, 2, 3, 10),
        ),
      );

      expect(
        label,
        'Stale timing difference / Escalate / Clear by Jan 29, 2026 / '
        'Overdue / Review Cleared / Owner Controller / '
        'Reviewed Feb 3, 2026 / Cleared on Feb bank statement.',
      );
    });

    test('uses open review evidence when a timing item has no review', () {
      final label = service.sourceLabel(item: _timingItem());

      expect(label, contains('Review Open'));
      expect(label, contains('Owner Unassigned'));
      expect(label, contains('No note'));
    });

    test('formats coverage and gap values for report pack metrics', () {
      final summary = service.summarize(
        items: [_timingItem()],
        reviews: {
          'PAY-001': BankReconciliationTimingReview(
            reference: 'PAY-001',
            status: BankReconciliationTimingReviewStatus.inReview,
            owner: '',
            note: 'Waiting for next bank statement.',
            reviewedAt: DateTime(2026, 2, 1),
          ),
        },
      );

      expect(service.coverageValue(summary), '1/1 documented / 0/1 resolved');
      expect(
        service.gapValue(summary),
        '0 unreviewed / 1 owner gaps / 1 overdue unresolved',
      );
    });
  });
}

BankReconciliationTimingRegisterItem _timingItem() {
  return BankReconciliationTimingRegisterItem(
    reference: 'PAY-001',
    date: DateTime(2025, 12, 30),
    description: 'Outstanding payment',
    amount: -300,
    ageDays: 32,
    clearByDate: DateTime(2026, 1, 29),
    bucket: BankReconciliationTimingBucket.stale,
    type: BankReconciliationResolutionType.outstandingPayment,
    clearanceStatus: BankReconciliationTimingClearanceStatus.escalate,
    suggestedAction: 'Investigate stale payment.',
  );
}
