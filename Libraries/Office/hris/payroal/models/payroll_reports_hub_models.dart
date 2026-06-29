import 'payroll_archive_models.dart';
import 'payroll_control_review_models.dart';
import 'payroll_cost_center_report_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_register_report_models.dart';
import 'payroll_statutory_report_models.dart';
import 'payroll_variance_report_models.dart';

enum PayrollReportHubCategory {
  finance('Finance'),
  payments('Payments'),
  compliance('Compliance'),
  audit('Audit');

  final String label;

  const PayrollReportHubCategory(this.label);
}

enum PayrollReportHubStatus {
  blocked('Blocked'),
  ready('Ready'),
  complete('Complete');

  final String label;

  const PayrollReportHubStatus(this.label);
}

class PayrollReportHubItem {
  final String id;
  final String title;
  final PayrollReportHubCategory category;
  final String owner;
  final String periodLabel;
  final DateTime generatedOn;
  final double amount;
  final PayrollReportHubStatus status;
  final List<String> blockers;
  final String nextAction;

  const PayrollReportHubItem({
    required this.id,
    required this.title,
    required this.category,
    required this.owner,
    required this.periodLabel,
    required this.generatedOn,
    required this.amount,
    required this.status,
    required this.blockers,
    required this.nextAction,
  });

  bool get isBlocked => status == PayrollReportHubStatus.blocked;

  bool get isReady => status == PayrollReportHubStatus.ready;

  bool get isComplete => status == PayrollReportHubStatus.complete;
}

class PayrollReportsHubSummary {
  final String periodLabel;
  final List<PayrollReportHubItem> items;

  const PayrollReportsHubSummary({
    required this.periodLabel,
    required this.items,
  });

  factory PayrollReportsHubSummary.fromRun({
    required DateTime asOfDate,
    required PayrollVarianceReportSummary varianceReport,
    required PayrollCostCenterReportSummary costCenterReport,
    required PayrollBankTransferFileSummary bankTransferFile,
    required PayrollRegisterReportSummary registerReport,
    required PayrollStatutoryReportSummary statutoryReport,
    required PayrollArchivePackageSummary archivePackage,
    required PayrollControlReviewSummary controlReview,
  }) {
    final items = <PayrollReportHubItem>[
      PayrollReportHubItem(
        id: varianceReport.reportId,
        title: 'Variance report',
        category: PayrollReportHubCategory.finance,
        owner: 'Finance Partner',
        periodLabel: varianceReport.periodLabel,
        generatedOn: asOfDate,
        amount: varianceReport.largestVarianceAmount,
        status: _statusForVarianceReport(varianceReport),
        blockers: varianceReport.blockers,
        nextAction: varianceReport.nextAction,
      ),
      PayrollReportHubItem(
        id: costCenterReport.reportId,
        title: 'Cost center payroll report',
        category: PayrollReportHubCategory.finance,
        owner: 'Finance Controller',
        periodLabel: costCenterReport.periodLabel,
        generatedOn: asOfDate,
        amount: costCenterReport.totalGrossPayroll,
        status: _statusForCostCenterReport(costCenterReport),
        blockers: costCenterReport.blockers,
        nextAction: costCenterReport.nextAction,
      ),
      PayrollReportHubItem(
        id: bankTransferFile.fileId,
        title: 'Bank transfer file',
        category: PayrollReportHubCategory.payments,
        owner: 'Finance Ops',
        periodLabel: bankTransferFile.periodLabel,
        generatedOn: bankTransferFile.payDate,
        amount: bankTransferFile.totalAmount,
        status: _statusForBankTransferFile(bankTransferFile),
        blockers: bankTransferFile.blockers,
        nextAction: bankTransferFile.nextAction,
      ),
      PayrollReportHubItem(
        id: registerReport.reportId,
        title: 'Payroll register',
        category: PayrollReportHubCategory.finance,
        owner: 'Payroll Ops',
        periodLabel: registerReport.periodLabel,
        generatedOn: registerReport.payDate,
        amount: registerReport.totalNet,
        status: _statusForRegisterReport(registerReport),
        blockers: registerReport.blockers,
        nextAction: registerReport.nextAction,
      ),
      PayrollReportHubItem(
        id: statutoryReport.packId,
        title: 'Statutory reporting pack',
        category: PayrollReportHubCategory.compliance,
        owner: 'Payroll Tax',
        periodLabel: statutoryReport.periodLabel,
        generatedOn: statutoryReport.payDate,
        amount: statutoryReport.totalAmount,
        status: _statusForStatutoryReport(statutoryReport),
        blockers: [
          for (final line in statutoryReport.lines.where(
            (line) => line.status == PayrollStatutoryFilingStatus.blocked,
          ))
            ...line.blockers,
        ],
        nextAction: statutoryReport.nextAction,
      ),
      PayrollReportHubItem(
        id: archivePackage.packageId,
        title: 'Audit archive package',
        category: PayrollReportHubCategory.audit,
        owner: 'Payroll Controller',
        periodLabel: archivePackage.periodLabel,
        generatedOn: archivePackage.archivedOn,
        amount: archivePackage.evidenceItems.length.toDouble(),
        status: _statusForArchivePackage(archivePackage),
        blockers: [
          for (final item in archivePackage.evidenceItems.where(
            (item) => item.hasBlockers,
          ))
            ...item.blockers,
        ],
        nextAction: archivePackage.nextAction,
      ),
      PayrollReportHubItem(
        id: controlReview.reviewId,
        title: 'Control review sign-off',
        category: PayrollReportHubCategory.audit,
        owner: 'Payroll Controller',
        periodLabel: controlReview.periodLabel,
        generatedOn: controlReview.reviewDate,
        amount: controlReview.items.length.toDouble(),
        status: _statusForControlReview(controlReview),
        blockers: [
          for (final item in controlReview.items.where(
            (item) => item.hasBlockers,
          ))
            ...item.blockers,
        ],
        nextAction: controlReview.nextAction,
      ),
    ];

    items.sort((left, right) {
      final status = left.status.index.compareTo(right.status.index);
      if (status != 0) return status;
      return left.category.index.compareTo(right.category.index);
    });

    return PayrollReportsHubSummary(
      periodLabel: registerReport.periodLabel,
      items: items,
    );
  }

  int get blockedCount => items.where((item) => item.isBlocked).length;

  int get readyCount => items.where((item) => item.isReady).length;

  int get completeCount => items.where((item) => item.isComplete).length;

  double get totalReportValue =>
      items.fold(0, (total, item) => total + item.amount);

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount payroll report blockers.';
    }
    if (readyCount > 0) return 'Export or retain $readyCount payroll reports.';
    return 'Payroll report hub is complete for this period.';
  }
}

PayrollReportHubStatus _statusForVarianceReport(
  PayrollVarianceReportSummary report,
) {
  return switch (report.status) {
    PayrollVarianceReportStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollVarianceReportStatus.ready => PayrollReportHubStatus.ready,
    PayrollVarianceReportStatus.exported => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForCostCenterReport(
  PayrollCostCenterReportSummary report,
) {
  return switch (report.status) {
    PayrollCostCenterReportStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollCostCenterReportStatus.ready => PayrollReportHubStatus.ready,
    PayrollCostCenterReportStatus.exported => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForBankTransferFile(
  PayrollBankTransferFileSummary file,
) {
  return switch (file.status) {
    PayrollBankTransferFileStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollBankTransferFileStatus.ready => PayrollReportHubStatus.ready,
    PayrollBankTransferFileStatus.exported => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForRegisterReport(
  PayrollRegisterReportSummary report,
) {
  return switch (report.status) {
    PayrollRegisterReportStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollRegisterReportStatus.ready => PayrollReportHubStatus.ready,
    PayrollRegisterReportStatus.exported => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForStatutoryReport(
  PayrollStatutoryReportSummary report,
) {
  return switch (report.status) {
    PayrollStatutoryFilingStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollStatutoryFilingStatus.ready => PayrollReportHubStatus.ready,
    PayrollStatutoryFilingStatus.exported => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForArchivePackage(
  PayrollArchivePackageSummary package,
) {
  return switch (package.status) {
    PayrollArchivePackageStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollArchivePackageStatus.ready => PayrollReportHubStatus.ready,
    PayrollArchivePackageStatus.archived => PayrollReportHubStatus.complete,
  };
}

PayrollReportHubStatus _statusForControlReview(
  PayrollControlReviewSummary review,
) {
  return switch (review.status) {
    PayrollControlReviewStatus.blocked => PayrollReportHubStatus.blocked,
    PayrollControlReviewStatus.ready => PayrollReportHubStatus.ready,
    PayrollControlReviewStatus.reviewed => PayrollReportHubStatus.complete,
  };
}
