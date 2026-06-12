enum FinancialReportReleaseMilestoneArea {
  packageIntegrity,
  signOff,
  distribution,
  archive,
  retention,
  statutoryFiling,
}

extension FinancialReportReleaseMilestoneAreaLabel
    on FinancialReportReleaseMilestoneArea {
  String get label {
    switch (this) {
      case FinancialReportReleaseMilestoneArea.packageIntegrity:
        return 'Package integrity';
      case FinancialReportReleaseMilestoneArea.signOff:
        return 'Sign-off';
      case FinancialReportReleaseMilestoneArea.distribution:
        return 'Distribution';
      case FinancialReportReleaseMilestoneArea.archive:
        return 'Archive';
      case FinancialReportReleaseMilestoneArea.retention:
        return 'Retention';
      case FinancialReportReleaseMilestoneArea.statutoryFiling:
        return 'Statutory filing';
    }
  }
}

enum FinancialReportReleaseMilestoneStatus {
  complete,
  upcoming,
  dueSoon,
  overdue,
  blocked,
}

extension FinancialReportReleaseMilestoneStatusLabel
    on FinancialReportReleaseMilestoneStatus {
  String get label {
    switch (this) {
      case FinancialReportReleaseMilestoneStatus.complete:
        return 'Complete';
      case FinancialReportReleaseMilestoneStatus.upcoming:
        return 'Upcoming';
      case FinancialReportReleaseMilestoneStatus.dueSoon:
        return 'Due soon';
      case FinancialReportReleaseMilestoneStatus.overdue:
        return 'Overdue';
      case FinancialReportReleaseMilestoneStatus.blocked:
        return 'Blocked';
    }
  }
}

class FinancialReportReleaseMilestoneItem {
  final String id;
  final FinancialReportReleaseMilestoneArea area;
  final String title;
  final FinancialReportReleaseMilestoneStatus status;
  final DateTime dueDate;
  final String owner;
  final String reference;
  final String detail;

  const FinancialReportReleaseMilestoneItem({
    required this.id,
    required this.area,
    required this.title,
    required this.status,
    required this.dueDate,
    required this.owner,
    required this.reference,
    required this.detail,
  });
}

class FinancialReportReleaseMilestoneSummary {
  final List<FinancialReportReleaseMilestoneItem> items;
  final int completeCount;
  final int upcomingCount;
  final int dueSoonCount;
  final int overdueCount;
  final int blockedCount;
  final double completionRatio;
  final String nextAction;

  const FinancialReportReleaseMilestoneSummary({
    required this.items,
    required this.completeCount,
    required this.upcomingCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.blockedCount,
    required this.completionRatio,
    required this.nextAction,
  });

  int get totalCount => items.length;

  bool get isComplete => totalCount > 0 && completeCount == totalCount;
}
