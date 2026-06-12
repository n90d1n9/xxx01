import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/services/journal_reversal_service.dart';

void main() {
  test(
    'creates a balanced reversal request by flipping debit and credit sides',
    () {
      final service = JournalReversalService(
        now: () => DateTime(2026, 6, 11, 10),
        nextId: () => 'rev-1',
      );

      final reversal = service.createReversalRequest(
        original: _postedRequest(),
        reversalDate: DateTime(2026, 6, 12),
      );

      expect(reversal.id, 'approval-reversal-rev-1');
      expect(reversal.draft.reference, 'JE-ORIGINAL-REV');
      expect(reversal.draft.date, DateTime(2026, 6, 12));
      expect(reversal.reversalDate, DateTime(2026, 6, 12));
      expect(reversal.status, JournalApprovalStatus.pendingReview);
      expect(reversal.draft.debitTotal, 750000);
      expect(reversal.draft.creditTotal, 750000);
      expect(reversal.draft.lines.first.side, JournalSide.credit);
      expect(reversal.draft.lines.last.side, JournalSide.debit);
      expect(
        reversal.latestAuditEvent?.note,
        'Submitted as reversal for JE-ORIGINAL.',
      );
    },
  );

  test('rejects journals that are not posted or were already reversed', () {
    final service = JournalReversalService(
      now: () => DateTime(2026, 6, 11, 10),
      nextId: () => 'rev-1',
    );

    expect(
      () => service.createReversalRequest(
        original: _postedRequest(status: JournalApprovalStatus.approved),
        reversalDate: DateTime(2026, 6, 12),
      ),
      throwsA(
        isA<JournalReversalException>().having(
          (error) => error.issues,
          'issues',
          contains('Only posted journals can be reversed.'),
        ),
      ),
    );

    expect(
      () => service.createReversalRequest(
        original: _postedRequest(reversalRequestId: 'approval-reversal-rev-0'),
        reversalDate: DateTime(2026, 6, 12),
      ),
      throwsA(
        isA<JournalReversalException>().having(
          (error) => error.issues,
          'issues',
          contains('A reversal request already exists for this journal.'),
        ),
      ),
    );
  });
}

JournalApprovalRequest _postedRequest({
  JournalApprovalStatus status = JournalApprovalStatus.posted,
  String? reversalRequestId,
}) {
  return JournalApprovalRequest(
    id: 'approval-original',
    draft: JournalDraft(
      id: 'je-original',
      date: DateTime(2026, 6, 10),
      reference: 'JE-ORIGINAL',
      description: 'Accrue closing utility expense',
      source: JournalSource.manualAdjustment,
      lines: const [
        JournalLineDraft(
          accountId: 'expense',
          accountName: 'Utility Expense',
          side: JournalSide.debit,
          amount: 750000,
          memo: 'June estimate',
        ),
        JournalLineDraft(
          accountId: 'accrual',
          accountName: 'Accrued Expense',
          side: JournalSide.credit,
          amount: 750000,
          memo: 'June estimate',
        ),
      ],
    ),
    preparerName: 'Accounting staff',
    reviewerName: 'Controller',
    status: status,
    submittedAt: DateTime(2026, 6, 10, 9),
    dueAt: DateTime(2026, 6, 11, 9),
    postedAt:
        status == JournalApprovalStatus.posted
            ? DateTime(2026, 6, 11, 9)
            : null,
    postingId: status == JournalApprovalStatus.posted ? 'posting-1' : null,
    reversalRequestId: reversalRequestId,
  );
}
