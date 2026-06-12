import 'payroll_archive_models.dart';
import 'payroll_cost_center_budget_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_models.dart';

enum PayrollControlSeverity {
  critical('Critical'),
  watch('Watch');

  final String label;

  const PayrollControlSeverity(this.label);
}

enum PayrollControlReviewStatus {
  blocked('Blocked'),
  ready('Ready'),
  reviewed('Reviewed');

  final String label;

  const PayrollControlReviewStatus(this.label);
}

class PayrollControlReviewItem {
  final String id;
  final String title;
  final String owner;
  final String controlLabel;
  final String evidenceLabel;
  final PayrollControlSeverity severity;
  final bool isReviewed;
  final List<String> blockers;

  const PayrollControlReviewItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.controlLabel,
    required this.evidenceLabel,
    required this.severity,
    required this.isReviewed,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get isReady => !isReviewed && !hasBlockers;

  String get statusLabel {
    if (isReviewed) return 'Signed off';
    if (hasBlockers) return 'Blocked';
    return 'Ready';
  }
}

class PayrollControlReviewSummary {
  final String reviewId;
  final String periodLabel;
  final DateTime reviewDate;
  final List<PayrollControlReviewItem> items;

  const PayrollControlReviewSummary({
    required this.reviewId,
    required this.periodLabel,
    required this.reviewDate,
    required this.items,
  });

  factory PayrollControlReviewSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required PayrollArchivePackageSummary archivePackage,
    required Set<String> reviewedControlIds,
  }) {
    PayrollControlReviewItem item({
      required String id,
      required String title,
      required String owner,
      required String controlLabel,
      required String evidenceLabel,
      required PayrollControlSeverity severity,
      required List<String> blockers,
    }) {
      return PayrollControlReviewItem(
        id: id,
        title: title,
        owner: owner,
        controlLabel: controlLabel,
        evidenceLabel: evidenceLabel,
        severity: severity,
        isReviewed: blockers.isEmpty && reviewedControlIds.contains(id),
        blockers: blockers,
      );
    }

    return PayrollControlReviewSummary(
      reviewId:
          'CR-${dashboard.payDate.year}${dashboard.payDate.month.toString().padLeft(2, '0')}',
      periodLabel: dashboard.periodLabel,
      reviewDate: dashboard.payDate,
      items: [
        item(
          id: 'exception-clearance',
          title: 'Exception clearance',
          owner: 'Payroll Ops',
          controlLabel: 'No unresolved payroll exceptions at close.',
          evidenceLabel:
              '${dashboard.openExceptionCount} open, ${dashboard.criticalExceptionCount} critical',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (dashboard.openExceptionCount > 0)
              '${dashboard.openExceptionCount} payroll exceptions remain open',
          ],
        ),
        item(
          id: 'adjustment-approval',
          title: 'Adjustment approval',
          owner: 'Payroll Manager',
          controlLabel: 'All payroll adjustments are approved or rejected.',
          evidenceLabel:
              '${dashboard.approvedAdjustmentCount} approved, ${dashboard.pendingAdjustmentCount} pending',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (dashboard.pendingAdjustmentCount > 0)
              '${dashboard.pendingAdjustmentCount} adjustments need approval',
          ],
        ),
        item(
          id: 'cost-center-budget-approval',
          title: 'Cost center budget approval',
          owner: 'Finance Partner',
          controlLabel:
              'Budget variances, reserve use, and payroll risks have release approval.',
          evidenceLabel:
              '${costCenterBudgets.readyEvidenceCount}/${costCenterBudgets.requiredEvidenceCount} evidence items ready',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (costCenterBudgets.pendingApprovalCount > 0)
              '${costCenterBudgets.pendingApprovalCount} cost center approvals pending',
            if (costCenterBudgets.incompleteEvidenceCount > 0)
              '${costCenterBudgets.incompleteEvidenceCount} budget evidence items incomplete',
          ],
        ),
        item(
          id: 'reconciliation-review',
          title: 'Reconciliation review',
          owner: 'Finance Partner',
          controlLabel: 'Funding and material variances have finance sign-off.',
          evidenceLabel:
              reconciliation.isReviewed
                  ? reconciliation.reviewSignature
                  : reconciliation.nextAction,
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (!reconciliation.isReviewed)
              'Payroll reconciliation is not reviewed',
          ],
        ),
        item(
          id: 'payment-disbursement',
          title: 'Payment disbursement',
          owner: 'Finance Ops',
          controlLabel: 'All employee net payments are released.',
          evidenceLabel:
              '${paymentBatch.paidCount}/${paymentBatch.lines.length} payments released',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (paymentBatch.pendingCount > 0)
              '${paymentBatch.pendingCount} employee payments remain pending',
          ],
        ),
        item(
          id: 'payslip-publication',
          title: 'Payslip publication',
          owner: 'Payroll Ops',
          controlLabel: 'Payslips are published through configured channels.',
          evidenceLabel:
              '${payslipPackage.publishedCount}/${payslipPackage.lines.length} payslips published',
          severity: PayrollControlSeverity.watch,
          blockers: [
            if (payslipPackage.pendingCount > 0)
              '${payslipPackage.pendingCount} payslips remain unpublished',
          ],
        ),
        item(
          id: 'liability-remittance',
          title: 'Liability remittance',
          owner: 'Payroll Tax',
          controlLabel: 'Tax and benefit liabilities are remitted.',
          evidenceLabel:
              '${liabilities.remittedCount}/${liabilities.lines.length} remittances complete',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (liabilities.pendingCount > 0)
              '${liabilities.pendingCount} liability remittances remain pending',
          ],
        ),
        item(
          id: 'journal-posting',
          title: 'Journal posting',
          owner: 'Finance Controller',
          controlLabel: 'Balanced payroll journal is posted to finance.',
          evidenceLabel:
              '${journalPosting.journalId}, ${journalPosting.status.label}',
          severity: PayrollControlSeverity.critical,
          blockers: [
            if (journalPosting.status != PayrollJournalPostingStatus.posted)
              'Payroll journal is not posted to finance',
            if (!journalPosting.isBalanced)
              'Payroll journal debits and credits are not balanced',
          ],
        ),
        item(
          id: 'archive-retention',
          title: 'Archive retention',
          owner: 'Payroll Controller',
          controlLabel: 'Close evidence is archived for retention.',
          evidenceLabel:
              '${archivePackage.packageId}, retain until ${archivePackage.retentionUntil.year}',
          severity: PayrollControlSeverity.watch,
          blockers: [
            if (archivePackage.status != PayrollArchivePackageStatus.archived)
              'Payroll audit package is not archived',
          ],
        ),
      ],
    );
  }

  int get reviewedCount => items.where((item) => item.isReviewed).length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get blockedCount => items.where((item) => item.hasBlockers).length;

  int get criticalBlockedCount =>
      items
          .where(
            (item) =>
                item.severity == PayrollControlSeverity.critical &&
                item.hasBlockers,
          )
          .length;

  int get pendingCount => items.length - reviewedCount;

  PayrollControlReviewStatus get status {
    if (blockedCount > 0) return PayrollControlReviewStatus.blocked;
    if (pendingCount == 0) return PayrollControlReviewStatus.reviewed;
    return PayrollControlReviewStatus.ready;
  }

  bool get canReview => status == PayrollControlReviewStatus.ready;

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount payroll control blockers.';
    }
    if (pendingCount > 0) {
      return 'Sign off $pendingCount payroll controls before final close.';
    }
    return 'Payroll control review is signed off.';
  }
}
