import '../models/accounting_workspace_work_queue.dart';
import '../models/accounting_workspace_work_queue_accounting_impact.dart';
import '../models/accounting_workspace_work_queue_compliance_guardrail.dart';
import '../models/accounting_workspace_work_queue_escalation_plan.dart';
import '../models/accounting_workspace_work_queue_evidence_request.dart';
import '../models/accounting_workspace_work_queue_risk_summary.dart';

class AccountingWorkspaceWorkQueueEvidenceRequestBuilder {
  const AccountingWorkspaceWorkQueueEvidenceRequestBuilder();

  AccountingWorkspaceWorkQueueEvidenceRequest build({
    required AccountingWorkspaceWorkQueue queue,
    required String evidenceNeeded,
    required String recommendedAction,
    required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
    required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
    required AccountingWorkspaceWorkQueueComplianceGuardrail
    complianceGuardrail,
    required AccountingWorkspaceWorkQueueAccountingImpact accountingImpact,
  }) {
    final requestedItems = _requestedItems(
      evidenceNeeded: evidenceNeeded,
      riskSummary: riskSummary,
      escalationPlan: escalationPlan,
      complianceGuardrail: complianceGuardrail,
      accountingImpact: accountingImpact,
    );
    final subject = 'Evidence request: ${queue.title}';
    final statusLabel = _trackingStatusLabel(queue);
    final nextTrackingActionLabel = _nextTrackingActionLabel(queue);

    return AccountingWorkspaceWorkQueueEvidenceRequest(
      recipientLabel: queue.ownerLabel,
      subject: subject,
      responseDueLabel: escalationPlan.deadlineLabel,
      statusLabel: statusLabel,
      agingLabel: queue.dueLabel,
      followUpLabel: escalationPlan.cadenceLabel,
      nextTrackingActionLabel: nextTrackingActionLabel,
      requestedItems: requestedItems,
      requestBody: _requestBody(
        queue: queue,
        subject: subject,
        requestedItems: requestedItems,
        statusLabel: statusLabel,
        followUpLabel: escalationPlan.cadenceLabel,
        nextTrackingActionLabel: nextTrackingActionLabel,
        recommendedAction: recommendedAction,
        riskSummary: riskSummary,
        escalationPlan: escalationPlan,
        complianceGuardrail: complianceGuardrail,
        accountingImpact: accountingImpact,
      ),
    );
  }
}

List<String> _requestedItems({
  required String evidenceNeeded,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
  required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
  required AccountingWorkspaceWorkQueueComplianceGuardrail complianceGuardrail,
  required AccountingWorkspaceWorkQueueAccountingImpact accountingImpact,
}) {
  return [
    evidenceNeeded,
    complianceGuardrail.retentionLabel,
    'Support ${accountingImpact.assertionLabel.toLowerCase()}',
    if (riskSummary.level == AccountingWorkspaceWorkQueueRiskLevel.critical ||
        riskSummary.level == AccountingWorkspaceWorkQueueRiskLevel.high)
      escalationPlan.governanceNote,
  ];
}

String _trackingStatusLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return 'Overdue follow-up';
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 'Due today follow-up';
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return 'Draft request';
  }
}

String _nextTrackingActionLabel(AccountingWorkspaceWorkQueue queue) {
  switch (queue.slaStatus) {
    case AccountingWorkspaceWorkQueueSlaStatus.overdue:
      return 'Send request and record owner response today';
    case AccountingWorkspaceWorkQueueSlaStatus.dueToday:
      return 'Send request before the close checkpoint';
    case AccountingWorkspaceWorkQueueSlaStatus.onTrack:
      return 'Prepare request and monitor before due date';
  }
}

String _requestBody({
  required AccountingWorkspaceWorkQueue queue,
  required String subject,
  required List<String> requestedItems,
  required String statusLabel,
  required String followUpLabel,
  required String nextTrackingActionLabel,
  required String recommendedAction,
  required AccountingWorkspaceWorkQueueRiskSummary riskSummary,
  required AccountingWorkspaceWorkQueueEscalationPlan escalationPlan,
  required AccountingWorkspaceWorkQueueComplianceGuardrail complianceGuardrail,
  required AccountingWorkspaceWorkQueueAccountingImpact accountingImpact,
}) {
  return [
    subject,
    'To: ${queue.ownerLabel}',
    'SLA: ${queue.dueLabel}',
    'Response due: ${escalationPlan.deadlineLabel}',
    'Priority: ${riskSummary.levelLabel} (${riskSummary.score}/100)',
    'Tracking: $statusLabel',
    'Follow-up: $followUpLabel',
    '',
    'Please provide:',
    for (final item in requestedItems) '- $item',
    '',
    'Accounting context:',
    '- Statement area: ${accountingImpact.statementAreaLabel}',
    '- Assertion: ${accountingImpact.assertionLabel}',
    '- Framework: ${complianceGuardrail.frameworkLabel}',
    '- Local rule: ${complianceGuardrail.localRuleLabel}',
    '- Journal action: ${accountingImpact.journalActionLabel}',
    '- Ledger focus: ${accountingImpact.ledgerFocusLabel}',
    '- Close gate: ${accountingImpact.closeGateLabel}',
    '',
    'Tracking action: $nextTrackingActionLabel',
    'Recommended action: $recommendedAction',
  ].join('\n');
}
