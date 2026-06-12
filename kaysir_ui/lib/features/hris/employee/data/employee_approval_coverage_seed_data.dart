import '../models/employee_approval_coverage_models.dart';
import '../models/employee_directory_models.dart';

EmployeeApprovalCoverageProfile buildEmployeeApprovalCoverageProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeApprovalCoverageProfile(
    employeeId: member.id,
    employeeName: member.name,
    manager: member.manager,
    asOfDate: today,
    delegations: _delegationsFor(member: member, today: today),
  );
}

List<EmployeeApprovalDelegation> _delegationsFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _delegation(
        id: '${member.id}-coverage-timeoff',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.timeOff,
        primaryApprover: member.manager,
        delegateApprover: 'HR Business Partner',
        startDate: today.subtract(const Duration(days: 5)),
        endDate: today.add(const Duration(days: 7)),
        status: EmployeeApprovalCoverageStatus.blocked,
        risk: EmployeeApprovalCoverageRisk.high,
        reason: 'Manager review conflict requires alternate approver.',
      ),
      _delegation(
        id: '${member.id}-coverage-expense',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.expense,
        primaryApprover: member.manager,
        delegateApprover: 'Finance Operations',
        startDate: today,
        endDate: today.add(const Duration(days: 30)),
        status: EmployeeApprovalCoverageStatus.pending,
        risk: EmployeeApprovalCoverageRisk.medium,
        reason: 'Expense approvals need backup during performance review.',
      ),
      _delegation(
        id: '${member.id}-coverage-access',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.access,
        primaryApprover: member.manager,
        delegateApprover: 'IT Security',
        startDate: today.subtract(const Duration(days: 60)),
        endDate: today.subtract(const Duration(days: 1)),
        status: EmployeeApprovalCoverageStatus.expired,
        risk: EmployeeApprovalCoverageRisk.high,
        reason: 'Access approval coverage expired yesterday.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _delegation(
        id: '${member.id}-coverage-docs',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.documents,
        primaryApprover: member.manager,
        delegateApprover: 'People Operations',
        startDate: today,
        endDate: today.add(const Duration(days: 21)),
        status: EmployeeApprovalCoverageStatus.pending,
        risk: EmployeeApprovalCoverageRisk.medium,
        reason: 'Onboarding document approvals need HR coverage.',
      ),
      _delegation(
        id: '${member.id}-coverage-access',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.access,
        primaryApprover: member.manager,
        delegateApprover: 'IT Operations',
        startDate: today,
        endDate: today.add(const Duration(days: 45)),
        status: EmployeeApprovalCoverageStatus.active,
        risk: EmployeeApprovalCoverageRisk.low,
        reason: 'New hire access approvals have active backup coverage.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      _delegation(
        id: '${member.id}-coverage-performance',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.performance,
        primaryApprover: member.manager,
        delegateApprover: 'Talent Management',
        startDate: today,
        endDate: today.add(const Duration(days: 10)),
        status: EmployeeApprovalCoverageStatus.active,
        risk: EmployeeApprovalCoverageRisk.medium,
        reason: 'Talent calibration requires alternate performance approver.',
      ),
      _delegation(
        id: '${member.id}-coverage-payroll',
        employeeId: member.id,
        area: EmployeeApprovalCoverageArea.payroll,
        primaryApprover: member.manager,
        delegateApprover: 'Compensation',
        startDate: today,
        endDate: today.add(const Duration(days: 35)),
        status: EmployeeApprovalCoverageStatus.active,
        risk: EmployeeApprovalCoverageRisk.low,
        reason: 'Promotion planning has payroll approval coverage.',
      ),
    ];
  }

  return [
    _delegation(
      id: '${member.id}-coverage-timeoff',
      employeeId: member.id,
      area: EmployeeApprovalCoverageArea.timeOff,
      primaryApprover: member.manager,
      delegateApprover: 'People Operations',
      startDate: today,
      endDate: today.add(const Duration(days: 90)),
      status: EmployeeApprovalCoverageStatus.active,
      risk: EmployeeApprovalCoverageRisk.low,
      reason: 'Standard leave approvals have fallback coverage.',
    ),
  ];
}

EmployeeApprovalDelegation _delegation({
  required String id,
  required String employeeId,
  required EmployeeApprovalCoverageArea area,
  required String primaryApprover,
  required String delegateApprover,
  required DateTime startDate,
  required DateTime endDate,
  required EmployeeApprovalCoverageStatus status,
  required EmployeeApprovalCoverageRisk risk,
  required String reason,
}) {
  return EmployeeApprovalDelegation(
    id: id,
    employeeId: employeeId,
    area: area,
    primaryApprover: primaryApprover,
    delegateApprover: delegateApprover,
    startDate: _dateOnly(startDate),
    endDate: _dateOnly(endDate),
    status: status,
    risk: risk,
    reason: reason,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
