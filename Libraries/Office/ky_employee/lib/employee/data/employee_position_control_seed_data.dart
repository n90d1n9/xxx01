import '../models/employee_directory_models.dart';
import '../models/employee_position_control_models.dart';

EmployeePositionControlProfile buildEmployeePositionControlProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeePositionControlProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    position: _positionFor(member, today),
    requisitions: _requisitionsFor(member, today),
  );
}

EmployeePositionRequisitionDraft buildEmployeePositionRequisitionDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  return EmployeePositionRequisitionDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    type:
        watchlist
            ? EmployeePositionRequisitionType.backfill
            : EmployeePositionRequisitionType.newHeadcount,
    title: '',
    owner: member.manager,
    requestedFte: 1,
    targetStartDate: _dateOnly(asOfDate).add(const Duration(days: 30)),
    businessCase: '',
  );
}

EmployeePositionControlRecord _positionFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.id == '4') {
    return EmployeePositionControlRecord(
      id: '${member.id}-position-control',
      employeeId: member.id,
      positionCode: 'POS-PROD-004',
      title: member.position,
      department: member.department,
      costCenter: 'CC-PROD-110',
      grade: 'M3',
      hiringManager: member.manager,
      approvedFte: 1,
      filledFte: 1,
      budgetedMonthlyCost: 6800,
      actualMonthlyCost: 7450,
      status: EmployeePositionStatus.filled,
      budgetStatus: EmployeePositionBudgetStatus.overBudget,
      criticality: EmployeePositionCriticality.critical,
      vacancySince: null,
      nextReviewDate: today.subtract(const Duration(days: 1)),
    );
  }

  if (member.id == '5') {
    return EmployeePositionControlRecord(
      id: '${member.id}-position-control',
      employeeId: member.id,
      positionCode: 'POS-MKT-005',
      title: member.position,
      department: member.department,
      costCenter: 'CC-MKT-240',
      grade: 'S2',
      hiringManager: member.manager,
      approvedFte: 1,
      filledFte: 0.5,
      budgetedMonthlyCost: 4200,
      actualMonthlyCost: 2100,
      status: EmployeePositionStatus.backfillPending,
      budgetStatus: EmployeePositionBudgetStatus.inBudget,
      criticality: EmployeePositionCriticality.standard,
      vacancySince: today.subtract(const Duration(days: 21)),
      nextReviewDate: today.add(const Duration(days: 14)),
    );
  }

  final highPerformer = member.isHighPerformer;
  return EmployeePositionControlRecord(
    id: '${member.id}-position-control',
    employeeId: member.id,
    positionCode:
        'POS-${member.department.substring(0, 3).toUpperCase()}-${member.id.padLeft(3, '0')}',
    title: member.position,
    department: member.department,
    costCenter: _costCenterFor(member.department),
    grade: highPerformer ? 'S4' : 'S3',
    hiringManager: member.manager,
    approvedFte: 1,
    filledFte: 1,
    budgetedMonthlyCost: highPerformer ? 7200 : 5600,
    actualMonthlyCost: highPerformer ? 7100 : 5500,
    status: EmployeePositionStatus.filled,
    budgetStatus: EmployeePositionBudgetStatus.inBudget,
    criticality:
        highPerformer
            ? EmployeePositionCriticality.high
            : EmployeePositionCriticality.standard,
    vacancySince: null,
    nextReviewDate: today.add(const Duration(days: 90)),
  );
}

List<EmployeePositionRequisition> _requisitionsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.id == '4') {
    return [
      EmployeePositionRequisition(
        id: '${member.id}-req-backfill',
        employeeId: member.id,
        type: EmployeePositionRequisitionType.backfill,
        title: 'Product manager backfill readiness',
        owner: member.manager,
        requestedFte: 1,
        targetStartDate: today.add(const Duration(days: 21)),
        status: EmployeePositionRequisitionStatus.submitted,
        businessCase:
            'Critical product role needs approved backfill path while support plan is active.',
      ),
    ];
  }

  if (member.id == '5') {
    return [
      EmployeePositionRequisition(
        id: '${member.id}-req-conversion',
        employeeId: member.id,
        type: EmployeePositionRequisitionType.conversion,
        title: 'Convert onboarding seat to full FTE',
        owner: member.manager,
        requestedFte: 0.5,
        targetStartDate: today.add(const Duration(days: 12)),
        status: EmployeePositionRequisitionStatus.approved,
        businessCase:
            'Marketing role needs full staffing after onboarding checkpoint.',
      ),
    ];
  }

  return const [];
}

String _costCenterFor(String department) {
  return switch (department) {
    'Engineering' => 'CC-ENG-120',
    'Design' => 'CC-DES-130',
    'Human Resources' => 'CC-HR-150',
    'Product' => 'CC-PROD-110',
    _ => 'CC-OPS-100',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
