import 'payroll_archive_models.dart';
import 'payroll_control_review_models.dart';
import 'payroll_cost_center_budget_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_close_models.dart';
import 'payroll_run_models.dart';

enum PayrollAnalyticsStatus {
  blocked('Blocked'),
  watch('Watch'),
  ready('Ready'),
  complete('Complete');

  final String label;

  const PayrollAnalyticsStatus(this.label);
}

class PayrollAnalyticsMetric {
  final String id;
  final String title;
  final String value;
  final String detail;
  final double progress;
  final PayrollAnalyticsStatus status;

  const PayrollAnalyticsMetric({
    required this.id,
    required this.title,
    required this.value,
    required this.detail,
    required this.progress,
    required this.status,
  });
}

class PayrollAnalyticsStage {
  final String id;
  final String title;
  final String owner;
  final String detail;
  final double progress;
  final PayrollAnalyticsStatus status;

  const PayrollAnalyticsStage({
    required this.id,
    required this.title,
    required this.owner,
    required this.detail,
    required this.progress,
    required this.status,
  });
}

class PayrollAnalyticsSummary {
  final String periodLabel;
  final int readinessScore;
  final double closeProgress;
  final int varianceRiskCount;
  final int blockedStageCount;
  final int completeStageCount;
  final String nextAction;
  final List<PayrollAnalyticsMetric> metrics;
  final List<PayrollAnalyticsStage> stages;

  const PayrollAnalyticsSummary({
    required this.periodLabel,
    required this.readinessScore,
    required this.closeProgress,
    required this.varianceRiskCount,
    required this.blockedStageCount,
    required this.completeStageCount,
    required this.nextAction,
    required this.metrics,
    required this.stages,
  });

  factory PayrollAnalyticsSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required PayrollControlReviewSummary controlReview,
    required PayrollRunClosePlan closePlan,
  }) {
    final stages = [
      PayrollAnalyticsStage(
        id: 'budgets',
        title: 'Budget approvals',
        owner: 'Finance Partner',
        detail: costCenterBudgets.nextAction,
        progress: _ratio(
          costCenterBudgets.approvedReleaseCount,
          costCenterBudgets.lines.length,
        ),
        status:
            costCenterBudgets.pendingApprovalCount == 0
                ? PayrollAnalyticsStatus.complete
                : PayrollAnalyticsStatus.blocked,
      ),
      PayrollAnalyticsStage(
        id: 'reconciliation',
        title: 'Reconciliation',
        owner: 'Finance Partner',
        detail: reconciliation.nextAction,
        progress:
            reconciliation.isReviewed
                ? 1
                : reconciliation.canReview
                ? 0.7
                : 0,
        status:
            reconciliation.isReviewed
                ? PayrollAnalyticsStatus.complete
                : reconciliation.canReview
                ? PayrollAnalyticsStatus.ready
                : reconciliation.status == PayrollReconciliationStatus.watch
                ? PayrollAnalyticsStatus.watch
                : PayrollAnalyticsStatus.blocked,
      ),
      PayrollAnalyticsStage(
        id: 'payments',
        title: 'Payment release',
        owner: 'Finance Ops',
        detail: paymentBatch.nextAction,
        progress: _ratio(paymentBatch.paidCount, paymentBatch.lines.length),
        status: _paymentStatus(paymentBatch),
      ),
      PayrollAnalyticsStage(
        id: 'payslips',
        title: 'Payslip publishing',
        owner: 'Payroll Ops',
        detail: payslipPackage.nextAction,
        progress: _ratio(
          payslipPackage.publishedCount,
          payslipPackage.lines.length,
        ),
        status: _payslipStatus(payslipPackage),
      ),
      PayrollAnalyticsStage(
        id: 'liabilities',
        title: 'Liability remittance',
        owner: 'Payroll Tax',
        detail: liabilities.nextAction,
        progress: _ratio(liabilities.remittedCount, liabilities.lines.length),
        status: _liabilityStatus(liabilities),
      ),
      PayrollAnalyticsStage(
        id: 'journal',
        title: 'Journal posting',
        owner: 'Finance Controller',
        detail: journalPosting.nextAction,
        progress:
            journalPosting.isPosted
                ? 1
                : journalPosting.canPost
                ? 0.75
                : 0,
        status: _journalStatus(journalPosting),
      ),
      PayrollAnalyticsStage(
        id: 'archive',
        title: 'Audit archive',
        owner: 'Payroll Controller',
        detail: archivePackage.nextAction,
        progress: _ratio(
          archivePackage.capturedCount,
          archivePackage.evidenceItems.length,
        ),
        status: _archiveStatus(archivePackage),
      ),
      PayrollAnalyticsStage(
        id: 'controls',
        title: 'Close controls',
        owner: 'Payroll Controller',
        detail: controlReview.nextAction,
        progress: _ratio(
          controlReview.reviewedCount,
          controlReview.items.length,
        ),
        status: _controlStatus(controlReview),
      ),
    ];
    final blockedStageCount =
        stages
            .where((stage) => stage.status == PayrollAnalyticsStatus.blocked)
            .length;
    final completeStageCount =
        stages
            .where((stage) => stage.status == PayrollAnalyticsStatus.complete)
            .length;

    return PayrollAnalyticsSummary(
      periodLabel: dashboard.periodLabel,
      readinessScore: dashboard.readinessScore,
      closeProgress: closePlan.progressRatio,
      varianceRiskCount: reconciliation.materialVarianceCount,
      blockedStageCount: blockedStageCount,
      completeStageCount: completeStageCount,
      nextAction: closePlan.nextAction,
      metrics: [
        PayrollAnalyticsMetric(
          id: 'readiness',
          title: 'Readiness',
          value: '${dashboard.readinessScore}%',
          detail: dashboard.status.label,
          progress: dashboard.readinessScore / 100,
          status: _readinessStatus(dashboard),
        ),
        PayrollAnalyticsMetric(
          id: 'close',
          title: 'Close plan',
          value: '${closePlan.completedCount}/${closePlan.steps.length}',
          detail:
              '${closePlan.readyCount} ready, ${closePlan.blockedCount} blocked',
          progress: closePlan.progressRatio,
          status:
              closePlan.isClosed
                  ? PayrollAnalyticsStatus.complete
                  : closePlan.readyCount > 0
                  ? PayrollAnalyticsStatus.ready
                  : PayrollAnalyticsStatus.blocked,
        ),
        PayrollAnalyticsMetric(
          id: 'variance',
          title: 'Variance risk',
          value: '${reconciliation.materialVarianceCount}',
          detail: reconciliation.status.label,
          progress:
              reconciliation.isReviewed
                  ? 1
                  : reconciliation.canReview
                  ? 0.7
                  : 0.25,
          status:
              reconciliation.materialVarianceCount == 0
                  ? PayrollAnalyticsStatus.complete
                  : reconciliation.hasReviewVariance
                  ? PayrollAnalyticsStatus.blocked
                  : PayrollAnalyticsStatus.watch,
        ),
        PayrollAnalyticsMetric(
          id: 'release',
          title: 'Release flow',
          value: '$completeStageCount/${stages.length}',
          detail: '$blockedStageCount blocked stages',
          progress: _ratio(completeStageCount, stages.length),
          status:
              completeStageCount == stages.length
                  ? PayrollAnalyticsStatus.complete
                  : blockedStageCount > 0
                  ? PayrollAnalyticsStatus.blocked
                  : PayrollAnalyticsStatus.ready,
        ),
      ],
      stages: stages,
    );
  }
}

PayrollAnalyticsStatus _readinessStatus(PayrollRunDashboard dashboard) {
  if (dashboard.readinessScore >= 90) return PayrollAnalyticsStatus.complete;
  if (dashboard.readinessScore >= 75) return PayrollAnalyticsStatus.ready;
  if (dashboard.criticalExceptionCount == 0) {
    return PayrollAnalyticsStatus.watch;
  }
  return PayrollAnalyticsStatus.blocked;
}

PayrollAnalyticsStatus _paymentStatus(PayrollPaymentBatchSummary batch) {
  return switch (batch.status) {
    PayrollPaymentBatchStatus.released => PayrollAnalyticsStatus.complete,
    PayrollPaymentBatchStatus.ready ||
    PayrollPaymentBatchStatus.releasing => PayrollAnalyticsStatus.ready,
    PayrollPaymentBatchStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

PayrollAnalyticsStatus _payslipStatus(PayrollPayslipPackageSummary package) {
  return switch (package.status) {
    PayrollPayslipPackageStatus.published => PayrollAnalyticsStatus.complete,
    PayrollPayslipPackageStatus.ready ||
    PayrollPayslipPackageStatus.publishing => PayrollAnalyticsStatus.ready,
    PayrollPayslipPackageStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

PayrollAnalyticsStatus _liabilityStatus(PayrollLiabilitySummary liabilities) {
  return switch (liabilities.status) {
    PayrollLiabilityRemittanceStatus.remitted =>
      PayrollAnalyticsStatus.complete,
    PayrollLiabilityRemittanceStatus.ready ||
    PayrollLiabilityRemittanceStatus.remitting => PayrollAnalyticsStatus.ready,
    PayrollLiabilityRemittanceStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

PayrollAnalyticsStatus _journalStatus(PayrollJournalPostingSummary journal) {
  return switch (journal.status) {
    PayrollJournalPostingStatus.posted => PayrollAnalyticsStatus.complete,
    PayrollJournalPostingStatus.ready => PayrollAnalyticsStatus.ready,
    PayrollJournalPostingStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

PayrollAnalyticsStatus _archiveStatus(PayrollArchivePackageSummary archive) {
  return switch (archive.status) {
    PayrollArchivePackageStatus.archived => PayrollAnalyticsStatus.complete,
    PayrollArchivePackageStatus.ready => PayrollAnalyticsStatus.ready,
    PayrollArchivePackageStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

PayrollAnalyticsStatus _controlStatus(PayrollControlReviewSummary review) {
  return switch (review.status) {
    PayrollControlReviewStatus.reviewed => PayrollAnalyticsStatus.complete,
    PayrollControlReviewStatus.ready => PayrollAnalyticsStatus.ready,
    PayrollControlReviewStatus.blocked => PayrollAnalyticsStatus.blocked,
  };
}

double _ratio(int complete, int total) {
  if (total <= 0) return 0;
  return complete / total;
}
