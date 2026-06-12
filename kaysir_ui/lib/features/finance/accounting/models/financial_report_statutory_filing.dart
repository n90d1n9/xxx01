enum FinancialReportStatutoryFilingKind {
  managementRelease,
  boardDistribution,
  auditorHandoff,
  annualCorporateTaxSupport,
  statutoryArchive,
}

extension FinancialReportStatutoryFilingKindLabel
    on FinancialReportStatutoryFilingKind {
  String get label {
    switch (this) {
      case FinancialReportStatutoryFilingKind.managementRelease:
        return 'Management release';
      case FinancialReportStatutoryFilingKind.boardDistribution:
        return 'Board / owner distribution';
      case FinancialReportStatutoryFilingKind.auditorHandoff:
        return 'Auditor handoff';
      case FinancialReportStatutoryFilingKind.annualCorporateTaxSupport:
        return 'Annual CIT filing support';
      case FinancialReportStatutoryFilingKind.statutoryArchive:
        return 'Statutory archive';
    }
  }
}

enum FinancialReportStatutoryFilingStatus {
  complete,
  dueSoon,
  pending,
  overdue,
  blocked,
}

extension FinancialReportStatutoryFilingStatusLabel
    on FinancialReportStatutoryFilingStatus {
  String get label {
    switch (this) {
      case FinancialReportStatutoryFilingStatus.complete:
        return 'Complete';
      case FinancialReportStatutoryFilingStatus.dueSoon:
        return 'Due soon';
      case FinancialReportStatutoryFilingStatus.pending:
        return 'Pending';
      case FinancialReportStatutoryFilingStatus.overdue:
        return 'Overdue';
      case FinancialReportStatutoryFilingStatus.blocked:
        return 'Blocked';
    }
  }
}

class FinancialReportStatutoryFilingItem {
  final FinancialReportStatutoryFilingKind kind;
  final String title;
  final FinancialReportStatutoryFilingStatus status;
  final DateTime dueDate;
  final String owner;
  final String reference;
  final String detail;
  final String evidenceReference;

  const FinancialReportStatutoryFilingItem({
    required this.kind,
    required this.title,
    required this.status,
    required this.dueDate,
    required this.owner,
    required this.reference,
    required this.detail,
    required this.evidenceReference,
  });
}

class FinancialReportStatutoryFilingSummary {
  final List<FinancialReportStatutoryFilingItem> items;
  final int completeCount;
  final int dueSoonCount;
  final int overdueCount;
  final int blockedCount;
  final double completionRatio;
  final String nextAction;

  const FinancialReportStatutoryFilingSummary({
    required this.items,
    required this.completeCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.blockedCount,
    required this.completionRatio,
    required this.nextAction,
  });
}
