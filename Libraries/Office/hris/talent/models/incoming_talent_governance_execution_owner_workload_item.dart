/// Load tier for an owner carrying talent governance execution actions.
enum IncomingTalentGovernanceExecutionOwnerLoad {
  critical('Critical'),
  stretched('Stretched'),
  balanced('Balanced');

  final String label;

  const IncomingTalentGovernanceExecutionOwnerLoad(this.label);
}

/// Owner-level workload snapshot for governance execution follow-through.
class IncomingTalentGovernanceExecutionOwnerWorkloadItem {
  final String ownerName;
  final IncomingTalentGovernanceExecutionOwnerLoad load;
  final int actionCount;
  final int criticalActionCount;
  final int highActionCount;
  final int standardActionCount;
  final int overdueActionCount;
  final int signalCount;
  final int decisionCount;
  final int readinessTaskCount;
  final DateTime earliestDueDate;
  final double averageProgressRatio;
  final String nextAction;
  final List<String> actionIds;

  const IncomingTalentGovernanceExecutionOwnerWorkloadItem({
    required this.ownerName,
    required this.load,
    required this.actionCount,
    required this.criticalActionCount,
    required this.highActionCount,
    required this.standardActionCount,
    required this.overdueActionCount,
    required this.signalCount,
    required this.decisionCount,
    required this.readinessTaskCount,
    required this.earliestDueDate,
    required this.averageProgressRatio,
    required this.nextAction,
    required this.actionIds,
  });

  bool get needsAttention {
    return load != IncomingTalentGovernanceExecutionOwnerLoad.balanced ||
        overdueActionCount > 0;
  }

  double get normalizedAverageProgressRatio {
    if (averageProgressRatio < 0) return 0;
    if (averageProgressRatio > 1) return 1;
    return averageProgressRatio;
  }

  int get urgencyRank {
    return switch (load) {
      IncomingTalentGovernanceExecutionOwnerLoad.critical => 0,
      IncomingTalentGovernanceExecutionOwnerLoad.stretched => 1,
      IncomingTalentGovernanceExecutionOwnerLoad.balanced => 2,
    };
  }
}
