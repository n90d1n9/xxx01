/// Decision type captured in the executive talent governance ledger.
enum IncomingTalentGovernanceDecisionLedgerType {
  clear('Clear'),
  executiveUnblock('Executive unblock'),
  capacityCommitment('Capacity commitment'),
  approvalDecision('Approval decision'),
  ownerAlignment('Owner alignment'),
  monitoringRecord('Monitoring record');

  final String label;

  const IncomingTalentGovernanceDecisionLedgerType(this.label);
}

/// Publication status for a talent governance decision ledger item.
enum IncomingTalentGovernanceDecisionLedgerStatus {
  clear('Clear'),
  blocked('Blocked'),
  needsDecision('Needs decision'),
  needsEvidence('Needs evidence'),
  needsOwner('Needs owner'),
  readyToPublish('Ready');

  final String label;

  const IncomingTalentGovernanceDecisionLedgerStatus(this.label);
}

/// Executive decision record prepared from a talent governance review item.
class IncomingTalentGovernanceDecisionLedgerItem {
  final String id;
  final String reviewItemId;
  final IncomingTalentGovernanceDecisionLedgerType type;
  final IncomingTalentGovernanceDecisionLedgerStatus status;
  final String title;
  final String decisionRecord;
  final String commitment;
  final String evidenceExpectation;
  final String ownerName;
  final DateTime dueDate;
  final int signalCount;
  final int decisionCount;
  final int timeboxMinutes;
  final List<String> readinessTaskIds;

  const IncomingTalentGovernanceDecisionLedgerItem({
    required this.id,
    required this.reviewItemId,
    required this.type,
    required this.status,
    required this.title,
    required this.decisionRecord,
    required this.commitment,
    required this.evidenceExpectation,
    required this.ownerName,
    required this.dueDate,
    required this.signalCount,
    required this.decisionCount,
    required this.timeboxMinutes,
    required this.readinessTaskIds,
  });

  bool get isPublishable {
    return status == IncomingTalentGovernanceDecisionLedgerStatus.clear ||
        status == IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish;
  }

  bool get needsAttention => !isPublishable;

  int get urgencyRank {
    return switch (status) {
      IncomingTalentGovernanceDecisionLedgerStatus.blocked => 0,
      IncomingTalentGovernanceDecisionLedgerStatus.needsDecision => 1,
      IncomingTalentGovernanceDecisionLedgerStatus.needsEvidence => 2,
      IncomingTalentGovernanceDecisionLedgerStatus.needsOwner => 3,
      IncomingTalentGovernanceDecisionLedgerStatus.readyToPublish => 4,
      IncomingTalentGovernanceDecisionLedgerStatus.clear => 5,
    };
  }
}
