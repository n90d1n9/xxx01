import 'payroll_reconciliation_models.dart';

enum PayrollVarianceReportStatus {
  blocked('Blocked'),
  ready('Ready'),
  exported('Exported');

  final String label;

  const PayrollVarianceReportStatus(this.label);
}

class PayrollVarianceReportSummary {
  final String reportId;
  final String periodLabel;
  final String baselinePeriodLabel;
  final List<PayrollVarianceLine> lines;
  final bool reconciliationReviewed;
  final bool isExported;

  const PayrollVarianceReportSummary({
    required this.reportId,
    required this.periodLabel,
    required this.baselinePeriodLabel,
    required this.lines,
    required this.reconciliationReviewed,
    required this.isExported,
  });

  factory PayrollVarianceReportSummary.fromReconciliation({
    required PayrollReconciliationSummary reconciliation,
    required Set<String> exportedReportIds,
  }) {
    final reportId = _reportId(reconciliation.periodLabel);
    return PayrollVarianceReportSummary(
      reportId: reportId,
      periodLabel: reconciliation.periodLabel,
      baselinePeriodLabel: reconciliation.baselinePeriodLabel,
      lines: reconciliation.varianceLines,
      reconciliationReviewed: reconciliation.isReviewed,
      isExported: exportedReportIds.contains(reportId),
    );
  }

  int get materialVarianceCount {
    return lines.where((line) => line.requiresAttention).length;
  }

  int get reviewVarianceCount {
    return lines
        .where((line) => line.status == PayrollVarianceStatus.review)
        .length;
  }

  double get largestVarianceAmount {
    if (lines.isEmpty) return 0;
    return largestVariance.absoluteDelta;
  }

  PayrollVarianceLine get largestVariance {
    final sorted = [
      ...lines,
    ]..sort((left, right) => right.absoluteDelta.compareTo(left.absoluteDelta));
    return sorted.first;
  }

  List<String> get blockers {
    return [
      if (lines.isEmpty) 'No variance lines are available',
      if (!reconciliationReviewed) 'Reconciliation is not reviewed',
      if (reviewVarianceCount > 0)
        '$reviewVarianceCount variances require investigation',
    ];
  }

  PayrollVarianceReportStatus get status {
    if (blockers.isNotEmpty) return PayrollVarianceReportStatus.blocked;
    if (isExported) return PayrollVarianceReportStatus.exported;
    return PayrollVarianceReportStatus.ready;
  }

  bool get canExport => status == PayrollVarianceReportStatus.ready;

  String get nextAction {
    final currentBlockers = blockers;
    if (currentBlockers.isNotEmpty) return currentBlockers.first;
    if (isExported) return 'Payroll variance report is exported.';
    return 'Export variance report for finance review.';
  }
}

String _reportId(String periodLabel) {
  final compact = periodLabel
      .toUpperCase()
      .replaceAll(RegExp('[^A-Z0-9]+'), '-')
      .replaceAll(RegExp('-+'), '-')
      .replaceAll(RegExp('(^-|-\$)'), '');
  return 'VAR-$compact';
}
