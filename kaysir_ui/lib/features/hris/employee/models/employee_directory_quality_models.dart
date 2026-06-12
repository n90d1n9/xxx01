import 'employee_directory_models.dart';

enum EmployeeDirectoryQualitySeverity { critical, warning, info }

extension EmployeeDirectoryQualitySeverityLabel
    on EmployeeDirectoryQualitySeverity {
  String get label {
    switch (this) {
      case EmployeeDirectoryQualitySeverity.critical:
        return 'Critical';
      case EmployeeDirectoryQualitySeverity.warning:
        return 'Warning';
      case EmployeeDirectoryQualitySeverity.info:
        return 'Info';
    }
  }

  int get priority {
    switch (this) {
      case EmployeeDirectoryQualitySeverity.critical:
        return 0;
      case EmployeeDirectoryQualitySeverity.warning:
        return 1;
      case EmployeeDirectoryQualitySeverity.info:
        return 2;
    }
  }
}

enum EmployeeDirectoryQualityIssueType {
  duplicateEmail,
  missingManager,
  missingContact,
  missingDepartment,
  missingLocation,
  futureStart,
}

extension EmployeeDirectoryQualityIssueTypeLabel
    on EmployeeDirectoryQualityIssueType {
  String get label {
    switch (this) {
      case EmployeeDirectoryQualityIssueType.duplicateEmail:
        return 'Duplicate email';
      case EmployeeDirectoryQualityIssueType.missingManager:
        return 'Missing manager';
      case EmployeeDirectoryQualityIssueType.missingContact:
        return 'Missing contact';
      case EmployeeDirectoryQualityIssueType.missingDepartment:
        return 'Missing department';
      case EmployeeDirectoryQualityIssueType.missingLocation:
        return 'Missing location';
      case EmployeeDirectoryQualityIssueType.futureStart:
        return 'Future start';
    }
  }
}

enum EmployeeDirectoryQualityFilter {
  all,
  duplicateEmail,
  missingManager,
  missingContact,
  futureStart,
  incompleteProfile,
}

extension EmployeeDirectoryQualityFilterLabel
    on EmployeeDirectoryQualityFilter {
  String get label {
    switch (this) {
      case EmployeeDirectoryQualityFilter.all:
        return 'All quality checks';
      case EmployeeDirectoryQualityFilter.duplicateEmail:
        return 'Duplicate emails';
      case EmployeeDirectoryQualityFilter.missingManager:
        return 'Missing managers';
      case EmployeeDirectoryQualityFilter.missingContact:
        return 'Missing contacts';
      case EmployeeDirectoryQualityFilter.futureStart:
        return 'Future starts';
      case EmployeeDirectoryQualityFilter.incompleteProfile:
        return 'Any issue';
    }
  }

  EmployeeDirectoryQualityIssueType? get issueType {
    switch (this) {
      case EmployeeDirectoryQualityFilter.all:
      case EmployeeDirectoryQualityFilter.incompleteProfile:
        return null;
      case EmployeeDirectoryQualityFilter.duplicateEmail:
        return EmployeeDirectoryQualityIssueType.duplicateEmail;
      case EmployeeDirectoryQualityFilter.missingManager:
        return EmployeeDirectoryQualityIssueType.missingManager;
      case EmployeeDirectoryQualityFilter.missingContact:
        return EmployeeDirectoryQualityIssueType.missingContact;
      case EmployeeDirectoryQualityFilter.futureStart:
        return EmployeeDirectoryQualityIssueType.futureStart;
    }
  }

  bool matches(
    EmployeeDirectoryMember member,
    EmployeeDirectoryQualityReport report,
  ) {
    switch (this) {
      case EmployeeDirectoryQualityFilter.all:
        return true;
      case EmployeeDirectoryQualityFilter.incompleteProfile:
        return report.hasAnyIssue(member.id);
      case EmployeeDirectoryQualityFilter.duplicateEmail:
      case EmployeeDirectoryQualityFilter.missingManager:
      case EmployeeDirectoryQualityFilter.missingContact:
      case EmployeeDirectoryQualityFilter.futureStart:
        return report.hasIssue(member.id, issueType!);
    }
  }
}

class EmployeeDirectoryQualityIssue {
  final EmployeeDirectoryQualityIssueType type;
  final EmployeeDirectoryQualitySeverity severity;
  final String employeeId;
  final String employeeName;
  final String detail;

  const EmployeeDirectoryQualityIssue({
    required this.type,
    required this.severity,
    required this.employeeId,
    required this.employeeName,
    required this.detail,
  });
}

class EmployeeDirectoryQualityReport {
  final List<EmployeeDirectoryMember> members;
  final List<EmployeeDirectoryQualityIssue> issues;

  const EmployeeDirectoryQualityReport({
    required this.members,
    required this.issues,
  });

  factory EmployeeDirectoryQualityReport.fromMembers({
    required List<EmployeeDirectoryMember> members,
    required DateTime asOfDate,
  }) {
    final normalizedEmails = <String, List<EmployeeDirectoryMember>>{};
    for (final member in members) {
      final email = _normalize(member.email);
      if (email.isEmpty) continue;
      normalizedEmails.putIfAbsent(email, () => []).add(member);
    }
    final duplicateEmails =
        normalizedEmails.entries
            .where((entry) => entry.value.length > 1)
            .map((entry) => entry.key)
            .toSet();

    final asOf = _dateOnly(asOfDate);
    final issues = <EmployeeDirectoryQualityIssue>[];
    for (final member in members) {
      final email = _normalize(member.email);
      if (duplicateEmails.contains(email)) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.duplicateEmail,
            severity: EmployeeDirectoryQualitySeverity.critical,
            employeeId: member.id,
            employeeName: member.name,
            detail: '${member.email} appears on more than one profile.',
          ),
        );
      }

      if (member.manager.trim().isEmpty) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.missingManager,
            severity: EmployeeDirectoryQualitySeverity.warning,
            employeeId: member.id,
            employeeName: member.name,
            detail: 'Assign a reporting manager before payroll cutoff.',
          ),
        );
      }

      if (member.email.trim().isEmpty || member.phone.trim().isEmpty) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.missingContact,
            severity: EmployeeDirectoryQualitySeverity.critical,
            employeeId: member.id,
            employeeName: member.name,
            detail: 'Email and phone are required for HR communication.',
          ),
        );
      }

      if (member.department.trim().isEmpty) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.missingDepartment,
            severity: EmployeeDirectoryQualitySeverity.warning,
            employeeId: member.id,
            employeeName: member.name,
            detail:
                'Set a department so approvals and reporting route cleanly.',
          ),
        );
      }

      if (member.location.trim().isEmpty) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.missingLocation,
            severity: EmployeeDirectoryQualitySeverity.info,
            employeeId: member.id,
            employeeName: member.name,
            detail: 'Add a work location for coverage and compliance views.',
          ),
        );
      }

      if (_dateOnly(member.joiningDate).isAfter(asOf)) {
        issues.add(
          EmployeeDirectoryQualityIssue(
            type: EmployeeDirectoryQualityIssueType.futureStart,
            severity: EmployeeDirectoryQualitySeverity.info,
            employeeId: member.id,
            employeeName: member.name,
            detail: 'Joining date is later than the current directory date.',
          ),
        );
      }
    }

    issues.sort(_compareIssues);
    return EmployeeDirectoryQualityReport(members: members, issues: issues);
  }

  int get issueCount => issues.length;

  int get criticalCount {
    return issues
        .where(
          (issue) =>
              issue.severity == EmployeeDirectoryQualitySeverity.critical,
        )
        .length;
  }

  int get affectedProfileCount {
    return issues.map((issue) => issue.employeeId).toSet().length;
  }

  int get readyProfileCount => members.length - affectedProfileCount;

  int get readinessScore {
    if (members.isEmpty) return 100;
    return ((readyProfileCount / members.length) * 100).round();
  }

  String get readinessLabel {
    if (issueCount == 0) return 'Ready';
    if (criticalCount > 0) return 'Needs cleanup';
    return 'Review';
  }

  List<EmployeeDirectoryQualityIssue> get topIssues {
    return issues.take(4).toList();
  }

  bool hasAnyIssue(String employeeId) {
    return issues.any((issue) => issue.employeeId == employeeId);
  }

  bool hasIssue(
    String employeeId,
    EmployeeDirectoryQualityIssueType issueType,
  ) {
    return issues.any((issue) {
      return issue.employeeId == employeeId && issue.type == issueType;
    });
  }

  int countForType(EmployeeDirectoryQualityIssueType issueType) {
    return issues.where((issue) => issue.type == issueType).length;
  }

  int countForFilter(EmployeeDirectoryQualityFilter filter) {
    switch (filter) {
      case EmployeeDirectoryQualityFilter.all:
        return members.length;
      case EmployeeDirectoryQualityFilter.incompleteProfile:
        return affectedProfileCount;
      case EmployeeDirectoryQualityFilter.duplicateEmail:
      case EmployeeDirectoryQualityFilter.missingManager:
      case EmployeeDirectoryQualityFilter.missingContact:
      case EmployeeDirectoryQualityFilter.futureStart:
        return countForType(filter.issueType!);
    }
  }
}

int _compareIssues(
  EmployeeDirectoryQualityIssue first,
  EmployeeDirectoryQualityIssue second,
) {
  final severity = first.severity.priority.compareTo(second.severity.priority);
  if (severity != 0) return severity;

  final type = first.type.label.compareTo(second.type.label);
  if (type != 0) return type;

  return first.employeeName.toLowerCase().compareTo(
    second.employeeName.toLowerCase(),
  );
}

String _normalize(String value) => value.trim().toLowerCase();

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
