import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/services/journal_posting_trace_service.dart';

void main() {
  test('links posted originals, reversal requests, and ledger postings', () {
    const service = JournalPostingTraceService();
    final original = _request(
      id: 'approval-original',
      journalId: 'je-original',
      reference: 'JE-ORIGINAL',
      status: JournalApprovalStatus.posted,
      postingId: 'posting-original',
      reversalRequestId: 'approval-reversal',
    );
    final reversal = _request(
      id: 'approval-reversal',
      journalId: 'je-reversal',
      reference: 'JE-ORIGINAL-REV',
      status: JournalApprovalStatus.posted,
      postingId: 'posting-reversal',
    );

    final traces = service.buildTraces(
      requests: [original, reversal],
      postedLedger: [
        _posting(
          id: 'posting-original',
          journalId: 'je-original',
          reference: 'JE-ORIGINAL',
        ),
        _posting(
          id: 'posting-reversal',
          journalId: 'je-reversal',
          reference: 'JE-ORIGINAL-REV',
        ),
      ],
    );

    final originalTrace = traces['approval-original']!;
    expect(originalTrace.postingFoundInLedger, isTrue);
    expect(originalTrace.reversalReference, 'JE-ORIGINAL-REV');
    expect(originalTrace.reversalStatus, JournalApprovalStatus.posted);
    expect(originalTrace.reversalPostingFoundInLedger, isTrue);
    expect(originalTrace.isFullyReversed, isTrue);
    expect(originalTrace.netExposure, 0);

    final reversalTrace = traces['approval-reversal']!;
    expect(reversalTrace.originalRequestId, 'approval-original');
    expect(reversalTrace.originalReference, 'JE-ORIGINAL');
  });
}

JournalApprovalRequest _request({
  required String id,
  required String journalId,
  required String reference,
  required JournalApprovalStatus status,
  String? postingId,
  String? reversalRequestId,
}) {
  return JournalApprovalRequest(
    id: id,
    draft: JournalDraft(
      id: journalId,
      date: DateTime(2026, 6, 10),
      reference: reference,
      description: 'Trace test journal',
      source: JournalSource.manualAdjustment,
      lines: const [
        JournalLineDraft(
          accountId: 'expense',
          accountName: 'Expense',
          side: JournalSide.debit,
          amount: 100,
        ),
        JournalLineDraft(
          accountId: 'cash',
          accountName: 'Cash',
          side: JournalSide.credit,
          amount: 100,
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
    postingId: postingId,
    reversalRequestId: reversalRequestId,
  );
}

LedgerPosting _posting({
  required String id,
  required String journalId,
  required String reference,
}) {
  return LedgerPosting(
    id: id,
    journalId: journalId,
    entryDate: DateTime(2026, 6, 10),
    postedAt: DateTime(2026, 6, 11, 10),
    reference: reference,
    description: 'Trace test posting',
    source: JournalSource.manualAdjustment,
    lines: const [],
  );
}
