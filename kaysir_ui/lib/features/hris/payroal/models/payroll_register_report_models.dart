import 'payroll_liability_models.dart';
import 'payroll_payment_batch_models.dart';
import 'payroll_payslip_models.dart';

enum PayrollRegisterReportStatus {
  blocked('Blocked'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const PayrollRegisterReportStatus(this.label);
}

class PayrollRegisterReportLine {
  final int employeeId;
  final String employeeName;
  final String position;
  final String paymentReferenceCode;
  final String statementId;
  final double grossAmount;
  final double adjustmentAmount;
  final double deductionAmount;
  final double netAmount;
  final bool paymentReleased;
  final bool payslipPublished;

  const PayrollRegisterReportLine({
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.paymentReferenceCode,
    required this.statementId,
    required this.grossAmount,
    required this.adjustmentAmount,
    required this.deductionAmount,
    required this.netAmount,
    required this.paymentReleased,
    required this.payslipPublished,
  });

  bool get isComplete => paymentReleased && payslipPublished;
}

class PayrollRegisterReportSummary {
  final String reportId;
  final String periodLabel;
  final DateTime payDate;
  final List<PayrollRegisterReportLine> lines;
  final double liabilityAmount;
  final bool liabilitiesRemitted;
  final bool journalPosted;
  final bool isExported;

  const PayrollRegisterReportSummary({
    required this.reportId,
    required this.periodLabel,
    required this.payDate,
    required this.lines,
    required this.liabilityAmount,
    required this.liabilitiesRemitted,
    required this.journalPosted,
    required this.isExported,
  });

  factory PayrollRegisterReportSummary.fromRun({
    required PayrollPaymentBatchSummary paymentBatch,
    required PayrollPayslipPackageSummary payslipPackage,
    required PayrollLiabilitySummary liabilities,
    required bool journalPosted,
    required Set<String> exportedReportIds,
  }) {
    final payslipByEmployeeId = {
      for (final line in payslipPackage.lines) line.employeeId: line,
    };
    final reportId = paymentBatch.batchId.replaceFirst('PB-', 'REG-');
    final lines =
        paymentBatch.lines.map((paymentLine) {
          final payslipLine = payslipByEmployeeId[paymentLine.employeeId];
          return PayrollRegisterReportLine(
            employeeId: paymentLine.employeeId,
            employeeName: paymentLine.employeeName,
            position: paymentLine.position,
            paymentReferenceCode: paymentLine.referenceCode,
            statementId: payslipLine?.statementId ?? 'Not prepared',
            grossAmount: paymentLine.grossAmount,
            adjustmentAmount: paymentLine.adjustmentAmount,
            deductionAmount: paymentLine.deductionAmount,
            netAmount: paymentLine.netAmount,
            paymentReleased: paymentLine.isPaid,
            payslipPublished: payslipLine?.isPublished ?? false,
          );
        }).toList();

    return PayrollRegisterReportSummary(
      reportId: reportId,
      periodLabel: paymentBatch.periodLabel,
      payDate: paymentBatch.payDate,
      lines: lines,
      liabilityAmount: liabilities.totalAmount,
      liabilitiesRemitted: liabilities.pendingCount == 0,
      journalPosted: journalPosted,
      isExported: exportedReportIds.contains(reportId),
    );
  }

  int get employeeCount => lines.length;

  int get releasedPaymentCount {
    return lines.where((line) => line.paymentReleased).length;
  }

  int get publishedPayslipCount {
    return lines.where((line) => line.payslipPublished).length;
  }

  int get completeLineCount {
    return lines.where((line) => line.isComplete).length;
  }

  double get totalGross {
    return lines.fold(0, (total, line) => total + line.grossAmount);
  }

  double get totalAdjustments {
    return lines.fold(0, (total, line) => total + line.adjustmentAmount);
  }

  double get totalDeductions {
    return lines.fold(0, (total, line) => total + line.deductionAmount);
  }

  double get totalNet {
    return lines.fold(0, (total, line) => total + line.netAmount);
  }

  List<String> get blockers {
    return [
      if (lines.isEmpty) 'No payroll register lines are available',
      if (releasedPaymentCount < employeeCount)
        '${employeeCount - releasedPaymentCount} payment releases pending',
      if (publishedPayslipCount < employeeCount)
        '${employeeCount - publishedPayslipCount} payslips unpublished',
      if (!liabilitiesRemitted) 'Payroll liabilities are not fully remitted',
      if (!journalPosted) 'Payroll journal is not posted',
    ];
  }

  PayrollRegisterReportStatus get status {
    if (blockers.isNotEmpty) return PayrollRegisterReportStatus.blocked;
    if (isExported) return PayrollRegisterReportStatus.exported;
    return PayrollRegisterReportStatus.ready;
  }

  bool get canExport => status == PayrollRegisterReportStatus.ready;

  String get nextAction {
    final currentBlockers = blockers;
    if (currentBlockers.isNotEmpty) return currentBlockers.first;
    if (isExported) return 'Payroll register report is exported.';
    return 'Export payroll register for finance review.';
  }
}
