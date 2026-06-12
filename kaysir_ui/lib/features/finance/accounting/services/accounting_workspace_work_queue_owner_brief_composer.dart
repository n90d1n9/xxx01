import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_clearance_checklist.dart';
import '../models/accounting_workspace_work_queue_detail.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_resolution_state.dart';

class AccountingWorkspaceWorkQueueOwnerBriefComposer {
  const AccountingWorkspaceWorkQueueOwnerBriefComposer();

  String compose({
    required AccountingWorkspaceWorkQueueDetail detail,
    required AccountingWorkspaceWorkQueueClearanceChecklist clearanceChecklist,
    required AccountingWorkspaceWorkQueueActivityActionState actionState,
    required AccountingWorkspaceWorkQueueReviewerSignOffState
    reviewerSignOffState,
    required AccountingWorkspaceWorkQueueResolutionState resolutionState,
  }) {
    return [
      detail.ownerBrief,
      '',
      clearanceChecklist.clearanceBrief,
      '',
      reviewerSignOffState.decisionBrief,
      '',
      resolutionState.resolutionBrief,
      '',
      actionState.auditActionBrief,
    ].join('\n');
  }
}
