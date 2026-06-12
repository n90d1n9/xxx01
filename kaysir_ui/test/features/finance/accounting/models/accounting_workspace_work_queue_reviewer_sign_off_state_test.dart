import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';

void main() {
  test('tracks reviewer sign-off labels and storage values', () {
    const pending = AccountingWorkspaceWorkQueueReviewerSignOffState(
      queueId: 'auditor-evidence-gaps',
    );

    expect(pending.hasDecision, isFalse);
    expect(pending.statusLabel, 'Pending review');
    expect(pending.nextActionLabel, 'Review evidence and record a decision');

    final approved = pending.copyWith(
      decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
    );

    expect(approved.hasDecision, isTrue);
    expect(approved.isApproved, isTrue);
    expect(approved.statusLabel, 'Approved');
    expect(approved.decisionBrief, contains('Reviewer sign-off: Approved'));

    final restored = AccountingWorkspaceWorkQueueReviewerSignOffState.fromJson(
      approved.toJson(),
    );

    expect(restored.queueId, 'auditor-evidence-gaps');
    expect(
      restored.decision,
      AccountingWorkspaceWorkQueueReviewerDecision.approved,
    );
  });

  test('parses reviewer decision aliases safely', () {
    expect(
      accountingWorkspaceWorkQueueReviewerDecisionFromStorage('return'),
      AccountingWorkspaceWorkQueueReviewerDecision.returned,
    );
    expect(
      accountingWorkspaceWorkQueueReviewerDecisionFromStorage('BLOCK'),
      AccountingWorkspaceWorkQueueReviewerDecision.blocked,
    );
    expect(
      accountingWorkspaceWorkQueueReviewerDecisionFromStorage('unknown'),
      AccountingWorkspaceWorkQueueReviewerDecision.pending,
    );
  });
}
