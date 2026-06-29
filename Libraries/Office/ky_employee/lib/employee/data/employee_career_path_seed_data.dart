import '../models/employee_career_path_models.dart';
import '../models/employee_directory_models.dart';

EmployeeCareerPathProfile buildEmployeeCareerPathProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeCareerPathProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    path: _pathFor(member, today),
    moves: _movesFor(member, today),
  );
}

EmployeeCareerMoveDraft buildEmployeeCareerMoveDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeCareerMoveDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeCareerMoveType.stretchAssignment,
    title: 'Career move proposal',
    sponsor: member.manager,
    targetRole: _targetRoleFor(member),
    targetDate: today.add(const Duration(days: 45)),
    summary: '',
  );
}

EmployeeCareerPathSnapshot _pathFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeCareerPathSnapshot(
      employeeId: member.id,
      employeeName: member.name,
      currentRole: member.position,
      targetRole: _targetRoleFor(member),
      sponsor: member.manager,
      readiness: EmployeeCareerReadiness.developing,
      mobilityPreference: EmployeeMobilityPreference.crossFunctional,
      successionCoverage: EmployeeSuccessionCoverage.uncovered,
      criticalRole: true,
      lastTalentReviewAt: today.subtract(const Duration(days: 110)),
      nextReviewDate: today.subtract(const Duration(days: 1)),
    );
  }

  if (member.isHighPerformer) {
    return EmployeeCareerPathSnapshot(
      employeeId: member.id,
      employeeName: member.name,
      currentRole: member.position,
      targetRole: _targetRoleFor(member),
      sponsor: member.manager,
      readiness: EmployeeCareerReadiness.readySoon,
      mobilityPreference: EmployeeMobilityPreference.managerTrack,
      successionCoverage: EmployeeSuccessionCoverage.partial,
      criticalRole: true,
      lastTalentReviewAt: today.subtract(const Duration(days: 28)),
      nextReviewDate: today.add(const Duration(days: 62)),
    );
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeCareerPathSnapshot(
      employeeId: member.id,
      employeeName: member.name,
      currentRole: member.position,
      targetRole: member.position,
      sponsor: member.manager,
      readiness: EmployeeCareerReadiness.exploratory,
      mobilityPreference: EmployeeMobilityPreference.sameTeam,
      successionCoverage: EmployeeSuccessionCoverage.notCritical,
      criticalRole: false,
      lastTalentReviewAt: today.subtract(const Duration(days: 10)),
      nextReviewDate: today.add(const Duration(days: 80)),
    );
  }

  return EmployeeCareerPathSnapshot(
    employeeId: member.id,
    employeeName: member.name,
    currentRole: member.position,
    targetRole: _targetRoleFor(member),
    sponsor: member.manager,
    readiness: EmployeeCareerReadiness.developing,
    mobilityPreference: EmployeeMobilityPreference.specialistTrack,
    successionCoverage: EmployeeSuccessionCoverage.notCritical,
    criticalRole: false,
    lastTalentReviewAt: today.subtract(const Duration(days: 45)),
    nextReviewDate: today.add(const Duration(days: 90)),
  );
}

List<EmployeeCareerMoveRequest> _movesFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeCareerMoveRequest(
        id: 'ECP-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeCareerMoveType.stretchAssignment,
        title: 'Roadmap recovery stretch assignment',
        sponsor: member.manager,
        targetRole: _targetRoleFor(member),
        targetDate: today.add(const Duration(days: 30)),
        status: EmployeeCareerMoveStatus.proposed,
        summary:
            'Validate readiness through a scoped roadmap recovery assignment.',
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeCareerMoveRequest(
        id: 'ECP-${member.id}-001',
        employeeId: member.id,
        employeeName: member.name,
        type: EmployeeCareerMoveType.promotion,
        title: 'Promotion readiness panel',
        sponsor: member.manager,
        targetRole: _targetRoleFor(member),
        targetDate: today.add(const Duration(days: 50)),
        status: EmployeeCareerMoveStatus.approved,
        summary: 'Panel approved readiness pending final transition planning.',
      ),
    ];
  }

  return const [];
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

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
