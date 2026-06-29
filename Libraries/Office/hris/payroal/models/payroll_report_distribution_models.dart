import 'payroll_reports_hub_models.dart';

/// Defines the delivery state for a payroll report artifact.
enum PayrollReportDistributionStatus {
  blocked('Blocked'),
  ready('Ready'),
  delivered('Delivered');

  final String label;

  const PayrollReportDistributionStatus(this.label);
}

/// Defines the channel used to send a payroll report artifact.
enum PayrollReportDistributionChannel {
  financeWorkspace('Finance workspace'),
  secureBankPortal('Secure bank portal'),
  taxPortal('Tax portal'),
  auditVault('Audit vault');

  final String label;

  const PayrollReportDistributionChannel(this.label);
}

/// Captures the delivery receipt for an exported payroll report package.
class PayrollReportDeliveryReceipt {
  final String reportId;
  final PayrollReportDistributionChannel channel;
  final List<String> recipients;
  final String deliveredBy;
  final DateTime deliveredAt;

  const PayrollReportDeliveryReceipt({
    required this.reportId,
    required this.channel,
    required this.recipients,
    required this.deliveredBy,
    required this.deliveredAt,
  });

  String get recipientLabel => recipients.join(', ');
}

/// Represents one payroll report package and its delivery readiness.
class PayrollReportDistributionLine {
  final PayrollReportHubItem report;
  final PayrollReportDistributionChannel channel;
  final List<String> recipients;
  final PayrollReportDeliveryReceipt? receipt;

  const PayrollReportDistributionLine({
    required this.report,
    required this.channel,
    required this.recipients,
    required this.receipt,
  });

  PayrollReportDistributionStatus get status {
    if (receipt != null && report.isComplete) {
      return PayrollReportDistributionStatus.delivered;
    }
    if (report.isComplete) return PayrollReportDistributionStatus.ready;
    return PayrollReportDistributionStatus.blocked;
  }

  bool get canDeliver => status == PayrollReportDistributionStatus.ready;

  bool get canReopen => status == PayrollReportDistributionStatus.delivered;

  List<String> get blockers {
    if (report.isBlocked) return report.blockers;
    if (report.isReady) return ['Complete ${report.title.toLowerCase()}.'];
    return const [];
  }

  String get recipientLabel => recipients.join(', ');

  String get nextAction {
    if (status == PayrollReportDistributionStatus.delivered) {
      return '${report.title} has been delivered.';
    }
    if (status == PayrollReportDistributionStatus.ready) {
      return 'Deliver ${report.title.toLowerCase()} to ${channel.label}.';
    }
    if (blockers.isNotEmpty) return blockers.first;
    return 'Complete report before distribution.';
  }
}

/// Summarizes report distribution readiness for the payroll close packet.
class PayrollReportDistributionSummary {
  final String periodLabel;
  final List<PayrollReportDistributionLine> lines;

  const PayrollReportDistributionSummary({
    required this.periodLabel,
    required this.lines,
  });

  factory PayrollReportDistributionSummary.fromReportsHub({
    required PayrollReportsHubSummary reportsHub,
    required Map<String, PayrollReportDeliveryReceipt> deliveryReceipts,
  }) {
    return PayrollReportDistributionSummary(
      periodLabel: reportsHub.periodLabel,
      lines: [
        for (final report in reportsHub.items)
          PayrollReportDistributionLine(
            report: report,
            channel: _channelFor(report.category),
            recipients: _recipientsFor(report.category),
            receipt: deliveryReceipts[report.id],
          ),
      ],
    );
  }

  int get blockedCount {
    return lines
        .where((line) => line.status == PayrollReportDistributionStatus.blocked)
        .length;
  }

  int get readyCount {
    return lines
        .where((line) => line.status == PayrollReportDistributionStatus.ready)
        .length;
  }

  int get deliveredCount {
    return lines
        .where(
          (line) => line.status == PayrollReportDistributionStatus.delivered,
        )
        .length;
  }

  List<PayrollReportDistributionLine> get readyLines {
    return lines
        .where((line) => line.status == PayrollReportDistributionStatus.ready)
        .toList();
  }

  List<PayrollReportDistributionLine> get deliveredLines {
    return lines
        .where(
          (line) => line.status == PayrollReportDistributionStatus.delivered,
        )
        .toList();
  }

  double get deliveryRate {
    if (lines.isEmpty) return 0;
    return deliveredCount / lines.length;
  }

  PayrollReportDistributionStatus get status {
    if (blockedCount > 0) return PayrollReportDistributionStatus.blocked;
    if (deliveredCount == lines.length) {
      return PayrollReportDistributionStatus.delivered;
    }
    return PayrollReportDistributionStatus.ready;
  }

  String get nextAction {
    if (blockedCount > 0) {
      return 'Resolve $blockedCount report distribution blockers.';
    }
    if (readyCount > 0) {
      return 'Deliver $readyCount payroll report packages.';
    }
    return 'Payroll report distribution is complete.';
  }
}

PayrollReportDistributionChannel _channelFor(
  PayrollReportHubCategory category,
) {
  return switch (category) {
    PayrollReportHubCategory.finance =>
      PayrollReportDistributionChannel.financeWorkspace,
    PayrollReportHubCategory.payments =>
      PayrollReportDistributionChannel.secureBankPortal,
    PayrollReportHubCategory.compliance =>
      PayrollReportDistributionChannel.taxPortal,
    PayrollReportHubCategory.audit =>
      PayrollReportDistributionChannel.auditVault,
  };
}

List<String> _recipientsFor(PayrollReportHubCategory category) {
  return switch (category) {
    PayrollReportHubCategory.finance => const [
      'Finance Controller',
      'Payroll Manager',
    ],
    PayrollReportHubCategory.payments => const [
      'Treasury Ops',
      'Bank Operations',
    ],
    PayrollReportHubCategory.compliance => const [
      'Payroll Tax',
      'Compliance Lead',
    ],
    PayrollReportHubCategory.audit => const [
      'Payroll Controller',
      'Internal Audit',
    ],
  };
}
