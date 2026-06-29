import 'payroll_payment_batch_models.dart';

enum PayrollPayslipDeliveryChannel {
  employeePortal('Employee portal'),
  email('Email'),
  sealedPrint('Sealed print');

  final String label;

  const PayrollPayslipDeliveryChannel(this.label);
}

enum PayrollPayslipPackageStatus {
  blocked('Blocked'),
  ready('Ready'),
  publishing('Publishing'),
  published('Published');

  final String label;

  const PayrollPayslipPackageStatus(this.label);
}

class PayrollPayslipDeliveryProfile {
  final int employeeId;
  final PayrollPayslipDeliveryChannel channel;
  final String destinationLabel;

  const PayrollPayslipDeliveryProfile({
    required this.employeeId,
    required this.channel,
    required this.destinationLabel,
  });

  bool get hasDestination => destinationLabel.trim().isNotEmpty;
}

class PayrollPayslipLine {
  final int employeeId;
  final String employeeName;
  final String position;
  final String statementId;
  final PayrollPayslipDeliveryChannel channel;
  final String destinationLabel;
  final String paymentReferenceCode;
  final double grossAmount;
  final double adjustmentAmount;
  final double deductionAmount;
  final double netAmount;
  final bool paymentReleased;
  final bool isPublished;
  final List<String> blockers;

  const PayrollPayslipLine({
    required this.employeeId,
    required this.employeeName,
    required this.position,
    required this.statementId,
    required this.channel,
    required this.destinationLabel,
    required this.paymentReferenceCode,
    required this.grossAmount,
    required this.adjustmentAmount,
    required this.deductionAmount,
    required this.netAmount,
    required this.paymentReleased,
    required this.isPublished,
    required this.blockers,
  });

  bool get hasBlockers => blockers.isNotEmpty;

  bool get canPublish => paymentReleased && !isPublished && !hasBlockers;

  String get statusLabel {
    if (isPublished) return 'Published';
    if (hasBlockers) return 'Blocked';
    return 'Ready';
  }
}

class PayrollPayslipPackageSummary {
  final String packageId;
  final String periodLabel;
  final DateTime payDate;
  final List<PayrollPayslipLine> lines;

  const PayrollPayslipPackageSummary({
    required this.packageId,
    required this.periodLabel,
    required this.payDate,
    required this.lines,
  });

  factory PayrollPayslipPackageSummary.fromPaymentBatch({
    required PayrollPaymentBatchSummary paymentBatch,
    required List<PayrollPayslipDeliveryProfile> deliveryProfiles,
    required Set<int> publishedEmployeeIds,
  }) {
    final profileByEmployeeId = {
      for (final profile in deliveryProfiles) profile.employeeId: profile,
    };

    final lines =
        paymentBatch.lines.map((paymentLine) {
          final profile = profileByEmployeeId[paymentLine.employeeId];
          final blockers = <String>[
            if (!paymentLine.isPaid) 'Payment is not released',
            if (profile == null || !profile.hasDestination)
              'Missing payslip destination',
          ];

          return PayrollPayslipLine(
            employeeId: paymentLine.employeeId,
            employeeName: paymentLine.employeeName,
            position: paymentLine.position,
            statementId:
                'PS-${paymentBatch.payDate.year}${paymentBatch.payDate.month.toString().padLeft(2, '0')}-${paymentLine.employeeId.toString().padLeft(4, '0')}',
            channel:
                profile?.channel ??
                PayrollPayslipDeliveryChannel.employeePortal,
            destinationLabel: profile?.destinationLabel ?? 'Not configured',
            paymentReferenceCode: paymentLine.referenceCode,
            grossAmount: paymentLine.grossAmount,
            adjustmentAmount: paymentLine.adjustmentAmount,
            deductionAmount: paymentLine.deductionAmount,
            netAmount: paymentLine.netAmount,
            paymentReleased: paymentLine.isPaid,
            isPublished:
                paymentLine.isPaid &&
                publishedEmployeeIds.contains(paymentLine.employeeId),
            blockers: blockers,
          );
        }).toList();

    return PayrollPayslipPackageSummary(
      packageId: paymentBatch.batchId.replaceFirst('PB-', 'PS-'),
      periodLabel: paymentBatch.periodLabel,
      payDate: paymentBatch.payDate,
      lines: lines,
    );
  }

  int get publishedCount => lines.where((line) => line.isPublished).length;

  int get pendingCount => lines.length - publishedCount;

  int get readyCount => lines.where((line) => line.canPublish).length;

  int get blockedCount =>
      lines.where((line) => !line.isPublished && line.hasBlockers).length;

  double get totalNet => lines.fold(0, (total, line) => total + line.netAmount);

  double get publishedNet => lines
      .where((line) => line.isPublished)
      .fold(0, (total, line) => total + line.netAmount);

  PayrollPayslipPackageStatus get status {
    if (pendingCount == 0) return PayrollPayslipPackageStatus.published;
    if (blockedCount > 0) return PayrollPayslipPackageStatus.blocked;
    if (publishedCount > 0) return PayrollPayslipPackageStatus.publishing;
    return PayrollPayslipPackageStatus.ready;
  }

  bool get canPublish => readyCount > 0 && blockedCount == 0;

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount payslip publishing blockers.';
    }
    if (pendingCount > 0) {
      return 'Publish $pendingCount employee payslips to configured channels.';
    }
    return 'Payslip package is fully published.';
  }
}

class PayrollPayslipDetail {
  final String packageId;
  final String periodLabel;
  final DateTime payDate;
  final PayrollPayslipLine? line;
  final String nextAction;

  const PayrollPayslipDetail({
    required this.packageId,
    required this.periodLabel,
    required this.payDate,
    required this.line,
    required this.nextAction,
  });

  factory PayrollPayslipDetail.fromPackage({
    required PayrollPayslipPackageSummary package,
    required int? selectedEmployeeId,
  }) {
    PayrollPayslipLine? selectedLine;
    if (package.lines.isNotEmpty) {
      selectedLine = package.lines.firstWhere(
        (line) => line.employeeId == selectedEmployeeId,
        orElse: () => package.lines.first,
      );
    }

    return PayrollPayslipDetail(
      packageId: package.packageId,
      periodLabel: package.periodLabel,
      payDate: package.payDate,
      line: selectedLine,
      nextAction:
          selectedLine == null
              ? 'No payslip statement is available for this package.'
              : selectedLine.isPublished
              ? '${selectedLine.employeeName} payslip is published.'
              : selectedLine.hasBlockers
              ? selectedLine.blockers.first
              : '${selectedLine.employeeName} payslip is ready to publish.',
    );
  }

  bool get hasStatement => line != null;

  double get grossAmount => line?.grossAmount ?? 0;

  double get adjustmentAmount => line?.adjustmentAmount ?? 0;

  double get deductionAmount => line?.deductionAmount ?? 0;

  double get netAmount => line?.netAmount ?? 0;

  double get deductionRate {
    if (grossAmount == 0) return 0;
    return deductionAmount / grossAmount;
  }

  String get statusLabel {
    final statement = line;
    if (statement == null) return 'Unavailable';
    return statement.statusLabel;
  }
}
