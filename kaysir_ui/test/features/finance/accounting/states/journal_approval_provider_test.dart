import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/data/journal_approval_seed_data.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_period_close_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/journal_approval_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/services/journal_reversal_service.dart';
import 'package:kaysir/features/finance/accounting/states/journal_approval_provider.dart';

void main() {
  test('seeds approval queue summary and readiness checks', () {
    final container = _container();
    addTearDown(container.dispose);

    final summary = container.read(journalApprovalSummaryProvider);
    final readiness = container.read(journalApprovalReadinessProvider);
    final closeReclass = readiness['approval-close-reclass']!;

    expect(summary.pendingReview, 1);
    expect(summary.approved, 1);
    expect(summary.returned, 1);
    expect(
      _request(container, 'approval-rent-accrual').auditTrail.single.action,
      JournalApprovalAuditAction.submitted,
    );
    expect(closeReclass.canApprove, isFalse);
    expect(
      closeReclass.issues.map((issue) => issue.message),
      contains('Reviewer must be different from preparer.'),
    );
  });

  test('moves journal approvals through review lifecycle', () {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(journalApprovalQueueProvider.notifier);

    notifier.approve('approval-rent-accrual');
    expect(
      _request(container, 'approval-rent-accrual').status,
      JournalApprovalStatus.approved,
    );
    expect(
      _request(container, 'approval-rent-accrual').latestAuditEvent?.action,
      JournalApprovalAuditAction.approved,
    );

    notifier.returnForCorrection('approval-rent-accrual', 'Attach lease.');
    final returned = _request(container, 'approval-rent-accrual');
    expect(returned.status, JournalApprovalStatus.returned);
    expect(returned.returnReason, 'Attach lease.');
    expect(
      returned.latestAuditEvent?.action,
      JournalApprovalAuditAction.returned,
    );
    expect(returned.latestAuditEvent?.note, 'Attach lease.');

    notifier.resubmit('approval-rent-accrual');
    expect(
      _request(container, 'approval-rent-accrual').status,
      JournalApprovalStatus.pendingReview,
    );
    expect(
      _request(container, 'approval-rent-accrual').latestAuditEvent?.action,
      JournalApprovalAuditAction.resubmitted,
    );

    notifier.markPosted('approval-interest-income', postingId: 'posting-1');
    final posted = _request(container, 'approval-interest-income');
    expect(posted.status, JournalApprovalStatus.posted);
    expect(posted.postingId, 'posting-1');
    expect(posted.latestAuditEvent?.action, JournalApprovalAuditAction.posted);
    expect(posted.latestAuditEvent?.note, 'Posted to GL as posting-1.');
  });

  test('adds reversal requests and audits the original journal link', () {
    final container = _container();
    addTearDown(container.dispose);
    final notifier = container.read(journalApprovalQueueProvider.notifier);

    notifier.markPosted('approval-interest-income', postingId: 'posting-1');
    final reversal = JournalReversalService(
      now: () => DateTime(2026, 6, 11, 10),
      nextId: () => 'rev-1',
    ).createReversalRequest(
      original: _request(container, 'approval-interest-income'),
      reversalDate: DateTime(2026, 6, 12),
    );

    notifier.addReversalRequest(
      originalRequestId: 'approval-interest-income',
      reversalRequest: reversal,
    );

    final original = _request(container, 'approval-interest-income');
    expect(original.reversalRequestId, 'approval-reversal-rev-1');
    expect(original.reversalDate, DateTime(2026, 6, 12));
    expect(
      original.latestAuditEvent?.action,
      JournalApprovalAuditAction.reversalRequested,
    );
    expect(
      container.read(journalApprovalQueueProvider).map((request) => request.id),
      contains('approval-reversal-rev-1'),
    );

    final trace =
        container.read(
          journalPostingTraceProvider,
        )['approval-interest-income']!;
    expect(trace.reversalRequestId, 'approval-reversal-rev-1');
    expect(trace.reversalReference, 'JE-2026-0609-002-REV');
    expect(trace.netExposure, original.totalAmount);
  });

  test('blocks journal posting readiness when the journal date is closed', () {
    final container = _container(periodCloseRecords: [_closedJune2026()]);
    addTearDown(container.dispose);

    final readiness = container.read(journalApprovalReadinessProvider);
    final interestIncome = readiness['approval-interest-income']!;

    expect(interestIncome.canPost, isFalse);
    expect(
      interestIncome.issues.map((issue) => issue.message),
      contains(
        'Journal date is inside closed period Jun 2026. '
        'Reopen the period before approval or posting.',
      ),
    );
  });
}

ProviderContainer _container({
  Iterable<FinancialPeriodCloseRecord> periodCloseRecords = const [],
}) {
  return ProviderContainer(
    overrides: [
      journalApprovalClockProvider.overrideWithValue(
        () => DateTime(2026, 6, 11, 10),
      ),
      financialPeriodCloseRepositoryProvider.overrideWithValue(
        InMemoryFinancialPeriodCloseRepository(
          records: {
            for (final record in periodCloseRecords) record.periodKey: record,
          },
        ),
      ),
      postedLedgerRepositoryProvider.overrideWithValue(
        InMemoryPostedLedgerRepository(),
      ),
      journalApprovalRepositoryProvider.overrideWithValue(
        InMemoryJournalApprovalRepository(requests: seedJournalApprovals()),
      ),
    ],
  );
}

JournalApprovalRequest _request(ProviderContainer container, String id) {
  return container
      .read(journalApprovalQueueProvider)
      .singleWhere((request) => request.id == id);
}

FinancialPeriodCloseRecord _closedJune2026() {
  return FinancialPeriodCloseRecord(
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
  );
}
