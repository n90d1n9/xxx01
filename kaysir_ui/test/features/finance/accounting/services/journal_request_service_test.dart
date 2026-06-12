import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/accounting_account.dart';
import 'package:kaysir/features/finance/accounting/accounting_core/models/journal_entry.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/models/journal_request_form.dart';
import 'package:kaysir/features/finance/accounting/services/journal_request_service.dart';

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

  test('creates a pending approval request from balanced form input', () {
    final service = JournalRequestService(
      now: () => DateTime(2026, 6, 11, 9),
      nextId: () => 'fixed',
    );

    final request = service.createApprovalRequest(
      const JournalRequestInput(
        reference: 'JE-NEW-001',
        description: 'Petty cash correction',
        source: JournalSource.manualAdjustment,
        preparerName: 'Accounting staff',
        reviewerName: 'Controller',
        lines: [
          JournalRequestLineInput(
            accountId: 'expense',
            side: JournalSide.debit,
            amount: 1000000,
            memo: 'Correction',
          ),
          JournalRequestLineInput(
            accountId: 'cash',
            side: JournalSide.credit,
            amount: 1000000,
            memo: 'Correction',
          ),
        ],
      ),
      chart,
    );

    expect(request.id, 'approval-fixed');
    expect(request.draft.id, 'je-fixed');
    expect(request.status, JournalApprovalStatus.pendingReview);
    expect(request.draft.lines.first.accountName, 'Rent Expense');
    expect(request.dueAt, DateTime(2026, 6, 12, 9));
    expect(
      request.auditTrail.single.action,
      JournalApprovalAuditAction.submitted,
    );
    expect(request.auditTrail.single.actorName, 'Accounting staff');
  });

  test('blocks unbalanced and material requests without evidence', () {
    final service = JournalRequestService(
      now: () => DateTime(2026, 6, 11, 9),
      nextId: () => 'fixed',
    );

    final validation = service.validate(
      const JournalRequestInput(
        reference: 'JE-NEW-002',
        description: 'Large accrual',
        source: JournalSource.manualAdjustment,
        preparerName: 'Controller',
        reviewerName: 'Controller',
        lines: [
          JournalRequestLineInput(
            accountId: 'expense',
            side: JournalSide.debit,
            amount: 50000000,
          ),
          JournalRequestLineInput(
            accountId: 'cash',
            side: JournalSide.credit,
            amount: 40000000,
          ),
        ],
      ),
      chart,
    );
    final messages = validation.issues.map((issue) => issue.message);

    expect(validation.isValid, isFalse);
    expect(messages, contains('Reviewer must be different from preparer.'));
    expect(messages, contains('Debits and credits must balance.'));
    expect(
      messages,
      contains('Evidence reference is required for this journal.'),
    );
  });
}
