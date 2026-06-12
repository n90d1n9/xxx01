import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/ledger_posting.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/services/ledger_posting_service.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/services/journal_approval_service.dart';

void main() {
  final chart = [
    const AccountingAccount(
      id: 'cash',
      code: '1000',
      name: 'Cash',
      type: AccountingAccountType.asset,
    ),
    const AccountingAccount(
      id: 'expense',
      code: '5000',
      name: 'Rent Expense',
      type: AccountingAccountType.expense,
    ),
  ];

  test('marks a valid pending journal ready for approval', () {
    final result = const JournalApprovalService().evaluate(
      request: _request(amount: 12000000),
      chartOfAccounts: chart,
      postingService: LedgerPostingService(),
    );

    expect(result.canApprove, isTrue);
    expect(result.errorCount, 0);
  });

  test('blocks missing evidence, self review, and non-posting accounts', () {
    final result = const JournalApprovalService().evaluate(
      request: _request(
        amount: 78000000,
        preparerName: 'Controller',
        reviewerName: 'Controller',
        evidenceReference: null,
      ),
      chartOfAccounts: [chart.first.copyWith(allowPosting: false), chart.last],
      postingService: LedgerPostingService(),
    );
    final messages = result.issues.map((issue) => issue.message);

    expect(result.canApprove, isFalse);
    expect(messages, contains('Reviewer must be different from preparer.'));
    expect(
      messages,
      contains('Evidence reference is required for this journal.'),
    );
    expect(messages, contains('Account does not allow direct posting: Cash.'));
  });

  test('blocks journals already posted to the ledger', () {
    final request = _request(status: JournalApprovalStatus.approved);
    final result = const JournalApprovalService().evaluate(
      request: request,
      chartOfAccounts: chart,
      postingService: LedgerPostingService(),
      postedLedger: [
        LedgerPosting(
          id: 'posting-1',
          journalId: request.draft.id,
          entryDate: request.draft.date,
          postedAt: DateTime(2026, 6, 11),
          reference: request.draft.reference,
          description: request.draft.description,
          source: request.draft.source,
          lines: const [],
        ),
      ],
    );

    expect(result.canPost, isFalse);
    expect(
      result.issues.map((issue) => issue.message),
      contains('Journal was already posted to the ledger.'),
    );
  });

  test('blocks approval and posting inside closed periods', () {
    final result = const JournalApprovalService().evaluate(
      request: _request(status: JournalApprovalStatus.approved),
      chartOfAccounts: chart,
      postingService: LedgerPostingService(),
      periodCloseRecords: [
        FinancialPeriodCloseRecord(
          periodKey: '2026-06',
          periodLabel: 'Jun 2026',
          periodStart: DateTime(2026, 6, 1),
          periodEnd: DateTime(2026, 6, 30),
          status: FinancialPeriodCloseStatus.closed,
          closedAt: DateTime(2026, 7, 1),
          closedBy: 'Controller',
          reopenedAt: null,
          reopenedBy: null,
          reopenReason: null,
          checklistReadinessRatio: 1,
          blockerCount: 0,
          reportGeneratedAt: DateTime(2026, 7, 1),
        ),
      ],
    );

    expect(result.canPost, isFalse);
    expect(
      result.issues.map((issue) => issue.message),
      contains(
        'Journal date is inside closed period Jun 2026. '
        'Reopen the period before approval or posting.',
      ),
    );
  });
}

JournalApprovalRequest _request({
  double amount = 12000000,
  String preparerName = 'Accounting staff',
  String reviewerName = 'Controller',
  String? evidenceReference = 'AP-001',
  JournalApprovalStatus status = JournalApprovalStatus.pendingReview,
}) {
  return JournalApprovalRequest(
    id: 'approval-1',
    draft: JournalDraft(
      id: 'je-1',
      date: DateTime(2026, 6, 10),
      reference: 'JE-001',
      description: 'Accrue rent',
      source: JournalSource.manualAdjustment,
      lines: [
        JournalLineDraft(
          accountId: 'expense',
          accountName: 'Rent Expense',
          side: JournalSide.debit,
          amount: amount,
          memo: 'Rent accrual',
        ),
        JournalLineDraft(
          accountId: 'cash',
          accountName: 'Cash',
          side: JournalSide.credit,
          amount: amount,
          memo: 'Rent accrual',
        ),
      ],
    ),
    preparerName: preparerName,
    reviewerName: reviewerName,
    status: status,
    submittedAt: DateTime(2026, 6, 10),
    dueAt: DateTime(2026, 6, 11),
    evidenceReference: evidenceReference,
  );
}
