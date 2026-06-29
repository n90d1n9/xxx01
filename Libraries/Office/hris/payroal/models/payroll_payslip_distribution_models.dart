import 'payroll_payslip_models.dart';

enum PayrollPayslipDistributionStatus {
  waitingForPublish('Waiting'),
  ready('Ready'),
  dispatching('Dispatching'),
  needsAttention('Needs attention'),
  complete('Complete');

  final String label;

  const PayrollPayslipDistributionStatus(this.label);
}

enum PayrollPayslipDistributionLineStatus {
  waitingForPublish('Waiting'),
  readyToSend('Ready to send'),
  sent('Sent'),
  failed('Failed'),
  acknowledged('Acknowledged');

  final String label;

  const PayrollPayslipDistributionLineStatus(this.label);
}

class PayrollPayslipDeliveryReceipt {
  final int employeeId;
  final DateTime sentAt;
  final DateTime? acknowledgedAt;
  final String? failureReason;

  const PayrollPayslipDeliveryReceipt({
    required this.employeeId,
    required this.sentAt,
    this.acknowledgedAt,
    this.failureReason,
  });

  bool get isFailed =>
      failureReason != null && failureReason!.trim().isNotEmpty;

  bool get isAcknowledged => acknowledgedAt != null && !isFailed;
}

class PayrollPayslipDistributionLine {
  final PayrollPayslipLine payslip;
  final PayrollPayslipDeliveryReceipt? receipt;

  const PayrollPayslipDistributionLine({
    required this.payslip,
    required this.receipt,
  });

  PayrollPayslipDistributionLineStatus get status {
    if (!payslip.isPublished) {
      return PayrollPayslipDistributionLineStatus.waitingForPublish;
    }
    final deliveryReceipt = receipt;
    if (deliveryReceipt == null) {
      return PayrollPayslipDistributionLineStatus.readyToSend;
    }
    if (deliveryReceipt.isFailed) {
      return PayrollPayslipDistributionLineStatus.failed;
    }
    if (deliveryReceipt.isAcknowledged) {
      return PayrollPayslipDistributionLineStatus.acknowledged;
    }
    return PayrollPayslipDistributionLineStatus.sent;
  }

  bool get canDispatch =>
      status == PayrollPayslipDistributionLineStatus.readyToSend ||
      status == PayrollPayslipDistributionLineStatus.failed;

  String get nextAction {
    return switch (status) {
      PayrollPayslipDistributionLineStatus.waitingForPublish =>
        'Publish payslip before delivery',
      PayrollPayslipDistributionLineStatus.readyToSend =>
        'Ready for statement dispatch',
      PayrollPayslipDistributionLineStatus.sent =>
        'Awaiting employee acknowledgement',
      PayrollPayslipDistributionLineStatus.failed =>
        receipt?.failureReason ?? 'Delivery failed',
      PayrollPayslipDistributionLineStatus.acknowledged =>
        'Employee acknowledgement received',
    };
  }
}

class PayrollPayslipDistributionSummary {
  final PayrollPayslipPackageSummary package;
  final List<PayrollPayslipDistributionLine> lines;

  const PayrollPayslipDistributionSummary({
    required this.package,
    required this.lines,
  });

  factory PayrollPayslipDistributionSummary.fromPackage({
    required PayrollPayslipPackageSummary package,
    required Map<int, PayrollPayslipDeliveryReceipt> receipts,
  }) {
    return PayrollPayslipDistributionSummary(
      package: package,
      lines:
          package.lines
              .map(
                (line) => PayrollPayslipDistributionLine(
                  payslip: line,
                  receipt: receipts[line.employeeId],
                ),
              )
              .toList(),
    );
  }

  int get waitingCount =>
      _count(PayrollPayslipDistributionLineStatus.waitingForPublish);

  int get readyToSendCount =>
      _count(PayrollPayslipDistributionLineStatus.readyToSend);

  int get sentCount => _count(PayrollPayslipDistributionLineStatus.sent);

  int get failedCount => _count(PayrollPayslipDistributionLineStatus.failed);

  int get acknowledgedCount =>
      _count(PayrollPayslipDistributionLineStatus.acknowledged);

  int get dispatchedCount => sentCount + failedCount + acknowledgedCount;

  bool get hasReceipts => lines.any((line) => line.receipt != null);

  bool get canDispatch => lines.any((line) => line.canDispatch);

  double get deliveryProgress {
    if (lines.isEmpty) return 0;
    return dispatchedCount / lines.length;
  }

  PayrollPayslipDistributionStatus get status {
    if (failedCount > 0) return PayrollPayslipDistributionStatus.needsAttention;
    if (waitingCount == lines.length) {
      return PayrollPayslipDistributionStatus.waitingForPublish;
    }
    if (readyToSendCount > 0) return PayrollPayslipDistributionStatus.ready;
    if (acknowledgedCount == lines.length && lines.isNotEmpty) {
      return PayrollPayslipDistributionStatus.complete;
    }
    return PayrollPayslipDistributionStatus.dispatching;
  }

  String get nextAction {
    if (failedCount > 0) {
      return 'Retry $failedCount failed payslip deliveries.';
    }
    if (waitingCount == lines.length) {
      return 'Publish payslips before dispatching statements.';
    }
    if (readyToSendCount > 0) {
      return 'Dispatch $readyToSendCount published payslip statements.';
    }
    if (acknowledgedCount < lines.length) {
      final pendingAcknowledgements = lines.length - acknowledgedCount;
      return 'Collect $pendingAcknowledgements employee acknowledgements.';
    }
    return 'All payslip statements are delivered and acknowledged.';
  }

  int _count(PayrollPayslipDistributionLineStatus target) {
    return lines.where((line) => line.status == target).length;
  }
}
