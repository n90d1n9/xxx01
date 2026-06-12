import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_clearance_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/services/work_queue_resolution_gate_service.dart';

void main() {
  const service = AccountingWorkspaceWorkQueueResolutionGateService();

  test('requires reviewer sign-off before clearing', () {
    final gate = service.resolve(
      clearanceChecklist: _readyChecklist(),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
          ),
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
      ),
    );

    expect(gate.canClear, isFalse);
    expect(gate.statusLabel, 'Reviewer sign-off required');
    expect(gate.blockers, ['Reviewer sign-off']);
  });

  test('allows clearing when reviewer approved and clearance is ready', () {
    final gate = service.resolve(
      clearanceChecklist: _readyChecklist(),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
      ),
    );

    expect(gate.canClear, isTrue);
    expect(gate.statusLabel, 'Ready to clear');
    expect(gate.nextActionLabel, 'Mark queue cleared');
  });

  test('blocks clearing when evidence readiness is not complete', () {
    final gate = service.resolve(
      clearanceChecklist: _readyChecklist(),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
      ),
      evidenceReadiness: _pendingEvidenceReadiness(),
    );

    expect(gate.canClear, isFalse);
    expect(gate.statusLabel, 'Evidence gate blocked');
    expect(gate.detailLabel, contains('need review'));
    expect(gate.nextActionLabel, contains('Review attached evidence'));
    expect(gate.blockers, ['Accepted evidence']);
  });

  test('blocks clearing until open clearance steps are resolved', () {
    final gate = service.resolve(
      clearanceChecklist: AccountingWorkspaceWorkQueueClearanceChecklist(
        steps: [
          _step(
            title: 'Owner acknowledgement',
            status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
          ),
          _step(
            title: 'Release or close gate',
            status: AccountingWorkspaceWorkQueueClearanceStatus.waiting,
          ),
        ],
      ),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
      ),
    );

    expect(gate.canClear, isFalse);
    expect(gate.statusLabel, 'Waiting on clearance');
    expect(gate.blockers, ['Release or close gate']);
  });

  test('reports already-cleared queues as completed', () {
    final gate = service.resolve(
      clearanceChecklist: _readyChecklist(),
      reviewerSignOffState:
          const AccountingWorkspaceWorkQueueReviewerSignOffState(
            queueId: 'auditor-evidence-gaps',
            decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
          ),
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
        cleared: true,
      ),
    );

    expect(gate.canClear, isFalse);
    expect(gate.isCleared, isTrue);
    expect(gate.statusLabel, 'Queue cleared');
  });
}

AccountingWorkspaceWorkQueueEvidenceReadiness _pendingEvidenceReadiness() {
  return AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
    queueId: 'auditor-evidence-gaps',
    request: AccountingWorkspaceWorkQueueEvidenceRequest(
      recipientLabel: 'Audit liaison',
      subject: 'Evidence request: Audit evidence gaps',
      responseDueLabel: 'Today before release',
      statusLabel: 'Overdue follow-up',
      agingLabel: '2 days overdue',
      followUpLabel: 'Daily until cleared',
      nextTrackingActionLabel: 'Send request today',
      requestBody: 'Evidence request body',
      requestedItems: const ['Release manifest support'],
    ),
    links: [
      AccountingWorkspaceWorkQueueEvidenceLink.create(
        id: 'link-1',
        queueId: 'auditor-evidence-gaps',
        label: 'Release manifest workpaper',
        reference: 'WP-REL-2026-06',
        addedByLabel: 'Auditor',
        addedAt: DateTime(2026, 6, 9, 10, 20),
      ),
    ],
  );
}

AccountingWorkspaceWorkQueueClearanceChecklist _readyChecklist() {
  return AccountingWorkspaceWorkQueueClearanceChecklist(
    steps: [
      _step(
        title: 'Owner acknowledgement',
        status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
      ),
      _step(
        title: 'Evidence pack',
        status: AccountingWorkspaceWorkQueueClearanceStatus.ready,
      ),
    ],
  );
}

AccountingWorkspaceWorkQueueClearanceStep _step({
  required String title,
  required AccountingWorkspaceWorkQueueClearanceStatus status,
}) {
  return AccountingWorkspaceWorkQueueClearanceStep(
    id: title.toLowerCase().replaceAll(' ', '-'),
    title: title,
    ownerLabel: 'Controller',
    evidenceLabel: 'Evidence support',
    status: status,
  );
}
