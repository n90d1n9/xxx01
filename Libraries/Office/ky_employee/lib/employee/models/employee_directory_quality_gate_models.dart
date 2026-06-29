import 'employee_directory_quality_models.dart';

/// Overall roster readiness status for payroll and reporting cutoffs.
enum EmployeeDirectoryQualityGateStatus { blocked, review, ready }

extension EmployeeDirectoryQualityGateStatusLabel
    on EmployeeDirectoryQualityGateStatus {
  String get label {
    return switch (this) {
      EmployeeDirectoryQualityGateStatus.blocked => 'Payroll blocked',
      EmployeeDirectoryQualityGateStatus.review => 'HR review',
      EmployeeDirectoryQualityGateStatus.ready => 'Ready',
    };
  }
}

/// Operational gate derived from roster quality checks before cutoff actions.
class EmployeeDirectoryQualityGate {
  final EmployeeDirectoryQualityGateStatus status;
  final int memberCount;
  final int readinessScore;
  final int blockerCount;
  final int reviewCount;
  final int advisoryCount;
  final EmployeeDirectoryQualityIssue? nextIssue;
  final List<EmployeeDirectoryQualityGateCheck> checks;

  const EmployeeDirectoryQualityGate({
    required this.status,
    required this.memberCount,
    required this.readinessScore,
    required this.blockerCount,
    required this.reviewCount,
    required this.advisoryCount,
    required this.nextIssue,
    required this.checks,
  });

  factory EmployeeDirectoryQualityGate.fromReport(
    EmployeeDirectoryQualityReport report,
  ) {
    final checks = _buildChecks(report);
    final blockerCount = _countSeverity(
      report,
      EmployeeDirectoryQualitySeverity.critical,
    );
    final warningCount = _countSeverity(
      report,
      EmployeeDirectoryQualitySeverity.warning,
    );
    final advisoryCount = _countSeverity(
      report,
      EmployeeDirectoryQualitySeverity.info,
    );

    return EmployeeDirectoryQualityGate(
      status: _statusFor(
        blockerCount: blockerCount,
        reviewCount: warningCount + advisoryCount,
      ),
      memberCount: report.members.length,
      readinessScore: report.readinessScore,
      blockerCount: blockerCount,
      reviewCount: warningCount,
      advisoryCount: advisoryCount,
      nextIssue: report.issues.firstOrNull,
      checks: checks,
    );
  }

  bool get isReady => status == EmployeeDirectoryQualityGateStatus.ready;

  int get passedCheckCount {
    return checks.where((check) => check.isPassed).length;
  }

  int get completionPercent {
    if (checks.isEmpty) return 100;
    return ((passedCheckCount / checks.length) * 100).round();
  }

  String get summaryLabel {
    return switch (status) {
      EmployeeDirectoryQualityGateStatus.blocked =>
        '$blockerCount payroll blocker${blockerCount == 1 ? '' : 's'} '
            'must clear before cutoff',
      EmployeeDirectoryQualityGateStatus.review =>
        '${reviewCount + advisoryCount} review item'
            '${reviewCount + advisoryCount == 1 ? '' : 's'} before cutoff',
      EmployeeDirectoryQualityGateStatus.ready =>
        'Roster gate is ready for payroll and reporting',
    };
  }

  String get nextActionLabel {
    final issue = nextIssue;
    if (issue == null) return 'Keep roster gate ready';
    return 'Fix ${issue.type.label.toLowerCase()} for ${issue.employeeName}';
  }
}

/// Checklist row that translates quality findings into cutoff readiness gates.
class EmployeeDirectoryQualityGateCheck {
  final String id;
  final String title;
  final String detail;
  final List<EmployeeDirectoryQualityIssueType> issueTypes;
  final List<EmployeeDirectoryQualityIssue> issues;

  const EmployeeDirectoryQualityGateCheck({
    required this.id,
    required this.title,
    required this.detail,
    required this.issueTypes,
    required this.issues,
  });

  bool get isPassed => issues.isEmpty;

  int get issueCount => issues.length;

  int get affectedProfileCount {
    return issues.map((issue) => issue.employeeId).toSet().length;
  }

  EmployeeDirectoryQualityIssue? get firstIssue => issues.firstOrNull;

  EmployeeDirectoryQualitySeverity get severity {
    if (issues.isEmpty) return EmployeeDirectoryQualitySeverity.info;
    return issues
        .map((issue) => issue.severity)
        .reduce(
          (current, next) => current.priority <= next.priority ? current : next,
        );
  }

  String get statusLabel {
    if (isPassed) return 'Clear';
    return severity.label;
  }

  String get summaryLabel {
    if (isPassed) return detail;
    return '$issueCount issue${issueCount == 1 ? '' : 's'} across '
        '$affectedProfileCount profile${affectedProfileCount == 1 ? '' : 's'}';
  }
}

List<EmployeeDirectoryQualityGateCheck> _buildChecks(
  EmployeeDirectoryQualityReport report,
) {
  return [
    _check(
      report,
      id: 'identityContact',
      title: 'Identity and contact',
      detail: 'Unique emails and required communication channels are present.',
      issueTypes: const [
        EmployeeDirectoryQualityIssueType.duplicateEmail,
        EmployeeDirectoryQualityIssueType.missingContact,
      ],
    ),
    _check(
      report,
      id: 'reportingLines',
      title: 'Reporting line',
      detail: 'Every employee has a manager for approvals and escalation.',
      issueTypes: const [EmployeeDirectoryQualityIssueType.missingManager],
    ),
    _check(
      report,
      id: 'orgCoverage',
      title: 'Organization coverage',
      detail: 'Departments and work locations support reporting coverage.',
      issueTypes: const [
        EmployeeDirectoryQualityIssueType.missingDepartment,
        EmployeeDirectoryQualityIssueType.missingLocation,
      ],
    ),
    _check(
      report,
      id: 'effectiveDates',
      title: 'Effective dates',
      detail: 'Joining dates are aligned with the directory cutoff date.',
      issueTypes: const [EmployeeDirectoryQualityIssueType.futureStart],
    ),
  ];
}

EmployeeDirectoryQualityGateCheck _check(
  EmployeeDirectoryQualityReport report, {
  required String id,
  required String title,
  required String detail,
  required List<EmployeeDirectoryQualityIssueType> issueTypes,
}) {
  final typeSet = issueTypes.toSet();
  return EmployeeDirectoryQualityGateCheck(
    id: id,
    title: title,
    detail: detail,
    issueTypes: issueTypes,
    issues:
        report.issues.where((issue) => typeSet.contains(issue.type)).toList(),
  );
}

EmployeeDirectoryQualityGateStatus _statusFor({
  required int blockerCount,
  required int reviewCount,
}) {
  if (blockerCount > 0) return EmployeeDirectoryQualityGateStatus.blocked;
  if (reviewCount > 0) return EmployeeDirectoryQualityGateStatus.review;
  return EmployeeDirectoryQualityGateStatus.ready;
}

int _countSeverity(
  EmployeeDirectoryQualityReport report,
  EmployeeDirectoryQualitySeverity severity,
) {
  return report.issues.where((issue) => issue.severity == severity).length;
}
