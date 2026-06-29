import '../models/employee_development_models.dart';
import '../models/employee_directory_models.dart';

EmployeeDevelopmentPlan buildEmployeeDevelopmentPlan({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeDevelopmentPlan(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    skills: _skillsFor(member),
    learning: _learningFor(member, asOfDate),
    certifications: _certificationsFor(member, asOfDate),
  );
}

EmployeeLearningAssignmentDraft buildEmployeeLearningAssignmentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeLearningAssignmentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    title: '',
    provider: 'People Academy',
    skillFocus: _primarySkill(member),
    dueDate: _dateOnly(asOfDate).add(const Duration(days: 21)),
  );
}

List<EmployeeSkillTarget> _skillsFor(EmployeeDirectoryMember member) {
  final primarySkill = _primarySkill(member);
  final secondarySkill = _secondarySkill(member);
  final isAtRisk = member.status == EmployeeDirectoryStatus.watchlist;
  final isHighPerformer = member.isHighPerformer;

  return [
    EmployeeSkillTarget(
      id: '${member.id}-skill-primary',
      employeeId: member.id,
      skill: primarySkill,
      mentor: member.manager,
      currentLevel:
          isAtRisk
              ? 2
              : isHighPerformer
              ? 4
              : 3,
      targetLevel: isHighPerformer ? 5 : 4,
      status:
          isAtRisk
              ? EmployeeSkillStatus.gap
              : isHighPerformer
              ? EmployeeSkillStatus.proficient
              : EmployeeSkillStatus.building,
    ),
    EmployeeSkillTarget(
      id: '${member.id}-skill-secondary',
      employeeId: member.id,
      skill: secondarySkill,
      mentor: 'People Academy',
      currentLevel: isAtRisk ? 2 : 3,
      targetLevel: 4,
      status: isAtRisk ? EmployeeSkillStatus.gap : EmployeeSkillStatus.building,
    ),
  ];
}

List<EmployeeLearningAssignment> _learningFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final atRisk = member.status == EmployeeDirectoryStatus.watchlist;

  return [
    EmployeeLearningAssignment(
      id: '${member.id}-learn-primary',
      employeeId: member.id,
      title: _learningTitle(member),
      provider: 'People Academy',
      skillFocus: _primarySkill(member),
      dueDate:
          atRisk
              ? today.subtract(const Duration(days: 2))
              : today.add(const Duration(days: 18)),
      progress:
          atRisk
              ? 0.35
              : member.isHighPerformer
              ? 0.82
              : 0.56,
      status:
          atRisk
              ? EmployeeLearningStatus.overdue
              : EmployeeLearningStatus.inProgress,
    ),
    EmployeeLearningAssignment(
      id: '${member.id}-learn-coaching',
      employeeId: member.id,
      title: 'Manager coaching and practice plan',
      provider: member.manager,
      skillFocus: _secondarySkill(member),
      dueDate: today.add(const Duration(days: 35)),
      progress: member.isHighPerformer ? 1 : 0.42,
      status:
          member.isHighPerformer
              ? EmployeeLearningStatus.completed
              : EmployeeLearningStatus.inProgress,
    ),
  ];
}

List<EmployeeCertificationTarget> _certificationsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final certification = switch (member.department) {
    'Engineering' => 'Cloud Security Foundation',
    'Human Resources' => 'HR Data Privacy',
    'Product' => 'Product Analytics Practitioner',
    'Design' => 'Design Systems Practitioner',
    _ => 'Workplace Safety Lead',
  };

  return [
    EmployeeCertificationTarget(
      id: '${member.id}-cert-primary',
      employeeId: member.id,
      name: certification,
      authority: 'People Academy',
      expiryDate:
          member.status == EmployeeDirectoryStatus.watchlist
              ? today.add(const Duration(days: 20))
              : today.add(const Duration(days: 160)),
      status:
          member.status == EmployeeDirectoryStatus.watchlist
              ? EmployeeCertificationStatus.expiring
              : EmployeeCertificationStatus.active,
    ),
  ];
}

String _primarySkill(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Flutter architecture',
    'Design' => 'Design systems',
    'Product' => 'Roadmap analytics',
    'Human Resources' => 'HR operations governance',
    _ => 'Operational excellence',
  };
}

String _secondarySkill(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Production readiness',
    'Design' => 'Research synthesis',
    'Product' => 'Stakeholder alignment',
    'Human Resources' => 'Employee relations',
    _ => 'Team collaboration',
  };
}

String _learningTitle(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Platform engineering readiness',
    'Design' => 'Design system quality sprint',
    'Product' => 'Roadmap execution accelerator',
    'Human Resources' => 'HR operations excellence',
    _ => 'Role capability growth plan',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
