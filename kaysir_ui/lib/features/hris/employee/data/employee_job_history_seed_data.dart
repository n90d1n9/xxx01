import '../models/employee_directory_models.dart';
import '../models/employee_job_history_models.dart';

EmployeeJobHistoryProfile buildEmployeeJobHistoryProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeJobHistoryProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    currentPosition: member.position,
    currentDepartment: member.department,
    currentManager: member.manager,
    history: _historyFor(member: member, today: today),
  );
}

EmployeeJobHistoryEventDraft buildEmployeeJobHistoryEventDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeJobHistoryEventDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

List<EmployeeJobHistoryEvent> _historyFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  final events = <EmployeeJobHistoryEvent>[
    _event(
      id: '${member.id}-job-hire',
      employeeId: member.id,
      type: EmployeeJobHistoryEventType.hire,
      title: 'Original hire',
      fromValue: 'Candidate',
      toValue: '${member.position} - ${member.department}',
      effectiveDate: member.joiningDate,
      recordedAt: member.joiningDate.add(const Duration(days: 1)),
      source: EmployeeJobHistorySource.employeeRecordAction,
      status: EmployeeJobHistoryStatus.effective,
      owner: 'HR Operations',
      note: 'Initial hire event imported from the employee record.',
      evidence: 'Signed employment agreement',
    ),
  ];

  if (member.id == '2') {
    events.addAll([
      _event(
        id: '${member.id}-job-promotion',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.promotion,
        title: 'Staff developer promotion',
        fromValue: 'Senior Developer - L4',
        toValue: 'Staff Developer - L5',
        effectiveDate: today.add(const Duration(days: 7)),
        recordedAt: today.subtract(const Duration(days: 2)),
        source: EmployeeJobHistorySource.jobAssignment,
        status: EmployeeJobHistoryStatus.pendingEvidence,
        owner: 'Talent Operations',
        note: 'Promotion package is approved, compensation memo is pending.',
        evidence: '',
      ),
      _event(
        id: '${member.id}-job-manager',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.managerChange,
        title: 'Engineering reporting line change',
        fromValue: 'David Kim',
        toValue: 'Priya Shah',
        effectiveDate: today.add(const Duration(days: 21)),
        recordedAt: today.subtract(const Duration(days: 1)),
        source: EmployeeJobHistorySource.managerChange,
        status: EmployeeJobHistoryStatus.scheduled,
        owner: 'People Operations',
        note: 'Future reporting line is aligned with the growth plan.',
        evidence: 'Manager change approval',
      ),
    ]);
  } else if (member.id == '4') {
    events.addAll([
      _event(
        id: '${member.id}-job-manager',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.managerChange,
        title: 'Interim manager assignment',
        fromValue: 'Olivia Wilson',
        toValue: 'Nadia Rahman',
        effectiveDate: today.subtract(const Duration(days: 3)),
        recordedAt: today.subtract(const Duration(days: 4)),
        source: EmployeeJobHistorySource.managerChange,
        status: EmployeeJobHistoryStatus.pendingEvidence,
        owner: 'People Operations',
        note: 'Interim reporting line needs the recovery-plan approval memo.',
        evidence: '',
      ),
      _event(
        id: '${member.id}-job-reversed',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.transfer,
        title: 'Product squad transfer rollback',
        fromValue: 'Platform Squad',
        toValue: 'Growth Squad',
        effectiveDate: today.subtract(const Duration(days: 20)),
        recordedAt: today.subtract(const Duration(days: 18)),
        source: EmployeeJobHistorySource.employeeRecordAction,
        status: EmployeeJobHistoryStatus.reversed,
        owner: 'HR Business Partner',
        note: 'Transfer was reversed after recovery plan calibration.',
        evidence: 'Reversal approval note',
      ),
    ]);
  } else if (member.status == EmployeeDirectoryStatus.onboarding) {
    events.add(
      _event(
        id: '${member.id}-job-contract',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.contractChange,
        title: 'Probation checkpoint conversion',
        fromValue: 'Probationary contract',
        toValue: 'Permanent contract',
        effectiveDate: today.add(const Duration(days: 10)),
        recordedAt: today,
        source: EmployeeJobHistorySource.contractLifecycle,
        status: EmployeeJobHistoryStatus.scheduled,
        owner: 'People Operations',
        note: 'Conversion will activate after onboarding checkpoint sign-off.',
        evidence: 'Accepted offer and probation plan',
      ),
    );
  } else if (member.isHighPerformer) {
    events.add(
      _event(
        id: '${member.id}-job-growth',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.promotion,
        title: 'Growth-track role calibration',
        fromValue: member.position,
        toValue: '${member.position} II',
        effectiveDate: today.subtract(const Duration(days: 35)),
        recordedAt: today.subtract(const Duration(days: 34)),
        source: EmployeeJobHistorySource.employeeRecordAction,
        status: EmployeeJobHistoryStatus.effective,
        owner: 'Talent Operations',
        note: 'Growth-track calibration is complete in the job ledger.',
        evidence: 'Calibration committee note',
      ),
    );
  } else {
    events.add(
      _event(
        id: '${member.id}-job-department',
        employeeId: member.id,
        type: EmployeeJobHistoryEventType.departmentChange,
        title: 'Department mapping cleanup',
        fromValue: 'People Team',
        toValue: member.department,
        effectiveDate: today.subtract(const Duration(days: 60)),
        recordedAt: today.subtract(const Duration(days: 58)),
        source: EmployeeJobHistorySource.manualCorrection,
        status: EmployeeJobHistoryStatus.effective,
        owner: 'HR Operations',
        note: 'Department naming was normalized for reporting.',
        evidence: '',
      ),
    );
  }

  return events;
}

EmployeeJobHistoryEvent _event({
  required String id,
  required String employeeId,
  required EmployeeJobHistoryEventType type,
  required String title,
  required String fromValue,
  required String toValue,
  required DateTime effectiveDate,
  required DateTime recordedAt,
  required EmployeeJobHistorySource source,
  required EmployeeJobHistoryStatus status,
  required String owner,
  required String note,
  required String evidence,
}) {
  return EmployeeJobHistoryEvent(
    id: id,
    employeeId: employeeId,
    type: type,
    title: title,
    fromValue: fromValue,
    toValue: toValue,
    effectiveDate: _dateOnly(effectiveDate),
    recordedAt: _dateOnly(recordedAt),
    source: source,
    status: status,
    owner: owner,
    note: note,
    evidence: evidence,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
