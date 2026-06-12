import '../models/employee_directory_models.dart';
import '../models/employee_manager_change_readiness_models.dart';

EmployeeManagerChangeReadinessProfile
buildEmployeeManagerChangeReadinessProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
  EmployeeManagerChangeType? changeType,
  String? targetManager,
  DateTime? effectiveDate,
  String? reason,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeManagerChangeReadinessProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    changeType: changeType ?? _defaultChangeType(member),
    currentManager: member.manager,
    targetManager: targetManager ?? _targetManagerFor(member),
    effectiveDate: _dateOnly(effectiveDate ?? _effectiveDateFor(member, today)),
    reason: reason ?? _reasonFor(member),
    checklist: _checklistFor(member: member, today: today),
  );
}

EmployeeManagerChangeChecklistDraft buildEmployeeManagerChangeChecklistDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeManagerChangeChecklistDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

EmployeeManagerChangeType _defaultChangeType(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeManagerChangeType.interimManager;
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeManagerChangeType.skipLevelSponsor;
  }
  if (member.isHighPerformer) {
    return EmployeeManagerChangeType.directManager;
  }
  return EmployeeManagerChangeType.matrixManager;
}

DateTime _effectiveDateFor(EmployeeDirectoryMember member, DateTime today) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.add(const Duration(days: 7));
  }
  if (member.isHighPerformer) {
    return today.add(const Duration(days: 21));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return today.add(const Duration(days: 30));
  }
  return today.add(const Duration(days: 45));
}

String _reasonFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return 'Interim manager coverage while recovery plan is reviewed.';
  }
  if (member.isHighPerformer) {
    return 'Manager transition for approved growth plan.';
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return 'Skip-level sponsor coverage during onboarding ramp.';
  }
  return 'Matrix coverage for cross-functional delivery.';
}

List<EmployeeManagerChangeChecklistItem> _checklistFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _item(
        id: '${member.id}-manager-outgoing',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.outgoingHandoff,
        title: 'Capture outgoing manager recovery notes',
        owner: member.manager,
        dueDate: today.subtract(const Duration(days: 1)),
        status: EmployeeManagerChangeChecklistStatus.blocked,
        risk: EmployeeManagerChangeRisk.high,
        detail:
            'Recovery notes must be attached before interim manager handoff.',
      ),
      _item(
        id: '${member.id}-manager-incoming',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.incomingAcknowledgement,
        title: 'Confirm interim manager acknowledgement',
        owner: _targetManagerFor(member),
        dueDate: today,
        status: EmployeeManagerChangeChecklistStatus.actionRequired,
        risk: EmployeeManagerChangeRisk.high,
        detail: 'Incoming manager must accept weekly coaching cadence.',
      ),
      _item(
        id: '${member.id}-manager-approval',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.approvalCoverage,
        title: 'Move approval coverage to interim manager',
        owner: 'People Operations',
        dueDate: today.add(const Duration(days: 2)),
        status: EmployeeManagerChangeChecklistStatus.actionRequired,
        risk: EmployeeManagerChangeRisk.medium,
        detail:
            'Leave, expenses, and access approvals need temporary coverage.',
      ),
      _item(
        id: '${member.id}-manager-performance',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.performanceOwnership,
        title: 'Transfer performance follow-up ownership',
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 3)),
        status: EmployeeManagerChangeChecklistStatus.ready,
        risk: EmployeeManagerChangeRisk.medium,
        detail: 'Performance follow-up owner is recorded.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      _item(
        id: '${member.id}-manager-growth',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.incomingAcknowledgement,
        title: 'Confirm receiving manager growth plan',
        owner: _targetManagerFor(member),
        dueDate: today.add(const Duration(days: 4)),
        status: EmployeeManagerChangeChecklistStatus.actionRequired,
        risk: EmployeeManagerChangeRisk.medium,
        detail: 'Receiving manager needs growth-plan acknowledgement.',
      ),
      _item(
        id: '${member.id}-manager-access',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.accessOwnership,
        title: 'Update access request owner',
        owner: 'IT Security',
        dueDate: today.add(const Duration(days: 7)),
        status: EmployeeManagerChangeChecklistStatus.actionRequired,
        risk: EmployeeManagerChangeRisk.medium,
        detail: 'Access request ownership changes with reporting line.',
      ),
      _item(
        id: '${member.id}-manager-outgoing',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.outgoingHandoff,
        title: 'Complete outgoing manager handoff',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 10)),
        status: EmployeeManagerChangeChecklistStatus.ready,
        risk: EmployeeManagerChangeRisk.low,
        detail: 'Handoff notes are ready for the new manager.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _item(
        id: '${member.id}-manager-onboarding',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.directReportImpact,
        title: 'Protect onboarding checkpoint ownership',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 12)),
        status: EmployeeManagerChangeChecklistStatus.actionRequired,
        risk: EmployeeManagerChangeRisk.medium,
        detail: 'Manager change should not interrupt onboarding checkpoints.',
      ),
      _item(
        id: '${member.id}-manager-approval',
        employeeId: member.id,
        type: EmployeeManagerChangeChecklistType.approvalCoverage,
        title: 'Confirm new hire approval backup',
        owner: 'People Operations',
        dueDate: today.add(const Duration(days: 18)),
        status: EmployeeManagerChangeChecklistStatus.ready,
        risk: EmployeeManagerChangeRisk.low,
        detail: 'Approval backup is active for onboarding workflows.',
      ),
    ];
  }

  return [
    _item(
      id: '${member.id}-manager-matrix',
      employeeId: member.id,
      type: EmployeeManagerChangeChecklistType.incomingAcknowledgement,
      title: 'Confirm matrix manager scope',
      owner: _targetManagerFor(member),
      dueDate: today.add(const Duration(days: 21)),
      status: EmployeeManagerChangeChecklistStatus.ready,
      risk: EmployeeManagerChangeRisk.low,
      detail: 'Matrix manager scope is documented.',
    ),
    _item(
      id: '${member.id}-manager-coverage',
      employeeId: member.id,
      type: EmployeeManagerChangeChecklistType.approvalCoverage,
      title: 'Review approval coverage impact',
      owner: 'People Operations',
      dueDate: today.add(const Duration(days: 28)),
      status: EmployeeManagerChangeChecklistStatus.ready,
      risk: EmployeeManagerChangeRisk.low,
      detail: 'No approval coverage change is required.',
    ),
  ];
}

EmployeeManagerChangeChecklistItem _item({
  required String id,
  required String employeeId,
  required EmployeeManagerChangeChecklistType type,
  required String title,
  required String owner,
  required DateTime dueDate,
  required EmployeeManagerChangeChecklistStatus status,
  required EmployeeManagerChangeRisk risk,
  required String detail,
}) {
  return EmployeeManagerChangeChecklistItem(
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

String _targetManagerFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return 'Nadia Rahman';
  }
  if (member.isHighPerformer && member.department == 'Engineering') {
    return 'Priya Shah';
  }
  if (member.department == 'Design') {
    return 'Michael Chen';
  }
  if (member.department == 'Human Resources') {
    return 'Nadia Rahman';
  }
  if (member.department == 'Marketing') {
    return 'Emma Rodriguez';
  }
  return member.manager;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
