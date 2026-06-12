import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/employee_data_quality_models.dart';
import '../models/employee_directory_models.dart';
import '../models/employee_profile_completeness_models.dart';
import 'employee_directory_provider.dart';
import 'employee_profile_completeness_provider.dart';

final employeeDataQualityProvider = StateNotifierProvider.family<
  EmployeeDataQualityNotifier,
  EmployeeDataQualityProfile?,
  String
>((ref, employeeId) {
  final asOfDate = _dateOnly(ref.watch(employeeDirectoryAsOfDateProvider));
  final members = ref.watch(employeeDirectoryMembersProvider);
  final member = _findMember(members, employeeId);
  if (member == null) {
    return EmployeeDataQualityNotifier(null);
  }

  final completeness = ref.watch(
    employeeProfileCompletenessProvider(employeeId),
  );

  return EmployeeDataQualityNotifier(
    EmployeeDataQualityProfile(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: asOfDate,
      issues: _seedIssues(
        member: member,
        members: members,
        completeness: completeness,
        asOfDate: asOfDate,
      ),
    ),
  );
});

final employeeDataQualityIssueDraftProvider = StateNotifierProvider.family<
  EmployeeDataQualityIssueDraftNotifier,
  EmployeeDataQualityIssueDraft?,
  String
>((ref, employeeId) {
  final asOfDate = _dateOnly(ref.watch(employeeDirectoryAsOfDateProvider));
  final member = _findMember(
    ref.watch(employeeDirectoryMembersProvider),
    employeeId,
  );
  if (member == null) {
    return EmployeeDataQualityIssueDraftNotifier(null);
  }

  return EmployeeDataQualityIssueDraftNotifier(
    EmployeeDataQualityIssueDraft(
      employeeId: member.id,
      employeeName: member.name,
      asOfDate: asOfDate,
      field: 'Profile data',
      title: '',
      detail: '',
      owner: 'People Operations',
      type: EmployeeDataQualityIssueType.manual,
      severity: EmployeeDataQualitySeverity.medium,
      dueDate: asOfDate.add(const Duration(days: 7)),
    ),
  );
});

class EmployeeDataQualityNotifier
    extends StateNotifier<EmployeeDataQualityProfile?> {
  EmployeeDataQualityNotifier(super.state);

  EmployeeDataQualityIssue addDraft(EmployeeDataQualityIssueDraft draft) {
    final profile = state;
    if (profile == null) {
      throw StateError('Employee data quality profile is unavailable');
    }

    final issue = draft.toIssue(id: _nextIssueId(profile));
    state = profile.copyWith(issues: [issue, ...profile.issues]);
    return issue;
  }

  void reviewIssue(String issueId) {
    _updateIssue(
      issueId,
      (issue) => issue.copyWith(status: EmployeeDataQualityStatus.reviewed),
    );
  }

  void resolveIssue(String issueId) {
    _updateIssue(
      issueId,
      (issue) => issue.copyWith(status: EmployeeDataQualityStatus.resolved),
    );
  }

  void waiveIssue(String issueId) {
    _updateIssue(
      issueId,
      (issue) => issue.copyWith(status: EmployeeDataQualityStatus.waived),
    );
  }

  void reopenIssue(String issueId) {
    _updateIssue(
      issueId,
      (issue) => issue.copyWith(status: EmployeeDataQualityStatus.open),
    );
  }

  void _updateIssue(
    String issueId,
    EmployeeDataQualityIssue Function(EmployeeDataQualityIssue issue) update,
  ) {
    final profile = state;
    if (profile == null) return;

    state = profile.copyWith(
      issues:
          profile.issues.map((issue) {
            if (issue.id != issueId) return issue;
            return update(issue);
          }).toList(),
    );
  }

  String _nextIssueId(EmployeeDataQualityProfile profile) {
    var index = profile.issues.length + 1;
    while (true) {
      final id =
          'EDQ-${profile.employeeId}-${index.toString().padLeft(3, '0')}';
      if (!profile.issues.any((issue) => issue.id == id)) {
        return id;
      }
      index++;
    }
  }
}

class EmployeeDataQualityIssueDraftNotifier
    extends StateNotifier<EmployeeDataQualityIssueDraft?> {
  final EmployeeDataQualityIssueDraft? _initialDraft;

  EmployeeDataQualityIssueDraftNotifier(super.state) : _initialDraft = state;

  void setField(String value) {
    state = state?.copyWith(field: value);
  }

  void setTitle(String value) {
    state = state?.copyWith(title: value);
  }

  void setDetail(String value) {
    state = state?.copyWith(detail: value);
  }

  void setOwner(String value) {
    state = state?.copyWith(owner: value);
  }

  void setType(EmployeeDataQualityIssueType value) {
    state = state?.copyWith(type: value);
  }

  void setSeverity(EmployeeDataQualitySeverity value) {
    state = state?.copyWith(severity: value);
  }

  void setDueDate(DateTime value) {
    state = state?.copyWith(dueDate: _dateOnly(value));
  }

  void reset() {
    state = _initialDraft;
  }
}

List<EmployeeDataQualityIssue> _seedIssues({
  required EmployeeDirectoryMember member,
  required List<EmployeeDirectoryMember> members,
  required EmployeeProfileCompletenessProfile? completeness,
  required DateTime asOfDate,
}) {
  return [
    ..._directoryIssues(member: member, members: members, asOfDate: asOfDate),
    ..._completenessIssues(
      employeeId: member.id,
      completeness: completeness,
      asOfDate: asOfDate,
    ),
  ];
}

List<EmployeeDataQualityIssue> _directoryIssues({
  required EmployeeDirectoryMember member,
  required List<EmployeeDirectoryMember> members,
  required DateTime asOfDate,
}) {
  final issues = <EmployeeDataQualityIssue>[];
  final normalizedEmail = member.email.trim().toLowerCase();

  if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
    issues.add(
      _issue(
        id: 'EDQ-${member.id}-directory-email',
        employeeId: member.id,
        field: 'Email',
        title: 'Directory email needs validation',
        detail: 'Employee directory email is empty or does not look valid.',
        owner: 'People Operations',
        sourceLabel: 'Employee directory',
        asOfDate: asOfDate,
        dueOffsetDays: 1,
        type: EmployeeDataQualityIssueType.inconsistentData,
        severity: EmployeeDataQualitySeverity.high,
      ),
    );
  }

  if (normalizedEmail.isNotEmpty &&
      members
              .where(
                (item) => item.email.trim().toLowerCase() == normalizedEmail,
              )
              .length >
          1) {
    issues.add(
      _issue(
        id: 'EDQ-${member.id}-duplicate-email',
        employeeId: member.id,
        field: 'Email',
        title: 'Duplicate employee email detected',
        detail: 'Another employee record uses ${member.email}.',
        owner: 'People Operations',
        sourceLabel: 'Employee directory',
        asOfDate: asOfDate,
        dueOffsetDays: 0,
        type: EmployeeDataQualityIssueType.duplicateRisk,
        severity: EmployeeDataQualitySeverity.critical,
      ),
    );
  }

  if (member.phone.trim().isEmpty) {
    issues.add(
      _issue(
        id: 'EDQ-${member.id}-directory-phone',
        employeeId: member.id,
        field: 'Phone',
        title: 'Directory phone is missing',
        detail: 'Employee contact phone is required for HR service workflows.',
        owner: 'People Operations',
        sourceLabel: 'Employee directory',
        asOfDate: asOfDate,
        dueOffsetDays: 2,
        type: EmployeeDataQualityIssueType.missingData,
        severity: EmployeeDataQualitySeverity.medium,
      ),
    );
  }

  if (member.manager.trim().isEmpty ||
      member.manager.trim().toLowerCase() == member.name.trim().toLowerCase()) {
    issues.add(
      _issue(
        id: 'EDQ-${member.id}-directory-manager',
        employeeId: member.id,
        field: 'Manager',
        title: 'Reporting manager needs review',
        detail: 'Employee manager is missing or points back to the employee.',
        owner: 'HR Business Partner',
        sourceLabel: 'Employee directory',
        asOfDate: asOfDate,
        dueOffsetDays: 2,
        type: EmployeeDataQualityIssueType.inconsistentData,
        severity: EmployeeDataQualitySeverity.high,
      ),
    );
  }

  if (member.joiningDate.isAfter(asOfDate)) {
    issues.add(
      _issue(
        id: 'EDQ-${member.id}-future-start',
        employeeId: member.id,
        field: 'Joining date',
        title: 'Future joining date on active profile',
        detail: 'Joining date is after the HRIS reporting date.',
        owner: 'People Operations',
        sourceLabel: 'Employee directory',
        asOfDate: asOfDate,
        dueOffsetDays: 0,
        type: EmployeeDataQualityIssueType.inconsistentData,
        severity: EmployeeDataQualitySeverity.critical,
      ),
    );
  }

  return issues;
}

List<EmployeeDataQualityIssue> _completenessIssues({
  required String employeeId,
  required EmployeeProfileCompletenessProfile? completeness,
  required DateTime asOfDate,
}) {
  if (completeness == null) return const [];

  return completeness.priorityItems
      .where((item) => item.isOpen)
      .take(4)
      .map(
        (item) => _issue(
          id: 'EDQ-$employeeId-${item.area.name}',
          employeeId: employeeId,
          field: item.area.label,
          title: '${item.area.label} data requires cleanup',
          detail: '${item.detail} ${item.nextAction}',
          owner: _ownerForArea(item.area),
          sourceLabel: 'Profile completeness',
          asOfDate: asOfDate,
          dueOffsetDays: _dueOffsetForStatus(item.status),
          type: _typeForStatus(item.status),
          severity: _severityForStatus(item.status, item.score),
        ),
      )
      .toList();
}

EmployeeDataQualityIssue _issue({
  required String id,
  required String employeeId,
  required String field,
  required String title,
  required String detail,
  required String owner,
  required String sourceLabel,
  required DateTime asOfDate,
  required int dueOffsetDays,
  required EmployeeDataQualityIssueType type,
  required EmployeeDataQualitySeverity severity,
}) {
  return EmployeeDataQualityIssue(
    id: id,
    employeeId: employeeId,
    field: field,
    title: title,
    detail: detail,
    owner: owner,
    sourceLabel: sourceLabel,
    detectedAt: asOfDate,
    dueDate: asOfDate.add(Duration(days: dueOffsetDays)),
    type: type,
    severity: severity,
    status: EmployeeDataQualityStatus.open,
  );
}

EmployeeDataQualityIssueType _typeForStatus(
  EmployeeProfileCompletenessStatus status,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing =>
      EmployeeDataQualityIssueType.missingData,
    EmployeeProfileCompletenessStatus.actionRequired =>
      EmployeeDataQualityIssueType.inconsistentData,
    EmployeeProfileCompletenessStatus.inProgress =>
      EmployeeDataQualityIssueType.staleData,
    EmployeeProfileCompletenessStatus.complete =>
      EmployeeDataQualityIssueType.governance,
  };
}

EmployeeDataQualitySeverity _severityForStatus(
  EmployeeProfileCompletenessStatus status,
  int score,
) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing =>
      score <= 50
          ? EmployeeDataQualitySeverity.critical
          : EmployeeDataQualitySeverity.high,
    EmployeeProfileCompletenessStatus.actionRequired =>
      EmployeeDataQualitySeverity.high,
    EmployeeProfileCompletenessStatus.inProgress =>
      EmployeeDataQualitySeverity.medium,
    EmployeeProfileCompletenessStatus.complete =>
      EmployeeDataQualitySeverity.low,
  };
}

int _dueOffsetForStatus(EmployeeProfileCompletenessStatus status) {
  return switch (status) {
    EmployeeProfileCompletenessStatus.missing => -1,
    EmployeeProfileCompletenessStatus.actionRequired => 1,
    EmployeeProfileCompletenessStatus.inProgress => 5,
    EmployeeProfileCompletenessStatus.complete => 14,
  };
}

String _ownerForArea(EmployeeProfileCompletenessArea area) {
  return switch (area) {
    EmployeeProfileCompletenessArea.payroll => 'Payroll Operations',
    EmployeeProfileCompletenessArea.benefits => 'Benefits Administrator',
    EmployeeProfileCompletenessArea.reporting => 'HR Business Partner',
    EmployeeProfileCompletenessArea.assetsAccess => 'IT Operations',
    EmployeeProfileCompletenessArea.compliance => 'Compliance Officer',
    EmployeeProfileCompletenessArea.documentVault => 'People Operations',
    EmployeeProfileCompletenessArea.workAuthorization => 'People Operations',
    EmployeeProfileCompletenessArea.personalRecords => 'People Operations',
    EmployeeProfileCompletenessArea.jobAssignment => 'HR Business Partner',
    EmployeeProfileCompletenessArea.schedule => 'Workforce Operations',
  };
}

EmployeeDirectoryMember? _findMember(
  List<EmployeeDirectoryMember> members,
  String employeeId,
) {
  for (final member in members) {
    if (member.id == employeeId) return member;
  }
  return null;
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
