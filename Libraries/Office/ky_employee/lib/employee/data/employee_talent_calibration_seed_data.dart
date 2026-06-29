import '../models/employee_directory_models.dart';
import '../models/employee_talent_calibration_models.dart';

EmployeeTalentCalibrationProfile buildEmployeeTalentCalibrationProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  final onboarding = member.status == EmployeeDirectoryStatus.onboarding;
  final highPerformer = member.isHighPerformer;

  return EmployeeTalentCalibrationProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    cycle: '${today.year} ${today.month <= 6 ? 'H1' : 'H2'}',
    role: member.position,
    calibrator: member.manager,
    performanceBand:
        watchlist
            ? EmployeeTalentPerformanceBand.inconsistent
            : highPerformer
            ? EmployeeTalentPerformanceBand.exceptional
            : EmployeeTalentPerformanceBand.solid,
    potentialBand:
        watchlist
            ? EmployeeTalentPotentialBand.growth
            : highPerformer
            ? EmployeeTalentPotentialBand.high
            : onboarding
            ? EmployeeTalentPotentialBand.steady
            : EmployeeTalentPotentialBand.growth,
    riskLevel:
        watchlist
            ? EmployeeTalentRiskLevel.high
            : onboarding
            ? EmployeeTalentRiskLevel.medium
            : EmployeeTalentRiskLevel.low,
    decision:
        watchlist
            ? EmployeeTalentCalibrationDecision.stabilize
            : highPerformer
            ? EmployeeTalentCalibrationDecision.advance
            : onboarding
            ? EmployeeTalentCalibrationDecision.monitor
            : EmployeeTalentCalibrationDecision.invest,
    status:
        watchlist || onboarding
            ? EmployeeTalentCalibrationStatus.actionDue
            : EmployeeTalentCalibrationStatus.calibrated,
    lastCalibratedDate: today.subtract(Duration(days: watchlist ? 58 : 38)),
    nextReviewDate:
        watchlist
            ? today.subtract(const Duration(days: 1))
            : today.add(Duration(days: onboarding ? 18 : 75)),
    followUps: _followUpsFor(member, today),
  );
}

EmployeeTalentFollowUpDraft buildEmployeeTalentFollowUpDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final watchlist = member.status == EmployeeDirectoryStatus.watchlist;
  return EmployeeTalentFollowUpDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: _dateOnly(asOfDate),
    type:
        watchlist
            ? EmployeeTalentFollowUpType.managerCoaching
            : EmployeeTalentFollowUpType.developmentPlan,
    title: '',
    owner: watchlist ? member.manager : 'Talent Enablement',
    dueDate: _dateOnly(asOfDate).add(const Duration(days: 14)),
    notes: '',
  );
}

List<EmployeeTalentFollowUp> _followUpsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.id == '4') {
    return [
      EmployeeTalentFollowUp(
        id: '${member.id}-talent-coaching',
        employeeId: member.id,
        type: EmployeeTalentFollowUpType.managerCoaching,
        title: 'Weekly manager calibration checkpoint',
        owner: member.manager,
        dueDate: today.subtract(const Duration(days: 2)),
        status: EmployeeTalentFollowUpStatus.open,
        notes:
            'Confirm recovery plan evidence before final H1 calibration lock.',
      ),
      EmployeeTalentFollowUp(
        id: '${member.id}-talent-retention',
        employeeId: member.id,
        type: EmployeeTalentFollowUpType.retentionCheck,
        title: 'Retention and role clarity check',
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 5)),
        status: EmployeeTalentFollowUpStatus.inProgress,
        notes:
            'Align expectations, support plan milestones, and next role options.',
      ),
    ];
  }

  if (member.id == '2') {
    return [
      EmployeeTalentFollowUp(
        id: '${member.id}-talent-advance',
        employeeId: member.id,
        type: EmployeeTalentFollowUpType.successionReview,
        title: 'Nominate for platform leadership slate',
        owner: 'Talent Council',
        dueDate: today.add(const Duration(days: 12)),
        status: EmployeeTalentFollowUpStatus.open,
        notes:
            'Exceptional delivery and high potential indicate ready-soon bench.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeTalentFollowUp(
        id: '${member.id}-talent-onboarding',
        employeeId: member.id,
        type: EmployeeTalentFollowUpType.developmentPlan,
        title: 'Complete first-cycle calibration evidence',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 10)),
        status: EmployeeTalentFollowUpStatus.open,
        notes:
            'Collect onboarding outcomes before assigning final potential band.',
      ),
    ];
  }

  return [
    EmployeeTalentFollowUp(
      id: '${member.id}-talent-development',
      employeeId: member.id,
      type: EmployeeTalentFollowUpType.developmentPlan,
      title: 'Refresh growth assignment',
      owner: 'Talent Enablement',
      dueDate: today.add(const Duration(days: 30)),
      status: EmployeeTalentFollowUpStatus.inProgress,
      notes: 'Keep growth plan aligned with calibrated potential band.',
    ),
  ];
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
