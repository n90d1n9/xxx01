import '../models/employee_contract_lifecycle_models.dart';
import '../models/employee_directory_models.dart';

EmployeeContractLifecycleProfile buildEmployeeContractLifecycleProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeContractLifecycleProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    contract: _contractFor(member, today),
    changes: _changesFor(member, today),
  );
}

EmployeeContractChangeDraft buildEmployeeContractChangeDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeContractChangeDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeContractChangeType.renewal,
    title: 'Contract renewal request',
    requestedBy: member.manager,
    effectiveDate: today.add(const Duration(days: 14)),
    detail: '',
  );
}

EmployeeContractRecord _contractFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeContractRecord(
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeContractType.fixedTerm,
      status: EmployeeContractStatus.renewalDue,
      startDate: _dateOnly(member.joiningDate),
      endDate: today.add(const Duration(days: 25)),
      probationEndDate: null,
      renewalDueDate: today.subtract(const Duration(days: 1)),
      owner: 'People Operations',
      version: 2,
      signedAt: today.subtract(const Duration(days: 330)),
    );
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeContractRecord(
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeContractType.probation,
      status: EmployeeContractStatus.probation,
      startDate: today.subtract(const Duration(days: 75)),
      endDate: null,
      probationEndDate: today.add(const Duration(days: 7)),
      renewalDueDate: null,
      owner: 'People Operations',
      version: 1,
      signedAt: today.subtract(const Duration(days: 75)),
    );
  }

  if (member.location == 'Singapore') {
    return EmployeeContractRecord(
      employeeId: member.id,
      employeeName: member.name,
      type: EmployeeContractType.fixedTerm,
      status: EmployeeContractStatus.active,
      startDate: _dateOnly(member.joiningDate),
      endDate: today.add(const Duration(days: 210)),
      probationEndDate: null,
      renewalDueDate: today.add(const Duration(days: 180)),
      owner: 'People Operations',
      version: 3,
      signedAt: today.subtract(const Duration(days: 180)),
    );
  }

  return EmployeeContractRecord(
    employeeId: member.id,
    employeeName: member.name,
    type: EmployeeContractType.permanent,
    status: EmployeeContractStatus.active,
    startDate: _dateOnly(member.joiningDate),
    endDate: null,
    probationEndDate: null,
    renewalDueDate: null,
    owner: 'People Operations',
    version: member.isHighPerformer ? 4 : 2,
    signedAt: today.subtract(const Duration(days: 360)),
  );
}

List<EmployeeContractChangeRequest> _changesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeContractChangeRequest(
        id: 'ECL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeContractChangeType.renewal,
        title: 'Renew fixed-term agreement',
        requestedBy: member.manager,
        effectiveDate: today.add(const Duration(days: 25)),
        detail: 'Renew fixed-term agreement after manager review.',
        status: EmployeeContractChangeStatus.submitted,
        submittedAt: today.subtract(const Duration(days: 2)),
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeContractChangeRequest(
        id: 'ECL-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeContractChangeType.conversion,
        title: 'Convert after probation',
        requestedBy: member.manager,
        effectiveDate: today.add(const Duration(days: 7)),
        detail: 'Convert probation agreement after first manager review.',
        status: EmployeeContractChangeStatus.approved,
        submittedAt: today.subtract(const Duration(days: 5)),
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
