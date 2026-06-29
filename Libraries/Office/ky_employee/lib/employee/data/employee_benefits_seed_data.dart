import '../models/employee_benefits_models.dart';
import '../models/employee_directory_models.dart';

EmployeeBenefitsProfile buildEmployeeBenefitsProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeBenefitsProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    enrollments: _enrollmentsFor(member, asOfDate),
    dependents: _dependentsFor(member, asOfDate),
  );
}

EmployeeDependentDraft buildEmployeeDependentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeeDependentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    fullName: '',
    relationship: EmployeeDependentRelationship.child,
    birthDate: null,
    eligibleForCoverage: true,
  );
}

List<EmployeeBenefitEnrollment> _enrollmentsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final onboarding = member.status == EmployeeDirectoryStatus.onboarding;
  final highPerformer = member.isHighPerformer;

  return [
    EmployeeBenefitEnrollment(
      id: '${member.id}-benefit-medical',
      employeeId: member.id,
      type: EmployeeBenefitPlanType.medical,
      planName: 'Kaysir Health Plus',
      provider: 'MediCare Global',
      coverageTier:
          highPerformer
              ? EmployeeBenefitCoverageTier.family
              : EmployeeBenefitCoverageTier.employeeOnly,
      monthlyEmployerContribution: highPerformer ? 420 : 330,
      monthlyEmployeeContribution: highPerformer ? 140 : 80,
      effectiveDate: member.joiningDate,
      renewalDate: today.add(const Duration(days: 185)),
      status:
          onboarding
              ? EmployeeBenefitEnrollmentStatus.actionRequired
              : EmployeeBenefitEnrollmentStatus.active,
    ),
    EmployeeBenefitEnrollment(
      id: '${member.id}-benefit-retirement',
      employeeId: member.id,
      type: EmployeeBenefitPlanType.retirement,
      planName: 'Retirement Saver 5%',
      provider: 'FutureFund',
      coverageTier: EmployeeBenefitCoverageTier.employeeOnly,
      monthlyEmployerContribution: highPerformer ? 260 : 180,
      monthlyEmployeeContribution: highPerformer ? 260 : 180,
      effectiveDate: member.joiningDate,
      renewalDate: today.add(const Duration(days: 365)),
      status:
          onboarding
              ? EmployeeBenefitEnrollmentStatus.pending
              : EmployeeBenefitEnrollmentStatus.active,
    ),
    EmployeeBenefitEnrollment(
      id: '${member.id}-benefit-wellness',
      employeeId: member.id,
      type: EmployeeBenefitPlanType.wellness,
      planName: 'Wellbeing stipend',
      provider: 'People Ops',
      coverageTier: EmployeeBenefitCoverageTier.employeeOnly,
      monthlyEmployerContribution: 45,
      monthlyEmployeeContribution: 0,
      effectiveDate: today.subtract(const Duration(days: 30)),
      renewalDate: today.add(const Duration(days: 90)),
      status:
          member.status == EmployeeDirectoryStatus.watchlist
              ? EmployeeBenefitEnrollmentStatus.actionRequired
              : EmployeeBenefitEnrollmentStatus.active,
    ),
  ];
}

List<EmployeeDependentRecord> _dependentsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);

  if (member.id == '1') {
    return [
      EmployeeDependentRecord(
        id: '1-dependent-spouse',
        employeeId: member.id,
        fullName: 'Alex Johnson',
        relationship: EmployeeDependentRelationship.spouse,
        birthDate: DateTime(1991, 8, 12),
        verificationStatus: EmployeeDependentVerificationStatus.verified,
        eligibleForCoverage: true,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeDependentRecord(
        id: '${member.id}-dependent-child',
        employeeId: member.id,
        fullName: 'Avery Wilson',
        relationship: EmployeeDependentRelationship.child,
        birthDate: today.subtract(const Duration(days: 365 * 8)),
        verificationStatus: EmployeeDependentVerificationStatus.pending,
        eligibleForCoverage: true,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeDependentRecord(
        id: '${member.id}-dependent-spouse',
        employeeId: member.id,
        fullName: '${member.name.split(' ').first} household',
        relationship: EmployeeDependentRelationship.spouse,
        birthDate: DateTime(1990, 3, 20),
        verificationStatus: EmployeeDependentVerificationStatus.verified,
        eligibleForCoverage: true,
      ),
    ];
  }

  return const [];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
