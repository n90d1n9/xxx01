/// Governance status for executive talent operating lanes.
enum IncomingTalentGovernanceCommandStatus {
  critical('Critical'),
  watch('Watch'),
  stable('Stable');

  final String label;

  const IncomingTalentGovernanceCommandStatus(this.label);

  int get sortRank {
    return switch (this) {
      IncomingTalentGovernanceCommandStatus.critical => 0,
      IncomingTalentGovernanceCommandStatus.watch => 1,
      IncomingTalentGovernanceCommandStatus.stable => 2,
    };
  }
}

/// Lane represented in the talent governance command center.
enum IncomingTalentGovernanceCommandLaneType {
  health('Talent health'),
  actionSla('Action SLA'),
  escalation('Escalation'),
  assurance('Assurance'),
  succession('Succession'),
  training('Training'),
  careerPath('Career path');

  final String label;

  const IncomingTalentGovernanceCommandLaneType(this.label);
}

/// Executive lane that summarizes one governance area for talent operations.
class IncomingTalentGovernanceCommandLane {
  final String id;
  final IncomingTalentGovernanceCommandLaneType type;
  final IncomingTalentGovernanceCommandStatus status;
  final String title;
  final String detail;
  final String metricLabel;
  final String metricValue;
  final String nextAction;
  final double pressureRatio;
  final int signalCount;
  final int decisionCount;

  const IncomingTalentGovernanceCommandLane({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.detail,
    required this.metricLabel,
    required this.metricValue,
    required this.nextAction,
    required this.pressureRatio,
    required this.signalCount,
    required this.decisionCount,
  });

  bool get needsAttention {
    return status != IncomingTalentGovernanceCommandStatus.stable;
  }

  double get normalizedPressureRatio {
    if (pressureRatio < 0) return 0;
    if (pressureRatio > 1) return 1;
    return pressureRatio;
  }

  int get urgencyRank => status.sortRank;
}

/// Executive command center that rolls up talent governance lanes.
class IncomingTalentGovernanceCommandCenter {
  final IncomingTalentGovernanceCommandStatus status;
  final int governanceScore;
  final int laneCount;
  final int criticalLaneCount;
  final int watchLaneCount;
  final int stableLaneCount;
  final int totalSignalCount;
  final int decisionCount;
  final String nextAction;
  final List<IncomingTalentGovernanceCommandLane> lanes;

  const IncomingTalentGovernanceCommandCenter({
    required this.status,
    required this.governanceScore,
    required this.laneCount,
    required this.criticalLaneCount,
    required this.watchLaneCount,
    required this.stableLaneCount,
    required this.totalSignalCount,
    required this.decisionCount,
    required this.nextAction,
    required this.lanes,
  });

  double get governanceRatio => governanceScore / 100;
}
