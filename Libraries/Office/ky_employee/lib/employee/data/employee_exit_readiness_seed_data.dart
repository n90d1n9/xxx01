import '../models/employee_directory_models.dart';
import '../models/employee_exit_readiness_models.dart';

EmployeeExitReadinessProfile buildEmployeeExitReadinessProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
  EmployeeExitType? exitType,
  DateTime? finalWorkday,
}) {
  final today = _dateOnly(asOfDate);
  final resolvedType = exitType ?? defaultEmployeeExitType(member);
  final resolvedFinalWorkday =
      finalWorkday ?? defaultEmployeeFinalWorkday(member: member, today: today);

  return EmployeeExitReadinessProfile(
    employeeId: member.id,
    employeeName: member.name,
    manager: member.manager,
    asOfDate: today,
    exitType: resolvedType,
    finalWorkday: _dateOnly(resolvedFinalWorkday),
    items: _seedItems(
      employeeId: member.id,
      manager: member.manager,
      today: today,
      status: member.status,
      isHighPerformer: member.isHighPerformer,
    ),
  );
}

EmployeeExitType defaultEmployeeExitType(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeExitType.involuntary;
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeExitType.contractEnd;
  }
  if (member.isHighPerformer) {
    return EmployeeExitType.internalTransfer;
  }
  return EmployeeExitType.voluntary;
}

DateTime defaultEmployeeFinalWorkday({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.add(const Duration(days: 10));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return today.add(const Duration(days: 45));
  }
  if (member.isHighPerformer) {
    return today.add(const Duration(days: 60));
  }
  return today.add(const Duration(days: 90));
}

List<EmployeeExitClearanceItem> _seedItems({
  required String employeeId,
  required String manager,
  required DateTime today,
  required EmployeeDirectoryStatus status,
  required bool isHighPerformer,
}) {
  if (status == EmployeeDirectoryStatus.watchlist) {
    return [
      _item(
        id: '$employeeId-exit-docs',
        employeeId: employeeId,
        title: 'Finalize separation notice and rationale',
        owner: 'HR Business Partner',
        category: EmployeeExitClearanceCategory.documents,
        status: EmployeeExitClearanceStatus.blocked,
        risk: EmployeeExitRisk.critical,
        dueDate: today.subtract(const Duration(days: 1)),
        note: 'Manager documentation must be attached before release.',
      ),
      _item(
        id: '$employeeId-exit-access',
        employeeId: employeeId,
        title: 'Schedule access revocation window',
        owner: 'IT Security',
        category: EmployeeExitClearanceCategory.access,
        status: EmployeeExitClearanceStatus.open,
        risk: EmployeeExitRisk.critical,
        dueDate: today,
      ),
      _item(
        id: '$employeeId-exit-payroll',
        employeeId: employeeId,
        title: 'Prepare final pay and unused leave calculation',
        owner: 'Payroll',
        category: EmployeeExitClearanceCategory.payroll,
        status: EmployeeExitClearanceStatus.inProgress,
        risk: EmployeeExitRisk.high,
        dueDate: today.add(const Duration(days: 2)),
      ),
      _item(
        id: '$employeeId-exit-assets',
        employeeId: employeeId,
        title: 'Collect laptop badge and assigned equipment',
        owner: 'Facilities',
        category: EmployeeExitClearanceCategory.assets,
        status: EmployeeExitClearanceStatus.open,
        risk: EmployeeExitRisk.high,
        dueDate: today.add(const Duration(days: 5)),
      ),
    ];
  }

  if (status == EmployeeDirectoryStatus.onboarding) {
    return [
      _item(
        id: '$employeeId-exit-probation',
        employeeId: employeeId,
        title: 'Confirm probation conversion or release decision',
        owner: manager,
        category: EmployeeExitClearanceCategory.compliance,
        status: EmployeeExitClearanceStatus.open,
        risk: EmployeeExitRisk.medium,
        dueDate: today.add(const Duration(days: 21)),
      ),
      _item(
        id: '$employeeId-exit-doc-return',
        employeeId: employeeId,
        title: 'Prepare contract end document packet',
        owner: 'People Operations',
        category: EmployeeExitClearanceCategory.documents,
        status: EmployeeExitClearanceStatus.inProgress,
        risk: EmployeeExitRisk.medium,
        dueDate: today.add(const Duration(days: 30)),
      ),
      _item(
        id: '$employeeId-exit-access-baseline',
        employeeId: employeeId,
        title: 'Validate revocation owner for trial accounts',
        owner: 'IT Operations',
        category: EmployeeExitClearanceCategory.access,
        status: EmployeeExitClearanceStatus.open,
        risk: EmployeeExitRisk.low,
        dueDate: today.add(const Duration(days: 35)),
      ),
    ];
  }

  if (isHighPerformer) {
    return [
      _item(
        id: '$employeeId-exit-transfer-handover',
        employeeId: employeeId,
        title: 'Capture critical handover notes',
        owner: manager,
        category: EmployeeExitClearanceCategory.knowledgeTransfer,
        status: EmployeeExitClearanceStatus.inProgress,
        risk: EmployeeExitRisk.medium,
        dueDate: today.add(const Duration(days: 14)),
      ),
      _item(
        id: '$employeeId-exit-transfer-access',
        employeeId: employeeId,
        title: 'Map access changes for internal transfer',
        owner: 'IT Security',
        category: EmployeeExitClearanceCategory.access,
        status: EmployeeExitClearanceStatus.open,
        risk: EmployeeExitRisk.medium,
        dueDate: today.add(const Duration(days: 21)),
      ),
      _item(
        id: '$employeeId-exit-transfer-payroll',
        employeeId: employeeId,
        title: 'Confirm cost center payroll movement',
        owner: 'Payroll',
        category: EmployeeExitClearanceCategory.payroll,
        status: EmployeeExitClearanceStatus.complete,
        risk: EmployeeExitRisk.low,
        dueDate: today.add(const Duration(days: 28)),
      ),
    ];
  }

  return [
    _item(
      id: '$employeeId-exit-contact',
      employeeId: employeeId,
      title: 'Confirm exit contact packet owner',
      owner: 'People Operations',
      category: EmployeeExitClearanceCategory.documents,
      status: EmployeeExitClearanceStatus.complete,
      risk: EmployeeExitRisk.low,
      dueDate: today.add(const Duration(days: 30)),
    ),
    _item(
      id: '$employeeId-exit-assets-baseline',
      employeeId: employeeId,
      title: 'Verify assigned asset register',
      owner: 'Facilities',
      category: EmployeeExitClearanceCategory.assets,
      status: EmployeeExitClearanceStatus.complete,
      risk: EmployeeExitRisk.low,
      dueDate: today.add(const Duration(days: 30)),
    ),
    _item(
      id: '$employeeId-exit-payroll-baseline',
      employeeId: employeeId,
      title: 'Confirm final pay workflow owner',
      owner: 'Payroll',
      category: EmployeeExitClearanceCategory.payroll,
      status: EmployeeExitClearanceStatus.complete,
      risk: EmployeeExitRisk.low,
      dueDate: today.add(const Duration(days: 30)),
    ),
  ];
}

EmployeeExitClearanceItem _item({
  required String id,
  required String employeeId,
  required String title,
  required String owner,
  required EmployeeExitClearanceCategory category,
  required EmployeeExitClearanceStatus status,
  required EmployeeExitRisk risk,
  required DateTime dueDate,
  String note = '',
}) {
  return EmployeeExitClearanceItem(
    id: id,
    employeeId: employeeId,
    title: title,
    owner: owner,
    category: category,
    status: status,
    risk: risk,
    dueDate: _dateOnly(dueDate),
    note: note,
  );
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
