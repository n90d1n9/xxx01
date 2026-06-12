import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/accounting_path.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_menu_search.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_role_preset.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_activity_action_state.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_clearance_checklist.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_escalation_plan.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_focus.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_risk_summary.dart';
import 'package:kaysir/features/finance/accounting/models/accounting_workspace_work_queue_sort.dart';
import 'package:kaysir/features/finance/accounting/services/accounting_workspace_work_queue_service.dart';

void main() {
  test('parses work queue focus route values', () {
    expect(
      accountingWorkspaceWorkQueueFocusFromQuery('critical'),
      AccountingWorkspaceWorkQueueFocus.blocked,
    );
    expect(
      accountingWorkspaceWorkQueueFocusFromQuery('warning'),
      AccountingWorkspaceWorkQueueFocus.review,
    );
    expect(
      accountingWorkspaceWorkQueueFocusFromQuery('info'),
      AccountingWorkspaceWorkQueueFocus.monitor,
    );
    expect(
      accountingWorkspaceWorkQueueFocusFromQuery('unknown'),
      AccountingWorkspaceWorkQueueFocus.all,
    );
  });

  test('parses work queue sort route values', () {
    expect(
      accountingWorkspaceWorkQueueSortFromQuery('urgent'),
      AccountingWorkspaceWorkQueueSort.urgent,
    );
    expect(
      accountingWorkspaceWorkQueueSortFromQuery('load'),
      AccountingWorkspaceWorkQueueSort.largest,
    );
    expect(
      accountingWorkspaceWorkQueueSortFromQuery('owner'),
      AccountingWorkspaceWorkQueueSort.owner,
    );
    expect(
      accountingWorkspaceWorkQueueSortFromQuery('unknown'),
      AccountingWorkspaceWorkQueueSort.workflow,
    );
  });

  test('returns controller work queues in operating order', () {
    const service = AccountingWorkspaceWorkQueueService();

    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    expect(queues.map((queue) => queue.id), [
      'controller-close-blockers',
      'controller-reconciliation-exceptions',
      'controller-release-approvals',
      'controller-report-pack-exceptions',
    ]);
    expect(queues.first.count, 4);
    expect(
      queues.first.severity,
      AccountingWorkspaceWorkQueueSeverity.critical,
    );
    expect(queues.first.ownerLabel, 'Controller');
    expect(queues.first.dueInDays, -1);
    expect(
      queues.first.slaStatus,
      AccountingWorkspaceWorkQueueSlaStatus.overdue,
    );
    expect(queues.first.dueLabel, '1 day overdue');
  });

  test('filters role work queues by owner and due labels', () {
    const service = AccountingWorkspaceWorkQueueService();

    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
      query: 'treasury due today',
    );

    expect(queues, hasLength(1));
    expect(queues.single.id, 'controller-reconciliation-exceptions');
    expect(queues.single.ownerLabel, 'Treasury lead');
    expect(queues.single.dueLabel, 'Due today');
  });

  test('filters auditor work queues by shortcut scope and evidence query', () {
    const service = AccountingWorkspaceWorkQueueService();

    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.auditor,
      query: 'evidence',
      scope: AccountingMenuSearchScope.shortcuts,
    );

    expect(queues, hasLength(1));
    expect(queues.single.id, 'auditor-evidence-gaps');
    expect(queues.single.path, AccountingPath.reportReleaseEvidence);
    expect(queues.single.registerRoute, isFalse);
  });

  test('builds actionable work queue detail for audit evidence gaps', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queue =
        service
            .queuesFor(
              rolePreset: AccountingWorkspaceRolePreset.auditor,
              query: 'evidence',
              scope: AccountingMenuSearchScope.shortcuts,
            )
            .single;

    final detail = service.detailFor(queue);

    expect(detail.queueId, 'auditor-evidence-gaps');
    expect(detail.rootCause, contains('Audit liaison'));
    expect(detail.rootCause, contains('5 open items'));
    expect(detail.evidenceNeeded, contains('Release manifest support'));
    expect(detail.controlObjective, contains('IFRS/SAK-aligned'));
    expect(detail.recommendedAction, contains('Escalate'));
    expect(
      detail.riskSummary.level,
      AccountingWorkspaceWorkQueueRiskLevel.critical,
    );
    expect(detail.riskSummary.score, 93);
    expect(detail.riskSummary.materialityLabel, 'High reporting materiality');
    expect(detail.riskSummary.controlRiskLabel, 'Release control risk');
    expect(detail.riskSummary.auditResponse, contains('Escalate today'));
    expect(
      detail.escalationPlan.tier,
      AccountingWorkspaceWorkQueueEscalationTier.releaseBlocker,
    );
    expect(detail.escalationPlan.escalationOwner, 'Audit liaison + Controller');
    expect(detail.escalationPlan.cadenceLabel, 'Daily until cleared');
    expect(
      detail.escalationPlan.deadlineLabel,
      'Today before release or close lock',
    );
    expect(detail.escalationPlan.governanceNote, contains('Block release'));
    expect(
      detail.clearanceChecklist.summaryLabel,
      '0 ready / 1 waiting / 3 blocked',
    );
    expect(detail.clearanceChecklist.blockedCount, 3);
    expect(detail.clearanceChecklist.waitingCount, 1);
    expect(detail.clearanceChecklist.readyCount, 0);
    expect(detail.clearanceChecklist.steps.map((step) => step.title), [
      'Owner acknowledgement',
      'Evidence pack',
      'Reviewer sign-off',
      'Release or close gate',
    ]);
    expect(detail.clearanceChecklist.steps.map((step) => step.status), [
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
      AccountingWorkspaceWorkQueueClearanceStatus.waiting,
      AccountingWorkspaceWorkQueueClearanceStatus.blocked,
    ]);
    expect(
      detail.clearanceChecklist.steps[1].evidenceLabel,
      contains('Release manifest support'),
    );
    expect(detail.ownerBrief, contains('Work queue: Audit evidence gaps'));
    expect(detail.ownerBrief, contains('Owner: Audit liaison'));
    expect(detail.ownerBrief, contains('SLA: 2 days overdue'));
    expect(detail.ownerBrief, contains('Status: Blocked'));
    expect(detail.ownerBrief, contains('Risk: Critical (93/100)'));
    expect(detail.ownerBrief, contains('Materiality: High reporting'));
    expect(detail.ownerBrief, contains('Control risk: Release control risk'));
    expect(detail.ownerBrief, contains('Escalation: Release blocker'));
    expect(
      detail.ownerBrief,
      contains('Escalation owner: Audit liaison + Controller'),
    );
    expect(detail.ownerBrief, contains('Cadence: Daily until cleared'));
    expect(
      detail.ownerBrief,
      contains('Clearance: 0 ready / 1 waiting / 3 blocked'),
    );
    expect(
      detail.complianceGuardrail.frameworkLabel,
      'IFRS-aligned SAK Indonesia release evidence',
    );
    expect(
      detail.complianceGuardrail.localRuleLabel,
      'OJK/IDX-style release governance and audit trail',
    );
    expect(
      detail.complianceGuardrail.retentionLabel,
      'Retain signed release pack and evidence manifest',
    );
    expect(
      detail.complianceGuardrail.filingImpactLabel,
      'Blocks report release readiness',
    );
    expect(
      detail.ownerBrief,
      contains('Framework: IFRS-aligned SAK Indonesia release evidence'),
    );
    expect(
      detail.ownerBrief,
      contains('Local rule: OJK/IDX-style release governance'),
    );
    expect(
      detail.ownerBrief,
      contains('Retention: Retain signed release pack'),
    );
    expect(detail.ownerBrief, contains('Filing impact: Blocks report release'));
    expect(
      detail.accountingImpact.statementAreaLabel,
      'Financial statement release package',
    );
    expect(
      detail.accountingImpact.assertionLabel,
      'Completeness and authorization of release evidence',
    );
    expect(
      detail.accountingImpact.taxImpactLabel,
      'No direct tax posting; indirect filing proof risk',
    );
    expect(
      detail.accountingImpact.closeGateLabel,
      'Block report release until evidence is signed off',
    );
    expect(
      detail.accountingImpact.journalActionLabel,
      'Disclosure evidence only',
    );
    expect(
      detail.accountingImpact.ledgerFocusLabel,
      'No debit/credit entry expected',
    );
    expect(
      detail.accountingImpact.postingGateLabel,
      'Do not release until evidence is tied out',
    );
    expect(
      detail.ownerBrief,
      contains('Statement area: Financial statement release package'),
    );
    expect(
      detail.ownerBrief,
      contains('Assertion: Completeness and authorization'),
    );
    expect(detail.ownerBrief, contains('Tax impact: No direct tax posting'));
    expect(detail.ownerBrief, contains('Close gate: Block report release'));
    expect(detail.ownerBrief, contains('Journal action: Disclosure evidence'));
    expect(
      detail.ownerBrief,
      contains('Ledger focus: No debit/credit entry expected'),
    );
    expect(
      detail.ownerBrief,
      contains('Posting gate: Do not release until evidence is tied out'),
    );
    expect(detail.evidenceRequest.recipientLabel, 'Audit liaison');
    expect(
      detail.evidenceRequest.subject,
      'Evidence request: Audit evidence gaps',
    );
    expect(
      detail.evidenceRequest.responseDueLabel,
      'Today before release or close lock',
    );
    expect(detail.evidenceRequest.statusLabel, 'Overdue follow-up');
    expect(detail.evidenceRequest.agingLabel, '2 days overdue');
    expect(detail.evidenceRequest.followUpLabel, 'Daily until cleared');
    expect(
      detail.evidenceRequest.nextTrackingActionLabel,
      'Send request and record owner response today',
    );
    expect(
      detail.evidenceRequest.requestedItems.first,
      contains('Release manifest support'),
    );
    expect(
      detail.evidenceRequest.requestedItems,
      contains('Retain signed release pack and evidence manifest'),
    );
    expect(
      detail.evidenceRequest.requestedItems,
      contains('Support completeness and authorization of release evidence'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Evidence request: Audit evidence gaps'),
    );
    expect(detail.evidenceRequest.requestBody, contains('To: Audit liaison'));
    expect(
      detail.evidenceRequest.requestBody,
      contains('Priority: Critical (93/100)'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Tracking: Overdue follow-up'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Follow-up: Daily until cleared'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Statement area: Financial statement release package'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Journal action: Disclosure evidence only'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Ledger focus: No debit/credit entry expected'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Close gate: Block report release'),
    );
    expect(
      detail.evidenceRequest.requestBody,
      contains('Tracking action: Send request and record owner response today'),
    );
    expect(detail.activityTrail.queueId, 'auditor-evidence-gaps');
    expect(detail.activityTrail.queueTitle, 'Audit evidence gaps');
    expect(
      detail.activityTrail.summaryLabel,
      '0 ready / 1 waiting / 3 blocked',
    );
    expect(
      detail.activityTrail.nextActionLabel,
      'Send request and record owner response today',
    );
    expect(detail.activityTrail.entries.map((entry) => entry.title), [
      'Queue triaged',
      'Evidence request issued',
      'Reviewer sign-off',
      'Escalation cadence set',
      'Retention rule attached',
    ]);
    expect(
      detail.activityTrail.entries[1].type,
      AccountingWorkspaceWorkQueueActivityType.evidence,
    );
    expect(
      detail.activityTrail.entries[1].detail,
      contains('Evidence request: Audit evidence gaps to Audit liaison'),
    );
    expect(
      detail.activityTrail.entries[3].actorLabel,
      'Audit liaison + Controller',
    );
    expect(
      detail.activityTrail.entries[4].detail,
      contains('OJK/IDX-style release governance and audit trail'),
    );
    expect(
      detail.activityTrail.auditTrailBrief,
      contains('Activity trail: Audit evidence gaps'),
    );
    expect(
      detail.activityTrail.auditTrailBrief,
      contains('Evidence: Evidence request issued'),
    );
    final auditBrief = detail.activityTrail.auditTrailBriefFor(
      const AccountingWorkspaceWorkQueueActivityActionState(
        queueId: 'auditor-evidence-gaps',
        ownerAcknowledged: true,
      ),
    );
    expect(auditBrief, contains('Activity trail: Audit evidence gaps'));
    expect(auditBrief, contains('Captured actions: 1/3 actions captured'));
    expect(auditBrief, contains('- Owner acknowledged: Yes'));
    expect(auditBrief, contains('- Evidence received: No'));
    expect(auditBrief, contains('Next action: Record evidence receipt'));
    expect(detail.ownerBrief, contains('Next action: Escalate'));
    expect(detail.checkpoints, contains('Record escalation note'));
    expect(detail.checkpoints, contains('Tie evidence to release manifest'));
  });

  test('summarizes work queue health by severity', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final health = service.summarize(queues);

    expect(health.queueCount, 4);
    expect(health.totalItems, 16);
    expect(health.blockedItems, 6);
    expect(health.reviewItems, 10);
    expect(health.monitorItems, 0);
    expect(health.hasBlockedItems, isTrue);
    expect(health.hasReviewItems, isTrue);
  });

  test('summarizes work queue SLA pressure', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final summary = service.summarizeSla(queues);

    expect(summary.queueCount, 4);
    expect(summary.overdueQueueCount, 2);
    expect(summary.dueTodayQueueCount, 1);
    expect(summary.onTrackQueueCount, 1);
    expect(summary.overdueItems, 6);
    expect(summary.dueTodayItems, 7);
    expect(summary.onTrackItems, 3);
    expect(summary.timeSensitiveItems, 13);
    expect(summary.worstOverdueDays, 2);
    expect(summary.hasTimeSensitiveItems, isTrue);
  });

  test('summarizes close readiness from release and posting gates', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final readiness = service.summarizeCloseReadiness(queues);

    expect(readiness.queueCount, 4);
    expect(readiness.totalItems, 16);
    expect(readiness.releaseBlockerItems, 6);
    expect(readiness.evidenceRequestItems, 13);
    expect(readiness.postingGateItems, 14);
    expect(readiness.readinessScore, 37);
    expect(readiness.scoreLabel, '37% ready');
    expect(readiness.lockGateLabel, 'Lock blocked');
    expect(readiness.primaryDriverItemCount, 13);
    expect(readiness.primaryDriverLabel, 'Evidence requests');
    expect(readiness.primaryDriverDetailLabel, '13 items need owner follow-up');
    expect(readiness.hasNextAction, isTrue);
    expect(readiness.hasActionPlan, isTrue);
    expect(readiness.actionPlanCount, 3);
    expect(readiness.actionPlan.map((action) => action.queueId), [
      'controller-close-blockers',
      'controller-release-approvals',
      'controller-reconciliation-exceptions',
    ]);
    expect(readiness.actionPlan.map((action) => action.rank), [1, 2, 3]);
    expect(readiness.actionPlan.map((action) => action.urgencyLabel), [
      'Critical overdue',
      'Critical overdue',
      'Due today',
    ]);
    expect(readiness.nextAction?.queueId, 'controller-close-blockers');
    expect(readiness.nextAction?.rankLabel, '#1');
    expect(readiness.nextAction?.title, 'Close blockers');
    expect(readiness.nextAction?.urgencyLabel, 'Critical overdue');
    expect(readiness.nextAction?.ownerLabel, 'Controller');
    expect(readiness.nextAction?.dueLabel, '1 day overdue');
    expect(readiness.nextAction?.reasonLabel, 'Release blocker');
    expect(
      readiness.nextAction?.detailLabel,
      'Release blocker · Controller · 1 day overdue',
    );
    expect(
      readiness.nextAction?.previewLabel,
      '#1 Critical overdue · Release blocker · Controller · 1 day overdue',
    );
    expect(
      readiness.actionPlanBrief,
      contains('Close readiness: Release blocked (37% ready)'),
    );
    expect(readiness.actionPlanBrief, contains('Lock gate: Lock blocked'));
    expect(
      readiness.actionPlanBrief,
      contains(
        'Primary driver: Evidence requests - 13 items need owner follow-up',
      ),
    );
    expect(
      readiness.actionPlanBrief,
      contains(
        '1. Close blockers - Critical overdue - Release blocker - Controller',
      ),
    );
    expect(
      readiness.actionPlanBrief,
      contains(
        '2. Release approvals - Critical overdue - Release blocker - '
        'Report approver',
      ),
    );
    expect(readiness.statusLabel, 'Release blocked');
    expect(
      readiness.statusDetailLabel,
      '6 blockers | 13 evidence | 14 posting',
    );
    expect(
      readiness.actionLabel,
      'Clear release blockers before close or reporting lock',
    );
    expect(readiness.hasReleaseBlockers, isTrue);
    expect(readiness.hasEvidenceRequests, isTrue);
    expect(readiness.hasPostingGates, isTrue);
  });

  test('summarizes owner load by SLA pressure', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final summary = service.summarizeOwners(queues);

    expect(summary.ownerCount, 4);
    expect(summary.primaryOwner?.ownerLabel, 'Controller');
    expect(summary.primaryOwner?.totalItems, 4);
    expect(summary.primaryOwner?.overdueItems, 4);
    expect(summary.primaryOwner?.criticalItems, 4);
    expect(summary.primaryOwner?.worstOverdueDays, 1);
    expect(summary.owners.map((owner) => owner.ownerLabel), [
      'Controller',
      'Report approver',
      'Treasury lead',
      'Reporting lead',
    ]);
  });

  test('sorts work queues by triage mode', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final urgent = service.sortQueues(
      queues,
      AccountingWorkspaceWorkQueueSort.urgent,
    );
    final largest = service.sortQueues(
      queues,
      AccountingWorkspaceWorkQueueSort.largest,
    );
    final owner = service.sortQueues(
      queues,
      AccountingWorkspaceWorkQueueSort.owner,
    );

    expect(urgent.map((queue) => queue.id), [
      'controller-release-approvals',
      'controller-close-blockers',
      'controller-reconciliation-exceptions',
      'controller-report-pack-exceptions',
    ]);
    expect(largest.map((queue) => queue.id), [
      'controller-reconciliation-exceptions',
      'controller-close-blockers',
      'controller-report-pack-exceptions',
      'controller-release-approvals',
    ]);
    expect(owner.map((queue) => queue.id), [
      'controller-close-blockers',
      'controller-release-approvals',
      'controller-report-pack-exceptions',
      'controller-reconciliation-exceptions',
    ]);
    expect(queues.map((queue) => queue.id), [
      'controller-close-blockers',
      'controller-reconciliation-exceptions',
      'controller-release-approvals',
      'controller-report-pack-exceptions',
    ]);
  });

  test('filters work queues by operating focus', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final blocked = service.filterByFocus(
      queues,
      AccountingWorkspaceWorkQueueFocus.blocked,
    );
    final review = service.filterByFocus(
      queues,
      AccountingWorkspaceWorkQueueFocus.review,
    );
    final monitor = service.filterByFocus(
      queues,
      AccountingWorkspaceWorkQueueFocus.monitor,
    );

    expect(blocked.map((queue) => queue.id), [
      'controller-close-blockers',
      'controller-release-approvals',
    ]);
    expect(review.map((queue) => queue.id), [
      'controller-reconciliation-exceptions',
      'controller-report-pack-exceptions',
    ]);
    expect(monitor, isEmpty);
  });

  test('filters work queues by owner label', () {
    const service = AccountingWorkspaceWorkQueueService();
    final queues = service.queuesFor(
      rolePreset: AccountingWorkspaceRolePreset.controller,
    );

    final controller = service.filterByOwner(queues, ' controller ');
    final approver = service.filterByOwner(queues, 'report approver');
    final all = service.filterByOwner(queues, null);

    expect(controller.map((queue) => queue.id), ['controller-close-blockers']);
    expect(approver.map((queue) => queue.id), ['controller-release-approvals']);
    expect(all.map((queue) => queue.id), [
      'controller-close-blockers',
      'controller-reconciliation-exceptions',
      'controller-release-approvals',
      'controller-report-pack-exceptions',
    ]);
  });
}
