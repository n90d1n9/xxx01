class LeaveRequest {
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final LeaveStatus status;
  final String leaveType;

  LeaveRequest({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.leaveType,
  });

  int get durationDays {
    final value = endDate.difference(startDate).inDays + 1;
    return value < 0 ? 0 : value;
  }
}

enum LeaveStatus { pending, approved, rejected }

class LeaveSummary {
  final int balanceDays;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final int pendingDays;
  final int approvedDays;

  const LeaveSummary({
    required this.balanceDays,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.pendingDays,
    required this.approvedDays,
  });

  factory LeaveSummary.fromRequests({
    required List<LeaveRequest> requests,
    required int balanceDays,
  }) {
    int pendingDays = 0;
    int approvedDays = 0;

    for (final request in requests) {
      switch (request.status) {
        case LeaveStatus.pending:
          pendingDays += request.durationDays;
          break;
        case LeaveStatus.approved:
          approvedDays += request.durationDays;
          break;
        case LeaveStatus.rejected:
          break;
      }
    }

    return LeaveSummary(
      balanceDays: balanceDays,
      pendingCount:
          requests.where((item) => item.status == LeaveStatus.pending).length,
      approvedCount:
          requests.where((item) => item.status == LeaveStatus.approved).length,
      rejectedCount:
          requests.where((item) => item.status == LeaveStatus.rejected).length,
      pendingDays: pendingDays,
      approvedDays: approvedDays,
    );
  }

  int get remainingBalance {
    final value = balanceDays - approvedDays;
    return value < 0 ? 0 : value;
  }
}

class LeaveRiskSummary {
  final int pendingRequests;
  final int pendingDays;
  final int upcomingPendingRequests;
  final int approvedDays;
  final int projectedRemainingBalance;
  final int balancePressureDays;

  const LeaveRiskSummary({
    required this.pendingRequests,
    required this.pendingDays,
    required this.upcomingPendingRequests,
    required this.approvedDays,
    required this.projectedRemainingBalance,
    required this.balancePressureDays,
  });

  int get totalRisks =>
      pendingRequests + upcomingPendingRequests + balancePressureDays;

  factory LeaveRiskSummary.fromRequests({
    required List<LeaveRequest> requests,
    required int balanceDays,
    required DateTime asOfDate,
  }) {
    final summary = LeaveSummary.fromRequests(
      requests: requests,
      balanceDays: balanceDays,
    );
    final upcomingThreshold = asOfDate.add(const Duration(days: 7));
    final projectedRemaining = summary.remainingBalance - summary.pendingDays;

    return LeaveRiskSummary(
      pendingRequests: summary.pendingCount,
      pendingDays: summary.pendingDays,
      upcomingPendingRequests:
          requests
              .where(
                (item) =>
                    item.status == LeaveStatus.pending &&
                    !item.startDate.isAfter(upcomingThreshold),
              )
              .length,
      approvedDays: summary.approvedDays,
      projectedRemainingBalance:
          projectedRemaining < 0 ? 0 : projectedRemaining,
      balancePressureDays:
          projectedRemaining < 0 ? projectedRemaining.abs() : 0,
    );
  }
}
