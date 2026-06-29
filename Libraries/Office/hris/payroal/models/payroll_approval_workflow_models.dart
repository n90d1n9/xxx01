import 'payroll_configuration_models.dart';
import 'payroll_cost_center_budget_models.dart';
import 'payroll_funding_authorization_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_builder_models.dart';
import 'payroll_run_models.dart';

enum PayrollApprovalStageStatus {
  blocked('Blocked'),
  ready('Ready'),
  approved('Approved');

  final String label;

  const PayrollApprovalStageStatus(this.label);
}

class PayrollApprovalRecord {
  final String stageId;
  final String approvedBy;
  final DateTime approvedAt;
  final String note;

  const PayrollApprovalRecord({
    required this.stageId,
    required this.approvedBy,
    required this.approvedAt,
    required this.note,
  });
}

class PayrollApprovalStage {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final List<String> blockers;
  final PayrollApprovalRecord? approval;

  const PayrollApprovalStage({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.blockers,
    required this.approval,
  });

  PayrollApprovalStageStatus get status {
    if (approval != null) return PayrollApprovalStageStatus.approved;
    if (blockers.isNotEmpty) return PayrollApprovalStageStatus.blocked;
    return PayrollApprovalStageStatus.ready;
  }

  bool get canApprove => status == PayrollApprovalStageStatus.ready;

  bool get canReopen => approval != null;

  String get nextAction {
    if (approval != null) return '${approval!.approvedBy} approved this stage.';
    if (blockers.isNotEmpty) return blockers.first;
    return 'Approve $title.';
  }
}

class PayrollApprovalWorkflowSummary {
  final String periodLabel;
  final List<PayrollApprovalStage> stages;

  const PayrollApprovalWorkflowSummary({
    required this.periodLabel,
    required this.stages,
  });

  factory PayrollApprovalWorkflowSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollActiveRunPlanSummary activeRunPlan,
    required PayrollConfigurationSummary configuration,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required PayrollReconciliationSummary reconciliation,
    required PayrollFundingAuthorizationSummary fundingAuthorization,
    required Map<String, PayrollApprovalRecord> approvals,
  }) {
    PayrollApprovalRecord? record(String stageId) => approvals[stageId];
    final hasActivePlan = activeRunPlan.hasActivePlan;
    final configurationReady =
        configuration.status != PayrollConfigurationStatus.blocked;
    final exceptionsClear = dashboard.openExceptionCount == 0;
    final adjustmentsClear = dashboard.pendingAdjustmentCount == 0;
    final budgetsApproved = costCenterBudgets.pendingApprovalCount == 0;

    final hrApproved = approvals.containsKey('hr-review');
    final financeApproved = approvals.containsKey('finance-review');
    final managerApproved = approvals.containsKey('payroll-manager');

    return PayrollApprovalWorkflowSummary(
      periodLabel: dashboard.periodLabel,
      stages: [
        PayrollApprovalStage(
          id: 'hr-review',
          title: 'HR review',
          owner: 'HR Operations',
          detail:
              configurationReady
                  ? 'Employee setup and payroll policy are ready for HR review.'
                  : configuration.nextAction,
          blockers: [
            if (!hasActivePlan) activeRunPlan.nextAction,
            if (!configurationReady) configuration.nextAction,
            if (!exceptionsClear)
              '${dashboard.openExceptionCount} payroll exceptions remain open',
          ],
          approval: record('hr-review'),
        ),
        PayrollApprovalStage(
          id: 'finance-review',
          title: 'Finance review',
          owner: 'Finance Partner',
          detail:
              reconciliation.isReviewed
                  ? 'Reconciliation and cost center release evidence are reviewed.'
                  : reconciliation.nextAction,
          blockers: [
            if (!hrApproved) 'HR review must be approved first',
            if (!budgetsApproved)
              '${costCenterBudgets.pendingApprovalCount} cost center approvals pending',
            if (!reconciliation.isReviewed)
              'Payroll reconciliation is not reviewed',
          ],
          approval: record('finance-review'),
        ),
        PayrollApprovalStage(
          id: 'payroll-manager',
          title: 'Payroll manager approval',
          owner: 'Payroll Manager',
          detail:
              adjustmentsClear
                  ? 'Run plan, adjustments, and close evidence are ready for manager approval.'
                  : dashboard.nextAction,
          blockers: [
            if (!financeApproved) 'Finance review must be approved first',
            if (!adjustmentsClear)
              '${dashboard.pendingAdjustmentCount} payroll adjustments need approval',
            if (!hasActivePlan) activeRunPlan.nextAction,
          ],
          approval: record('payroll-manager'),
        ),
        PayrollApprovalStage(
          id: 'final-release',
          title: 'Final release authorization',
          owner: 'Payroll Controller',
          detail:
              fundingAuthorization.isAuthorizedForRelease
                  ? 'Funding is authorized for final payroll release.'
                  : fundingAuthorization.nextAction,
          blockers: [
            if (!managerApproved)
              'Payroll manager approval must be completed first',
            if (!fundingAuthorization.isAuthorizedForRelease)
              fundingAuthorization.nextAction,
          ],
          approval: record('final-release'),
        ),
      ],
    );
  }

  int get approvedCount {
    return stages
        .where((stage) => stage.status == PayrollApprovalStageStatus.approved)
        .length;
  }

  int get readyCount {
    return stages
        .where((stage) => stage.status == PayrollApprovalStageStatus.ready)
        .length;
  }

  int get blockedCount {
    return stages
        .where((stage) => stage.status == PayrollApprovalStageStatus.blocked)
        .length;
  }

  bool get isFullyApproved => approvedCount == stages.length;

  PayrollApprovalStage? get nextStage {
    for (final stage in stages) {
      if (stage.status != PayrollApprovalStageStatus.approved) return stage;
    }
    return null;
  }

  bool get canReleasePayments {
    return stages.any(
      (stage) =>
          stage.id == 'final-release' &&
          stage.status == PayrollApprovalStageStatus.approved,
    );
  }

  String get nextAction {
    if (isFullyApproved) return 'Payroll approvals are complete.';
    return nextStage?.nextAction ?? 'Payroll approvals are complete.';
  }
}
