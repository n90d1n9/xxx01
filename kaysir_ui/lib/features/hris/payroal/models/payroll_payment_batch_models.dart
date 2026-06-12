import '../../employee/models/employee.dart';
import 'payroll_adjustment_models.dart';
import 'payroll_detail.dart';
import 'payroll_reconciliation_models.dart';
import 'payroll_run_builder_models.dart';
import 'payroll_run_models.dart';

enum PayrollPaymentMethod {
  bankTransfer('Bank transfer'),
  instantWallet('Instant wallet'),
  manualTransfer('Manual transfer');

  final String label;

  const PayrollPaymentMethod(this.label);
}

enum PayrollPaymentBatchStatus {
  blocked('Blocked'),
  ready('Ready'),
  releasing('Releasing'),
  released('Released');

  final String label;

  const PayrollPaymentBatchStatus(this.label);
}

enum PayrollBankTransferFileStatus {
  blocked('Blocked'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const PayrollBankTransferFileStatus(this.label);
}

class PayrollPaymentProfile {
  final int employeeId;
  final PayrollPaymentMethod method;
  final String destinationLabel;
  final String fundingSource;
  final String referenceCode;

  const PayrollPaymentProfile({
    required this.employeeId,
    required this.method,
    required this.destinationLabel,
    required this.fundingSource,
    required this.referenceCode,
  });

  bool get hasDestination => destinationLabel.trim().isNotEmpty;
}

class PayrollPaymentBatchLine {
  final int employeeId;
  final String employeeName;
  final String position;
  final PayrollPaymentMethod method;
  final String destinationLabel;
  final String fundingSource;
  final String referenceCode;
  final double grossAmount;
  final double adjustmentAmount;
  final double deductionAmount;
  final double netAmount;
  final bool isPaid;
  final List<String> blockers;

  const PayrollPaymentBatchLine({
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.method,
    required this.destinationLabel,
    required this.fundingSource,
    required this.referenceCode,
    required this.grossAmount,
    required this.adjustmentAmount,
    required this.deductionAmount,
    required this.netAmount,
    required this.isPaid,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get canRelease => !isPaid && !hasBlockers;

  String get statusLabel {
    if (isPaid) return 'Released';
    if (hasBlockers) return 'Blocked';
    return 'Scheduled';
  }

  double get deductionRate {
    if (grossAmount == 0) return 0;
    return deductionAmount / grossAmount;
  }
}

class PayrollPaymentBatchSummary {
  final String batchId;
  final String periodLabel;
  final DateTime payDate;
  final bool hasActiveRunPlan;
  final String activeRunPlanLabel;
  final bool reconciliationReviewed;
  final bool isRunLocked;
  final List<PayrollPaymentBatchLine> lines;

  const PayrollPaymentBatchSummary({
    required this.batchId,
    required this.periodLabel,
    required this.payDate,
    required this.hasActiveRunPlan,
    required this.activeRunPlanLabel,
    required this.reconciliationReviewed,
    required this.isRunLocked,
    required this.lines,
  });

  factory PayrollPaymentBatchSummary.fromRun({
    required PayrollRunDashboard dashboard,
    required List<Employee> employees,
    required Map<int, bool> paymentStatus,
    required List<PayrollPaymentProfile> profiles,
    required List<PayrollAdjustmentRequest> adjustments,
    required PayrollReconciliationSummary reconciliation,
    required PayrollActiveRunPlanSummary activeRunPlan,
    required Set<String> completedStepIds,
  }) {
    final profileByEmployeeId = {
      for (final profile in profiles) profile.employeeId: profile,
    };
    final adjustmentByEmployeeId = <int, double>{};
    for (final adjustment in adjustments.where(
      (adjustment) => adjustment.isApproved,
    )) {
      adjustmentByEmployeeId.update(
        adjustment.employeeId,
        (total) => total + adjustment.amount,
        ifAbsent: () => adjustment.amount,
      );
    }

    final lines =
        employees.map((employee) {
          final details = PayrollDetails.fromSalary(employee.salary ?? 0);
          final profile = profileByEmployeeId[employee.id];
          final adjustmentAmount = adjustmentByEmployeeId[employee.id] ?? 0;
          final position = employee.position?.trim();
          final blockers = <String>[
            if ((employee.salary ?? 0) <= 0) 'Missing salary setup',
            if (profile == null || !profile.hasDestination)
              'Missing payment destination',
          ];

          return PayrollPaymentBatchLine(
            employeeId: employee.id,
            employeeName: employee.name,
            position:
                position == null || position.isEmpty ? 'Employee' : position,
            method: profile?.method ?? PayrollPaymentMethod.manualTransfer,
            destinationLabel: profile?.destinationLabel ?? 'Not configured',
            fundingSource: profile?.fundingSource ?? 'Payroll funding',
            referenceCode:
                profile?.referenceCode ??
                'PAY-${dashboard.payDate.year}${dashboard.payDate.month.toString().padLeft(2, '0')}-${employee.id.toString().padLeft(4, '0')}',
            grossAmount: details.grossSalary + adjustmentAmount,
            adjustmentAmount: adjustmentAmount,
            deductionAmount: details.totalDeductions,
            netAmount: details.netSalary + adjustmentAmount,
            isPaid: paymentStatus[employee.id] ?? false,
            blockers: blockers,
          );
        }).toList();

    return PayrollPaymentBatchSummary(
      batchId:
          'PB-${dashboard.payDate.year}${dashboard.payDate.month.toString().padLeft(2, '0')}',
      periodLabel: dashboard.periodLabel,
      payDate: dashboard.payDate,
      hasActiveRunPlan: activeRunPlan.hasActivePlan,
      activeRunPlanLabel: activeRunPlan.request?.label ?? 'No active run plan',
      reconciliationReviewed: reconciliation.isReviewed,
      isRunLocked:
          reconciliation.isReviewed &&
          completedStepIds.contains('lock-payroll'),
      lines: lines,
    );
  }

  int get paidCount => lines.where((line) => line.isPaid).length;

  int get pendingCount => lines.length - paidCount;

  int get blockedRecipientCount =>
      lines.where((line) => !line.isPaid && line.hasBlockers).length;

  int get readyRecipientCount => lines.where((line) => line.canRelease).length;

  double get totalGross =>
      lines.fold(0, (total, line) => total + line.grossAmount);

  double get totalNet => lines.fold(0, (total, line) => total + line.netAmount);

  double get releasedNet => lines
      .where((line) => line.isPaid)
      .fold(0, (total, line) => total + line.netAmount);

  double get pendingNet => lines
      .where((line) => !line.isPaid)
      .fold(0, (total, line) => total + line.netAmount);

  double get adjustmentTotal =>
      lines.fold(0, (total, line) => total + line.adjustmentAmount);

  PayrollPaymentBatchStatus get status {
    if (pendingCount == 0) return PayrollPaymentBatchStatus.released;
    if (!hasActiveRunPlan ||
        !reconciliationReviewed ||
        !isRunLocked ||
        blockedRecipientCount > 0) {
      return PayrollPaymentBatchStatus.blocked;
    }
    if (paidCount > 0) return PayrollPaymentBatchStatus.releasing;
    return PayrollPaymentBatchStatus.ready;
  }

  bool get canRelease =>
      hasActiveRunPlan &&
      isRunLocked &&
      pendingCount > 0 &&
      blockedRecipientCount == 0;

  String get nextAction {
    if (!hasActiveRunPlan) {
      return 'Activate a payroll run plan before payment release.';
    }
    if (!reconciliationReviewed) {
      return 'Review reconciliation before building payment release.';
    }
    if (!isRunLocked) {
      return 'Lock payroll run before releasing payment batch.';
    }
    if (blockedRecipientCount > 0) {
      return 'Resolve $blockedRecipientCount recipient payment blockers.';
    }
    if (pendingCount > 0) {
      return 'Release $pendingCount scheduled payments from payroll funding.';
    }
    return 'Payment batch is fully released.';
  }
}

class PayrollBankTransferFileLine {
  final int employeeId;
  final String employeeName;
  final String destinationLabel;
  final String fundingSource;
  final String referenceCode;
  final double netAmount;
  final bool isReleased;
  final List<String> blockers;

  const PayrollBankTransferFileLine({
    required this.employeeId,
    required this.employeeName,
    required this.destinationLabel,
    required this.fundingSource,
    required this.referenceCode,
    required this.netAmount,
    required this.isReleased,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;
}

class PayrollBankTransferFileSummary {
  final String fileId;
  final String periodLabel;
  final DateTime payDate;
  final List<PayrollBankTransferFileLine> lines;
  final int nonBankRecipientCount;
  final List<String> blockers;
  final bool isExported;

  const PayrollBankTransferFileSummary({
    required this.fileId,
    required this.periodLabel,
    required this.payDate,
    required this.lines,
    required this.nonBankRecipientCount,
    required this.blockers,
    required this.isExported,
  });

  factory PayrollBankTransferFileSummary.fromPaymentBatch({
    required PayrollPaymentBatchSummary paymentBatch,
    required Set<String> exportedFileIds,
  }) {
    final bankLines =
        paymentBatch.lines
            .where((line) => line.method == PayrollPaymentMethod.bankTransfer)
            .map(
              (line) => PayrollBankTransferFileLine(
                employeeId: line.employeeId,
                employeeName: line.employeeName,
                destinationLabel: line.destinationLabel,
                fundingSource: line.fundingSource,
                referenceCode: line.referenceCode,
                netAmount: line.netAmount,
                isReleased: line.isPaid,
                blockers: [
                  if (line.destinationLabel.trim().isEmpty ||
                      line.destinationLabel == 'Not configured')
                    'Missing bank destination',
                  if (line.netAmount <= 0) 'Net payment amount is unavailable',
                  ...line.blockers,
                ],
              ),
            )
            .toList();
    final fileId = paymentBatch.batchId.replaceFirst('PB-', 'BANK-');
    final lineBlockerCount = bankLines.where((line) => line.hasBlockers).length;
    final blockers = <String>[
      if (!paymentBatch.hasActiveRunPlan) 'Payroll run plan is not active',
      if (!paymentBatch.reconciliationReviewed)
        'Payroll reconciliation is not reviewed',
      if (!paymentBatch.isRunLocked) 'Payroll run is not locked',
      if (bankLines.isEmpty) 'No bank transfer recipients available',
      if (lineBlockerCount > 0)
        '$lineBlockerCount bank transfer recipients have blockers',
    ];

    return PayrollBankTransferFileSummary(
      fileId: fileId,
      periodLabel: paymentBatch.periodLabel,
      payDate: paymentBatch.payDate,
      lines: bankLines,
      nonBankRecipientCount:
          paymentBatch.lines.length -
          paymentBatch.lines
              .where((line) => line.method == PayrollPaymentMethod.bankTransfer)
              .length,
      blockers: blockers,
      isExported: exportedFileIds.contains(fileId),
    );
  }

  int get recipientCount => lines.length;

  int get releasedRecipientCount {
    return lines.where((line) => line.isReleased).length;
  }

  double get totalAmount {
    return lines.fold(0, (total, line) => total + line.netAmount);
  }

  bool get hasBlockers => blockers.isNotEmpty;

  PayrollBankTransferFileStatus get status {
    if (hasBlockers) return PayrollBankTransferFileStatus.blocked;
    if (isExported) return PayrollBankTransferFileStatus.exported;
    return PayrollBankTransferFileStatus.ready;
  }

  bool get canExport => status == PayrollBankTransferFileStatus.ready;

  String get nextAction {
    if (hasBlockers) return blockers.first;
    if (isExported) return 'Bank transfer file is exported.';
    return 'Export bank transfer file for payment release.';
  }
}
