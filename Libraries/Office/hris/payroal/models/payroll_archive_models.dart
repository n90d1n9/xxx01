import 'payroll_cost_center_budget_models.dart';
import 'payroll_journal_models.dart';
import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_models.dart';

enum PayrollArchivePackageStatus {
  blocked('Blocked'),
  ready('Ready'),
  archived('Archived');

  final String label;

  const PayrollArchivePackageStatus(this.label);
}

class PayrollArchiveEvidenceItem {
  final String id;
  final String title;
  final String owner;
  final String referenceCode;
  final String evidenceLabel;
  final bool isCaptured;
  final List<String> blockers;

  const PayrollArchiveEvidenceItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.referenceCode,
    required this.evidenceLabel,
    required this.isCaptured,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get isReady => !hasBlockers;

  String get statusLabel {
    if (isCaptured) return 'Archived';
    if (hasBlockers) return 'Blocked';
    return 'Ready';
  }
}

class PayrollArchivePackageSummary {
  final String packageId;
  final String periodLabel;
  final DateTime archivedOn;
  final DateTime retentionUntil;
  final List<PayrollArchiveEvidenceItem> evidenceItems;
  final bool isArchived;

  const PayrollArchivePackageSummary({
    required this.packageId,
    required this.periodLabel,
    required this.archivedOn,
    required this.retentionUntil,
    required this.evidenceItems,
    required this.isArchived,
  });

  factory PayrollArchivePackageSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollCostCenterBudgetSummary costCenterBudgets,
    required PayrollReconciliationSummary reconciliation,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required PayrollJournalPostingSummary journalPosting,
    required Set<String> archivedPackageIds,
  }) {
    final packageId =
        'AR-${dashboard.payDate.year}${dashboard.payDate.month.toString().padLeft(2, '0')}';
    final isArchived = archivedPackageIds.contains(packageId);

    PayrollArchiveEvidenceItem item({
      required String id,
      required String title,
      required String owner,
      required String referenceCode,
      required String evidenceLabel,
      required List<String> blockers,
    }) {
      return PayrollArchiveEvidenceItem(
        id: id,
        title: title,
        owner: owner,
        referenceCode: referenceCode,
        evidenceLabel: evidenceLabel,
        isCaptured: isArchived && blockers.isEmpty,
        blockers: blockers,
      );
    }

    return PayrollArchivePackageSummary(
      packageId: packageId,
      periodLabel: dashboard.periodLabel,
      archivedOn: dashboard.payDate,
      retentionUntil: DateTime(
        dashboard.payDate.year + 7,
        dashboard.payDate.month,
        dashboard.payDate.day,
      ),
      evidenceItems: [
        item(
          id: 'employee-register',
          title: 'Employee payroll register',
          owner: 'Payroll Ops',
          referenceCode: '${dashboard.employeeCount} employees',
          evidenceLabel: 'Gross and net payroll summary',
          blockers: [
            if (dashboard.employeeCount == 0) 'No employees in payroll run',
          ],
        ),
        item(
          id: 'cost-center-budget-approvals',
          title: 'Cost center budget approvals',
          owner: 'Finance Partner',
          referenceCode:
              '${costCenterBudgets.approvedReleaseCount}/${costCenterBudgets.lines.length} cost centers approved',
          evidenceLabel:
              '${costCenterBudgets.readyEvidenceCount}/${costCenterBudgets.requiredEvidenceCount} budget evidence items ready',
          blockers: [
            if (costCenterBudgets.pendingApprovalCount > 0)
              '${costCenterBudgets.pendingApprovalCount} cost center approvals pending',
            if (costCenterBudgets.incompleteEvidenceCount > 0)
              '${costCenterBudgets.incompleteEvidenceCount} budget evidence items incomplete',
          ],
        ),
        item(
          id: 'reconciliation',
          title: 'Reconciliation sign-off',
          owner: 'Finance Partner',
          referenceCode:
              reconciliation.isReviewed
                  ? reconciliation.reviewSignature
                  : 'Not reviewed',
          evidenceLabel: 'Variance and funding review',
          blockers: [
            if (!reconciliation.isReviewed)
              'Payroll reconciliation is not reviewed',
          ],
        ),
        item(
          id: 'payment-batch',
          title: 'Payment release batch',
          owner: 'Finance Ops',
          referenceCode: paymentBatch.batchId,
          evidenceLabel: 'Employee net payment release',
          blockers: [
            if (paymentBatch.pendingCount > 0)
              '${paymentBatch.pendingCount} payment releases pending',
          ],
        ),
        item(
          id: 'payslip-package',
          title: 'Payslip publishing package',
          owner: 'Payroll Ops',
          referenceCode: payslipPackage.packageId,
          evidenceLabel: 'Employee payslip delivery proof',
          blockers: [
            if (payslipPackage.pendingCount > 0)
              '${payslipPackage.pendingCount} payslips unpublished',
          ],
        ),
        item(
          id: 'liability-receipts',
          title: 'Liability remittance receipts',
          owner: 'Payroll Tax',
          referenceCode: liabilities.remittanceId,
          evidenceLabel: 'Tax and benefit remittance proof',
          blockers: [
            if (liabilities.pendingCount > 0)
              '${liabilities.pendingCount} liability remittances pending',
          ],
        ),
        item(
          id: 'journal-posting',
          title: 'Finance journal posting',
          owner: 'Finance Controller',
          referenceCode: journalPosting.journalId,
          evidenceLabel: 'Balanced GL posting evidence',
          blockers: [
            if (journalPosting.status != PayrollJournalPostingStatus.posted)
              'Payroll journal is not posted to finance',
          ],
        ),
      ],
      isArchived: isArchived,
    );
  }

  int get readyCount =>
      evidenceItems.where((item) => item.isReady && !item.isCaptured).length;

  int get capturedCount =>
      evidenceItems.where((item) => item.isCaptured).length;

  int get blockedCount =>
      evidenceItems.where((item) => item.hasBlockers).length;

  PayrollArchivePackageStatus get status {
    if (blockedCount > 0) return PayrollArchivePackageStatus.blocked;
    if (isArchived) return PayrollArchivePackageStatus.archived;
    return PayrollArchivePackageStatus.ready;
  }

  bool get canArchive => !isArchived && blockedCount == 0;

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount archive evidence blockers.';
    }
    if (isArchived) {
      return 'Payroll run package is archived for audit retention.';
    }
    return 'Archive payroll evidence package before final close.';
  }
}
