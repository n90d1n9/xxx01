import '../models/employee_directory_models.dart';
import '../models/employee_succession_plan_models.dart';

EmployeeSuccessionProfile buildEmployeeSuccessionProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeeSuccessionProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    incumbentRole: member.position,
    department: member.department,
    manager: member.manager,
    criticality: _criticalityFor(member),
    coverageOwner: _coverageOwnerFor(member),
    reviewDate: _reviewDateFor(member, today),
    candidates: _candidatesFor(member: member, today: today),
  );
}

EmployeeSuccessionCandidateDraft buildEmployeeSuccessionCandidateDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeSuccessionCandidateDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

EmployeeSuccessionCriticality _criticalityFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeSuccessionCriticality.critical;
  }
  if (member.isHighPerformer) {
    return EmployeeSuccessionCriticality.high;
  }
  if (member.department == 'Human Resources') {
    return EmployeeSuccessionCriticality.high;
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeSuccessionCriticality.low;
  }
  return EmployeeSuccessionCriticality.medium;
}

String _coverageOwnerFor(EmployeeDirectoryMember member) {
  if (member.department == 'Engineering') return 'Engineering Talent Council';
  if (member.department == 'Human Resources') return 'People Leadership Team';
  if (member.department == 'Product') return 'Product Talent Council';
  return member.manager;
}

DateTime _reviewDateFor(EmployeeDirectoryMember member, DateTime today) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.subtract(const Duration(days: 1));
  }
  if (member.isHighPerformer) {
    return today.add(const Duration(days: 21));
  }
  if (member.department == 'Human Resources') {
    return today.add(const Duration(days: 14));
  }
  return today.add(const Duration(days: 45));
}

List<EmployeeSuccessionCandidate> _candidatesFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _candidate(
        id: '${member.id}-succession-hana',
        employeeId: member.id,
        name: 'Hana Prasetyo',
        currentRole: 'Associate Product Manager',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.developing,
        risk: EmployeeSuccessionRisk.high,
        actionType: EmployeeSuccessionActionType.knowledgeTransfer,
        owner: member.manager,
        reviewDate: today.subtract(const Duration(days: 2)),
        benchScore: 52,
        notes: 'Needs roadmap ownership shadowing before critical coverage.',
      ),
      _candidate(
        id: '${member.id}-succession-noah',
        employeeId: member.id,
        name: 'Noah Patel',
        currentRole: 'Senior Product Analyst',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.readySoon,
        risk: EmployeeSuccessionRisk.medium,
        actionType: EmployeeSuccessionActionType.talentReview,
        owner: 'Product Talent Council',
        reviewDate: today.add(const Duration(days: 14)),
        benchScore: 68,
        notes: 'Strong discovery skills; needs stakeholder calibration.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      _candidate(
        id: '${member.id}-succession-aisha',
        employeeId: member.id,
        name: 'Aisha Rahman',
        currentRole: 'Staff Developer',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.readyNow,
        risk: EmployeeSuccessionRisk.low,
        actionType: EmployeeSuccessionActionType.retentionCheck,
        owner: 'Engineering Talent Council',
        reviewDate: today.add(const Duration(days: 28)),
        benchScore: 88,
        notes: 'Ready for interim ownership if leadership coverage changes.',
      ),
      _candidate(
        id: '${member.id}-succession-daniel',
        employeeId: member.id,
        name: 'Daniel Lee',
        currentRole: 'Senior Developer',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.readySoon,
        risk: EmployeeSuccessionRisk.medium,
        actionType: EmployeeSuccessionActionType.developmentPlan,
        owner: member.manager,
        reviewDate: today.add(const Duration(days: 35)),
        benchScore: 74,
        notes: 'Needs production incident commander rotation.',
      ),
    ];
  }

  if (member.department == 'Human Resources') {
    return [
      _candidate(
        id: '${member.id}-succession-nadia',
        employeeId: member.id,
        name: 'Nadia Rahman',
        currentRole: 'HR Business Partner',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.readyNow,
        risk: EmployeeSuccessionRisk.medium,
        actionType: EmployeeSuccessionActionType.compensationReview,
        owner: 'People Leadership Team',
        reviewDate: today.add(const Duration(days: 12)),
        benchScore: 82,
        notes: 'Ready with compensation committee exposure.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _candidate(
        id: '${member.id}-succession-rina',
        employeeId: member.id,
        name: 'Rina Lestari',
        currentRole: 'Marketing Coordinator',
        targetRole: member.position,
        readiness: EmployeeSuccessionReadiness.developing,
        risk: EmployeeSuccessionRisk.medium,
        actionType: EmployeeSuccessionActionType.developmentPlan,
        owner: member.manager,
        reviewDate: today.add(const Duration(days: 60)),
        benchScore: 48,
        notes: 'Early bench signal only; revisit after onboarding ramp.',
      ),
    ];
  }

  return [
    _candidate(
      id: '${member.id}-succession-default',
      employeeId: member.id,
      name: 'Maya Santoso',
      currentRole: 'Senior ${member.position}',
      targetRole: member.position,
      readiness: EmployeeSuccessionReadiness.readySoon,
      risk: EmployeeSuccessionRisk.low,
      actionType: EmployeeSuccessionActionType.talentReview,
      owner: member.manager,
      reviewDate: today.add(const Duration(days: 30)),
      benchScore: 72,
      notes: 'Coverage candidate is tracking toward next review.',
    ),
  ];
}

EmployeeSuccessionCandidate _candidate({
  required String id,
  required String employeeId,
  required String name,
  required String currentRole,
  required String targetRole,
  required EmployeeSuccessionReadiness readiness,
  required EmployeeSuccessionRisk risk,
  required EmployeeSuccessionActionType actionType,
  required String owner,
  required DateTime reviewDate,
  required int benchScore,
  required String notes,
}) {
  return EmployeeSuccessionCandidate(
    id: id,
    employeeId: employeeId,
    name: name,
    currentRole: currentRole,
    targetRole: targetRole,
    readiness: readiness,
    risk: risk,
    actionType: actionType,
    owner: owner,
    reviewDate: _dateOnly(reviewDate),
    benchScore: benchScore,
    notes: notes,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
