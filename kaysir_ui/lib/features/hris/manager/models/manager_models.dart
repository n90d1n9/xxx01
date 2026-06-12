enum TeamMemberStatus { available, busy, onLeave }

extension TeamMemberStatusLabel on TeamMemberStatus {
  String get label {
    switch (this) {
      case TeamMemberStatus.available:
        return 'Available';
      case TeamMemberStatus.busy:
        return 'Busy';
      case TeamMemberStatus.onLeave:
        return 'On leave';
    }
  }
}

enum ManagerRequestPriority { standard, urgent }

extension ManagerRequestPriorityLabel on ManagerRequestPriority {
  String get label {
    switch (this) {
      case ManagerRequestPriority.standard:
        return 'Standard';
      case ManagerRequestPriority.urgent:
        return 'Urgent';
    }
  }
}

enum ManagerRequestStatus { pending, approved, rejected }

extension ManagerRequestStatusLabel on ManagerRequestStatus {
  String get label {
    switch (this) {
      case ManagerRequestStatus.pending:
        return 'Pending';
      case ManagerRequestStatus.approved:
        return 'Approved';
      case ManagerRequestStatus.rejected:
        return 'Rejected';
    }
  }
}

class TeamMember {
  final String id;
  final String name;
  final String role;
  final String team;
  final String avatarUrl;
  final TeamMemberStatus status;
  final int capacityPercent;
  final int performanceScore;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.team,
    required this.avatarUrl,
    required this.status,
    required this.capacityPercent,
    required this.performanceScore,
  });

  bool get isAvailable => status == TeamMemberStatus.available;

  bool get needsAttention =>
      status != TeamMemberStatus.available ||
      capacityPercent >= 90 ||
      performanceScore < 80;
}

class PendingRequest {
  final String id;
  final String employeeName;
  final String team;
  final String requestType;
  final DateTime requestDate;
  final ManagerRequestStatus status;
  final String avatarUrl;
  final ManagerRequestPriority priority;

  const PendingRequest({
    required this.id,
    required this.employeeName,
    required this.team,
    required this.requestType,
    required this.requestDate,
    required this.status,
    required this.avatarUrl,
    required this.priority,
  });

  bool get isPending => status == ManagerRequestStatus.pending;

  bool get needsAttention =>
      isPending && priority == ManagerRequestPriority.urgent;

  bool isOlderThan(Duration duration, DateTime asOfDate) {
    return asOfDate.difference(requestDate) >= duration;
  }
}

class TeamMetricSnapshot {
  final int productivity;
  final int satisfaction;
  final int taskCompletion;
  final List<int> weeklyData;

  const TeamMetricSnapshot({
    required this.productivity,
    required this.satisfaction,
    required this.taskCompletion,
    required this.weeklyData,
  });

  int get healthScore =>
      ((productivity + satisfaction + taskCompletion) / 3).round();
}

class ManagerSelfServiceSummary {
  final int teamMemberCount;
  final int availableCount;
  final int pendingApprovalCount;
  final int highPriorityApprovals;
  final int averageCapacity;
  final int teamHealthScore;
  final int attentionCount;

  const ManagerSelfServiceSummary({
    required this.teamMemberCount,
    required this.availableCount,
    required this.pendingApprovalCount,
    required this.highPriorityApprovals,
    required this.averageCapacity,
    required this.teamHealthScore,
    required this.attentionCount,
  });

  factory ManagerSelfServiceSummary.fromData({
    required List<TeamMember> members,
    required List<PendingRequest> requests,
    required TeamMetricSnapshot metrics,
  }) {
    final averageCapacity =
        members.isEmpty
            ? 0
            : (members
                        .map((member) => member.capacityPercent)
                        .reduce((total, capacity) => total + capacity) /
                    members.length)
                .round();

    return ManagerSelfServiceSummary(
      teamMemberCount: members.length,
      availableCount: members.where((member) => member.isAvailable).length,
      pendingApprovalCount:
          requests.where((request) => request.isPending).length,
      highPriorityApprovals:
          requests.where((request) => request.needsAttention).length,
      averageCapacity: averageCapacity,
      teamHealthScore: metrics.healthScore,
      attentionCount:
          members.where((member) => member.needsAttention).length +
          requests.where((request) => request.needsAttention).length,
    );
  }
}

class ManagerRiskSummary {
  final int busyMembers;
  final int onLeaveMembers;
  final int highCapacityMembers;
  final int lowPerformanceMembers;
  final int urgentPendingRequests;
  final int stalePendingRequests;

  const ManagerRiskSummary({
    required this.busyMembers,
    required this.onLeaveMembers,
    required this.highCapacityMembers,
    required this.lowPerformanceMembers,
    required this.urgentPendingRequests,
    required this.stalePendingRequests,
  });

  int get totalRisks =>
      busyMembers +
      onLeaveMembers +
      highCapacityMembers +
      lowPerformanceMembers +
      urgentPendingRequests +
      stalePendingRequests;

  factory ManagerRiskSummary.fromData({
    required List<TeamMember> members,
    required List<PendingRequest> requests,
    required DateTime asOfDate,
  }) {
    return ManagerRiskSummary(
      busyMembers:
          members
              .where((member) => member.status == TeamMemberStatus.busy)
              .length,
      onLeaveMembers:
          members
              .where((member) => member.status == TeamMemberStatus.onLeave)
              .length,
      highCapacityMembers:
          members.where((member) => member.capacityPercent >= 90).length,
      lowPerformanceMembers:
          members.where((member) => member.performanceScore < 80).length,
      urgentPendingRequests:
          requests.where((request) => request.needsAttention).length,
      stalePendingRequests:
          requests
              .where(
                (request) =>
                    request.isPending &&
                    request.isOlderThan(const Duration(hours: 48), asOfDate),
              )
              .length,
    );
  }
}
