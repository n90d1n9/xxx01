import 'payroll_approval_workflow_models.dart';
import 'payroll_exception_resolution_models.dart';
import 'payroll_funding_authorization_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_distribution_models.dart';
import 'payroll_run_builder_models.dart';
import 'payroll_run_close_models.dart';
import 'payroll_run_models.dart';

enum PayrollOperationsStageStatus {
  blocked('Blocked'),
  ready('Ready'),
  active('Active'),
  complete('Complete');

  final String label;

  const PayrollOperationsStageStatus(this.label);
}

class PayrollOperationsStage {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final String nextAction;
  final PayrollOperationsStageStatus status;
  final double progress;
  final int blockerCount;
  final double amountAtRisk;

  const PayrollOperationsStage({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.nextAction,
    required this.status,
    required this.progress,
    required this.blockerCount,
    required this.amountAtRisk,
  });

  bool get isComplete => status == PayrollOperationsStageStatus.complete;

  bool get needsAttention =>
      status == PayrollOperationsStageStatus.blocked || blockerCount > 0;
}

class PayrollOperationsCenterSummary {
  final String periodLabel;
  final List<PayrollOperationsStage> stages;

  const PayrollOperationsCenterSummary({
    required this.periodLabel,
    required this.stages,
  });

  factory PayrollOperationsCenterSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollActiveRunPlanSummary activeRunPlan,
    required PayrollExceptionResolutionSummary exceptionResolution,
    required PayrollApprovalWorkflowSummary approvalWorkflow,
    required PayrollFundingAuthorizationSummary fundingAuthorization,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipDistributionSummary payslipDistribution,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollRunClosePlan closePlan,
  }) {
    final activePlanComplete = activeRunPlan.hasActivePlan;
    final exceptionsClear =
        exceptionResolution.status == PayrollExceptionResolutionStatus.clear;
    final paymentsReleased =
        paymentBatch.status == PayrollPaymentBatchStatus.released;
    final payslipsDelivered =
        payslipDistribution.status == PayrollPayslipDistributionStatus.complete;
    final liabilitiesRemitted =
        liabilities.status == PayrollLiabilityRemittanceStatus.remitted;
    final journalPosted =
        journalPosting.status == PayrollJournalPostingStatus.posted;

    return PayrollOperationsCenterSummary(
      periodLabel: dashboard.periodLabel,
      stages: [
        PayrollOperationsStage(
          id: 'run-plan',
          title: 'Run plan',
          owner: 'Payroll Manager',
          detail:
              activePlanComplete
                  ? activeRunPlan.request!.label
                  : 'No active payroll run plan.',
          nextAction:
              activePlanComplete
                  ? 'Run scope is active for payroll operations.'
                  : activeRunPlan.nextAction,
          status:
              activePlanComplete
                  ? PayrollOperationsStageStatus.complete
                  : PayrollOperationsStageStatus.blocked,
          progress: activePlanComplete ? 1 : 0,
          blockerCount: activePlanComplete ? 0 : 1,
          amountAtRisk: activePlanComplete ? 0 : dashboard.netPayroll,
        ),
        PayrollOperationsStage(
          id: 'readiness',
          title: 'Readiness',
          owner: 'Payroll Ops',
          detail:
              exceptionsClear
                  ? 'Inputs, attendance, loans, and mappings are clear.'
                  : '${exceptionResolution.lines.length} cross-module blockers remain.',
          nextAction: exceptionResolution.nextAction,
          status:
              exceptionsClear
                  ? PayrollOperationsStageStatus.complete
                  : PayrollOperationsStageStatus.blocked,
          progress: exceptionsClear ? 1 : 0.35,
          blockerCount: exceptionResolution.lines.length,
          amountAtRisk: exceptionResolution.financialExposure,
        ),
        PayrollOperationsStage(
          id: 'approvals',
          title: 'Approvals',
          owner: 'HR and Finance',
          detail:
              '${approvalWorkflow.approvedCount}/${approvalWorkflow.stages.length} approval gates complete.',
          nextAction: approvalWorkflow.nextAction,
          status:
              approvalWorkflow.isFullyApproved
                  ? PayrollOperationsStageStatus.complete
                  : approvalWorkflow.readyCount > 0
                  ? PayrollOperationsStageStatus.ready
                  : PayrollOperationsStageStatus.blocked,
          progress: _ratio(
            approvalWorkflow.approvedCount,
            approvalWorkflow.stages.length,
          ),
          blockerCount: approvalWorkflow.blockedCount,
          amountAtRisk:
              approvalWorkflow.isFullyApproved ? 0 : dashboard.netPayroll,
        ),
        PayrollOperationsStage(
          id: 'funding',
          title: 'Funding',
          owner: 'Finance Ops',
          detail:
              '${fundingAuthorization.authorizedCount}/${fundingAuthorization.lines.length} funding accounts authorized.',
          nextAction: fundingAuthorization.nextAction,
          status:
              fundingAuthorization.isAuthorizedForRelease
                  ? PayrollOperationsStageStatus.complete
                  : fundingAuthorization.readyCount > 0
                  ? PayrollOperationsStageStatus.ready
                  : PayrollOperationsStageStatus.blocked,
          progress: _ratio(
            fundingAuthorization.authorizedCount,
            fundingAuthorization.lines.length,
          ),
          blockerCount: fundingAuthorization.blockedCount,
          amountAtRisk: fundingAuthorization.pendingNet,
        ),
        PayrollOperationsStage(
          id: 'payments',
          title: 'Payments',
          owner: 'Finance Ops',
          detail:
              '${paymentBatch.paidCount}/${paymentBatch.lines.length} employee payments released.',
          nextAction: paymentBatch.nextAction,
          status:
              paymentsReleased
                  ? PayrollOperationsStageStatus.complete
                  : paymentBatch.status == PayrollPaymentBatchStatus.ready ||
                      paymentBatch.status == PayrollPaymentBatchStatus.releasing
                  ? PayrollOperationsStageStatus.active
                  : PayrollOperationsStageStatus.blocked,
          progress: _ratio(paymentBatch.paidCount, paymentBatch.lines.length),
          blockerCount: paymentBatch.blockedRecipientCount,
          amountAtRisk: paymentBatch.pendingNet,
        ),
        PayrollOperationsStage(
          id: 'statements',
          title: 'Statements',
          owner: 'Payroll Ops',
          detail:
              '${payslipDistribution.dispatchedCount}/${payslipDistribution.lines.length} payslip statements dispatched.',
          nextAction: payslipDistribution.nextAction,
          status:
              payslipsDelivered
                  ? PayrollOperationsStageStatus.complete
                  : payslipDistribution.status ==
                      PayrollPayslipDistributionStatus.ready
                  ? PayrollOperationsStageStatus.ready
                  : payslipDistribution.status ==
                      PayrollPayslipDistributionStatus.dispatching
                  ? PayrollOperationsStageStatus.active
                  : PayrollOperationsStageStatus.blocked,
          progress: payslipDistribution.deliveryProgress,
          blockerCount: payslipDistribution.failedCount,
          amountAtRisk: 0,
        ),
        PayrollOperationsStage(
          id: 'statutory',
          title: 'Statutory',
          owner: 'Payroll Tax',
          detail:
              '${liabilities.remittedCount}/${liabilities.lines.length} liabilities remitted.',
          nextAction: liabilities.nextAction,
          status:
              liabilitiesRemitted
                  ? PayrollOperationsStageStatus.complete
                  : liabilities.status == PayrollLiabilityRemittanceStatus.ready
                  ? PayrollOperationsStageStatus.ready
                  : liabilities.status ==
                      PayrollLiabilityRemittanceStatus.remitting
                  ? PayrollOperationsStageStatus.active
                  : PayrollOperationsStageStatus.blocked,
          progress: _ratio(liabilities.remittedCount, liabilities.lines.length),
          blockerCount: liabilities.blockedCount,
          amountAtRisk: liabilities.pendingAmount,
        ),
        PayrollOperationsStage(
          id: 'finance-posting',
          title: 'Finance posting',
          owner: 'Finance Controller',
          detail:
              journalPosted
                  ? '${journalPosting.journalId} is posted.'
                  : '${journalPosting.journalId} awaits posting.',
          nextAction: journalPosting.nextAction,
          status:
              journalPosted
                  ? PayrollOperationsStageStatus.complete
                  : journalPosting.status == PayrollJournalPostingStatus.ready
                  ? PayrollOperationsStageStatus.ready
                  : PayrollOperationsStageStatus.blocked,
          progress: journalPosted ? 1 : 0,
          blockerCount: journalPosting.blockers.length,
          amountAtRisk: journalPosting.balanceVariance,
        ),
        PayrollOperationsStage(
          id: 'close',
          title: 'Close',
          owner: 'Payroll Controller',
          detail:
              '${closePlan.completedCount}/${closePlan.steps.length} close steps complete.',
          nextAction: closePlan.nextAction,
          status:
              closePlan.isClosed
                  ? PayrollOperationsStageStatus.complete
                  : closePlan.readyCount > 0
                  ? PayrollOperationsStageStatus.ready
                  : PayrollOperationsStageStatus.blocked,
          progress: closePlan.progressRatio,
          blockerCount: closePlan.blockedCount,
          amountAtRisk: closePlan.isClosed ? 0 : dashboard.netPayroll,
        ),
      ],
    );
  }

  int get completeCount => stages.where((stage) => stage.isComplete).length;

  int get blockedCount {
    return stages
        .where((stage) => stage.status == PayrollOperationsStageStatus.blocked)
        .length;
  }

  int get readyCount {
    return stages
        .where((stage) => stage.status == PayrollOperationsStageStatus.ready)
        .length;
  }

  int get activeCount {
    return stages
        .where((stage) => stage.status == PayrollOperationsStageStatus.active)
        .length;
  }

  int get blockerCount {
    return stages.fold(0, (total, stage) => total + stage.blockerCount);
  }

  double get amountAtRisk {
    return stages.fold(0, (total, stage) => total + stage.amountAtRisk);
  }

  double get progress {
    if (stages.isEmpty) return 0;
    return stages.fold(0.0, (total, stage) => total + stage.progress) /
        stages.length;
  }

  PayrollOperationsStage? get currentStage {
    for (final stage in stages) {
      if (!stage.isComplete) return stage;
    }
    return null;
  }

  String get nextAction {
    return currentStage?.nextAction ?? 'Payroll operations are complete.';
  }
}

double _ratio(int complete, int total) {
  if (total <= 0) return 1;
  return (complete / total).clamp(0, 1);
}
