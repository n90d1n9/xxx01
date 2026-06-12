import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_filter.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_summary.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/services/work_queue_resolution_summary_service.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_service.dart';

void main() {
  const summaryService = AccountingWorkspaceWorkQueueResolutionSummaryService();
  const workQueueService = AccountingWorkspaceWorkQueueService();

  test('summarizes cleared, ready, and blocked queue resolution states', () {
    final queues = [
      _queue(
        id: 'ready-evidence-pack',
        title: 'Ready evidence pack',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'blocked-close-gate',
        title: 'Blocked close gate',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -1,
      ),
      _queue(
        id: 'cleared-posting-review',
        title: 'Cleared posting review',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };

    final summary = summaryService.summarize(
      queues: queues,
      detailsByQueueId: detailsByQueueId,
      actionStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'ready-evidence-pack',
          ownerAcknowledged: true,
          evidenceReceived: true,
          escalationLogged: true,
        ),
      },
      reviewerSignOffStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
          queueId: 'ready-evidence-pack',
          decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
        ),
      },
      resolutionStates: const {
        'cleared-posting-review': AccountingWorkspaceWorkQueueResolutionState(
          queueId: 'cleared-posting-review',
          cleared: true,
        ),
      },
    );

    expect(summary.queueCount, 3);
    expect(summary.clearedQueueCount, 1);
    expect(summary.readyToClearQueueCount, 1);
    expect(summary.blockedQueueCount, 1);
    expect(summary.waitingQueueCount, 0);
    expect(summary.clearanceScore, 33);
    expect(summary.statusLabel, '1 ready to clear');
    expect(summary.nextAction?.queueId, 'ready-evidence-pack');
    expect(summary.resolutionBrief, contains('Ready evidence pack'));
  });

  test('reports a fully cleared queue set', () {
    final queues = [
      _queue(
        id: 'cleared-one',
        title: 'Cleared one',
        severity: AccountingWorkspaceWorkQueueSeverity.info,
        dueInDays: 2,
      ),
      _queue(
        id: 'cleared-two',
        title: 'Cleared two',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };

    final summary = summaryService.summarize(
      queues: queues,
      detailsByQueueId: detailsByQueueId,
      actionStates: const {},
      reviewerSignOffStates: const {},
      resolutionStates: const {
        'cleared-one': AccountingWorkspaceWorkQueueResolutionState(
          queueId: 'cleared-one',
          cleared: true,
        ),
        'cleared-two': AccountingWorkspaceWorkQueueResolutionState(
          queueId: 'cleared-two',
          cleared: true,
        ),
      },
    );

    expect(summary.isFullyCleared, isTrue);
    expect(summary.openQueueCount, 0);
    expect(summary.clearanceScore, 100);
    expect(summary.nextAction, isNull);
    expect(summary.statusLabel, 'All queues cleared');
  });

  test('keeps approved queues blocked until evidence is accepted', () {
    final queue = _queue(
      id: 'ready-evidence-pack',
      title: 'Ready evidence pack',
      severity: AccountingWorkspaceWorkQueueSeverity.critical,
      dueInDays: -2,
    );
    final detail = workQueueService.detailFor(queue);
    final summary = summaryService.summarize(
      queues: [queue],
      detailsByQueueId: {queue.id: detail},
      actionStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'ready-evidence-pack',
          ownerAcknowledged: true,
          evidenceReceived: true,
          escalationLogged: true,
        ),
      },
      reviewerSignOffStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
          queueId: 'ready-evidence-pack',
          decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
        ),
      },
      resolutionStates: const {},
      evidenceReadinessByQueueId: {
        queue.id: AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
          queueId: queue.id,
          request: detail.evidenceRequest,
          links: [
            AccountingWorkspaceWorkQueueEvidenceLink.create(
              id: 'link-1',
              queueId: queue.id,
              label: 'Release manifest workpaper',
              reference: 'WP-REL-2026-06',
              addedByLabel: 'Auditor',
              addedAt: DateTime(2026, 6, 9, 10, 20),
            ),
          ],
        ),
      },
    );

    expect(summary.readyToClearQueueCount, 0);
    expect(summary.blockedQueueCount, 1);
    expect(summary.nextAction?.statusLabel, 'Evidence gate blocked');
  });

  test('builds row snapshots from live resolution gate status', () {
    final queues = [
      _queue(
        id: 'ready-evidence-pack',
        title: 'Ready evidence pack',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'blocked-close-gate',
        title: 'Blocked close gate',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -1,
      ),
      _queue(
        id: 'cleared-posting-review',
        title: 'Cleared posting review',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };

    final snapshots = summaryService.snapshotsFor(
      queues: queues,
      detailsByQueueId: detailsByQueueId,
      actionStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'ready-evidence-pack',
          ownerAcknowledged: true,
          evidenceReceived: true,
          escalationLogged: true,
        ),
      },
      reviewerSignOffStates: const {
        'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
          queueId: 'ready-evidence-pack',
          decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
        ),
      },
      resolutionStates: const {
        'cleared-posting-review': AccountingWorkspaceWorkQueueResolutionState(
          queueId: 'cleared-posting-review',
          cleared: true,
        ),
      },
    );

    expect(
      snapshots['ready-evidence-pack']?.status,
      AccountingWorkspaceWorkQueueResolutionSnapshotStatus.ready,
    );
    expect(snapshots['ready-evidence-pack']?.badgeLabel, 'Ready');
    expect(snapshots['ready-evidence-pack']?.statusLabel, 'Ready to clear');
    expect(
      snapshots['blocked-close-gate']?.status,
      AccountingWorkspaceWorkQueueResolutionSnapshotStatus.blocked,
    );
    expect(
      snapshots['blocked-close-gate']?.statusLabel,
      'Reviewer sign-off required',
    );
    expect(
      snapshots['cleared-posting-review']?.status,
      AccountingWorkspaceWorkQueueResolutionSnapshotStatus.cleared,
    );
    expect(snapshots['cleared-posting-review']?.badgeLabel, 'Cleared');
  });

  test('filters queues by resolution status', () {
    final queues = [
      _queue(
        id: 'ready-evidence-pack',
        title: 'Ready evidence pack',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'blocked-close-gate',
        title: 'Blocked close gate',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -1,
      ),
      _queue(
        id: 'cleared-posting-review',
        title: 'Cleared posting review',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };
    const actionStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'ready-evidence-pack',
        ownerAcknowledged: true,
        evidenceReceived: true,
        escalationLogged: true,
      ),
    };
    const reviewerSignOffStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
        queueId: 'ready-evidence-pack',
        decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
      ),
    };
    const resolutionStates = {
      'cleared-posting-review': AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'cleared-posting-review',
        cleared: true,
      ),
    };

    expect(
      summaryService
          .filterByResolution(
            queues: queues,
            filter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
            detailsByQueueId: detailsByQueueId,
            actionStates: actionStates,
            reviewerSignOffStates: reviewerSignOffStates,
            resolutionStates: resolutionStates,
          )
          .map((queue) => queue.id),
      ['ready-evidence-pack'],
    );
    expect(
      summaryService
          .filterByResolution(
            queues: queues,
            filter: AccountingWorkspaceWorkQueueResolutionFilter.blocked,
            detailsByQueueId: detailsByQueueId,
            actionStates: actionStates,
            reviewerSignOffStates: reviewerSignOffStates,
            resolutionStates: resolutionStates,
          )
          .map((queue) => queue.id),
      ['blocked-close-gate'],
    );
    expect(
      summaryService
          .filterByResolution(
            queues: queues,
            filter: AccountingWorkspaceWorkQueueResolutionFilter.cleared,
            detailsByQueueId: detailsByQueueId,
            actionStates: actionStates,
            reviewerSignOffStates: reviewerSignOffStates,
            resolutionStates: resolutionStates,
          )
          .map((queue) => queue.id),
      ['cleared-posting-review'],
    );
    expect(
      summaryService
          .filterByResolution(
            queues: queues,
            filter: AccountingWorkspaceWorkQueueResolutionFilter.open,
            detailsByQueueId: detailsByQueueId,
            actionStates: actionStates,
            reviewerSignOffStates: reviewerSignOffStates,
            resolutionStates: resolutionStates,
          )
          .map((queue) => queue.id),
      ['ready-evidence-pack', 'blocked-close-gate'],
    );
  });

  test('resolves next action inside the active resolution filter', () {
    final queues = [
      _queue(
        id: 'ready-evidence-pack',
        title: 'Ready evidence pack',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'blocked-close-gate',
        title: 'Blocked close gate',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -1,
      ),
      _queue(
        id: 'cleared-posting-review',
        title: 'Cleared posting review',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };
    const actionStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'ready-evidence-pack',
        ownerAcknowledged: true,
        evidenceReceived: true,
        escalationLogged: true,
      ),
    };
    const reviewerSignOffStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
        queueId: 'ready-evidence-pack',
        decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
      ),
    };
    const resolutionStates = {
      'cleared-posting-review': AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'cleared-posting-review',
        cleared: true,
      ),
    };

    final readyNext = summaryService.nextActionFor(
      queues: queues,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
      detailsByQueueId: detailsByQueueId,
      actionStates: actionStates,
      reviewerSignOffStates: reviewerSignOffStates,
      resolutionStates: resolutionStates,
    );
    final blockedNext = summaryService.nextActionFor(
      queues: queues,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.blocked,
      detailsByQueueId: detailsByQueueId,
      actionStates: actionStates,
      reviewerSignOffStates: reviewerSignOffStates,
      resolutionStates: resolutionStates,
    );
    final clearedNext = summaryService.nextActionFor(
      queues: queues,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.cleared,
      detailsByQueueId: detailsByQueueId,
      actionStates: actionStates,
      reviewerSignOffStates: reviewerSignOffStates,
      resolutionStates: resolutionStates,
    );

    expect(readyNext?.queueId, 'ready-evidence-pack');
    expect(blockedNext?.queueId, 'blocked-close-gate');
    expect(clearedNext, isNull);
  });

  test('builds ranked brief items inside the active resolution filter', () {
    final queues = [
      _queue(
        id: 'ready-evidence-pack',
        title: 'Ready evidence pack',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'ready-lower-risk',
        title: 'Ready lower risk',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 0,
      ),
      _queue(
        id: 'cleared-posting-review',
        title: 'Cleared posting review',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 1,
      ),
    ];
    final detailsByQueueId = {
      for (final queue in queues) queue.id: workQueueService.detailFor(queue),
    };
    const actionStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'ready-evidence-pack',
        ownerAcknowledged: true,
        evidenceReceived: true,
        escalationLogged: true,
      ),
      'ready-lower-risk': AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'ready-lower-risk',
        ownerAcknowledged: true,
        evidenceReceived: true,
        escalationLogged: true,
      ),
    };
    const reviewerSignOffStates = {
      'ready-evidence-pack': AccountingWorkspaceWorkQueueReviewerSignOffState(
        queueId: 'ready-evidence-pack',
        decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
      ),
      'ready-lower-risk': AccountingWorkspaceWorkQueueReviewerSignOffState(
        queueId: 'ready-lower-risk',
        decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
      ),
    };
    const resolutionStates = {
      'cleared-posting-review': AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'cleared-posting-review',
        cleared: true,
      ),
    };

    final readyItems = summaryService.briefItemsFor(
      queues: queues,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.ready,
      detailsByQueueId: detailsByQueueId,
      actionStates: actionStates,
      reviewerSignOffStates: reviewerSignOffStates,
      resolutionStates: resolutionStates,
    );
    final clearedItems = summaryService.briefItemsFor(
      queues: queues,
      filter: AccountingWorkspaceWorkQueueResolutionFilter.cleared,
      detailsByQueueId: detailsByQueueId,
      actionStates: actionStates,
      reviewerSignOffStates: reviewerSignOffStates,
      resolutionStates: resolutionStates,
    );

    expect(readyItems.map((item) => item.queueId), [
      'ready-evidence-pack',
      'ready-lower-risk',
    ]);
    expect(readyItems.first.rank, 1);
    expect(readyItems.first.briefLabel, contains('Ready evidence pack'));
    expect(clearedItems.single.queueId, 'cleared-posting-review');
    expect(clearedItems.single.actionLabel, contains('Retain evidence'));
  });
}

AccountingWorkspaceWorkQueue _queue({
  required String id,
  required String title,
  required AccountingWorkspaceWorkQueueSeverity severity,
  required int dueInDays,
}) {
  return AccountingWorkspaceWorkQueue(
    id: id,
    title: title,
    description: 'Queue under resolution review',
    count: 5,
    severity: severity,
    ownerLabel: 'Controller',
    dueInDays: dueInDays,
    icon: 'fact_check_rounded',
    path: '/accounting/$id',
    registerRoute: false,
  );
}
