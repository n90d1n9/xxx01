import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_clearance_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_clearance_action_sync.dart';

void main() {
  const sync = AccountingWorkspaceWorkQueueClearanceActionSync();

  test(
    'keeps the generated checklist when no activity actions are captured',
    () {
      final checklist = _checklist();

      final synced = sync.sync(
        checklist: checklist,
        actionState: const AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'auditor-evidence-gaps',
        ),
      );

      expect(identical(synced, checklist), isTrue);
      expect(synced.summaryLabel, '0 ready / 0 waiting / 4 blocked');
    },
  );

  test(
    'promotes owner and evidence action captures into clearance progress',
    () {
      final synced = sync.sync(
        checklist: _checklist(),
        actionState: const AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'auditor-evidence-gaps',
          ownerAcknowledged: true,
          evidenceReceived: true,
        ),
      );

      expect(synced.summaryLabel, '2 ready / 2 waiting / 0 blocked');
      expect(synced.steps.map((step) => step.status), [
        AccountingWorkspaceWorkQueueClearanceStatus.ready,
        AccountingWorkspaceWorkQueueClearanceStatus.ready,
        AccountingWorkspaceWorkQueueClearanceStatus.waiting,
        AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      ]);
    },
  );

  test('promotes escalation capture into a ready gate decision', () {
    final synced = sync.sync(
      checklist: _checklist(),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        escalationLogged: true,
      ),
    );

    expect(synced.summaryLabel, '1 ready / 0 waiting / 3 blocked');
    expect(
      synced.steps.last.status,
      AccountingWorkspaceWorkQueueClearanceStatus.ready,
    );
  });

  test('promotes evidence pack from accepted evidence readiness', () {
    final synced = sync.sync(
      checklist: _checklist(),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
      ),
      evidenceReadiness: _acceptedEvidenceReadiness(),
    );

    expect(
      synced.steps[1].status,
      AccountingWorkspaceWorkQueueClearanceStatus.ready,
    );
  });

  test(
    'does not clear evidence pack from manual receipt when review is pending',
    () {
      final synced = sync.sync(
        checklist: _checklist(),
        actionState: const AccountingWorkspaceWorkQueueActivityActionState(
          queueId: 'auditor-evidence-gaps',
          evidenceReceived: true,
        ),
        evidenceReadiness: _pendingEvidenceReadiness(),
      );

      expect(
        synced.steps[1].status,
        AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      );
      expect(
        synced.steps[2].status,
        AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      );
    },
  );

  test('blocks evidence-dependent clearance when evidence is returned', () {
    final synced = sync.sync(
      checklist: _checklist(),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        ownerAcknowledged: true,
        evidenceReceived: true,
      ),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
      evidenceReadiness: _returnedEvidenceReadiness(),
    );

    expect(
      synced.steps[1].status,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    );
    expect(
      synced.steps[2].status,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    );
    expect(
      synced.steps[3].status,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    );
  });

  test('promotes approved reviewer sign-off into clearance progress', () {
    final synced = sync.sync(
      checklist: _checklist(),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        ownerAcknowledged: true,
        evidenceReceived: true,
      ),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
    );

    expect(synced.summaryLabel, '3 ready / 1 waiting / 0 blocked');
    expect(
      synced.steps[2].status,
      AccountingWorkspaceWorkQueueClearanceStatus.ready,
    );
    expect(
      synced.steps[3].status,
      AccountingWorkspaceWorkQueueClearanceStatus.waiting,
    );
  });

  test('marks returned reviewer sign-off as blocked clearance', () {
    final synced = sync.sync(
      checklist: _checklist(),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        ownerAcknowledged: true,
        evidenceReceived: true,
      ),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.returned,
          ),
    );

    expect(synced.summaryLabel, '2 ready / 0 waiting / 2 blocked');
    expect(
      synced.steps[2].status,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    );
    expect(
      synced.steps[3].status,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    );
  });

  test('does not downgrade already-ready generated clearance steps', () {
    final synced = sync.sync(
      checklist: AccountingWorkspaceWorkQueueClearanceChecklist(
        steps: [
          _step(
            id: 'auditor-evidence-gaps-reviewer-signoff',
            status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
          ),
        ],
      ),
      actionState: const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        ownerAcknowledged: true,
        evidenceReceived: true,
      ),
    );

    expect(
      synced.steps.single.status,
      AccountingWorkspaceWorkQueueClearanceStatus.ready,
    );
  });
}

AccountingWorkspaceWorkQueueEvidenceReadiness _acceptedEvidenceReadiness() {
  return AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
    queueId: 'auditor-evidence-gaps',
    request: _request(),
    links: [_link()],
    reviewStates: const [
      AccountingWorkspaceWorkQueueEvidenceReviewState(
        queueId: 'auditor-evidence-gaps',
        linkId: 'link-1',
        decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
      ),
    ],
  );
}

AccountingWorkspaceWorkQueueEvidenceReadiness _pendingEvidenceReadiness() {
  return AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
    queueId: 'auditor-evidence-gaps',
    request: _request(),
    links: [_link()],
  );
}

AccountingWorkspaceWorkQueueEvidenceReadiness _returnedEvidenceReadiness() {
  return AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
    queueId: 'auditor-evidence-gaps',
    request: _request(),
    links: [_link()],
    reviewStates: const [
      AccountingWorkspaceWorkQueueEvidenceReviewState(
        queueId: 'auditor-evidence-gaps',
        linkId: 'link-1',
        decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
      ),
    ],
  );
}

AccountingWorkspaceWorkQueueEvidenceRequest _request() {
  return AccountingWorkspaceWorkQueueEvidenceRequest(
    recipientLabel: 'Audit liaison',
    subject: 'Evidence request: Audit evidence gaps',
    responseDueLabel: 'Today before release',
    statusLabel: 'Overdue follow-up',
    agingLabel: '2 days overdue',
    followUpLabel: 'Daily until cleared',
    nextTrackingActionLabel: 'Send request today',
    requestBody: 'Evidence request body',
    requestedItems: const ['Release manifest support'],
  );
}

AccountingWorkspaceWorkQueueEvidenceLink _link() {
  return AccountingWorkspaceWorkQueueEvidenceLink.create(
    id: 'link-1',
    queueId: 'auditor-evidence-gaps',
    label: 'Release manifest workpaper',
    reference: 'WP-REL-2026-06',
    addedByLabel: 'Auditor',
    addedAt: DateTime(2026, 6, 9, 10, 20),
  );
}

AccountingWorkspaceWorkQueueClearanceChecklist _checklist() {
  return AccountingWorkspaceWorkQueueClearanceChecklist(
    steps: [
      _step(id: 'auditor-evidence-gaps-owner-acknowledgement'),
      _step(id: 'auditor-evidence-gaps-evidence-pack'),
      _step(id: 'auditor-evidence-gaps-reviewer-signoff'),
      _step(id: 'auditor-evidence-gaps-gate-decision'),
    ],
  );
}

AccountingWorkspaceWorkQueueClearanceStep _step({
  required String id,
  AccountingWorkspaceWorkQueueClearanceStatus status =
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
}) {
  return AccountingWorkspaceWorkQueueClearanceStep(
    id: id,
    title: 'Clearance step',
    ownerLabel: 'Audit liaison',
    evidenceLabel: 'Evidence support',
    status: status,
  );
}
