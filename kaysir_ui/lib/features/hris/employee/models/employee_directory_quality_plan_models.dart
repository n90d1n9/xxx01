import 'employee_directory_quality_models.dart';

/// Prioritized cleanup plan derived from the current roster quality report.
class EmployeeDirectoryQualityFixPlan {
  final int memberCount;
  final int issueCount;
  final int affectedProfileCount;
  final int estimatedMinutes;
  final int targetReadinessScore;
  final EmployeeDirectoryQualityIssue? recommendedIssue;
  final List<EmployeeDirectoryQualityPlanLane> lanes;
  final List<EmployeeDirectoryQualityPlanGroup> groups;

  const EmployeeDirectoryQualityFixPlan({
    required this.memberCount,
    required this.issueCount,
    required this.affectedProfileCount,
    required this.estimatedMinutes,
    required this.targetReadinessScore,
    required this.recommendedIssue,
    required this.lanes,
    required this.groups,
  });

  factory EmployeeDirectoryQualityFixPlan.fromReport(
    EmployeeDirectoryQualityReport report,
  ) {
    final lanes = _buildLanes(report);
    final groups = _buildGroups(report);
    final nextLane = lanes.firstOrNull;

    return EmployeeDirectoryQualityFixPlan(
      memberCount: report.members.length,
      issueCount: report.issueCount,
      affectedProfileCount: report.affectedProfileCount,
      estimatedMinutes: report.issues
          .map((issue) => issue.type.estimatedFixMinutes)
          .fold(0, (total, minutes) => total + minutes),
      targetReadinessScore:
          nextLane == null
              ? report.readinessScore
              : _projectReadinessAfterSeverity(report, nextLane.severity),
      recommendedIssue: report.issues.firstOrNull,
      lanes: lanes,
      groups: groups,
    );
  }

  bool get isClear => issueCount == 0;

  String get etaLabel => '$estimatedMinutes min';

  String get nextFocusLabel {
    final issue = recommendedIssue;
    if (issue == null) return 'No fixes';
    return issue.type.label;
  }

  String get statusLabel {
    if (isClear) return 'Ready';
    return '${lanes.first.severity.label} lane';
  }

  String get summaryLabel {
    if (isClear) return 'Roster quality is ready for payroll and reporting';
    return '${_plural(issueCount, 'fix', 'fixes')} planned across '
        '${_plural(affectedProfileCount, 'profile', 'profiles')}, '
        '$etaLabel estimated';
  }

  String get recommendedActionLabel {
    final issue = recommendedIssue;
    if (issue == null) return 'Keep monitoring roster quality';
    return 'Fix ${issue.type.label.toLowerCase()} for ${issue.employeeName}';
  }

  String get laneActionLabel {
    if (isClear) return 'No cleanup backlog';
    return 'Clear ${lanes.first.severity.label.toLowerCase()} lane to reach '
        '$targetReadinessScore% readiness';
  }
}

/// Severity lane that groups quality issues by operational urgency.
class EmployeeDirectoryQualityPlanLane {
  final EmployeeDirectoryQualitySeverity severity;
  final int issueCount;
  final int affectedProfileCount;
  final int estimatedMinutes;

  const EmployeeDirectoryQualityPlanLane({
    required this.severity,
    required this.issueCount,
    required this.affectedProfileCount,
    required this.estimatedMinutes,
  });

  String get etaLabel => '$estimatedMinutes min';

  String get summaryLabel {
    return '${_plural(issueCount, 'issue', 'issues')} across '
        '${_plural(affectedProfileCount, 'profile', 'profiles')}';
  }

  String get actionLabel {
    return switch (severity) {
      EmployeeDirectoryQualitySeverity.critical => 'Resolve before payroll',
      EmployeeDirectoryQualitySeverity.warning => 'Clean routing data',
      EmployeeDirectoryQualitySeverity.info => 'Polish roster hygiene',
    };
  }
}

/// Issue-type grouping used to choose the best batch of fixes to work next.
class EmployeeDirectoryQualityPlanGroup {
  final EmployeeDirectoryQualityIssueType type;
  final EmployeeDirectoryQualitySeverity severity;
  final int issueCount;
  final int affectedProfileCount;
  final int estimatedMinutes;
  final List<String> employeeNames;
  final EmployeeDirectoryQualityIssue firstIssue;

  const EmployeeDirectoryQualityPlanGroup({
    required this.type,
    required this.severity,
    required this.issueCount,
    required this.affectedProfileCount,
    required this.estimatedMinutes,
    required this.employeeNames,
    required this.firstIssue,
  });

  String get etaLabel => '$estimatedMinutes min';

  String get profileLabel {
    final visibleNames = employeeNames.take(3).toList();
    final remainingCount = affectedProfileCount - visibleNames.length;
    final suffix = remainingCount > 0 ? ' +$remainingCount' : '';
    return '${visibleNames.join(', ')}$suffix';
  }

  String get summaryLabel {
    return '${_plural(issueCount, 'fix', 'fixes')}, '
        '${_plural(affectedProfileCount, 'profile', 'profiles')}';
  }
}

extension EmployeeDirectoryQualityIssueTypeEffort
    on EmployeeDirectoryQualityIssueType {
  int get estimatedFixMinutes {
    return switch (this) {
      EmployeeDirectoryQualityIssueType.duplicateEmail => 7,
      EmployeeDirectoryQualityIssueType.missingContact => 6,
      EmployeeDirectoryQualityIssueType.missingManager => 5,
      EmployeeDirectoryQualityIssueType.missingDepartment => 4,
      EmployeeDirectoryQualityIssueType.futureStart => 4,
      EmployeeDirectoryQualityIssueType.missingLocation => 3,
    };
  }
}

List<EmployeeDirectoryQualityPlanLane> _buildLanes(
  EmployeeDirectoryQualityReport report,
) {
  final lanes = <EmployeeDirectoryQualityPlanLane>[];
  for (final severity in EmployeeDirectoryQualitySeverity.values) {
    final issues =
        report.issues.where((issue) => issue.severity == severity).toList();
    if (issues.isEmpty) continue;

    lanes.add(
      EmployeeDirectoryQualityPlanLane(
        severity: severity,
        issueCount: issues.length,
        affectedProfileCount:
            issues.map((issue) => issue.employeeId).toSet().length,
        estimatedMinutes: issues
            .map((issue) => issue.type.estimatedFixMinutes)
            .fold(0, (total, minutes) => total + minutes),
      ),
    );
  }
  lanes.sort(
    (first, second) =>
        first.severity.priority.compareTo(second.severity.priority),
  );
  return lanes;
}

List<EmployeeDirectoryQualityPlanGroup> _buildGroups(
  EmployeeDirectoryQualityReport report,
) {
  final byType =
      <
        EmployeeDirectoryQualityIssueType,
        List<EmployeeDirectoryQualityIssue>
      >{};
  for (final issue in report.issues) {
    byType.putIfAbsent(issue.type, () => []).add(issue);
  }

  final groups =
      byType.entries.map((entry) {
        final issues = entry.value;
        return EmployeeDirectoryQualityPlanGroup(
          type: entry.key,
          severity: _highestSeverity(issues),
          issueCount: issues.length,
          affectedProfileCount:
              issues.map((issue) => issue.employeeId).toSet().length,
          estimatedMinutes: issues
              .map((issue) => issue.type.estimatedFixMinutes)
              .fold(0, (total, minutes) => total + minutes),
          employeeNames:
              issues.map((issue) => issue.employeeName).toSet().toList()
                ..sort(),
          firstIssue: issues.first,
        );
      }).toList();

  groups.sort((first, second) {
    final severity = first.severity.priority.compareTo(
      second.severity.priority,
    );
    if (severity != 0) return severity;

    final count = second.issueCount.compareTo(first.issueCount);
    if (count != 0) return count;

    return first.type.label.compareTo(second.type.label);
  });
  return groups;
}

EmployeeDirectoryQualitySeverity _highestSeverity(
  List<EmployeeDirectoryQualityIssue> issues,
) {
  return issues
      .map((issue) => issue.severity)
      .reduce(
        (current, next) => current.priority <= next.priority ? current : next,
      );
}

int _projectReadinessAfterSeverity(
  EmployeeDirectoryQualityReport report,
  EmployeeDirectoryQualitySeverity severity,
) {
  if (report.members.isEmpty) return 100;

  final remainingAffectedProfiles =
      report.issues
          .where((issue) => issue.severity != severity)
          .map((issue) => issue.employeeId)
          .toSet()
          .length;
  final readyProfiles = report.members.length - remainingAffectedProfiles;
  return ((readyProfiles / report.members.length) * 100).round();
}

String _plural(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}
