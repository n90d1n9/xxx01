import '../models/employee_directory_models.dart';
import '../models/employee_mobility_readiness_models.dart';

EmployeeMobilityReadinessProfile buildEmployeeMobilityReadinessProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
  EmployeeMobilityMoveType? moveType,
  String? targetRole,
  String? targetDepartment,
  String? targetManager,
  DateTime? effectiveDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeMobilityReadinessProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    moveType: moveType ?? _defaultMoveType(member),
    currentRole: member.position,
    currentDepartment: member.department,
    currentManager: member.manager,
    targetRole: targetRole ?? _targetRoleFor(member),
    targetDepartment: targetDepartment ?? _targetDepartmentFor(member),
    targetManager: targetManager ?? _targetManagerFor(member),
    effectiveDate: _dateOnly(effectiveDate ?? _effectiveDateFor(member, today)),
    gates: _gatesFor(member: member, today: today),
  );
}

EmployeeMobilityGateDraft buildEmployeeMobilityGateDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeMobilityGateDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

EmployeeMobilityMoveType _defaultMoveType(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeMobilityMoveType.projectAssignment;
  }
  if (member.isHighPerformer) {
    return EmployeeMobilityMoveType.promotion;
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeMobilityMoveType.managerChange;
  }
  return EmployeeMobilityMoveType.lateralTransfer;
}

DateTime _effectiveDateFor(EmployeeDirectoryMember member, DateTime today) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.add(const Duration(days: 14));
  }
  if (member.isHighPerformer) {
    return today.add(const Duration(days: 30));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return today.add(const Duration(days: 45));
  }
  return today.add(const Duration(days: 60));
}

List<EmployeeMobilityGate> _gatesFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _gate(
        id: '${member.id}-mobility-manager',
        employeeId: member.id,
        type: EmployeeMobilityGateType.managerAlignment,
        title: 'Confirm recovery assignment sponsor',
        owner: member.manager,
        dueDate: today.subtract(const Duration(days: 1)),
        status: EmployeeMobilityGateStatus.blocked,
        risk: EmployeeMobilityGateRisk.critical,
        detail: 'Sponsor must agree to scope and weekly checkpoints.',
      ),
      _gate(
        id: '${member.id}-mobility-handover',
        employeeId: member.id,
        type: EmployeeMobilityGateType.handover,
        title: 'Document current roadmap handover',
        owner: 'People Operations',
        dueDate: today.add(const Duration(days: 2)),
        status: EmployeeMobilityGateStatus.actionRequired,
        risk: EmployeeMobilityGateRisk.high,
        detail: 'Current work needs a named backup before reassignment.',
      ),
      _gate(
        id: '${member.id}-mobility-start',
        employeeId: member.id,
        type: EmployeeMobilityGateType.startDate,
        title: 'Lock assignment start date',
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 5)),
        status: EmployeeMobilityGateStatus.actionRequired,
        risk: EmployeeMobilityGateRisk.medium,
        detail: 'Align start date with manager coaching plan.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      _gate(
        id: '${member.id}-mobility-comp',
        employeeId: member.id,
        type: EmployeeMobilityGateType.compensation,
        title: 'Validate promotion compensation band',
        owner: 'Compensation',
        dueDate: today.add(const Duration(days: 3)),
        status: EmployeeMobilityGateStatus.actionRequired,
        risk: EmployeeMobilityGateRisk.high,
        detail: 'Promotion panel approved; compensation guardrails pending.',
      ),
      _gate(
        id: '${member.id}-mobility-access',
        employeeId: member.id,
        type: EmployeeMobilityGateType.access,
        title: 'Prepare leadership access changes',
        owner: 'IT Security',
        dueDate: today.add(const Duration(days: 7)),
        status: EmployeeMobilityGateStatus.actionRequired,
        risk: EmployeeMobilityGateRisk.medium,
        detail: 'Access package needs manager approval before effective date.',
      ),
      _gate(
        id: '${member.id}-mobility-manager',
        employeeId: member.id,
        type: EmployeeMobilityGateType.managerAlignment,
        title: 'Confirm receiving manager handoff',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 10)),
        status: EmployeeMobilityGateStatus.ready,
        risk: EmployeeMobilityGateRisk.low,
        detail: 'Receiving manager has acknowledged the move.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _gate(
        id: '${member.id}-mobility-manager',
        employeeId: member.id,
        type: EmployeeMobilityGateType.managerAlignment,
        title: 'Confirm onboarding manager alignment',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 14)),
        status: EmployeeMobilityGateStatus.actionRequired,
        risk: EmployeeMobilityGateRisk.medium,
        detail: 'Manager change should wait until probation checkpoint.',
      ),
      _gate(
        id: '${member.id}-mobility-access',
        employeeId: member.id,
        type: EmployeeMobilityGateType.access,
        title: 'Map onboarding access owner changes',
        owner: 'IT Operations',
        dueDate: today.add(const Duration(days: 21)),
        status: EmployeeMobilityGateStatus.ready,
        risk: EmployeeMobilityGateRisk.low,
        detail: 'Baseline access owner is documented.',
      ),
    ];
  }

  return [
    _gate(
      id: '${member.id}-mobility-manager',
      employeeId: member.id,
      type: EmployeeMobilityGateType.managerAlignment,
      title: 'Confirm mobility sponsor',
      owner: member.manager,
      dueDate: today.add(const Duration(days: 21)),
      status: EmployeeMobilityGateStatus.ready,
      risk: EmployeeMobilityGateRisk.low,
      detail: 'Sponsor is aligned for future mobility planning.',
    ),
    _gate(
      id: '${member.id}-mobility-access',
      employeeId: member.id,
      type: EmployeeMobilityGateType.access,
      title: 'Review future access impact',
      owner: 'IT Security',
      dueDate: today.add(const Duration(days: 30)),
      status: EmployeeMobilityGateStatus.ready,
      risk: EmployeeMobilityGateRisk.low,
      detail: 'No immediate access blockers identified.',
    ),
  ];
}

EmployeeMobilityGate _gate({
  required String id,
  required String employeeId,
  required EmployeeMobilityGateType type,
  required String title,
  required String owner,
  required DateTime dueDate,
  required EmployeeMobilityGateStatus status,
  required EmployeeMobilityGateRisk risk,
  required String detail,
}) {
  return EmployeeMobilityGate(
    id: id,
    employeeId: employeeId,
    type: type,
    title: title,
    owner: owner,
    dueDate: _dateOnly(dueDate),
    status: status,
    risk: risk,
    detail: detail,
  );
}

String _targetRoleFor(EmployeeDirectoryMember member) {
  return switch (member.position) {
    'UX Designer' => 'Senior UX Designer',
    'Senior Developer' => 'Engineering Lead',
    'HR Manager' => 'People Operations Lead',
    'Product Manager' => 'Senior Product Manager',
    'Marketing Specialist' => 'Marketing Campaign Lead',
    _ => 'Senior ${member.position}',
  };
}

String _targetDepartmentFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return member.department;
  }
  return switch (member.department) {
    'Engineering' => 'Platform Engineering',
    'Design' => 'Product Design',
    'Human Resources' => 'People Operations',
    'Product' => 'Product Strategy',
    'Marketing' => 'Growth Marketing',
    _ => member.department,
  };
}

String _targetManagerFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return member.manager;
  }
  return switch (member.department) {
    'Engineering' => 'Priya Shah',
    'Design' => 'Emma Rodriguez',
    'Human Resources' => 'Nadia Rahman',
    'Product' => 'Olivia Wilson',
    'Marketing' => 'Emma Rodriguez',
    _ => member.manager,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
