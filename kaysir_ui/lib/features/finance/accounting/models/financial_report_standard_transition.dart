enum FinancialReportStandardTransitionKind {
  effectiveStandard,
  profitLossSubtotals,
  incomeExpenseClassification,
  managementPerformanceMeasures,
  comparativeTransition,
  cashFlowPresentation,
  disclosureUpdate,
}

extension FinancialReportStandardTransitionKindLabel
    on FinancialReportStandardTransitionKind {
  String get label {
    switch (this) {
      case FinancialReportStandardTransitionKind.effectiveStandard:
        return 'Effective standard';
      case FinancialReportStandardTransitionKind.profitLossSubtotals:
        return 'Profit or loss subtotals';
      case FinancialReportStandardTransitionKind.incomeExpenseClassification:
        return 'Income and expense categories';
      case FinancialReportStandardTransitionKind.managementPerformanceMeasures:
        return 'Management performance measures';
      case FinancialReportStandardTransitionKind.comparativeTransition:
        return 'Comparative transition';
      case FinancialReportStandardTransitionKind.cashFlowPresentation:
        return 'Cash flow presentation';
      case FinancialReportStandardTransitionKind.disclosureUpdate:
        return 'Disclosure update';
    }
  }
}

enum FinancialReportStandardTransitionStatus {
  ready,
  monitor,
  actionRequired,
  overdue,
  notApplicable,
}

extension FinancialReportStandardTransitionStatusLabel
    on FinancialReportStandardTransitionStatus {
  String get label {
    switch (this) {
      case FinancialReportStandardTransitionStatus.ready:
        return 'Ready';
      case FinancialReportStandardTransitionStatus.monitor:
        return 'Monitor';
      case FinancialReportStandardTransitionStatus.actionRequired:
        return 'Action required';
      case FinancialReportStandardTransitionStatus.overdue:
        return 'Overdue';
      case FinancialReportStandardTransitionStatus.notApplicable:
        return 'Not applicable';
    }
  }
}

class FinancialReportStandardTransitionItem {
  final FinancialReportStandardTransitionKind kind;
  final String title;
  final FinancialReportStandardTransitionStatus status;
  final String metric;
  final String owner;
  final String reference;
  final String detail;
  final String evidenceReference;

  const FinancialReportStandardTransitionItem({
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

class FinancialReportStandardTransitionSummary {
  final String currentStandardReference;
  final String nextStandardReference;
  final DateTime effectiveDate;
  final int daysUntilEffective;
  final List<FinancialReportStandardTransitionItem> items;
  final int readyCount;
  final int monitorCount;
  final int actionRequiredCount;
  final int overdueCount;
  final int notApplicableCount;
  final double readinessRatio;
  final String headline;
  final String nextAction;

  const FinancialReportStandardTransitionSummary({
    required this.currentStandardReference,
    required this.nextStandardReference,
    required this.effectiveDate,
    required this.daysUntilEffective,
    required this.items,
    required this.readyCount,
    required this.monitorCount,
    required this.actionRequiredCount,
    required this.overdueCount,
    required this.notApplicableCount,
    required this.readinessRatio,
    required this.headline,
    required this.nextAction,
  });

  int get totalCount => items.length;

  int get applicableCount => totalCount - notApplicableCount;

  bool get hasBlockingTransitionRisk =>
      overdueCount > 0 || actionRequiredCount > 0;

  bool get hasTransitionWork =>
      monitorCount > 0 || actionRequiredCount > 0 || overdueCount > 0;
}
