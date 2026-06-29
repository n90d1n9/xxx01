import '../models/employee_directory_models.dart';
import '../models/employee_lifecycle_task_models.dart';

EmployeeLifecyclePlan buildEmployeeLifecyclePlan({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
  EmployeeLifecyclePlanType? type,
}) {
  final resolvedType = type ?? defaultEmployeeLifecyclePlanType(member);
  return EmployeeLifecyclePlan(
    employeeId: member.id,
    employeeName: member.name,
    type: resolvedType,
    launchedAt: _dateOnly(asOfDate),
    asOfDate: _dateOnly(asOfDate),
    tasks: _seedTasks(
      employeeId: member.id,
      manager: member.manager,
      asOfDate: asOfDate,
      type: resolvedType,
    ),
  );
}

EmployeeLifecyclePlanType defaultEmployeeLifecyclePlanType(
  EmployeeDirectoryMember member,
) {
  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return EmployeeLifecyclePlanType.onboarding;
  }
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return EmployeeLifecyclePlanType.probationReview;
  }
  return EmployeeLifecyclePlanType.contractReview;
}

List<EmployeeLifecycleTask> _seedTasks({
  required String employeeId,
  required String manager,
  required DateTime asOfDate,
  required EmployeeLifecyclePlanType type,
}) {
  final today = _dateOnly(asOfDate);
  return switch (type) {
    EmployeeLifecyclePlanType.onboarding => [
      _task(
        id: '$employeeId-onboarding-docs',
        employeeId: employeeId,
        title: 'Verify payroll and tax documents',
        owner: 'Payroll',
        dueDate: today.subtract(const Duration(days: 1)),
        status: EmployeeLifecycleTaskStatus.blocked,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
      _task(
        id: '$employeeId-onboarding-access',
        employeeId: employeeId,
        title: 'Confirm workspace and access readiness',
        owner: 'IT Operations',
        dueDate: today.add(const Duration(days: 2)),
        status: EmployeeLifecycleTaskStatus.inProgress,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
      _task(
        id: '$employeeId-onboarding-checkin',
        employeeId: employeeId,
        title: 'Schedule 30 day manager check-in',
        owner: manager,
        dueDate: today.add(const Duration(days: 14)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.medium,
      ),
    ],
    EmployeeLifecyclePlanType.probationReview => [
      _task(
        id: '$employeeId-probation-coaching',
        employeeId: employeeId,
        title: 'Log manager coaching notes',
        owner: manager,
        dueDate: today.add(const Duration(days: 3)),
        status: EmployeeLifecycleTaskStatus.inProgress,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
      _task(
        id: '$employeeId-probation-plan',
        employeeId: employeeId,
        title: 'Draft improvement milestones',
        owner: 'HR Business Partner',
        dueDate: today.add(const Duration(days: 7)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
      _task(
        id: '$employeeId-probation-review',
        employeeId: employeeId,
        title: 'Book formal review conversation',
        owner: manager,
        dueDate: today.add(const Duration(days: 10)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.medium,
      ),
    ],
    EmployeeLifecyclePlanType.offboarding => [
      _task(
        id: '$employeeId-offboarding-exit',
        employeeId: employeeId,
        title: 'Schedule exit interview',
        owner: 'People Operations',
        dueDate: today.add(const Duration(days: 2)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.medium,
      ),
      _task(
        id: '$employeeId-offboarding-access',
        employeeId: employeeId,
        title: 'Prepare access revocation checklist',
        owner: 'IT Operations',
        dueDate: today.add(const Duration(days: 3)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
      _task(
        id: '$employeeId-offboarding-assets',
        employeeId: employeeId,
        title: 'Collect assigned assets',
        owner: 'Facilities',
        dueDate: today.add(const Duration(days: 5)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.high,
      ),
    ],
    EmployeeLifecyclePlanType.contractReview => [
      _task(
        id: '$employeeId-contract-profile',
        employeeId: employeeId,
        title: 'Review employee profile completeness',
        owner: 'HR Operations',
        dueDate: today.add(const Duration(days: 5)),
        status: EmployeeLifecycleTaskStatus.inProgress,
        priority: EmployeeLifecycleTaskPriority.medium,
      ),
      _task(
        id: '$employeeId-contract-comp',
        employeeId: employeeId,
        title: 'Validate compensation and payroll group',
        owner: 'Payroll',
        dueDate: today.add(const Duration(days: 8)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.medium,
      ),
      _task(
        id: '$employeeId-contract-manager',
        employeeId: employeeId,
        title: 'Confirm manager and cost center',
        owner: manager,
        dueDate: today.add(const Duration(days: 12)),
        status: EmployeeLifecycleTaskStatus.open,
        priority: EmployeeLifecycleTaskPriority.low,
      ),
    ],
  };
}

EmployeeLifecycleTask _task({
  required String id,
  required String employeeId,
  required String title,
  required String owner,
  required DateTime dueDate,
  required EmployeeLifecycleTaskStatus status,
  required EmployeeLifecycleTaskPriority priority,
}) {
  return EmployeeLifecycleTask(
    id: id,
    employeeId: employeeId,
    title: title,
    owner: owner,
    dueDate: _dateOnly(dueDate),
    status: status,
    priority: priority,
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
