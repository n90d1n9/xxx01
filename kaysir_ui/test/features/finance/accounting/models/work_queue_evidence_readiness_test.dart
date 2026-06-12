import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_evidence_request.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_readiness.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';

void main() {
  test('reports missing evidence when no support links are attached', () {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
      queueId: 'auditor-evidence-gaps',
      request: _request(),
      links: const [],
    );

    expect(
      readiness.status,
      AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing,
    );
    expect(readiness.coverageLabel, '0/3 accepted');
    expect(readiness.remainingItemCount, 3);
    expect(readiness.remainingRequestedItems.first, 'Release manifest support');
    expect(readiness.nextActionLabel, contains('Attach the first evidence'));
  });

  test(
    'reports pending review when support links are attached but not accepted',
    () {
      final readiness =
          AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
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
          );

      expect(
        readiness.status,
        AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded,
      );
      expect(readiness.coverageLabel, '0/3 accepted');
      expect(readiness.pendingReviewCount, 1);
      expect(readiness.remainingItemCount, 3);
      expect(readiness.remainingRequestedItems, [
        'Release manifest support',
        'Signed controller approval',
        'Disclosure checklist tie-out',
      ]);
    },
  );

  test('formats readiness brief for audit copy', () {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
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
        AccountingWorkspaceWorkQueueEvidenceLink.create(
          id: 'link-2',
          queueId: 'auditor-evidence-gaps',
          label: 'Signed controller approval',
          reference: 'APP-42',
          addedByLabel: 'Auditor',
          addedAt: DateTime(2026, 6, 9, 10, 25),
        ),
        AccountingWorkspaceWorkQueueEvidenceLink.create(
          id: 'link-3',
          queueId: 'auditor-evidence-gaps',
          label: 'Disclosure checklist tie-out',
          reference: 'DISC-77',
          addedByLabel: 'Auditor',
          addedAt: DateTime(2026, 6, 9, 10, 30),
        ),
      ],
      reviewStates: const [
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'auditor-evidence-gaps',
          linkId: 'link-1',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'auditor-evidence-gaps',
          linkId: 'link-2',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'auditor-evidence-gaps',
          linkId: 'link-3',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
        ),
      ],
    );

    final brief = readiness.briefFor('Audit evidence gaps');

    expect(
      readiness.status,
      AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready,
    );
    expect(brief, contains('Evidence readiness: Audit evidence gaps'));
    expect(brief, contains('Status: Evidence ready'));
    expect(brief, contains('Coverage: 3/3 accepted'));
    expect(brief, contains('Accepted evidence: 3'));
  });

  test('reports rework before reviewer sign-off', () {
    final readiness = AccountingWorkspaceWorkQueueEvidenceReadiness.fromRequest(
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
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
        ),
      ],
    );

    expect(
      readiness.status,
      AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework,
    );
    expect(readiness.reworkEvidenceCount, 1);
    expect(readiness.coverageLabel, '0/3 accepted');
    expect(readiness.nextActionLabel, contains('rework comments'));
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
    requestedItems: const [
      'Release manifest support',
      'Signed controller approval',
      'Disclosure checklist tie-out',
    ],
  );
}
