import '../models/employee_directory_models.dart';
import '../models/employee_leave_models.dart';

EmployeeLeaveProfile buildEmployeeLeaveProfile({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeLeaveProfile(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    balances: _balancesFor(member),
    requests: _requestsFor(member, today),
    blackouts: _blackoutsFor(member, today),
  );
}

EmployeeLeaveRequestDraft buildEmployeeLeaveRequestDraft({
  required EmployeeDirectoryMember member,
  required DateTime asOfDate,
}) {
  final today = _dateOnly(asOfDate);

  return EmployeeLeaveRequestDraft(
    employeeId: member.id,
    employeeName: member.name,
    asOfDate: today,
    type: EmployeeLeaveType.vacation,
    startDate: today.add(const Duration(days: 7)),
    endDate: today.add(const Duration(days: 8)),
    reason: '',
    coverageOwner: member.manager,
  );
}

List<EmployeeLeaveBalance> _balancesFor(EmployeeDirectoryMember member) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return const [
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.vacation,
        accruedDays: 15,
        usedDays: 12,
        pendingDays: 2,
        approvedUpcomingDays: 0,
      ),
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.sick,
        accruedDays: 10,
        usedDays: 5,
        pendingDays: 0,
        approvedUpcomingDays: 0,
      ),
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.personal,
        accruedDays: 5,
        usedDays: 4,
        pendingDays: 0,
        approvedUpcomingDays: 0,
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return const [
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.vacation,
        accruedDays: 8,
        usedDays: 0,
        pendingDays: 0,
        approvedUpcomingDays: 0,
      ),
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.sick,
        accruedDays: 5,
        usedDays: 0,
        pendingDays: 1,
        approvedUpcomingDays: 0,
      ),
      EmployeeLeaveBalance(
        type: EmployeeLeaveType.personal,
        accruedDays: 2,
        usedDays: 0,
        pendingDays: 0,
        approvedUpcomingDays: 0,
      ),
    ];
  }

  return [
    EmployeeLeaveBalance(
      type: EmployeeLeaveType.vacation,
      accruedDays: 15,
      usedDays: member.isHighPerformer ? 6 : 3,
      pendingDays: 0,
      approvedUpcomingDays: member.isHighPerformer ? 2 : 0,
    ),
    const EmployeeLeaveBalance(
      type: EmployeeLeaveType.sick,
      accruedDays: 10,
      usedDays: 2,
      pendingDays: 0,
      approvedUpcomingDays: 0,
    ),
    const EmployeeLeaveBalance(
      type: EmployeeLeaveType.personal,
      accruedDays: 5,
      usedDays: 1,
      pendingDays: 0,
      approvedUpcomingDays: 0,
    ),
  ];
}

List<EmployeeLeaveRequest> _requestsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  if (member.status == EmployeeDirectoryStatus.watchlist) {
    return [
      EmployeeLeaveRequest(
        id: 'ELR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeLeaveType.vacation,
        startDate: today.add(const Duration(days: 3)),
        endDate: today.add(const Duration(days: 4)),
        reason: 'Personal time requested during delivery stabilization.',
        coverageOwner: member.manager,
        status: EmployeeLeaveRequestStatus.pending,
        submittedAt: today.subtract(const Duration(days: 1)),
      ),
    ];
  }

  if (member.status == EmployeeDirectoryStatus.onboarding) {
    return [
      EmployeeLeaveRequest(
        id: 'ELR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeLeaveType.sick,
        startDate: today.add(const Duration(days: 1)),
        endDate: today.add(const Duration(days: 1)),
        reason: 'Medical appointment during onboarding week.',
        coverageOwner: member.manager,
        status: EmployeeLeaveRequestStatus.pending,
        submittedAt: today,
      ),
    ];
  }

  if (member.isHighPerformer) {
    return [
      EmployeeLeaveRequest(
        id: 'ELR-${member.id}-001',
        employeeId: member.id,
        type: EmployeeLeaveType.vacation,
        startDate: today.add(const Duration(days: 14)),
        endDate: today.add(const Duration(days: 15)),
        reason: 'Recovery days after product launch milestone.',
        coverageOwner: member.manager,
        status: EmployeeLeaveRequestStatus.approved,
        submittedAt: today.subtract(const Duration(days: 3)),
      ),
    ];
  }

  return const [];
}

List<EmployeeLeaveBlackoutPeriod> _blackoutsFor(
  EmployeeDirectoryMember member,
  DateTime today,
) {
  final blackouts = <EmployeeLeaveBlackoutPeriod>[
    EmployeeLeaveBlackoutPeriod(
      id: 'ELB-quarter-close',
      title: 'Quarter close coverage',
      startDate: today.add(const Duration(days: 3)),
      endDate: today.add(const Duration(days: 6)),
      owner: 'People Operations',
    ),
  ];

  if (member.department == 'Engineering' || member.department == 'Product') {
    blackouts.add(
      EmployeeLeaveBlackoutPeriod(
        id: 'ELB-release-window',
        title: 'Release window',
        startDate: today.add(const Duration(days: 12)),
        endDate: today.add(const Duration(days: 14)),
        owner: 'Delivery Operations',
      ),
    );
  }

  return blackouts;
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
