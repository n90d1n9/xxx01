enum IncomingTalentRiskCouncilCommitmentOwnerLoad {
  critical('Critical'),
  stretched('Stretched'),
  balanced('Balanced'),
  clear('Clear');

  final String label;

  const IncomingTalentRiskCouncilCommitmentOwnerLoad(this.label);
}

class IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem {
  final String ownerName;
  final IncomingTalentRiskCouncilCommitmentOwnerLoad load;
  final int totalCount;
  final int openCount;
  final int completedCount;
  final int blockedCount;
  final int escalatedCount;
  final int waitingEvidenceCount;
  final int dueSoonCount;
  final int overdueCount;
  final int attentionCount;
  final int sourceCount;
  final DateTime earliestDueDate;
  final String nextAction;
  final List<String> actionIds;

  const IncomingTalentRiskCouncilCommitmentOwnerWorkloadItem({
    required this.ownerName,
    required this.load,
    required this.totalCount,
    required this.openCount,
    required this.completedCount,
    required this.blockedCount,
    required this.escalatedCount,
    required this.waitingEvidenceCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.attentionCount,
    required this.sourceCount,
    required this.earliestDueDate,
    required this.nextAction,
    required this.actionIds,
  });

  bool get needsAttention {
    return attentionCount > 0 ||
        load == IncomingTalentRiskCouncilCommitmentOwnerLoad.critical ||
        load == IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched;
  }

  int get urgencyRank {
    return switch (load) {
      IncomingTalentRiskCouncilCommitmentOwnerLoad.critical => 0,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.stretched => 1,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.balanced => 2,
      IncomingTalentRiskCouncilCommitmentOwnerLoad.clear => 3,
    };
  }
}
