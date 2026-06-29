import '../models/employee_approval_policy_models.dart';
import '../models/employee_directory_models.dart';

EmployeeApprovalPolicyProfile buildEmployeeApprovalPolicyProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeApprovalPolicyProfile(
    employeeId: member.id,
    employeeName: member.name,
    department: member.department,
    manager: member.manager,
    asOfDate: today,
    rules: _rulesFor(member: member, today: today),
  );
}

EmployeeApprovalPolicyRuleDraft buildEmployeeApprovalPolicyRuleDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeApprovalPolicyRuleDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

List<EmployeeApprovalPolicyRule> _rulesFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  final rules = <EmployeeApprovalPolicyRule>[
    _rule(
      id: '${member.id}-policy-timeoff',
      employeeId: member.id,
      area: EmployeeApprovalPolicyArea.timeOff,
      name: 'Standard time-off routing',
      primaryRoute: EmployeeApprovalRoute.directManager,
      fallbackRoute: EmployeeApprovalRoute.hrBusinessPartner,
      owner: 'People Operations',
      thresholdLabel: 'Any paid leave request',
      escalationHours: 24,
      escalationMode: EmployeeApprovalEscalationMode.fallbackDelegate,
      expiresOn: today.add(const Duration(days: 90)),
      status: EmployeeApprovalPolicyStatus.active,
      risk: EmployeeApprovalPolicyRisk.low,
      notes: 'Standard leave requests route through manager with HR fallback.',
    ),
  ];

  if (member.status == EmployeeDirectoryStatus.watchlist) {
    rules.addAll([
      _rule(
        id: '${member.id}-policy-expense-exception',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.expense,
        name: 'High-risk expense exception routing',
        primaryRoute: EmployeeApprovalRoute.financePartner,
        fallbackRoute: EmployeeApprovalRoute.executiveSponsor,
        owner: 'Finance Operations',
        thresholdLabel: 'Expenses above recovery-plan budget',
        escalationHours: 8,
        escalationMode: EmployeeApprovalEscalationMode.holdQueue,
        expiresOn: today.subtract(const Duration(days: 1)),
        status: EmployeeApprovalPolicyStatus.reviewRequired,
        risk: EmployeeApprovalPolicyRisk.high,
        notes: 'Expense exceptions must be recalibrated for recovery plan.',
      ),
      _rule(
        id: '${member.id}-policy-access-suspended',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.access,
        name: 'Privileged access approval hold',
        primaryRoute: EmployeeApprovalRoute.securityOwner,
        fallbackRoute: EmployeeApprovalRoute.hrBusinessPartner,
        owner: 'IT Security',
        thresholdLabel: 'Privileged access changes',
        escalationHours: 4,
        escalationMode: EmployeeApprovalEscalationMode.holdQueue,
        expiresOn: today.add(const Duration(days: 30)),
        status: EmployeeApprovalPolicyStatus.suspended,
        risk: EmployeeApprovalPolicyRisk.high,
        notes:
            'Privileged access approval is suspended until ownership review.',
      ),
    ]);
  } else if (member.id == '2') {
    rules.addAll([
      _rule(
        id: '${member.id}-policy-compensation',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.compensation,
        name: 'Promotion compensation routing',
        primaryRoute: EmployeeApprovalRoute.departmentHead,
        fallbackRoute: EmployeeApprovalRoute.hrBusinessPartner,
        owner: 'Talent Operations',
        thresholdLabel: 'Promotion package and allowance changes',
        escalationHours: 24,
        escalationMode: EmployeeApprovalEscalationMode.autoEscalate,
        expiresOn: today.add(const Duration(days: 21)),
        status: EmployeeApprovalPolicyStatus.draft,
        risk: EmployeeApprovalPolicyRisk.high,
        notes: 'Promotion compensation path is drafted for upcoming move.',
      ),
      _rule(
        id: '${member.id}-policy-job-change',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.jobChange,
        name: 'Growth move approval routing',
        primaryRoute: EmployeeApprovalRoute.departmentHead,
        fallbackRoute: EmployeeApprovalRoute.executiveSponsor,
        owner: 'People Operations',
        thresholdLabel: 'Role and manager changes',
        escalationHours: 48,
        escalationMode: EmployeeApprovalEscalationMode.autoEscalate,
        expiresOn: today.add(const Duration(days: 10)),
        status: EmployeeApprovalPolicyStatus.active,
        risk: EmployeeApprovalPolicyRisk.medium,
        notes: 'Growth-track job changes route through engineering leadership.',
      ),
    ]);
  } else if (member.status == EmployeeDirectoryStatus.onboarding) {
    rules.add(
      _rule(
        id: '${member.id}-policy-documents',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.documents,
        name: 'New hire document approval',
        primaryRoute: EmployeeApprovalRoute.hrBusinessPartner,
        fallbackRoute: EmployeeApprovalRoute.directManager,
        owner: 'HR Operations',
        thresholdLabel: 'Onboarding documents and profile changes',
        escalationHours: 24,
        escalationMode: EmployeeApprovalEscalationMode.notifyOnly,
        expiresOn: today.add(const Duration(days: 45)),
        status: EmployeeApprovalPolicyStatus.reviewRequired,
        risk: EmployeeApprovalPolicyRisk.medium,
        notes: 'New hire document approval needs onboarding checkpoint review.',
      ),
    );
  } else if (member.isHighPerformer) {
    rules.add(
      _rule(
        id: '${member.id}-policy-performance',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.performance,
        name: 'Performance exception routing',
        primaryRoute: EmployeeApprovalRoute.departmentHead,
        fallbackRoute: EmployeeApprovalRoute.hrBusinessPartner,
        owner: 'Talent Operations',
        thresholdLabel: 'Calibration and retention exceptions',
        escalationHours: 48,
        escalationMode: EmployeeApprovalEscalationMode.autoEscalate,
        expiresOn: today.add(const Duration(days: 12)),
        status: EmployeeApprovalPolicyStatus.active,
        risk: EmployeeApprovalPolicyRisk.medium,
        notes: 'Performance exceptions are active for high performer review.',
      ),
    );
  } else {
    rules.add(
      _rule(
        id: '${member.id}-policy-payroll',
        employeeId: member.id,
        area: EmployeeApprovalPolicyArea.payroll,
        name: 'Payroll correction routing',
        primaryRoute: EmployeeApprovalRoute.hrBusinessPartner,
        fallbackRoute: EmployeeApprovalRoute.financePartner,
        owner: 'Payroll',
        thresholdLabel: 'Payroll correction requests',
        escalationHours: 72,
        escalationMode: EmployeeApprovalEscalationMode.notifyOnly,
        expiresOn: today.add(const Duration(days: 120)),
        status: EmployeeApprovalPolicyStatus.active,
        risk: EmployeeApprovalPolicyRisk.low,
        notes: 'Payroll corrections route through HR then payroll partner.',
      ),
    );
  }

  return rules;
}

EmployeeApprovalPolicyRule _rule({
  required String id,
  required String employeeId,
  required EmployeeApprovalPolicyArea area,
  required String name,
  required EmployeeApprovalRoute primaryRoute,
  required EmployeeApprovalRoute fallbackRoute,
  required String owner,
  required String thresholdLabel,
  required int escalationHours,
  required EmployeeApprovalEscalationMode escalationMode,
  required DateTime expiresOn,
  required EmployeeApprovalPolicyStatus status,
  required EmployeeApprovalPolicyRisk risk,
  required String notes,
}) {
  return EmployeeApprovalPolicyRule(
    id: id,
    employeeId: employeeId,
    area: area,
    name: name,
    primaryRoute: primaryRoute,
    fallbackRoute: fallbackRoute,
    owner: owner,
    thresholdLabel: thresholdLabel,
    escalationHours: escalationHours,
    escalationMode: escalationMode,
    expiresOn: _dateOnly(expiresOn),
    status: status,
    risk: risk,
    notes: notes,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
