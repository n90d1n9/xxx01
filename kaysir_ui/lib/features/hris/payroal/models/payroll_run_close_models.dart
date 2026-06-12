import 'payroll_archive_models.dart';
import 'payroll_control_review_models.dart';
import 'payroll_cost_center_budget_models.dart';
import 'payroll_funding_authorization_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_builder_models.dart';
import 'payroll_run_models.dart';

enum PayrollRunCloseStepStatus {
  blocked('Blocked'),
  ready('Ready'),
  complete('Complete');

  final String label;

  const PayrollRunCloseStepStatus(this.label);
}

class PayrollRunCloseStep {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final String action;
  final PayrollRunCloseStepStatus status;

  const PayrollRunCloseStep({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.action,
    required this.status,
  });

  bool get isComplete => status == PayrollRunCloseStepStatus.complete;

  bool get canComplete => status == PayrollRunCloseStepStatus.ready;

  bool get canReopen =>
      id == 'review-reconciliation' ||
      id == 'lock-payroll' ||
      id == 'remit-liabilities' ||
      id == 'post-journal' ||
      id == 'archive-run' ||
      id == 'review-controls' ||
      id == 'publish-payslips' ||
      id == 'close-period';
}

class PayrollRunClosePlan {
  final List<PayrollRunCloseStep> steps;

  const PayrollRunClosePlan({required this.steps});

  factory PayrollRunClosePlan.fromDashboard({
    required PayrollRunDashboard dashboard,
    required PayrollActiveRunPlanSummary activeRunPlan,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollFundingAuthorizationSummary fundingAuthorization,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required PayrollControlReviewSummary controlReview,
    required Set<String> completedStepIds,
  }) {
    final runPlanActivated = activeRunPlan.hasActivePlan;
    final exceptionsClear = dashboard.openExceptionCount == 0;
    final adjustmentsClear = dashboard.pendingAdjustmentCount == 0;
    final costCenterBudgetsApproved =
        costCenterBudgets.pendingApprovalCount == 0;
    final prechecksClear =
        exceptionsClear && adjustmentsClear && costCenterBudgetsApproved;
    final reconciliationReady = prechecksClear && reconciliation.canReview;
    final reconciled = reconciliationReady && reconciliation.isReviewed;
    final locked = reconciled && completedStepIds.contains('lock-payroll');
    final fundingAuthorized = fundingAuthorization.isAuthorizedForRelease;
    final disbursed = paymentBatch.pendingCount == 0;
    final payslipsPublished = payslipPackage.pendingCount == 0;
    final liabilitiesReady = payslipsPublished && liabilities.canRemit;
    final liabilitiesRemitted =
        payslipsPublished && liabilities.pendingCount == 0;
    final journalReady = liabilitiesRemitted && journalPosting.canPost;
    final journalPosted =
        liabilitiesRemitted &&
        journalPosting.status == PayrollJournalPostingStatus.posted;
    final archiveReady = journalPosted && archivePackage.canArchive;
    final archived =
        journalPosted &&
        archivePackage.status == PayrollArchivePackageStatus.archived;
    final controlReady = archived && controlReview.canReview;
    final controlsReviewed =
        archived && controlReview.status == PayrollControlReviewStatus.reviewed;
    final closed =
        controlsReviewed && completedStepIds.contains('close-period');

    return PayrollRunClosePlan(
      steps: [
        PayrollRunCloseStep(
          id: 'activate-run-plan',
          title: 'Activate run plan',
          owner: 'Payroll Manager',
          detail:
              runPlanActivated
                  ? '${activeRunPlan.request!.label} is active for this close.'
                  : 'No payroll run plan has been activated.',
          action:
              runPlanActivated
                  ? 'Active run plan is linked to close readiness.'
                  : activeRunPlan.nextAction,
          status:
              runPlanActivated
                  ? PayrollRunCloseStepStatus.complete
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'clear-exceptions',
          title: 'Clear exceptions',
          owner: 'Payroll Ops',
          detail:
              exceptionsClear
                  ? 'No open payroll exceptions remain.'
                  : '${dashboard.openExceptionCount} payroll exceptions remain open.',
          action:
              exceptionsClear
                  ? 'Keep exception evidence attached to the run.'
                  : dashboard.nextAction,
          status:
              runPlanActivated && exceptionsClear
                  ? PayrollRunCloseStepStatus.complete
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'approve-adjustments',
          title: 'Approve adjustments',
          owner: 'Payroll Manager',
          detail:
              adjustmentsClear
                  ? 'All payroll adjustments are approved or rejected.'
                  : '${dashboard.pendingAdjustmentCount} payroll adjustments need approval.',
          action:
              adjustmentsClear
                  ? 'Keep approvals attached to the run package.'
                  : 'Approve pending payroll adjustments.',
          status:
              runPlanActivated && adjustmentsClear
                  ? PayrollRunCloseStepStatus.complete
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'approve-cost-centers',
          title: 'Approve cost center budgets',
          owner: 'Finance Partner',
          detail:
              costCenterBudgetsApproved
                  ? 'All cost center budget releases are approved.'
                  : '${costCenterBudgets.pendingApprovalCount} cost center budget approvals remain.',
          action:
              costCenterBudgetsApproved
                  ? 'Budget approvals are attached to the run.'
                  : costCenterBudgets.nextAction,
          status:
              runPlanActivated && costCenterBudgetsApproved
                  ? PayrollRunCloseStepStatus.complete
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'review-reconciliation',
          title: 'Review reconciliation',
          owner: 'Finance Partner',
          detail:
              reconciled
                  ? 'Payroll variance and funding are reviewed.'
                  : reconciliationReady
                  ? 'Variance and funding are ready for finance sign-off.'
                  : reconciliation.nextAction,
          action:
              reconciled
                  ? 'Reconciliation is attached to the run package.'
                  : reconciliationReady
                  ? 'Mark payroll reconciliation reviewed.'
                  : 'Complete reconciliation blockers before locking payroll.',
          status:
              reconciled
                  ? PayrollRunCloseStepStatus.complete
                  : reconciliationReady
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'lock-payroll',
          title: 'Lock payroll run',
          owner: 'Payroll Manager',
          detail:
              locked
                  ? '${dashboard.periodLabel} is locked for payment.'
                  : 'Lock the run after reconciliation sign-off.',
          action:
              locked
                  ? 'Run is locked.'
                  : 'Lock payroll calculations and approved adjustments.',
          status:
              locked
                  ? PayrollRunCloseStepStatus.complete
                  : reconciled
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'disburse-payments',
          title: 'Disburse payments',
          owner: 'Finance Ops',
          detail:
              disbursed
                  ? 'All employee payments are marked paid.'
                  : !fundingAuthorized
                  ? '${fundingAuthorization.pendingCount} funding accounts need authorization.'
                  : '${paymentBatch.pendingCount} employee payments remain pending.',
          action:
              disbursed
                  ? 'Bank disbursement is complete.'
                  : !fundingAuthorized
                  ? fundingAuthorization.nextAction
                  : paymentBatch.nextAction,
          status:
              disbursed
                  ? PayrollRunCloseStepStatus.complete
                  : paymentBatch.canRelease && fundingAuthorized
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'publish-payslips',
          title: 'Publish payslips',
          owner: 'Payroll Ops',
          detail:
              payslipsPublished
                  ? 'All employee payslips are published.'
                  : '${payslipPackage.pendingCount} employee payslips remain unpublished.',
          action:
              payslipsPublished
                  ? 'Payslip package is attached to the run archive.'
                  : payslipPackage.nextAction,
          status:
              payslipsPublished
                  ? PayrollRunCloseStepStatus.complete
                  : payslipPackage.canPublish
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'remit-liabilities',
          title: 'Remit liabilities',
          owner: 'Payroll Tax',
          detail:
              liabilitiesRemitted
                  ? 'All payroll tax and benefit liabilities are remitted.'
                  : payslipsPublished
                  ? '${liabilities.pendingCount} payroll liabilities remain pending.'
                  : 'Publish employee payslips before liability remittance.',
          action:
              liabilitiesRemitted
                  ? 'Liability receipts are attached to the run archive.'
                  : payslipsPublished
                  ? liabilities.nextAction
                  : 'Publish payslips before final liability remittance.',
          status:
              liabilitiesRemitted
                  ? PayrollRunCloseStepStatus.complete
                  : liabilitiesReady
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'post-journal',
          title: 'Post payroll journal',
          owner: 'Finance Controller',
          detail:
              journalPosted
                  ? 'Balanced payroll journal is posted to finance.'
                  : journalReady
                  ? '${journalPosting.journalId} is ready for finance posting.'
                  : liabilitiesRemitted
                  ? journalPosting.nextAction
                  : 'Remit payroll liabilities before journal posting.',
          action:
              journalPosted
                  ? 'Journal posting evidence is attached to the run archive.'
                  : journalReady
                  ? journalPosting.nextAction
                  : liabilitiesRemitted
                  ? 'Resolve journal posting blockers before close.'
                  : 'Complete liability remittance before finance posting.',
          status:
              journalPosted
                  ? PayrollRunCloseStepStatus.complete
                  : journalReady
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'archive-run',
          title: 'Archive run package',
          owner: 'Payroll Controller',
          detail:
              archived
                  ? 'Payroll evidence package is archived for audit retention.'
                  : archiveReady
                  ? '${archivePackage.packageId} is ready for retention archive.'
                  : journalPosted
                  ? archivePackage.nextAction
                  : 'Post payroll journal before archiving evidence.',
          action:
              archived
                  ? 'Audit package is attached to the closed payroll run.'
                  : archiveReady
                  ? archivePackage.nextAction
                  : journalPosted
                  ? 'Resolve archive evidence blockers before final close.'
                  : 'Post the finance journal before archiving the run package.',
          status:
              archived
                  ? PayrollRunCloseStepStatus.complete
                  : archiveReady
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'review-controls',
          title: 'Review payroll controls',
          owner: 'Payroll Controller',
          detail:
              controlsReviewed
                  ? 'Payroll close controls are signed off.'
                  : archived
                  ? '${controlReview.pendingCount} payroll controls need sign-off.'
                  : 'Archive payroll evidence before control review.',
          action:
              controlsReviewed
                  ? 'Control review evidence is attached to the close package.'
                  : archived
                  ? controlReview.nextAction
                  : 'Archive the audit package before final control sign-off.',
          status:
              controlsReviewed
                  ? PayrollRunCloseStepStatus.complete
                  : controlReady
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
        PayrollRunCloseStep(
          id: 'close-period',
          title: 'Close payroll period',
          owner: 'Payroll Controller',
          detail:
              closed
                  ? '${dashboard.periodLabel} is closed.'
                  : 'Close the period after payroll controls are reviewed.',
          action:
              closed
                  ? 'Payroll period is closed.'
                  : 'Close the payroll period and archive the run package.',
          status:
              closed
                  ? PayrollRunCloseStepStatus.complete
                  : controlsReviewed
                  ? PayrollRunCloseStepStatus.ready
                  : PayrollRunCloseStepStatus.blocked,
        ),
      ],
    );
  }

  int get completedCount => steps.where((step) => step.isComplete).length;

  int get readyCount =>
      steps
          .where((step) => step.status == PayrollRunCloseStepStatus.ready)
          .length;

  int get blockedCount =>
      steps
          .where((step) => step.status == PayrollRunCloseStepStatus.blocked)
          .length;

  double get progressRatio {
    if (steps.isEmpty) return 0;
    return completedCount / steps.length;
  }

  PayrollRunCloseStep? get nextStep {
    for (final step in steps) {
      if (!step.isComplete) return step;
    }
    return null;
  }

  String get nextAction => nextStep?.action ?? 'Payroll run is closed.';

  bool get isClosed => steps.isNotEmpty && completedCount == steps.length;
}
