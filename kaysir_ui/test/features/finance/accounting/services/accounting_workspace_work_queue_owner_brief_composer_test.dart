import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import 'package:kaysir/features/finance/accounting/models/work_queue_resolution_state.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_clearance_action_sync.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_owner_brief_composer.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_service.dart';

void main() {
  test('composes copied owner brief with synced clearance and actions', () {
    const workQueueService = AccountingWorkspaceWorkQueueService();
    const clearanceActionSync =
        AccountingWorkspaceWorkQueueClearanceActionSync();
    const composer = AccountingWorkspaceWorkQueueOwnerBriefComposer();
    final queue =
        workQueueService
            .queuesFor(
              rolePreset: AccountingWorkspaceRolePreset.auditor,
              query: 'evidence',
              scope: AccountingMenuSearchScope.shortcuts,
            )
            .single;
    final detail = workQueueService.detailFor(queue);
    const actionState = AccountingWorkspaceWorkQueueActivityActionState(
      queueId: 'auditor-evidence-gaps',
      ownerAcknowledged: true,
      evidenceReceived: true,
    );
    const reviewerSignOffState =
        AccountingWorkspaceWorkQueueReviewerSignOffState(
          queueId: 'auditor-evidence-gaps',
          decision: AccountingWorkspaceWorkQueueReviewerDecision.approved,
        );
    final clearanceChecklist = clearanceActionSync.sync(
      checklist: detail.clearanceChecklist,
      actionState: actionState,
      reviewerSignOffState: reviewerSignOffState,
    );

    final brief = composer.compose(
      detail: detail,
      clearanceChecklist: clearanceChecklist,
      actionState: actionState,
      reviewerSignOffState: reviewerSignOffState,
      resolutionState: const AccountingWorkspaceWorkQueueResolutionState(
        queueId: 'auditor-evidence-gaps',
        cleared: true,
      ),
    );

    expect(brief, contains('Work queue: Audit evidence gaps'));
    expect(brief, contains('Clearance readiness: Waiting on review (75%)'));
    expect(brief, contains('Summary: 3 ready / 1 waiting / 0 blocked'));
    expect(brief, contains('1. Owner acknowledgement - Ready'));
    expect(brief, contains('2. Evidence pack - Ready'));
    expect(brief, contains('Reviewer sign-off: Approved'));
    expect(brief, contains('Queue resolution: Cleared'));
    expect(brief, contains('Captured actions: 2/3 actions captured'));
    expect(brief, contains('Next action: Log escalation outcome'));
  });
}
