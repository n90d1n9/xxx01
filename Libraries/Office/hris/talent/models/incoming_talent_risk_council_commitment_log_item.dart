enum IncomingTalentRiskCouncilCommitmentLogType {
  clear('Clear'),
  leadershipDecision('Leadership decision'),
  recoveryAction('Recovery action'),
  decisionRecord('Decision record'),
  followUpPlan('Follow-up plan'),
  ownerUpdate('Owner update'),
  executionEvidence('Execution evidence'),
  publishCloseout('Publish closeout');

  final String label;

  const IncomingTalentRiskCouncilCommitmentLogType(this.label);
}

enum IncomingTalentRiskCouncilCommitmentLogStatus {
  clear('Clear'),
  blocked('Blocked'),
  needsDecision('Needs decision'),
  needsEvidence('Needs evidence'),
  needsOwner('Needs owner'),
  readyToPublish('Ready');

  final String label;

  const IncomingTalentRiskCouncilCommitmentLogStatus(this.label);
}

class IncomingTalentRiskCouncilCommitmentLogItem {
  final String id;
  final String agendaItemId;
  final IncomingTalentRiskCouncilCommitmentLogType type;
  final IncomingTalentRiskCouncilCommitmentLogStatus status;
  final String title;
  final String commitment;
  final String evidenceExpectation;
  final String ownerName;
  final DateTime dueDate;
  final int sourceCount;
  final List<String> readinessTaskIds;

  const IncomingTalentRiskCouncilCommitmentLogItem({
    required this.id,
    required this.agendaItemId,
    required this.type,
    required this.status,
    required this.title,
    required this.commitment,
    required this.evidenceExpectation,
    required this.ownerName,
    required this.dueDate,
    required this.sourceCount,
    required this.readinessTaskIds,
  });

  bool get isPublishable {
    return status == IncomingTalentRiskCouncilCommitmentLogStatus.clear ||
        status == IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish;
  }

  bool get needsAttention => !isPublishable;

  int get urgencyRank {
    return switch (status) {
      IncomingTalentRiskCouncilCommitmentLogStatus.blocked => 0,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsDecision => 1,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsEvidence => 2,
      IncomingTalentRiskCouncilCommitmentLogStatus.needsOwner => 3,
      IncomingTalentRiskCouncilCommitmentLogStatus.readyToPublish => 4,
      IncomingTalentRiskCouncilCommitmentLogStatus.clear => 5,
    };
  }
}
