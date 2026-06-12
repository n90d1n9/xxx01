import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_reviewer_sign_off_guard.dart';

void main() {
  test('blocks reviewer approval until evidence readiness is complete', () {
    final guard = AccountingWorkspaceWorkQueueReviewerSignOffGuard(
      readiness: AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
        queueId: 'auditor-evidence-gaps',
        request: _request(),
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
      ),
    );

    expect(guard.canApprove, isFalse);
    expect(guard.statusLabel, 'Evidence gate blocked');
    expect(guard.detailLabel, contains('needs review'));
    expect(guard.actionLabel, contains('Review attached evidence'));
  });

  test('allows reviewer approval when requested evidence is accepted', () {
    final guard = AccountingWorkspaceWorkQueueReviewerSignOffGuard(
      readiness: AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
        queueId: 'auditor-evidence-gaps',
        request: _request(),
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
        reviewStates: const [
          AccountingWorkspaceWorkQueueEvidenceReviewState(
            queueId: 'auditor-evidence-gaps',
            linkId: 'link-1',
            decision:
                AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
          ),
        ],
      ),
    );

    expect(guard.canApprove, isTrue);
    expect(guard.statusLabel, 'Approval ready');
    expect(guard.detailLabel, contains('complete'));
  });
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
