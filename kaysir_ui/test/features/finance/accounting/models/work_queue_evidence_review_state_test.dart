import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_evidence_review_state.dart';

void main() {
  test('serializes accepted evidence review state for persistence', () {
    final state = AccountingWorkspaceWorkQueueEvidenceReviewState(
      queueId: 'auditor-evidence-gaps',
      linkId: 'link-1',
      decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
      reviewNote: ' Controller approval checked. ',
      reviewedByLabel: ' Auditor ',
      reviewedAt: DateTime(2026, 6, 9, 12, 5),
    );

    expect(state.isPersistable, isTrue);
    expect(state.isAccepted, isTrue);
    expect(state.normalizedReviewNote, 'Controller approval checked.');
    expect(state.reviewedByDisplayLabel, 'Auditor');
    expect(state.reviewedAtLabel, '2026-06-09 12:05');
    expect(state.reviewTrailLabel, 'Reviewed by Auditor · 2026-06-09 12:05');
    expect(state.statusLabel, 'Accepted');
    expect(state.toJson(), {
      'queueId': 'auditor-evidence-gaps',
      'linkId': 'link-1',
      'decision': 'accepted',
      'reviewNote': 'Controller approval checked.',
      'reviewedByLabel': 'Auditor',
      'reviewedAt': '2026-06-09T12:05:00.000',
    });
  });

  test('treats pending or incomplete review state as non-persistable', () {
    final state = AccountingWorkspaceWorkQueueEvidenceReviewState.fromJson({
      'queueId': ' auditor-evidence-gaps ',
      'linkId': ' ',
      'decision': 'unknown',
    });

    expect(
      state.decision,
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.pending,
    );
    expect(state.isPersistable, isFalse);
    expect(state.statusLabel, 'Review pending');
  });

  test('restores reviewer audit trail aliases from json', () {
    final state = AccountingWorkspaceWorkQueueEvidenceReviewState.fromJson({
      'queueId': 'auditor-evidence-gaps',
      'linkId': 'link-1',
      'decision': 'approved',
      'reviewerLabel': ' Audit reviewer ',
      'reviewedAt': '2026-06-09T13:15:00.000',
    });

    expect(state.reviewedByDisplayLabel, 'Audit reviewer');
    expect(state.reviewedAtLabel, '2026-06-09 13:15');
    expect(
      state.reviewTrailLabel,
      'Reviewed by Audit reviewer · 2026-06-09 13:15',
    );
  });

  test('parses common reviewer decision aliases', () {
    expect(
      accountingWorkspaceWorkQueueEvidenceReviewDecisionFromStorage('approved'),
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.accepted,
    );
    expect(
      accountingWorkspaceWorkQueueEvidenceReviewDecisionFromStorage('returned'),
      AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
    );
  });

  test('requires reviewer memo for rework drafts', () {
    const missingMemo = AccountingWorkspaceWorkQueueEvidenceReviewDraft(
      decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
    );
    const readyMemo = AccountingWorkspaceWorkQueueEvidenceReviewDraft(
      decision: AccountingWorkspaceWorkQueueEvidenceReviewDecision.rework,
      reviewNote: ' Missing signed controller approval. ',
    );

    expect(missingMemo.canSubmit, isFalse);
    expect(readyMemo.canSubmit, isTrue);
    expect(
      readyMemo.normalizedReviewNote,
      'Missing signed controller approval.',
    );
  });
}
