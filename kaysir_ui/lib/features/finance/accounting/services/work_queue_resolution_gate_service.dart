import '../models/accounting_workspace_work_queue_clearance_checklist.dart';
import '../models/work_queue_evidence_readiness.dart';
import '../models/work_queue_resolution_state.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';

/// Resolved gate state that decides whether a work queue can be cleared.
class AccountingWorkspaceWorkQueueResolutionGate {
  AccountingWorkspaceWorkQueueResolutionGate({
    required this.canClear,
    required this.isCleared,
    required this.statusLabel,
    required this.detailLabel,
    required this.nextActionLabel,
    required Iterable<String> blockers,
  }) : blockers = List<String>.unmodifiable(blockers);

  final bool canClear;
  final bool isCleared;
  final String statusLabel;
  final String detailLabel;
  final String nextActionLabel;
  final List<String> blockers;

  bool get hasBlockers => blockers.isNotEmpty;
}

/// Applies close-clearance, reviewer sign-off, and evidence readiness gates.
class AccountingWorkspaceWorkQueueResolutionGateService {
  const AccountingWorkspaceWorkQueueResolutionGateService();

  AccountingWorkspaceWorkQueueResolutionGate resolve({
    required AccountingWorkspaceWorkQueueClearanceChecklist clearanceChecklist,
    required AccountingWorkspaceWorkQueueReviewerSignOffState
    reviewerSignOffState,
    required AccountingWorkspaceWorkQueueResolutionState resolutionState,
    AccountingWorkspaceWorkQueueEvidenceReadiness? evidenceReadiness,
  }) {
    if (resolutionState.cleared) {
      return AccountingWorkspaceWorkQueueResolutionGate(
        canClear: false,
        isCleared: true,
        statusLabel: 'Queue cleared',
        detailLabel: 'Clearance has been recorded for this queue',
        nextActionLabel: 'Retain evidence and monitor changes',
        blockers: const [],
      );
    }

    if (evidenceReadiness != null &&
        evidenceReadiness.status !=
            AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready) {
      return AccountingWorkspaceWorkQueueResolutionGate(
        canClear: false,
        isCleared: false,
        statusLabel: 'Evidence gate blocked',
        detailLabel: evidenceReadiness.detailLabel,
        nextActionLabel: evidenceReadiness.nextActionLabel,
        blockers: const ['Accepted evidence'],
      );
    }

    if (!reviewerSignOffState.isApproved) {
      return AccountingWorkspaceWorkQueueResolutionGate(
        canClear: false,
        isCleared: false,
        statusLabel: 'Reviewer sign-off required',
        detailLabel: reviewerSignOffState.detailLabel,
        nextActionLabel: reviewerSignOffState.nextActionLabel,
        blockers: const ['Reviewer sign-off'],
      );
    }

    final nextOpenStep = clearanceChecklist.nextOpenStep;
    if (nextOpenStep == null) {
      return AccountingWorkspaceWorkQueueResolutionGate(
        canClear: true,
        isCleared: false,
        statusLabel: 'Ready to clear',
        detailLabel: 'All clearance steps are ready',
        nextActionLabel: 'Mark queue cleared',
        blockers: const [],
      );
    }

    return AccountingWorkspaceWorkQueueResolutionGate(
      canClear: false,
      isCleared: false,
      statusLabel:
          clearanceChecklist.blockedCount > 0
              ? 'Clearance blocked'
              : 'Waiting on clearance',
      detailLabel: 'Resolve ${nextOpenStep.title} before clearing',
      nextActionLabel: clearanceChecklist.nextActionLabel,
      blockers: [
        for (final step in clearanceChecklist.steps)
          if (step.status != AccountingWorkspaceWorkQueueClearanceStatus.ready)
            step.title,
      ],
    );
  }
}
