import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_close_packet_evidence_summary.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_summary.dart';
import 'package:kaysir/features/finance/accounting/widgets/work_queue_resolution_summary_components.dart';

void main() {
  testWidgets('renders queue resolution summary and review action', (
    tester,
  ) async {
    var copied = false;
    var reviewed = false;
    AccountingWorkspaceWorkQueueResolutionFilter? selectedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionSummaryStrip(
            summary: const AccountingWorkspaceWorkQueueResolutionSummary(
              queueCount: 4,
              clearedQueueCount: 1,
              readyToClearQueueCount: 2,
              blockedQueueCount: 1,
              waitingQueueCount: 0,
              nextAction: AccountingWorkspaceWorkQueueResolutionNextAction(
                queueId: 'ready-evidence-pack',
                title: 'Ready evidence pack',
                statusLabel: 'Ready to clear',
                actionLabel: 'Mark queue cleared',
                ownerLabel: 'Controller',
                dueLabel: 'Due today',
              ),
            ),
            evidenceSummary:
                const AccountingWorkspaceWorkQueueClosePacketEvidenceSummary(
                  queueCount: 4,
                  readyQueueCount: 2,
                  reviewNeededQueueCount: 1,
                  reworkQueueCount: 1,
                  partialQueueCount: 0,
                  missingQueueCount: 0,
                  requestedEvidenceCount: 8,
                  linkedEvidenceCount: 7,
                  acceptedEvidenceCount: 5,
                  pendingReviewCount: 1,
                  reworkEvidenceCount: 1,
                ),
            onCopyBrief: () => copied = true,
            onFilterChanged: (filter) => selectedFilter = filter,
            onNextActionSelected: () => reviewed = true,
          ),
        ),
      ),
    );

    expect(find.text('Resolution'), findsOneWidget);
    expect(find.text('2 ready to clear'), findsOneWidget);
    expect(find.text('25% cleared'), findsOneWidget);
    expect(find.text('Cleared'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);
    expect(find.text('Evidence rework needed'), findsOneWidget);
    expect(
      find.text('5/8 accepted · 7 linked | 1 pending review | 1 rework'),
      findsOneWidget,
    );
    expect(find.text('2 actions'), findsOneWidget);
    expect(find.text('Ready evidence pack'), findsOneWidget);
    expect(
      find.byKey(
        const ValueKey('accounting-work-queue-resolution-active-filter'),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-resolution-copy-brief')),
    );
    await tester.pump();

    expect(copied, isTrue);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-resolution-ready')),
    );
    await tester.pump();

    expect(selectedFilter, AccountingWorkspaceWorkQueueResolutionFilter.ready);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-resolution-review-next'),
      ),
    );
    await tester.pump();

    expect(reviewed, isTrue);
  });

  testWidgets('clears the active resolution filter notice', (tester) async {
    AccountingWorkspaceWorkQueueResolutionFilter? selectedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionSummaryStrip(
            filter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
            summary: const AccountingWorkspaceWorkQueueResolutionSummary(
              queueCount: 4,
              clearedQueueCount: 1,
              readyToClearQueueCount: 2,
              blockedQueueCount: 1,
              waitingQueueCount: 0,
            ),
            onFilterChanged: (filter) => selectedFilter = filter,
          ),
        ),
      ),
    );

    expect(find.text('Ready filter active'), findsOneWidget);

    await tester.tap(
      find.byKey(
        const ValueKey('accounting-work-queue-resolution-clear-filter'),
      ),
    );
    await tester.pump();

    expect(selectedFilter, AccountingWorkspaceWorkQueueResolutionFilter.all);
  });

  testWidgets('ignores inactive zero-count resolution filters', (tester) async {
    AccountingWorkspaceWorkQueueResolutionFilter? selectedFilter;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionSummaryStrip(
            summary: const AccountingWorkspaceWorkQueueResolutionSummary(
              queueCount: 3,
              clearedQueueCount: 1,
              readyToClearQueueCount: 0,
              blockedQueueCount: 0,
              waitingQueueCount: 2,
            ),
            onFilterChanged: (filter) => selectedFilter = filter,
          ),
        ),
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-resolution-ready')),
    );
    await tester.pump();

    expect(selectedFilter, isNull);

    await tester.tap(
      find.byKey(const ValueKey('accounting-work-queue-resolution-open')),
    );
    await tester.pump();

    expect(selectedFilter, AccountingWorkspaceWorkQueueResolutionFilter.open);
  });

  testWidgets('uses a filter-aware next action override', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AccountingNavigationWorkQueueResolutionSummaryStrip(
            filter: AccountingWorkspaceWorkQueueResolutionFilter.blocked,
            summary: const AccountingWorkspaceWorkQueueResolutionSummary(
              queueCount: 3,
              clearedQueueCount: 1,
              readyToClearQueueCount: 1,
              blockedQueueCount: 1,
              waitingQueueCount: 0,
              nextAction: AccountingWorkspaceWorkQueueResolutionNextAction(
                queueId: 'ready-evidence-pack',
                title: 'Ready evidence pack',
                statusLabel: 'Ready to clear',
                actionLabel: 'Mark queue cleared',
                ownerLabel: 'Controller',
                dueLabel: 'Due today',
              ),
            ),
            nextAction: const AccountingWorkspaceWorkQueueResolutionNextAction(
              queueId: 'blocked-close-gate',
              title: 'Blocked close gate',
              statusLabel: 'Reviewer sign-off required',
              actionLabel: 'Review evidence and record a decision',
              ownerLabel: 'Controller',
              dueLabel: '1 day overdue',
            ),
          ),
        ),
      ),
    );

    expect(find.text('Blocked filter active'), findsOneWidget);
    expect(find.text('Blocked close gate'), findsOneWidget);
    expect(find.text('Ready evidence pack'), findsNothing);
  });
}
