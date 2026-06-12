import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_summary.dart';

void main() {
  test('keeps default empty state copy aligned with work queue context', () {
    expect(
      AccountingWorkspaceWorkQueueResolutionFilter.all.emptyStateLabel(
        hasQueues: true,
      ),
      'No work queues match this focus.',
    );
    expect(
      AccountingWorkspaceWorkQueueResolutionFilter.all.emptyStateLabel(
        hasQueues: false,
      ),
      'No work queues match this context.',
    );
  });

  test('describes active resolution filters in empty state copy', () {
    expect(
      AccountingWorkspaceWorkQueueResolutionFilter.ready.emptyStateLabel(
        hasQueues: true,
      ),
      'No ready queues match this view.',
    );
    expect(
      AccountingWorkspaceWorkQueueResolutionFilter.cleared.emptyStateLabel(
        hasQueues: true,
      ),
      'No cleared queues match this view.',
    );
    expect(
      AccountingWorkspaceWorkQueueResolutionFilter.blocked.clearActionLabel,
      'Clear filter',
    );
  });

  test('builds filtered resolution briefs with filter-aware next action', () {
    const nextAction = AccountingWorkspaceWorkQueueResolutionNextAction(
      queueId: 'blocked-close-gate',
      title: 'Blocked close gate',
      statusLabel: 'Reviewer sign-off required',
      actionLabel: 'Review evidence and record a decision',
      ownerLabel: 'Controller',
      dueLabel: '1 day overdue',
    );
    const summary = AccountingWorkspaceWorkQueueResolutionSummary(
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
    );

    final brief = AccountingWorkspaceWorkQueueResolutionFilter.blocked
        .resolutionBriefFor(
          summary: summary,
          nextAction: nextAction,
          briefItems: const [
            AccountingWorkspaceWorkQueueResolutionBriefItem(
              rank: 1,
              queueId: 'blocked-close-gate',
              title: 'Blocked close gate',
              statusLabel: 'Reviewer sign-off required',
              actionLabel: 'Review evidence and record a decision',
              ownerLabel: 'Controller',
              dueLabel: '1 day overdue',
            ),
          ],
        );

    expect(brief, contains('Blocked queue resolution: 1 queue'));
    expect(brief, contains('Filtered detail: Blocked queues'));
    expect(brief, contains('Next: Blocked close gate'));
    expect(brief, isNot(contains('Next: Ready evidence pack')));
    expect(brief, contains('Review queues:'));
    expect(brief, contains('1. Blocked close gate'));
  });

  test('explains when a filtered brief has no active review action', () {
    const summary = AccountingWorkspaceWorkQueueResolutionSummary(
      queueCount: 1,
      clearedQueueCount: 1,
      readyToClearQueueCount: 0,
      blockedQueueCount: 0,
      waitingQueueCount: 0,
    );

    final brief = AccountingWorkspaceWorkQueueResolutionFilter.cleared
        .resolutionBriefFor(summary: summary);

    expect(brief, contains('Cleared queue resolution: 1 queue'));
    expect(brief, contains('No active cleared review action'));
    expect(brief, contains('Review queues: none'));
  });
}
