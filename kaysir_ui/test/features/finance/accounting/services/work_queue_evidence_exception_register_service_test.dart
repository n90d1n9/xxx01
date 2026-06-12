import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/services/work_queue_evidence_exception_register_service.dart';

void main() {
  const service =
      AccountingWorkspaceWorkQueueEvidenceExceptionRegisterService();

  test('builds sorted evidence exceptions for actionable queue readiness', () {
    final queues = [
      _queue(
        id: 'review',
        title: 'Review evidence',
        ownerLabel: 'Treasury',
        severity: AccountingWorkspaceWorkQueueSeverity.warning,
        dueInDays: 0,
      ),
      _queue(
        id: 'rework',
        title: 'Returned evidence',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -1,
      ),
      _queue(
        id: 'missing',
        title: 'Missing support',
        severity: AccountingWorkspaceWorkQueueSeverity.critical,
        dueInDays: -2,
      ),
      _queue(
        id: 'ready',
        title: 'Accepted evidence',
        severity: AccountingWorkspaceWorkQueueSeverity.info,
        dueInDays: 2,
      ),
    ];

    final register = service.build(
      queues: queues,
      evidenceReadinessByQueueId: {
        'review': _readiness(
          queueId: 'review',
          status:
              AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded,
          linkedEvidenceCount: 1,
          pendingReviewCount: 1,
          remainingRequestedItems: const ['Controller approval'],
        ),
        'rework': _readiness(
          queueId: 'rework',
          status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework,
          linkedEvidenceCount: 1,
          reworkEvidenceCount: 1,
          remainingRequestedItems: const ['Owner memo'],
        ),
        'missing': _readiness(
          queueId: 'missing',
          status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing,
          remainingRequestedItems: const ['Bank confirmation'],
        ),
        'ready': _readiness(
          queueId: 'ready',
          status: AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready,
          linkedEvidenceCount: 2,
          acceptedEvidenceCount: 2,
        ),
      },
    );

    expect(register.exceptionCount, 3);
    expect(register.blockerCount, 2);
    expect(register.reviewCount, 1);
    expect(register.statusLabel, '2 blocker(s)');
    expect(register.ownerHandoffs.map((handoff) => handoff.ownerLabel), [
      'Controller',
      'Treasury',
    ]);
    expect(register.ownerHandoffs.first.displayLabel, contains('2 open'));
    expect(register.ownerHandoffs.first.displayLabel, contains('2 blockers'));
    expect(register.items.map((item) => item.queueId), [
      'rework',
      'missing',
      'review',
    ]);
    expect(register.items.first.metricLabel, contains('1 rework'));
    expect(register.items.first.metricLabel, contains('2 remaining'));
    expect(
      register.exceptionBrief,
      contains('Evidence exception register: 2 blocker(s)'),
    );
    expect(register.exceptionBrief, contains('1. Returned evidence - Rework'));
    expect(register.exceptionBrief, contains('3. Review evidence - Review'));
    expect(
      register.exceptionBrief,
      contains('- Controller - 2 open - 2 blocker(s) - 0 review item(s)'),
    );
    expect(
      register.exceptionBrief,
      contains('- Treasury - 1 open - 0 blocker(s) - 1 review item(s)'),
    );
  });
}

AccountingWorkspaceWorkQueue _queue({
  required String id,
  required String title,
  String ownerLabel = 'Controller',
  required AccountingWorkspaceWorkQueueSeverity severity,
  required int dueInDays,
}) {
  return AccountingWorkspaceWorkQueue(
    id: id,
    title: title,
    description: 'Evidence exception queue',
    count: 3,
    severity: severity,
    ownerLabel: ownerLabel,
    dueInDays: dueInDays,
    icon: 'fact_check_rounded',
    path: '/accounting/$id',
    registerRoute: false,
  );
}

AccountingWorkspaceWorkQueueEvidenceReadiness _readiness({
  required String queueId,
  required AccountingWorkspaceWorkQueueEvidenceReadinessStatus status,
  int requestedItemCount = 2,
  int linkedEvidenceCount = 0,
  int acceptedEvidenceCount = 0,
  int pendingReviewCount = 0,
  int reworkEvidenceCount = 0,
  Iterable<String> remainingRequestedItems = const [],
}) {
  return AccountingWorkspaceWorkQueueEvidenceReadiness(
    queueId: queueId,
    requestedItemCount: requestedItemCount,
    linkedEvidenceCount: linkedEvidenceCount,
    acceptedEvidenceCount: acceptedEvidenceCount,
    pendingReviewCount: pendingReviewCount,
    reworkEvidenceCount: reworkEvidenceCount,
    status: status,
    remainingRequestedItems: remainingRequestedItems,
  );
}
