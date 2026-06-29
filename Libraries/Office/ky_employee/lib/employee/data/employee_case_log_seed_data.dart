import '../models/employee_case_log_models.dart';
import '../models/employee_directory_models.dart';

EmployeeHrCaseLog buildEmployeeHrCaseLog({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final cases = _casesFor(member, today);

  return EmployeeHrCaseLog(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    cases: cases,
    notes: _notesFor(member, cases),
  );
}

EmployeeHrCaseNoteDraft buildEmployeeHrCaseNoteDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final cases = _casesFor(member, today);

  return EmployeeHrCaseNoteDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    caseId: cases.isEmpty ? '' : cases.first.id,
    author: member.manager,
    body: '',
    confidential: true,
  );
}

EmployeeHrCaseIntakeDraft buildEmployeeHrCaseIntakeDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeHrCaseIntakeDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    title: '',
    summary: '',
    owner: member.manager.trim().isEmpty ? 'People Operations' : member.manager,
    type:
        member.status == EmployeeDirectoryStatus.onboarding
            ? EmployeeHrCaseType.onboarding
            : EmployeeHrCaseType.inquiry,
    priority:
        member.status == EmployeeDirectoryStatus.watchlist
            ? EmployeeHrCasePriority.high
            : EmployeeHrCasePriority.medium,
    confidentiality:
        member.status == EmployeeDirectoryStatus.watchlist
            ? EmployeeHrCaseConfidentiality.sensitive
            : EmployeeHrCaseConfidentiality.standard,
    followUpDate: today.add(const Duration(days: 7)),
  );
}

List<EmployeeHrCaseRecord> _casesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeHrCaseRecord(
        id: '${member.id}-case-performance',
        employeeId: member.id,
        type: EmployeeHrCaseType.performance,
        title: 'Performance support plan',
        owner: 'HR Business Partner',
        openedAt: today.subtract(const Duration(days: 18)),
        followUpDate: today.subtract(const Duration(days: 1)),
        status: EmployeeHrCaseStatus.inProgress,
        priority: EmployeeHrCasePriority.high,
        confidentiality: EmployeeHrCaseConfidentiality.restricted,
        summary: 'Manager coaching cadence and documentation need follow-up.',
      ),
      EmployeeHrCaseRecord(
        id: '${member.id}-case-policy',
        employeeId: member.id,
        type: EmployeeHrCaseType.policy,
        title: 'Policy acknowledgement follow-up',
        owner: 'People Operations',
        openedAt: today.subtract(const Duration(days: 6)),
        followUpDate: today.add(const Duration(days: 5)),
        status: EmployeeHrCaseStatus.open,
        priority: EmployeeHrCasePriority.medium,
        confidentiality: EmployeeHrCaseConfidentiality.sensitive,
        summary: 'Confirm employee acknowledgement and manager context.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeHrCaseRecord(
        id: '${member.id}-case-onboarding',
        employeeId: member.id,
        type: EmployeeHrCaseType.onboarding,
        title: 'Onboarding support request',
        owner: 'People Operations',
        openedAt: today.subtract(const Duration(days: 2)),
        followUpDate: today.add(const Duration(days: 2)),
        status: EmployeeHrCaseStatus.open,
        priority: EmployeeHrCasePriority.medium,
        confidentiality: EmployeeHrCaseConfidentiality.standard,
        summary: 'Track document completion questions and first-week support.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeHrCaseRecord(
        id: '${member.id}-case-retention',
        employeeId: member.id,
        type: EmployeeHrCaseType.employeeRelations,
        title: 'Retention check-in note',
        owner: member.manager,
        openedAt: today.subtract(const Duration(days: 9)),
        followUpDate: today.add(const Duration(days: 14)),
        status: EmployeeHrCaseStatus.inProgress,
        priority: EmployeeHrCasePriority.medium,
        confidentiality: EmployeeHrCaseConfidentiality.sensitive,
        summary: 'Document stay conversation themes and growth commitments.',
      ),
    ];
  }

  return [
    EmployeeHrCaseRecord(
      id: '${member.id}-case-profile',
      employeeId: member.id,
      type: EmployeeHrCaseType.inquiry,
      title: 'General HR profile check',
      owner: 'People Operations',
      openedAt: today.subtract(const Duration(days: 30)),
      followUpDate: today.subtract(const Duration(days: 7)),
      status: EmployeeHrCaseStatus.resolved,
      priority: EmployeeHrCasePriority.low,
      confidentiality: EmployeeHrCaseConfidentiality.standard,
      summary: 'Routine profile confirmation completed.',
    ),
  ];
}

List<EmployeeHrCaseNote> _notesFor(
  EmployeeDirectoryMember member,
  List<EmployeeHrCaseRecord> cases,
) {
  return cases
      .map(
        (record) => EmployeeHrCaseNote(
          id: '${record.id}-note-1',
          employeeId: member.id,
          caseId: record.id,
          author: record.owner,
          createdAt: record.openedAt,
          body: record.summary,
          confidential:
              record.confidentiality != EmployeeHrCaseConfidentiality.standard,
        ),
      )
      .toList();
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
