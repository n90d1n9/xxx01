import 'payroll_approval_workflow_models.dart';
import 'payroll_archive_models.dart';
import 'payroll_configuration_models.dart';
import 'payroll_cost_center_report_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_register_report_models.dart';
import 'payroll_run_models.dart';
import 'payroll_variance_report_models.dart';

enum PayrollEvidenceStatus {
  blocked('Blocked'),
  ready('Ready'),
  captured('Captured');

  final String label;

  const PayrollEvidenceStatus(this.label);
}

enum PayrollEvidenceCategory {
  setup('Setup'),
  approval('Approval'),
  finance('Finance'),
  payment('Payment'),
  archive('Archive');

  final String label;

  const PayrollEvidenceCategory(this.label);
}

class PayrollEvidenceItem {
  final String id;
  final String title;
  final String owner;
  final PayrollEvidenceCategory category;
  final String reference;
  final List<String> blockers;
  final bool isCaptured;

  const PayrollEvidenceItem({
    required this.id,
    required this.title,
    required this.owner,
    required this.category,
    required this.reference,
    required this.blockers,
    required this.isCaptured,
  });

  PayrollEvidenceStatus get status {
    if (isCaptured) return PayrollEvidenceStatus.captured;
    if (blockers.isNotEmpty) return PayrollEvidenceStatus.blocked;
    return PayrollEvidenceStatus.ready;
  }

  String get nextAction {
    if (blockers.isNotEmpty) return blockers.first;
    if (isCaptured) return 'Evidence is captured.';
    return 'Capture evidence for audit package.';
  }
}

class PayrollEvidenceCenterSummary {
  final String periodLabel;
  final List<PayrollEvidenceItem> items;

  const PayrollEvidenceCenterSummary({
    required this.periodLabel,
    required this.items,
  });

  factory PayrollEvidenceCenterSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required PayrollConfigurationSummary configuration,
    required PayrollReconciliationSummary reconciliation,
    required PayrollApprovalWorkflowSummary approvals,
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollVarianceReportSummary varianceReport,
    required PayrollCostCenterReportSummary costCenterReport,
    required PayrollRegisterReportSummary registerReport,
    required PayrollArchivePackageSummary archivePackage,
  }) {
    return PayrollEvidenceCenterSummary(
      periodLabel: dashboard.periodLabel,
      items: [
        PayrollEvidenceItem(
          id: 'configuration',
          title: 'Payroll configuration',
          owner: 'Payroll Ops',
          category: PayrollEvidenceCategory.setup,
          reference: configuration.status.label,
          blockers: configuration.blockers,
          isCaptured: configuration.status == PayrollConfigurationStatus.ready,
        ),
        PayrollEvidenceItem(
          id: 'exception-clearance',
          title: 'Exception clearance evidence',
          owner: 'Payroll Ops',
          category: PayrollEvidenceCategory.approval,
          reference:
              '${dashboard.openExceptionCount} open, ${dashboard.criticalExceptionCount} critical',
          blockers: [
            if (dashboard.openExceptionCount > 0)
              '${dashboard.openExceptionCount} payroll exceptions remain open',
          ],
          isCaptured: dashboard.openExceptionCount == 0,
        ),
        PayrollEvidenceItem(
          id: 'reconciliation',
          title: 'Reconciliation evidence',
          owner: 'Finance Partner',
          category: PayrollEvidenceCategory.finance,
          reference:
              reconciliation.isReviewed
                  ? reconciliation.reviewSignature
                  : reconciliation.status.label,
          blockers: [
            if (!reconciliation.isReviewed)
              'Payroll reconciliation is not reviewed',
          ],
          isCaptured: reconciliation.isReviewed,
        ),
        PayrollEvidenceItem(
          id: 'approvals',
          title: 'Approval workflow',
          owner: 'Payroll Controller',
          category: PayrollEvidenceCategory.approval,
          reference: '${approvals.approvedCount}/${approvals.stages.length}',
          blockers: [if (!approvals.isFullyApproved) approvals.nextAction],
          isCaptured: approvals.isFullyApproved,
        ),
        PayrollEvidenceItem(
          id: 'variance-report',
          title: 'Variance report',
          owner: 'Finance Partner',
          category: PayrollEvidenceCategory.finance,
          reference: varianceReport.reportId,
          blockers: [if (!varianceReport.isExported) varianceReport.nextAction],
          isCaptured: varianceReport.isExported,
        ),
        PayrollEvidenceItem(
          id: 'cost-center-report',
          title: 'Cost center payroll report',
          owner: 'Finance Partner',
          category: PayrollEvidenceCategory.finance,
          reference: costCenterReport.reportId,
          blockers: [
            if (!costCenterReport.isExported) costCenterReport.nextAction,
          ],
          isCaptured: costCenterReport.isExported,
        ),
        PayrollEvidenceItem(
          id: 'payment-release',
          title: 'Payment release evidence',
          owner: 'Finance Ops',
          category: PayrollEvidenceCategory.payment,
          reference: paymentBatch.batchId,
          blockers: [
            if (paymentBatch.pendingCount > 0)
              '${paymentBatch.pendingCount} payment releases pending',
          ],
          isCaptured: paymentBatch.pendingCount == 0,
        ),
        PayrollEvidenceItem(
          id: 'register-report',
          title: 'Payroll register report',
          owner: 'Payroll Ops',
          category: PayrollEvidenceCategory.finance,
          reference: registerReport.reportId,
          blockers: [if (!registerReport.isExported) registerReport.nextAction],
          isCaptured: registerReport.isExported,
        ),
        PayrollEvidenceItem(
          id: 'archive-package',
          title: 'Audit archive package',
          owner: 'Payroll Controller',
          category: PayrollEvidenceCategory.archive,
          reference: archivePackage.packageId,
          blockers: [
            if (archivePackage.status != PayrollArchivePackageStatus.archived)
              archivePackage.nextAction,
          ],
          isCaptured:
              archivePackage.status == PayrollArchivePackageStatus.archived,
        ),
      ],
    );
  }

  int get capturedCount {
    return items
        .where((item) => item.status == PayrollEvidenceStatus.captured)
        .length;
  }

  int get readyCount {
    return items
        .where((item) => item.status == PayrollEvidenceStatus.ready)
        .length;
  }

  int get blockedCount {
    return items
        .where((item) => item.status == PayrollEvidenceStatus.blocked)
        .length;
  }

  double get captureRate {
    if (items.isEmpty) return 0;
    return capturedCount / items.length;
  }

  PayrollEvidenceStatus get status {
    if (blockedCount > 0) return PayrollEvidenceStatus.blocked;
    if (capturedCount == items.length) return PayrollEvidenceStatus.captured;
    return PayrollEvidenceStatus.ready;
  }

  String get nextAction {
    final blocked = items.where(
      (item) => item.status == PayrollEvidenceStatus.blocked,
    );
    if (blocked.isNotEmpty) return blocked.first.nextAction;
    if (readyCount > 0) return 'Capture $readyCount payroll evidence items.';
    return 'Payroll evidence center is complete.';
  }
}
