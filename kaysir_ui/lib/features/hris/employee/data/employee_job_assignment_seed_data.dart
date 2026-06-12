import '../models/employee_directory_models.dart';
import '../models/employee_job_assignment_models.dart';

EmployeeJobAssignmentProfile buildEmployeeJobAssignmentProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final assignments = _assignmentsFor(member, today);

  return EmployeeJobAssignmentProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    assignments: assignments,
  );
}

EmployeeJobAssignmentDraft buildEmployeeJobAssignmentDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final current = _currentAssignmentFor(member, today);

  return EmployeeJobAssignmentDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    currentPosition: current.position,
    currentDepartment: current.department,
    currentManager: current.manager,
    currentLocation: current.location,
    currentCostCenter: current.costCenter,
    currentGrade: current.grade,
    currentContractType: current.contractType,
    currentArrangement: current.arrangement,
    position: current.position,
    department: current.department,
    manager: current.manager,
    location: current.location,
    costCenter: current.costCenter,
    grade: current.grade,
    contractType: current.contractType,
    arrangement: current.arrangement,
    assignmentType: EmployeeJobAssignmentType.primary,
    startDate: today.add(const Duration(days: 14)),
    notes: '',
  );
}

List<EmployeeJobAssignmentRecord> _assignmentsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final current = _currentAssignmentFor(member, today);
  final assignments = <EmployeeJobAssignmentRecord>[current];

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    assignments.add(
      EmployeeJobAssignmentRecord(
        id: 'EJA-${member.id}-002',
        employeeId: member.id,
        position: member.position,
        department: member.department,
        manager: member.manager,
        location: member.location,
        costCenter: _costCenterFor(member.department),
        grade: 'P2',
        contractType: EmployeeEmploymentContractType.permanent,
        arrangement: _arrangementFor(member.location),
        assignmentType: EmployeeJobAssignmentType.primary,
        startDate: today.add(const Duration(days: 21)),
        endDate: null,
        status: EmployeeJobAssignmentStatus.pendingApproval,
        notes: 'Confirm probation outcomes before permanent assignment.',
      ),
    );
  } else if (member.status == EmployeeDirectoryStatus.watchlist) {
    assignments.add(
      EmployeeJobAssignmentRecord(
        id: 'EJA-${member.id}-002',
        employeeId: member.id,
        position: 'Product Delivery Lead',
        department: member.department,
        manager: member.manager,
        location: member.location,
        costCenter: _costCenterFor(member.department),
        grade: _gradeFor(member),
        contractType: EmployeeEmploymentContractType.permanent,
        arrangement: _arrangementFor(member.location),
        assignmentType: EmployeeJobAssignmentType.acting,
        startDate: today.add(const Duration(days: 10)),
        endDate: null,
        status: EmployeeJobAssignmentStatus.pendingApproval,
        notes: 'Temporary delivery assignment pending HRBP review.',
      ),
    );
  } else if (member.isHighPerformer) {
    assignments.add(
      EmployeeJobAssignmentRecord(
        id: 'EJA-${member.id}-002',
        employeeId: member.id,
        position: 'Senior ${member.position}',
        department: member.department,
        manager: member.manager,
        location: member.location,
        costCenter: _costCenterFor(member.department),
        grade: _nextGradeFor(member),
        contractType: EmployeeEmploymentContractType.permanent,
        arrangement: _arrangementFor(member.location),
        assignmentType: EmployeeJobAssignmentType.primary,
        startDate: today.add(const Duration(days: 30)),
        endDate: null,
        status: EmployeeJobAssignmentStatus.scheduled,
        notes: 'Growth assignment prepared after performance calibration.',
      ),
    );
  }

  return assignments;
}

EmployeeJobAssignmentRecord _currentAssignmentFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final contractType =
      member.status == EmployeeDirectoryStatus.onboarding
          ? EmployeeEmploymentContractType.probationary
          : EmployeeEmploymentContractType.permanent;
  final assignmentType =
      member.status == EmployeeDirectoryStatus.onboarding
          ? EmployeeJobAssignmentType.probation
          : EmployeeJobAssignmentType.primary;

  return EmployeeJobAssignmentRecord(
    id: 'EJA-${member.id}-001',
    employeeId: member.id,
    position: member.position,
    department: member.department,
    manager: member.manager,
    location: member.location,
    costCenter: _costCenterFor(member.department),
    grade: _gradeFor(member),
    contractType: contractType,
    arrangement: _arrangementFor(member.location),
    assignmentType: assignmentType,
    startDate: _dateOnly(member.joiningDate),
    endDate: null,
    status: EmployeeJobAssignmentStatus.active,
    notes: 'Current assignment synchronized from employee directory profile.',
  );
}

String _costCenterFor(String department) {
  return switch (department) {
    'Design' => 'DES-210',
    'Engineering' => 'ENG-100',
    'Human Resources' => 'HR-300',
    'Product' => 'PRD-220',
    'Marketing' => 'MKT-150',
    _ => 'COR-000',
  };
}

String _gradeFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.onboarding) return 'P1';
  if (member.performance >= 4.8) return 'P5';
  if (member.performance >= 4.6) return 'P4';
  return 'P3';
}

String _nextGradeFor(EmployeeDirectoryMember member) {
  return switch (_gradeFor(member)) {
    'P1' => 'P2',
    'P2' => 'P3',
    'P3' => 'P4',
    'P4' => 'P5',
    _ => 'P6',
  };
}

EmployeeWorkArrangement _arrangementFor(String location) {
  return switch (location) {
    'Singapore' => EmployeeWorkArrangement.remote,
    'Surabaya' => EmployeeWorkArrangement.onsite,
    _ => EmployeeWorkArrangement.hybrid,
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
