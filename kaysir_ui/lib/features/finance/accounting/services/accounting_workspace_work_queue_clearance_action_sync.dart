import '../models/accounting_workspace_work_queue_activity_action_state.dart';
import '../models/accounting_workspace_work_queue_clearance_checklist.dart';
import '../models/accounting_workspace_work_queue_reviewer_sign_off_state.dart';
import '../models/work_queue_evidence_readiness.dart';

/// Synchronizes clearance checklist steps from captured work queue evidence.
class AccountingWorkspaceWorkQueueClearanceActionSync {
  const AccountingWorkspaceWorkQueueClearanceActionSync();

  AccountingWorkspaceWorkQueueClearanceChecklist sync({
    required AccountingWorkspaceWorkQueueClearanceChecklist checklist,
    required AccountingWorkspaceWorkQueueActivityActionState actionState,
    AccountingWorkspaceWorkQueueReviewerSignOffState? reviewerSignOffState,
    AccountingWorkspaceWorkQueueEvidenceReadiness? evidenceReadiness,
  }) {
    final hasReviewerDecision = reviewerSignOffState?.hasDecision ?? false;
    final hasEvidenceReadiness = evidenceReadiness != null;
    if (actionState.completedActionCount == 0 &&
        !hasReviewerDecision &&
        !hasEvidenceReadiness) {
      return checklist;
    }

    return AccountingWorkspaceWorkQueueClearanceChecklist(
      steps: [
        for (final step in checklist.steps)
          step.copyWith(
            status: _syncedStatus(
              step,
              actionState,
              reviewerSignOffState: reviewerSignOffState,
              evidenceReadiness: evidenceReadiness,
            ),
          ),
      ],
    );
  }

  AccountingWorkspaceWorkQueueClearanceStatus _syncedStatus(
    AccountingWorkspaceWorkQueueClearanceStep step,
    AccountingWorkspaceWorkQueueActivityActionState actionState, {
    AccountingWorkspaceWorkQueueReviewerSignOffState? reviewerSignOffState,
    AccountingWorkspaceWorkQueueEvidenceReadiness? evidenceReadiness,
  }) {
    final reviewerDecision = reviewerSignOffState?.decision;
    final evidenceQueueId = evidenceReadiness?.queueId;
    final isEvidenceReady =
        evidenceReadiness?.status ==
        AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready;

    if (step.id == '${actionState.queueId}-owner-acknowledgement' &&
        actionState.ownerAcknowledged) {
      return _promoteStatus(
        step.status,
        AccountingWorkspaceWorkQueueClearanceStatus.ready,
      );
    }

    if (step.id == '${actionState.queueId}-evidence-pack' ||
        step.id == '$evidenceQueueId-evidence-pack') {
      if (evidenceReadiness != null) {
        return _evidenceSyncedStatus(step.status, evidenceReadiness);
      }

      if (actionState.evidenceReceived) {
        return _promoteStatus(
          step.status,
          AccountingWorkspaceWorkQueueClearanceStatus.ready,
        );
      }
    }

    if ((step.id == '${actionState.queueId}-reviewer-signoff' ||
            step.id == '$evidenceQueueId-reviewer-signoff') &&
        evidenceReadiness != null &&
        !isEvidenceReady) {
      return _evidenceSyncedStatus(step.status, evidenceReadiness);
    }

    if (step.id == '${actionState.queueId}-reviewer-signoff' &&
        actionState.ownerAcknowledged &&
        (evidenceReadiness == null
            ? actionState.evidenceReceived
            : isEvidenceReady)) {
      final actionSyncedStatus = _promoteStatus(
        step.status,
        AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      );

      return _reviewerSyncedStatus(
        actionSyncedStatus,
        reviewerDecision,
        reviewerStep: true,
      );
    }

    if (step.id == '${actionState.queueId}-gate-decision') {
      if (reviewerDecision ==
              AccountingWorkspaceWorkQueueReviewerDecision.returned ||
          reviewerDecision ==
              AccountingWorkspaceWorkQueueReviewerDecision.blocked) {
        return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
      }

      if (evidenceReadiness != null && !isEvidenceReady) {
        return _evidenceSyncedStatus(step.status, evidenceReadiness);
      }

      if (actionState.escalationLogged) {
        return _promoteStatus(
          step.status,
          AccountingWorkspaceWorkQueueClearanceStatus.ready,
        );
      }

      if (actionState.ownerAcknowledged &&
          (evidenceReadiness == null
              ? actionState.evidenceReceived
              : isEvidenceReady)) {
        return _promoteStatus(
          step.status,
          AccountingWorkspaceWorkQueueClearanceStatus.waiting,
        );
      }
    }

    if (step.id == '${reviewerSignOffState?.queueId}-reviewer-signoff') {
      if (evidenceReadiness != null && !isEvidenceReady) {
        return _evidenceSyncedStatus(step.status, evidenceReadiness);
      }

      return _reviewerSyncedStatus(
        step.status,
        reviewerDecision,
        reviewerStep: true,
      );
    }

    if (step.id == '${reviewerSignOffState?.queueId}-gate-decision') {
      if (evidenceReadiness != null && !isEvidenceReady) {
        return _evidenceSyncedStatus(step.status, evidenceReadiness);
      }

      return _reviewerSyncedStatus(step.status, reviewerDecision);
    }

    return step.status;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _evidenceSyncedStatus(
  AccountingWorkspaceWorkQueueClearanceStatus current,
  AccountingWorkspaceWorkQueueEvidenceReadiness readiness,
) {
  switch (readiness.status) {
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.ready:
      return _promoteStatus(
        current,
        AccountingWorkspaceWorkQueueClearanceStatus.ready,
      );
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.reviewNeeded:
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.partial:
      return AccountingWorkspaceWorkQueueClearanceStatus.waiting;
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.missing:
    case AccountingWorkspaceWorkQueueEvidenceReadinessStatus.rework:
      return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _reviewerSyncedStatus(
  AccountingWorkspaceWorkQueueClearanceStatus current,
  AccountingWorkspaceWorkQueueReviewerDecision? decision, {
  bool reviewerStep = false,
}) {
  switch (decision) {
    case AccountingWorkspaceWorkQueueReviewerDecision.approved:
      return _promoteStatus(
        current,
        reviewerStep
            ? AccountingWorkspaceWorkQueueClearanceStatus.ready
            : AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      );
    case AccountingWorkspaceWorkQueueReviewerDecision.returned:
    case AccountingWorkspaceWorkQueueReviewerDecision.blocked:
      return AccountingWorkspaceWorkQueueClearanceStatus.blocked;
    case AccountingWorkspaceWorkQueueReviewerDecision.pending:
    case null:
      return current;
  }
}

AccountingWorkspaceWorkQueueClearanceStatus _promoteStatus(
  AccountingWorkspaceWorkQueueClearanceStatus current,
  AccountingWorkspaceWorkQueueClearanceStatus candidate,
) {
  if (candidate.index > current.index) return candidate;

  return current;
}
