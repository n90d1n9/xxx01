import '../accounting_core/models/journal_entry.dart';
import '../models/journal_approval.dart';

/// Starter journal approval queue used before a persisted snapshot exists.
List<JournalApprovalRequest> seedJournalApprovals() {
  final submittedAt = DateTime(2026, 6, 10, 9);
  return [
    JournalApprovalRequest(
      id: 'approval-rent-accrual',
      draft: JournalDraft(
        id: 'je-rent-accrual',
        date: DateTime(2026, 6, 10),
        reference: 'JE-2026-0610-001',
        description: 'Accrue June office rent',
        source: JournalSource.manualAdjustment,
        lines: const [
          JournalLineDraft(
            accountId: '8',
            accountName: 'Rent Expense',
            side: JournalSide.debit,
            amount: 12000000,
            memo: 'June accrual',
          ),
          JournalLineDraft(
            accountId: '4',
            accountName: 'Accounts Payable',
            side: JournalSide.credit,
            amount: 12000000,
            memo: 'Vendor invoice pending',
          ),
        ],
      ),
      preparerName: 'Accounting staff',
      reviewerName: 'Controller',
      status: JournalApprovalStatus.pendingReview,
      submittedAt: submittedAt,
      dueAt: DateTime(2026, 6, 11, 17),
      evidenceReference: 'AP-RENT-2026-06',
      auditTrail: [
        JournalApprovalAuditEvent(
          id: 'approval-rent-accrual-audit-1',
          action: JournalApprovalAuditAction.submitted,
          actorName: 'Accounting staff',
          occurredAt: submittedAt,
          note: 'Submitted with rent invoice evidence.',
        ),
      ],
    ),
    JournalApprovalRequest(
      id: 'approval-interest-income',
      draft: JournalDraft(
        id: 'je-interest-income',
        date: DateTime(2026, 6, 9),
        reference: 'JE-2026-0609-002',
        description: 'Record bank interest from statement',
        source: JournalSource.manualAdjustment,
        lines: const [
          JournalLineDraft(
            accountId: '1',
            accountName: 'Cash',
            side: JournalSide.debit,
            amount: 350000,
            memo: 'Bank statement line',
          ),
          JournalLineDraft(
            accountId: '11',
            accountName: 'Bank Interest Income',
            side: JournalSide.credit,
            amount: 350000,
            memo: 'Monthly bank interest',
          ),
        ],
      ),
      preparerName: 'Accounting staff',
      reviewerName: 'Controller',
      status: JournalApprovalStatus.approved,
      submittedAt: DateTime(2026, 6, 9, 14),
      dueAt: DateTime(2026, 6, 10, 17),
      evidenceReference: 'BANK-BCA-2026-06',
      approvalNote: 'Matched to bank statement.',
      reviewedAt: DateTime(2026, 6, 10, 10),
      auditTrail: [
        JournalApprovalAuditEvent(
          id: 'approval-interest-income-audit-1',
          action: JournalApprovalAuditAction.submitted,
          actorName: 'Accounting staff',
          occurredAt: DateTime(2026, 6, 9, 14),
          note: 'Submitted from bank reconciliation support.',
        ),
        JournalApprovalAuditEvent(
          id: 'approval-interest-income-audit-2',
          action: JournalApprovalAuditAction.approved,
          actorName: 'Controller',
          occurredAt: DateTime(2026, 6, 10, 10),
          note: 'Matched to bank statement.',
        ),
      ],
    ),
    JournalApprovalRequest(
      id: 'approval-close-reclass',
      draft: JournalDraft(
        id: 'je-close-reclass',
        date: DateTime(2026, 6, 10),
        reference: 'JE-2026-0610-003',
        description: 'Reclass closing expense presentation',
        source: JournalSource.periodClose,
        lines: const [
          JournalLineDraft(
            accountId: '10',
            accountName: 'Salary Expense',
            side: JournalSide.debit,
            amount: 78000000,
            memo: 'Close review reclass',
          ),
          JournalLineDraft(
            accountId: '9',
            accountName: 'Utilities Expense',
            side: JournalSide.credit,
            amount: 78000000,
            memo: 'Close review reclass',
          ),
        ],
      ),
      preparerName: 'Accounting staff',
      reviewerName: 'Accounting staff',
      status: JournalApprovalStatus.returned,
      submittedAt: DateTime(2026, 6, 10, 16),
      dueAt: DateTime(2026, 6, 11, 12),
      returnReason: 'Assign an independent reviewer and attach close evidence.',
      reviewedAt: DateTime(2026, 6, 10, 17),
      auditTrail: [
        JournalApprovalAuditEvent(
          id: 'approval-close-reclass-audit-1',
          action: JournalApprovalAuditAction.submitted,
          actorName: 'Accounting staff',
          occurredAt: DateTime(2026, 6, 10, 16),
          note: 'Submitted from close review workpaper.',
        ),
        JournalApprovalAuditEvent(
          id: 'approval-close-reclass-audit-2',
          action: JournalApprovalAuditAction.returned,
          actorName: 'Accounting staff',
          occurredAt: DateTime(2026, 6, 10, 17),
          note: 'Assign an independent reviewer and attach close evidence.',
        ),
      ],
    ),
  ];
}
