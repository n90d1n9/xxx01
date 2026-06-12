import 'financial_report_tax_profile.dart';

enum FinancialReportStatementKind {
  financialPosition,
  profitOrLossAndOci,
  changesInEquity,
  cashFlows,
  notes,
}

extension FinancialReportStatementKindLabel on FinancialReportStatementKind {
  String get label {
    switch (this) {
      case FinancialReportStatementKind.financialPosition:
        return 'Statement of Financial Position';
      case FinancialReportStatementKind.profitOrLossAndOci:
        return 'Profit or Loss and OCI';
      case FinancialReportStatementKind.changesInEquity:
        return 'Statement of Changes in Equity';
      case FinancialReportStatementKind.cashFlows:
        return 'Statement of Cash Flows';
      case FinancialReportStatementKind.notes:
        return 'Notes to Financial Statements';
    }
  }
}

enum FinancialReportLineType { section, line, subtotal, total, note }

class FinancialReportLine {
  final String label;
  final double? amount;
  final double? comparativeAmount;
  final FinancialReportLineType type;
  final int indentLevel;
  final String? noteReference;

  const FinancialReportLine({
    required this.label,
    this.amount,
    this.comparativeAmount,
    this.type = FinancialReportLineType.line,
    this.indentLevel = 0,
    this.noteReference,
  });

  bool get hasAmount => amount != null;

  bool get hasComparativeAmount => comparativeAmount != null;

  double? get variance {
    if (amount == null || comparativeAmount == null) {
      return null;
    }
    return amount! - comparativeAmount!;
  }

  double? get varianceRatio {
    if (variance == null || comparativeAmount == null) {
      return null;
    }
    if (comparativeAmount!.abs() < 0.01) {
      return null;
    }
    return variance! / comparativeAmount!.abs();
  }
}

class FinancialReportStatement {
  final FinancialReportStatementKind kind;
  final String title;
  final String subtitle;
  final List<FinancialReportLine> lines;
  final List<String> standardReferences;

  const FinancialReportStatement({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.lines,
    this.standardReferences = const [],
  });

  bool get hasComparativeAmounts {
    return lines.any((line) => line.hasComparativeAmount);
  }
}

class FinancialReportDisclosureNote {
  final String number;
  final String title;
  final String body;
  final List<String> standardReferences;

  const FinancialReportDisclosureNote({
    required this.number,
    required this.title,
    required this.body,
    this.standardReferences = const [],
  });
}

enum FinancialReportSupportingScheduleKind {
  cashRollForward,
  bankReconciliation,
  incomeTax,
  incomeTaxSettlement,
  incomeTaxReconciliation,
  valueAddedTaxSettlement,
  managementPerformanceMeasure,
  otherComprehensiveIncome,
}

class FinancialReportScheduleLine {
  final String label;
  final double amount;
  final double? comparativeAmount;
  final String? sourceCategory;
  final String? noteReference;

  const FinancialReportScheduleLine({
    required this.label,
    required this.amount,
    this.comparativeAmount,
    this.sourceCategory,
    this.noteReference,
  });

  bool get hasComparativeAmount => comparativeAmount != null;

  double? get variance {
    final comparative = comparativeAmount;
    if (comparative == null) {
      return null;
    }
    return amount - comparative;
  }
}

class FinancialReportScheduleMetric {
  final String label;
  final String value;
  final String helperText;

  const FinancialReportScheduleMetric({
    required this.label,
    required this.value,
    required this.helperText,
  });
}

class FinancialReportSupportingSchedule {
  final FinancialReportSupportingScheduleKind kind;
  final String title;
  final String subtitle;
  final String totalLabel;
  final List<FinancialReportScheduleLine> lines;
  final List<FinancialReportScheduleMetric> metrics;
  final List<String> standardReferences;
  final double? totalAmountOverride;
  final double? comparativeTotalAmountOverride;

  const FinancialReportSupportingSchedule({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.totalLabel,
    required this.lines,
    this.metrics = const [],
    this.standardReferences = const [],
    this.totalAmountOverride,
    this.comparativeTotalAmountOverride,
  });

  double get totalAmount {
    final override = totalAmountOverride;
    if (override != null) {
      return override;
    }
    return lines.fold(0.0, (sum, line) => sum + line.amount);
  }

  double? get comparativeTotalAmount {
    final override = comparativeTotalAmountOverride;
    if (override != null) {
      return override;
    }
    if (!hasComparativeAmounts) {
      return null;
    }
    return lines.fold<double>(
      0.0,
      (sum, line) => sum + (line.comparativeAmount ?? 0),
    );
  }

  double? get variance {
    final comparative = comparativeTotalAmount;
    if (comparative == null) {
      return null;
    }
    return totalAmount - comparative;
  }

  bool get hasActivity {
    if ((totalAmountOverride?.abs() ?? 0) >= 0.01 ||
        (comparativeTotalAmountOverride?.abs() ?? 0) >= 0.01) {
      return true;
    }
    return lines.any(
      (line) =>
          line.amount.abs() >= 0.01 ||
          (line.comparativeAmount?.abs() ?? 0) >= 0.01,
    );
  }

  bool get hasComparativeAmounts {
    return lines.any((line) => line.hasComparativeAmount);
  }
}

class FinancialReportComplianceItem {
  final String id;
  final String title;
  final String description;
  final String standardReference;
  final bool isSatisfied;
  final double? variance;
  final double? comparativeVariance;
  final double? materialityThreshold;
  final String? materialityBasis;

  const FinancialReportComplianceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.standardReference,
    required this.isSatisfied,
    this.variance,
    this.comparativeVariance,
    this.materialityThreshold,
    this.materialityBasis,
  });

  bool get hasVarianceEvidence {
    return variance != null || comparativeVariance != null;
  }

  bool get hasMaterialityEvidence {
    final threshold = materialityThreshold;
    return threshold != null && threshold > 0;
  }

  bool get isMaterialVariance {
    final threshold = materialityThreshold;
    if (threshold == null || threshold <= 0) {
      return false;
    }
    return (variance?.abs() ?? 0) > threshold ||
        (comparativeVariance?.abs() ?? 0) > threshold;
  }
}

class FinancialReportMetric {
  final String label;
  final double amount;
  final double? comparativeAmount;
  final String helperText;

  const FinancialReportMetric({
    required this.label,
    required this.amount,
    this.comparativeAmount,
    required this.helperText,
  });

  double? get variance {
    if (comparativeAmount == null) {
      return null;
    }
    return amount - comparativeAmount!;
  }
}

class FinancialReportPack {
  final String entityName;
  final String frameworkName;
  final String jurisdiction;
  final String presentationCurrency;
  final String periodLabel;
  final String asOfLabel;
  final String? comparativePeriodLabel;
  final String? comparativeAsOfLabel;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final DateTime generatedAt;
  final List<FinancialReportStatement> statements;
  final List<FinancialReportDisclosureNote> notes;
  final List<FinancialReportSupportingSchedule> supportingSchedules;
  final List<FinancialReportComplianceItem> complianceItems;
  final List<FinancialReportMetric> metrics;
  final FinancialReportTaxProfile taxProfile;

  const FinancialReportPack({
    required this.entityName,
    required this.frameworkName,
    required this.jurisdiction,
    required this.presentationCurrency,
    required this.periodLabel,
    required this.asOfLabel,
    this.comparativePeriodLabel,
    this.comparativeAsOfLabel,
    required this.periodStart,
    required this.periodEnd,
    required this.generatedAt,
    required this.statements,
    required this.notes,
    this.supportingSchedules = const [],
    required this.complianceItems,
    required this.metrics,
    this.taxProfile = FinancialReportTaxProfiles.standardCorporate,
  });

  bool get hasCompletePrimaryStatements {
    return FinancialReportStatementKind.values.every(statementForKindExists);
  }

  bool get hasComparativePeriod {
    return comparativePeriodLabel != null || comparativeAsOfLabel != null;
  }

  bool statementForKindExists(FinancialReportStatementKind kind) {
    return statements.any((statement) => statement.kind == kind);
  }

  FinancialReportStatement statementFor(FinancialReportStatementKind kind) {
    return statements.firstWhere((statement) => statement.kind == kind);
  }

  Iterable<FinancialReportComplianceItem> get openComplianceItems {
    return complianceItems.where((item) => !item.isSatisfied);
  }

  double get readinessRatio {
    if (complianceItems.isEmpty) {
      return 0;
    }
    final satisfiedCount =
        complianceItems.where((item) => item.isSatisfied).length;
    return satisfiedCount / complianceItems.length;
  }
}
