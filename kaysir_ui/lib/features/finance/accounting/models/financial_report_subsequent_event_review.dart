enum FinancialReportSubsequentEventReviewKind {
  packageLock,
  managementInquiry,
  adjustingEventAssessment,
  disclosureUpdate,
  authorizationForIssue,
  releaseChangeFreeze,
}

extension FinancialReportSubsequentEventReviewKindLabel
    on FinancialReportSubsequentEventReviewKind {
  String get label {
    switch (this) {
      case FinancialReportSubsequentEventReviewKind.packageLock:
        return 'Package lock';
      case FinancialReportSubsequentEventReviewKind.managementInquiry:
        return 'Management inquiry';
      case FinancialReportSubsequentEventReviewKind.adjustingEventAssessment:
        return 'Adjusting event assessment';
      case FinancialReportSubsequentEventReviewKind.disclosureUpdate:
        return 'Disclosure update';
      case FinancialReportSubsequentEventReviewKind.authorizationForIssue:
        return 'Authorization for issue';
      case FinancialReportSubsequentEventReviewKind.releaseChangeFreeze:
        return 'Release change freeze';
    }
  }
}

enum FinancialReportSubsequentEventReviewStatus {
  complete,
  open,
  dueSoon,
  overdue,
  blocked,
}

extension FinancialReportSubsequentEventReviewStatusLabel
    on FinancialReportSubsequentEventReviewStatus {
  String get label {
    switch (this) {
      case FinancialReportSubsequentEventReviewStatus.complete:
        return 'Complete';
      case FinancialReportSubsequentEventReviewStatus.open:
        return 'Open';
      case FinancialReportSubsequentEventReviewStatus.dueSoon:
        return 'Due soon';
      case FinancialReportSubsequentEventReviewStatus.overdue:
        return 'Overdue';
      case FinancialReportSubsequentEventReviewStatus.blocked:
        return 'Blocked';
    }
  }
}

class FinancialReportSubsequentEventReviewItem {
  final FinancialReportSubsequentEventReviewKind kind;
  final String title;
  final FinancialReportSubsequentEventReviewStatus status;
  final DateTime dueDate;
  final String owner;
  final String reference;
  final String detail;
  final String evidenceReference;

  const FinancialReportSubsequentEventReviewItem({
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

class FinancialReportSubsequentEventReviewSummary {
  final DateTime periodEnd;
  final DateTime authorizationTargetDate;
  final int reviewWindowDays;
  final String standardReference;
  final List<FinancialReportSubsequentEventReviewItem> items;
  final int completeCount;
  final int openCount;
  final int dueSoonCount;
  final int overdueCount;
  final int blockedCount;
  final double completionRatio;
  final String nextAction;

  const FinancialReportSubsequentEventReviewSummary({
    required this.periodEnd,
    required this.authorizationTargetDate,
    required this.reviewWindowDays,
    required this.standardReference,
    required this.items,
    required this.completeCount,
    required this.openCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.blockedCount,
    required this.completionRatio,
    required this.nextAction,
  });

  int get totalCount => items.length;

  bool get isComplete => totalCount > 0 && completeCount == totalCount;
}
