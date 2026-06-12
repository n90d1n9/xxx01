import '../models/employee_directory_models.dart';
import '../models/employee_performance_support_models.dart';

EmployeePerformanceSupportPlan buildEmployeePerformanceSupportPlan({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);
  return EmployeePerformanceSupportPlan(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    manager: member.manager,
    hrPartner: _hrPartnerFor(member),
    title: _titleFor(member),
    status: _statusFor(member),
    startDate: _startDateFor(member, today),
    endDate: _endDateFor(member, today),
    milestones: _milestonesFor(member: member, today: today),
  );
}

EmployeePerformanceSupportMilestoneDraft
buildEmployeePerformanceSupportMilestoneDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  return EmployeePerformanceSupportMilestoneDraft.fromMember(
    member: member,
    asOfDate: asOfDate,
  );
}

String _titleFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return 'Roadmap recovery performance support';
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return 'Probation coaching support';
  }
  return 'Performance support plan';
}

String _hrPartnerFor(EmployeeDirectoryMember member) {
  if (member.department == 'Engineering') return 'Priya Shah';
  if (member.department == 'Human Resources') return 'Nadia Rahman';
  if (member.department == 'Product') return 'HR Business Partner';
  return 'People Operations';
}

EmployeePerformanceSupportStatus _statusFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeePerformanceSupportStatus.active;
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeePerformanceSupportStatus.draft;
  }
  return EmployeePerformanceSupportStatus.completed;
}

DateTime _startDateFor(EmployeeDirectoryMember member, DateTime today) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.subtract(const Duration(days: 10));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return today.add(const Duration(days: 3));
  }
  return today.subtract(const Duration(days: 60));
}

DateTime _endDateFor(EmployeeDirectoryMember member, DateTime today) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return today.add(const Duration(days: 20));
  }
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return today.add(const Duration(days: 45));
  }
  return today.subtract(const Duration(days: 5));
}

List<EmployeePerformanceSupportMilestone> _milestonesFor({
  required EmployeeDirectoryMember member,
  required DateTime today,
}) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      _milestone(
        id: '${member.id}-support-coaching',
        employeeId: member.id,
        type: EmployeePerformanceMilestoneType.coaching,
        title: 'Log weekly coaching evidence',
        owner: member.manager,
        dueDate: today.subtract(const Duration(days: 1)),
        status: EmployeePerformanceMilestoneStatus.blocked,
        risk: EmployeePerformanceSupportRisk.critical,
        successMetric: 'Manager notes attached for the weekly checkpoint',
        notes: 'Coaching evidence is missing from the current recovery cycle.',
      ),
      _milestone(
        id: '${member.id}-support-deliverable',
        employeeId: member.id,
        type: EmployeePerformanceMilestoneType.deliverable,
        title: 'Ship roadmap recovery slice',
        owner: member.name,
        dueDate: today.add(const Duration(days: 6)),
        status: EmployeePerformanceMilestoneStatus.inProgress,
        risk: EmployeePerformanceSupportRisk.high,
        successMetric: 'Recovery slice accepted by product leadership',
        notes: 'Scope is agreed; execution evidence is still developing.',
      ),
      _milestone(
        id: '${member.id}-support-feedback',
        employeeId: member.id,
        type: EmployeePerformanceMilestoneType.behavior,
        title: 'Complete stakeholder feedback review',
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 13)),
        status: EmployeePerformanceMilestoneStatus.open,
        risk: EmployeePerformanceSupportRisk.medium,
        successMetric: 'Feedback summary reviewed with manager and employee',
        notes: 'Use feedback themes to tune the next coaching checkpoint.',
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      _milestone(
        id: '${member.id}-support-probation',
        employeeId: member.id,
        type: EmployeePerformanceMilestoneType.review,
        title: 'Confirm probation success criteria',
        owner: member.manager,
        dueDate: today.add(const Duration(days: 14)),
        status: EmployeePerformanceMilestoneStatus.open,
        risk: EmployeePerformanceSupportRisk.medium,
        successMetric: 'Probation success criteria signed by manager',
        notes: 'Confirm expectations before the first probation checkpoint.',
      ),
    ];
  }

  return const [];
}

EmployeePerformanceSupportMilestone _milestone({
  required String id,
  required String employeeId,
  required EmployeePerformanceMilestoneType type,
  required String title,
  required String owner,
  required DateTime dueDate,
  required EmployeePerformanceMilestoneStatus status,
  required EmployeePerformanceSupportRisk risk,
  required String successMetric,
  required String notes,
}) {
  return EmployeePerformanceSupportMilestone(
    id: id,
    employeeId: employeeId,
    type: type,
    title: title,
    owner: owner,
    dueDate: _dateOnly(dueDate),
    status: status,
    risk: risk,
    successMetric: successMetric,
    notes: notes,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
