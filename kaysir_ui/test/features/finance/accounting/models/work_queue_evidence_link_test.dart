import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_link.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';

void main() {
  test('creates and serializes accounting work queue evidence links', () {
    final link = AccountingWorkspaceWorkQueueEvidenceLink.create(
      id: 'link-1',
      queueId: ' auditor-evidence-gaps ',
      label: ' Release manifest workpaper ',
      reference: ' WP-REL-2026-06 ',
      addedByLabel: ' Auditor ',
      addedAt: DateTime(2026, 6, 9, 10, 20),
      type: AccountingWorkspaceWorkQueueEvidenceLinkType.workpaper,
    );

    expect(link.queueId, 'auditor-evidence-gaps');
    expect(link.label, 'Release manifest workpaper');
    expect(link.reference, 'WP-REL-2026-06');
    expect(link.addedByLabel, 'Auditor');
    expect(link.typeLabel, 'Workpaper');
    expect(link.isPersistable, isTrue);
    expect(link.toJson(), {
      'id': 'link-1',
      'queueId': 'auditor-evidence-gaps',
      'label': 'Release manifest workpaper',
      'reference': 'WP-REL-2026-06',
      'addedByLabel': 'Auditor',
      'addedAt': '2026-06-09T10:20:00.000',
      'type': 'workpaper',
    });
  });

  test('restores valid links and rejects malformed evidence links', () {
    final restored = accountingWorkspaceWorkQueueEvidenceLinkFromJson({
      'id': 'link-1',
      'queueId': 'auditor-evidence-gaps',
      'label': 'Signed controller approval',
      'reference': 'https://example.internal/approval/42',
      'addedByLabel': '',
      'addedAt': '2026-06-09T11:00:00.000',
      'type': 'signoff',
    });
    final rejected = accountingWorkspaceWorkQueueEvidenceLinkFromJson({
      'id': 'link-2',
      'queueId': 'auditor-evidence-gaps',
      'label': '',
      'reference': 'missing-label',
    });

    expect(restored, isNotNull);
    expect(
      restored!.type,
      AccountingWorkspaceWorkQueueEvidenceLinkType.approval,
    );
    expect(restored.addedByDisplayLabel, 'Accounting workspace');
    expect(restored.timeLabel, '2026-06-09 11:00');
    expect(rejected, isNull);
  });

  test('formats evidence link audit brief newest first', () {
    final brief = accountingWorkspaceWorkQueueEvidenceLinksBrief(
      queueTitle: 'Audit evidence gaps',
      links: [
        AccountingWorkspaceWorkQueueEvidenceLink.create(
          id: 'link-1',
          queueId: 'auditor-evidence-gaps',
          label: 'Older workpaper',
          reference: 'WP-OLD',
          addedByLabel: 'Auditor',
          addedAt: DateTime(2026, 6, 9, 9),
        ),
        AccountingWorkspaceWorkQueueEvidenceLink.create(
          id: 'link-2',
          queueId: 'auditor-evidence-gaps',
          label: 'Latest approval',
          reference: 'APP-42',
          addedByLabel: 'Controller',
          addedAt: DateTime(2026, 6, 9, 12),
          type: AccountingWorkspaceWorkQueueEvidenceLinkType.approval,
        ),
      ],
      reviewStates: [
        AccountingWorkspaceWorkQueueEvidenceReviewState(
          queueId: 'auditor-evidence-gaps',
          linkId: 'link-2',
          decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
          reviewNote: 'Missing signed controller approval.',
          reviewedByLabel: 'Auditor',
          reviewedAt: DateTime(2026, 6, 9, 12, 15),
        ),
      ],
    );

    expect(brief, contains('Evidence links: Audit evidence gaps'));
    expect(
      brief.indexOf('Latest approval'),
      lessThan(brief.indexOf('Older workpaper')),
    );
    expect(brief, contains('Approval: Latest approval - APP-42'));
    expect(
      brief,
      contains(
        'Review: Needs rework - Reviewed by Auditor · 2026-06-09 12:15 - '
        'Missing signed controller approval.',
      ),
    );
    expect(brief, contains('Review: Review pending'));
  });
}
