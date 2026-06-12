import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/data/journal_approval_seed_data.dart';
import 'package:kaysir/features/finance/accounting/models/financial_period_close.dart';
import 'package:kaysir/features/finance/accounting/models/journal_approval.dart';
import 'package:kaysir/features/finance/accounting/repositories/financial_period_close_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/journal_approval_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/repositories/posted_ledger_repository_provider.dart';
import 'package:kaysir/features/finance/accounting/screens/journal_approval_screen.dart';
import 'package:kaysir/features/finance/accounting/states/accounting_core_provider.dart';
import 'package:kaysir/features/finance/accounting/states/journal_approval_provider.dart';

void main() {
  testWidgets('shows journal approval queue and filters by search', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpScreen(tester, container);

    expect(find.text('Journal Approval'), findsOneWidget);
    expect(find.text('Accrue June office rent'), findsOneWidget);
    expect(find.text('Audit trail'), findsWidgets);

    await tester.enterText(
      find.byKey(const ValueKey('journal-approval-search')),
      'interest',
    );
    await tester.pump();

    expect(find.text('Record bank interest from statement'), findsOneWidget);
    expect(find.text('Accrue June office rent'), findsNothing);
  });

  testWidgets('approves and posts approved journals to ledger', (tester) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpScreen(tester, container);

    final approveButton = find.byKey(
      const ValueKey('journal-approval-approve-approval-rent-accrual'),
    );
    await tester.ensureVisible(approveButton);
    await tester.pumpAndSettle();
    await tester.tap(approveButton);
    await tester.pump();

    expect(
      _request(container, 'approval-rent-accrual').status,
      JournalApprovalStatus.approved,
    );

    final postButton = find.byKey(
      const ValueKey('journal-approval-post-approval-interest-income'),
    );
    await tester.ensureVisible(postButton);
    await tester.pumpAndSettle();
    await tester.tap(postButton);
    await tester.pump();

    expect(container.read(postedLedgerProvider), hasLength(1));
    expect(
      _request(container, 'approval-interest-income').status,
      JournalApprovalStatus.posted,
    );
    expect(
      find.byKey(
        const ValueKey('journal-posting-trace-approval-interest-income'),
      ),
      findsOneWidget,
    );
    expect(find.text('Posting trace'), findsOneWidget);
  });

  testWidgets('blocks posting approved journals in closed periods', (
    tester,
  ) async {
    final container = _container(periodCloseRecords: [_closedJune2026()]);
    addTearDown(container.dispose);

    await _pumpScreen(tester, container);

    final postButton = find.byKey(
      const ValueKey('journal-approval-post-approval-interest-income'),
    );
    await tester.scrollUntilVisible(
      postButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(
      container
          .read(journalApprovalReadinessProvider)['approval-interest-income']!
          .issues
          .map((issue) => issue.message),
      contains(
        'Journal date is inside closed period Jun 2026. '
        'Reopen the period before approval or posting.',
      ),
    );
    final button = tester.widget<FilledButton>(postButton);
    expect(button.onPressed, isNull);
    expect(container.read(postedLedgerProvider), isEmpty);
  });

  testWidgets('creates reversal requests for posted journals', (tester) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpScreen(tester, container);

    final postButton = find.byKey(
      const ValueKey('journal-approval-post-approval-interest-income'),
    );
    await tester.scrollUntilVisible(
      postButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(postButton);
    await tester.pumpAndSettle();

    final reverseButton = find.byKey(
      const ValueKey('journal-approval-reverse-approval-interest-income'),
    );
    await tester.scrollUntilVisible(
      reverseButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(reverseButton);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('journal-reversal-submit')));
    await tester.pumpAndSettle();

    final original = _request(container, 'approval-interest-income');
    expect(original.reversalRequested, isTrue);
    expect(
      original.latestAuditEvent?.action,
      JournalApprovalAuditAction.reversalRequested,
    );
    expect(
      container
          .read(journalApprovalQueueProvider)
          .map((request) => request.draft.description),
      contains('Reverse JE-2026-0609-002: Record bank interest from statement'),
    );
  });

  testWidgets('creates a new journal request from the approval screen', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);

    await _pumpScreen(tester, container);

    await tester.tap(
      find.byKey(const ValueKey('journal-approval-new-request')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-reference')),
      'JE-NEW-101',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-description')),
      'Owner petty cash correction',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-0-amount')),
      '1250000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('journal-request-line-1-amount')),
      '1250000',
    );
    await tester.tap(find.byKey(const ValueKey('journal-request-submit')));
    await tester.pumpAndSettle();

    expect(
      container
          .read(journalApprovalQueueProvider)
          .map((request) => request.draft.description),
      contains('Owner petty cash correction'),
    );
    expect(
      container
          .read(journalApprovalQueueProvider)
          .last
          .latestAuditEvent
          ?.action,
      JournalApprovalAuditAction.submitted,
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

Future<void> _pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: JournalApprovalScreen()),
    ),
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
