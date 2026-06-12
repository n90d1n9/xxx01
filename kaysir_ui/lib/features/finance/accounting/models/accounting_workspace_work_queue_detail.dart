import 'accounting_workspace_work_queue_accounting_impact.dart';
import 'accounting_workspace_work_queue_activity.dart';
import 'accounting_workspace_work_queue_clearance_checklist.dart';
import 'accounting_workspace_work_queue_compliance_guardrail.dart';
import 'accounting_workspace_work_queue_escalation_plan.dart';
import 'accounting_workspace_work_queue_evidence_request.dart';
import 'accounting_workspace_work_queue_risk_summary.dart';

class AccountingWorkspaceWorkQueueDetail {
  AccountingWorkspaceWorkQueueDetail({
    required this.queueId,
    required this.rootCause,
    required this.evidenceNeeded,
    required this.controlObjective,
    required this.recommendedAction,
    required this.riskSummary,
    required this.escalationPlan,
    required this.clearanceChecklist,
    required this.complianceGuardrail,
    required this.accountingImpact,
    required this.evidenceRequest,
    required this.activityTrail,
    required this.ownerBrief,
    required Iterable<String> checkpoints,
  }) : checkpoints = List<String>.unmodifiable(checkpoints);

  final String queueId;
  final String rootCause;
  final String evidenceNeeded;
  final String controlObjective;
  final String recommendedAction;
  final AccountingWorkspaceWorkQueueRiskSummary riskSummary;
  final AccountingWorkspaceWorkQueueEscalationPlan escalationPlan;
  final AccountingWorkspaceWorkQueueClearanceChecklist clearanceChecklist;
  final AccountingWorkspaceWorkQueueComplianceGuardrail complianceGuardrail;
  final AccountingWorkspaceWorkQueueAccountingImpact accountingImpact;
  final AccountingWorkspaceWorkQueueEvidenceRequest evidenceRequest;
  final AccountingWorkspaceWorkQueueActivityTrail activityTrail;
  final String ownerBrief;
  final List<String> checkpoints;
}
