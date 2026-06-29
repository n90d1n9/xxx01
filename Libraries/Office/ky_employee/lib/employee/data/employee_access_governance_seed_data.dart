import '../models/employee_access_governance_models.dart';
import '../models/employee_directory_models.dart';

EmployeeAccessGovernanceProfile buildEmployeeAccessGovernanceProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeAccessGovernanceProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    reviews: _reviewsFor(member, today),
  );
}

EmployeeAccessGovernanceDraft buildEmployeeAccessGovernanceDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeAccessGovernanceDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    systemName: 'Kaysir workspace',
    roleName: 'Standard employee',
    scope: EmployeeAccessGovernanceScope.productivity,
    risk: EmployeeAccessGovernanceRisk.standard,
    owner: 'IT Security',
    reviewer: member.manager,
    dueDate: today.add(const Duration(days: 7)),
    businessJustification: '',
  );
}

List<EmployeeAccessGovernanceReview> _reviewsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeAccessGovernanceReview(
        id: 'EAG-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        systemName: 'Kaysir Admin',
        roleName: 'Product administrator',
        scope: EmployeeAccessGovernanceScope.admin,
        risk: EmployeeAccessGovernanceRisk.privilegedAccess,
        owner: 'Platform Security',
        reviewer: member.manager,
        grantedAt: today.subtract(const Duration(days: 180)),
        dueDate: today.subtract(const Duration(days: 1)),
        reviewedAt: null,
        businessJustification: 'Privileged access for product release support.',
        status: EmployeeAccessGovernanceStatus.dueReview,
      ),
      EmployeeAccessGovernanceReview(
        id: 'EAG-${member.id}-002',
        employeeId: member.id,
        employeeName: member.name,
        systemName: 'Finance Workspace',
        roleName: 'Expense approver',
        scope: EmployeeAccessGovernanceScope.finance,
        risk: EmployeeAccessGovernanceRisk.separationOfDuties,
        owner: 'Finance Operations',
        reviewer: 'IT Security',
        grantedAt: today.subtract(const Duration(days: 120)),
        dueDate: today.add(const Duration(days: 2)),
        reviewedAt: null,
        businessJustification:
            'Temporary expense approval access needs removal.',
        status: EmployeeAccessGovernanceStatus.revokeRequested,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeAccessGovernanceReview(
        id: 'EAG-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        systemName: 'HRIS Self Service',
        roleName: 'Employee self service',
        scope: EmployeeAccessGovernanceScope.hris,
        risk: EmployeeAccessGovernanceRisk.standard,
        owner: 'People Operations',
        reviewer: member.manager,
        grantedAt: today,
        dueDate: today.add(const Duration(days: 3)),
        reviewedAt: null,
        businessJustification: 'Confirm onboarding self-service permissions.',
        status: EmployeeAccessGovernanceStatus.dueReview,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeAccessGovernanceReview(
        id: 'EAG-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        systemName: 'Design Studio',
        roleName: 'Design lead',
        scope: EmployeeAccessGovernanceScope.productivity,
        risk: EmployeeAccessGovernanceRisk.standard,
        owner: 'IT Security',
        reviewer: member.manager,
        grantedAt: today.subtract(const Duration(days: 240)),
        dueDate: today.add(const Duration(days: 60)),
        reviewedAt: today.subtract(const Duration(days: 30)),
        businessJustification: 'Approved design leadership workspace access.',
        status: EmployeeAccessGovernanceStatus.approved,
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
