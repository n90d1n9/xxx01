import '../models/employee_directory_models.dart';
import '../models/employee_performance_models.dart';

EmployeePerformancePlan buildEmployeePerformancePlan({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeePerformancePlan(
    employeeId: member.id,
    employeeName: member.name,
    manager: member.manager,
    asOfDate: _dateOnly(asOfDate),
    cycleName: '${asOfDate.year} H1 Performance',
    reviewDueDate: _reviewDueDate(member, asOfDate),
    goals: _goalsFor(member, asOfDate),
    checkIns: _checkInsFor(member, asOfDate),
  );
}

EmployeePerformanceCheckInDraft buildEmployeePerformanceCheckInDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeePerformanceCheckInDraft(
    employeeId: member.id,
    employeeName: member.name,
    manager: member.manager,
    asOfDate: _dateOnly(asOfDate),
    sentiment:
        member.status == EmployeeDirectoryStatus.watchlist
            ? EmployeePerformanceCheckInSentiment.concern
            : EmployeePerformanceCheckInSentiment.neutral,
    summary: '',
    nextStep: '',
  );
}

DateTime _reviewDueDate(EmployeeDirectoryMember member, DateTime asOfDate) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return _dateOnly(asOfDate).add(const Duration(days: 7));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return _dateOnly(asOfDate).add(const Duration(days: 30));
  }
  return DateTime(asOfDate.year, 6, 30);
}

List<EmployeePerformanceGoal> _goalsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  final defaultStatus =
      member.status == EmployeeDirectoryStatus.watchlist
          ? EmployeePerformanceGoalStatus.atRisk
          : EmployeePerformanceGoalStatus.active;
  final firstProgress =
      member.isHighPerformer
          ? 0.88
          : member.status == EmployeeDirectoryStatus.watchlist
          ? 0.42
          : 0.64;
  final secondProgress =
      member.isHighPerformer
          ? 0.78
          : member.status == EmployeeDirectoryStatus.watchlist
          ? 0.36
          : 0.58;

  return [
    EmployeePerformanceGoal(
      id: '${member.id}-goal-impact',
      employeeId: member.id,
      title: _impactGoal(member),
      owner: member.manager,
      targetDate:
          member.status == EmployeeDirectoryStatus.watchlist
              ? today.add(const Duration(days: 10))
              : DateTime(asOfDate.year, 6, 30),
      progress: firstProgress,
      weight: 45,
      status: defaultStatus,
    ),
    EmployeePerformanceGoal(
      id: '${member.id}-goal-growth',
      employeeId: member.id,
      title: _growthGoal(member),
      owner: member.manager,
      targetDate: today.add(const Duration(days: 28)),
      progress: secondProgress,
      weight: 35,
      status:
          member.status == EmployeeDirectoryStatus.watchlist
              ? EmployeePerformanceGoalStatus.atRisk
              : EmployeePerformanceGoalStatus.active,
    ),
    EmployeePerformanceGoal(
      id: '${member.id}-goal-team',
      employeeId: member.id,
      title: 'Document team contribution and knowledge sharing',
      owner: member.manager,
      targetDate: today.add(const Duration(days: 40)),
      progress: member.isHighPerformer ? 1 : 0.52,
      weight: 20,
      status:
          member.isHighPerformer
              ? EmployeePerformanceGoalStatus.complete
              : EmployeePerformanceGoalStatus.active,
    ),
  ];
}

List<EmployeePerformanceCheckIn> _checkInsFor(
  EmployeeDirectoryMember member,
  DateTime asOfDate,
) {
  final today = _dateOnly(asOfDate);
  return [
    EmployeePerformanceCheckIn(
      id: '${member.id}-checkin-latest',
      employeeId: member.id,
      author: member.manager,
      date: today.subtract(const Duration(days: 12)),
      sentiment:
          member.status == EmployeeDirectoryStatus.watchlist
              ? EmployeePerformanceCheckInSentiment.concern
              : EmployeePerformanceCheckInSentiment.positive,
      summary:
          member.status == EmployeeDirectoryStatus.watchlist
              ? 'Manager flagged delivery consistency and clearer milestone tracking.'
              : 'Progress is visible and manager noted strong ownership momentum.',
      nextStep:
          member.status == EmployeeDirectoryStatus.watchlist
              ? 'Review weekly milestone plan with HRBP.'
              : 'Prepare examples for calibration packet.',
    ),
  ];
}

String _impactGoal(EmployeeDirectoryMember member) {
  return switch (member.department) {
    'Engineering' => 'Deliver platform milestone with production readiness',
    'Design' => 'Ship validated product experience improvements',
    'Product' => 'Improve roadmap execution and stakeholder alignment',
    'Human Resources' => 'Raise HR operations service quality',
    _ => 'Deliver department priority outcomes',
  };
}

String _growthGoal(EmployeeDirectoryMember member) {
  return switch (member.status) {
    EmployeeDirectoryStatus.onboarding => 'Complete onboarding capability ramp',
    EmployeeDirectoryStatus.watchlist => 'Stabilize performance recovery plan',
    EmployeeDirectoryStatus.active => 'Advance role capability growth plan',
  };
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
