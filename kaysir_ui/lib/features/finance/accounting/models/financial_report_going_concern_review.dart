enum FinancialReportGoingConcernReviewKind {
  liquidityBuffer,
  operatingPerformance,
  netAssetPosition,
  operatingCashFlow,
  liabilitiesPressure,
  managementAssessment,
}

extension FinancialReportGoingConcernReviewKindLabel
    on FinancialReportGoingConcernReviewKind {
  String get label {
    switch (this) {
      case FinancialReportGoingConcernReviewKind.liquidityBuffer:
        return 'Liquidity buffer';
      case FinancialReportGoingConcernReviewKind.operatingPerformance:
        return 'Operating performance';
      case FinancialReportGoingConcernReviewKind.netAssetPosition:
        return 'Net asset position';
      case FinancialReportGoingConcernReviewKind.operatingCashFlow:
        return 'Operating cash flow';
      case FinancialReportGoingConcernReviewKind.liabilitiesPressure:
        return 'Liabilities pressure';
      case FinancialReportGoingConcernReviewKind.managementAssessment:
        return 'Management assessment';
    }
  }
}

enum FinancialReportGoingConcernReviewStatus {
  satisfactory,
  watch,
  attention,
  materialUncertainty,
  incomplete,
}

extension FinancialReportGoingConcernReviewStatusLabel
    on FinancialReportGoingConcernReviewStatus {
  String get label {
    switch (this) {
      case FinancialReportGoingConcernReviewStatus.satisfactory:
        return 'Satisfactory';
      case FinancialReportGoingConcernReviewStatus.watch:
        return 'Watch';
      case FinancialReportGoingConcernReviewStatus.attention:
        return 'Attention';
      case FinancialReportGoingConcernReviewStatus.materialUncertainty:
        return 'Material uncertainty';
      case FinancialReportGoingConcernReviewStatus.incomplete:
        return 'Incomplete';
    }
  }
}

class FinancialReportGoingConcernReviewItem {
  final FinancialReportGoingConcernReviewKind kind;
  final String title;
  final FinancialReportGoingConcernReviewStatus status;
  final String metric;
  final String owner;
  final String reference;
  final String detail;
  final String evidenceReference;

  const FinancialReportGoingConcernReviewItem({
    required this.kind,
    required this.title,
    required this.status,
    required this.metric,
    required this.owner,
    required this.reference,
    required this.detail,
    required this.evidenceReference,
  });
}

class FinancialReportGoingConcernReviewSummary {
  final String standardReference;
  final List<FinancialReportGoingConcernReviewItem> items;
  final int satisfactoryCount;
  final int watchCount;
  final int attentionCount;
  final int materialUncertaintyCount;
  final int incompleteCount;
  final double readinessRatio;
  final String conclusion;
  final String nextAction;

  const FinancialReportGoingConcernReviewSummary({
    required this.standardReference,
    required this.items,
    required this.satisfactoryCount,
    required this.watchCount,
    required this.attentionCount,
    required this.materialUncertaintyCount,
    required this.incompleteCount,
    required this.readinessRatio,
    required this.conclusion,
    required this.nextAction,
  });

  int get totalCount => items.length;

  bool get hasMaterialUncertainty => materialUncertaintyCount > 0;

  bool get needsAttention =>
      materialUncertaintyCount > 0 || attentionCount > 0 || incompleteCount > 0;
}
