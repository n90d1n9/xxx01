enum FinancialReportManagementMeasureReleaseCheckKind {
  auditTrail,
  approval,
  reconciliation,
  exportEvidence,
}

enum FinancialReportManagementMeasureReleaseCheckStatus {
  ready,
  actionRequired,
}

extension FinancialReportManagementMeasureReleaseCheckStatusLabel
    on FinancialReportManagementMeasureReleaseCheckStatus {
  String get label {
    switch (this) {
      case FinancialReportManagementMeasureReleaseCheckStatus.ready:
        return 'Ready';
      case FinancialReportManagementMeasureReleaseCheckStatus.actionRequired:
        return 'Action needed';
    }
  }
}

class FinancialReportManagementMeasureReleaseCheckItem {
  final FinancialReportManagementMeasureReleaseCheckKind kind;
  final String title;
  final FinancialReportManagementMeasureReleaseCheckStatus status;
  final String metric;
  final String detail;

  const FinancialReportManagementMeasureReleaseCheckItem({
    required this.kind,
    required this.title,
    required this.status,
    required this.metric,
    required this.detail,
  });

  bool get isReady =>
      status == FinancialReportManagementMeasureReleaseCheckStatus.ready;
}

class FinancialReportManagementMeasureReleaseReadinessSummary {
  final List<FinancialReportManagementMeasureReleaseCheckItem> items;
  final int readyCount;
  final int actionRequiredCount;
  final bool readyForExport;
  final double completionRatio;
  final String nextAction;

  const FinancialReportManagementMeasureReleaseReadinessSummary({
    required this.items,
    required this.readyCount,
    required this.actionRequiredCount,
    required this.readyForExport,
    required this.completionRatio,
    required this.nextAction,
  });
}
