import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_activity.dart';
import '../models/accounting_workspace_work_queue_accounting_impact.dart';
import '../models/accounting_workspace_work_queue_clearance_checklist.dart';
import '../models/accounting_workspace_work_queue_compliance_guardrail.dart';
import '../models/accounting_workspace_work_queue_escalation_plan.dart';
import '../models/accounting_workspace_work_queue_evidence_request.dart';
import '../models/accounting_workspace_work_queue_risk_summary.dart';

class AccountingWorkspaceWorkQueueActivityBuilder {
  const AccountingWorkspaceWorkQueueActivityBuilder();

  AccountingWorkspaceWorkQueueActivityTrail build({
    required AccountingWorkspaceWorkQueue queue,
    required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
    required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
    required AccountingWorkspaceWorkQueueClearanceChecklist clearanceChecklist,
    required AccountingWorkspaceWorkQueueComplianceGuardrail
    complianceGuardrail,
    required AccountingWorkspaceWorkQueueAccountingImpact accountingImpact,
    required AccountingWorkspaceWorkQueueEvidenceRequest evidenceRequest,
  }) {
    final reviewerStep = _stepByTitle(clearanceChecklist, 'Reviewer sign-off');
    final gateStep = _stepByTitle(clearanceChecklist, 'Release or close gate');
    final itemLabel = queue.count == 1 ? '1 item' : '${queue.count} items';

    return AccountingWorkspaceWorkQueueActivityTrail(
      queueId: queue.id,
      queueTitle: queue.title,
      ownerLabel: queue.ownerLabel,
      dueLabel: queue.dueLabel,
      summaryLabel: clearanceChecklist.summaryLabel,
      nextActionLabel: evidenceRequest.nextTrackingActionLabel,
      entries: [
        AccountingWorkspaceWorkQueueActivityEntry(
          id: '${queue.id}-activity-triage',
          type: AccountingWorkspaceWorkQueueActivityType.status,
          title: 'Queue triaged',
          detail:
              '$itemLabel mapped to ${riskSummary.materialityLabel} and '
              '${riskSummary.controlRiskLabel}.',
          actorLabel: 'Kaysir control engine',
          timeLabel: _triageTimeLabel(queue),
          statusLabel: _queueStatusLabel(queue),
        ),
        AccountingWorkspaceWorkQueueActivityEntry(
          id: '${queue.id}-activity-evidence-request',
          type: AccountingWorkspaceWorkQueueActivityType.evidence,
          title: 'Evidence request issued',
          detail:
              '${evidenceRequest.subject} to '
              '${evidenceRequest.recipientLabel}. '
              '${evidenceRequest.nextTrackingActionLabel}.',
          actorLabel: 'Accounting workspace',
          timeLabel: 'Today',
          statusLabel: evidenceRequest.statusLabel,
        ),
        AccountingWorkspaceWorkQueueActivityEntry(
          id: '${queue.id}-activity-reviewer-signoff',
          type: AccountingWorkspaceWorkQueueActivityType.approval,
          title: reviewerStep.title,
          detail: '${reviewerStep.statusLabel}: ${reviewerStep.evidenceLabel}',
          actorLabel: reviewerStep.ownerLabel,
          timeLabel: _reviewTimeLabel(queue),
          statusLabel: reviewerStep.statusLabel,
        ),
        AccountingWorkspaceWorkQueueActivityEntry(
          id: '${queue.id}-activity-escalation',
          type: AccountingWorkspaceWorkQueueActivityType.escalation,
          title: 'Escalation cadence set',
          detail:
              '${escalationPlan.governanceNote} '
              '${accountingImpact.closeGateLabel}.',
          actorLabel: escalationPlan.escalationOwner,
          timeLabel: escalationPlan.deadlineLabel,
          statusLabel: escalationPlan.cadenceLabel,
        ),
        AccountingWorkspaceWorkQueueActivityEntry(
          id: '${queue.id}-activity-retention',
          type: AccountingWorkspaceWorkQueueActivityType.retention,
          title: 'Retention rule attached',
          detail:
              '${complianceGuardrail.retentionLabel}. '
              '${complianceGuardrail.localRuleLabel}.',
          actorLabel: gateStep.ownerLabel,
          timeLabel: 'Before archive',
          statusLabel: complianceGuardrail.frameworkLabel,
        ),
      ],
    );
  }

  AccountingWorkspaceWorkQueueClearanceStep _stepByTitle(
    AccountingWorkspaceWorkQueueClearanceChecklist checklist,
    String title,
  ) {
    for (final step in checklist.steps) {
      if (step.title == title) return step;
    }

    return checklist.steps.last;
  }

  String _triageTimeLabel(AccountingWorkspaceWorkQueue queue) {
    switch (queue.slaStatus) {
      case AccountingWorkspaceWorkQueueSlaStatus.overdue:
        return '${queue.dueInDays.abs()} day(s) overdue';
      case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
        return 'Due today';
      case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
        return queue.dueLabel;
    }
  }

  String _reviewTimeLabel(AccountingWorkspaceWorkQueue queue) {
    switch (queue.slaStatus) {
      case AccountingWorkspaceWorkQueueSlaStatus.overdue:
        return 'Before close lock';
      case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
        return 'Before SLA end';
      case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
        return 'Before due date';
    }
  }

  String _queueStatusLabel(AccountingWorkspaceWorkQueue queue) {
    switch (queue.severity) {
      case AccountingWorkspaceWorkQueueSeverity.critical:
        return 'Blocked';
      case AccountingWorkspaceWorkQueueSeverity.warning:
        return 'Needs review';
      case AccountingWorkspaceWorkQueueSeverity.info:
        return 'Monitoring';
    }
  }
}
