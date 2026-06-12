enum IncomingTalentRiskCouncilReadinessChecklistCategory {
  councilPack('Council pack'),
  decisionPrep('Decision prep'),
  escalationPrep('Escalation prep'),
  followUpPlanning('Follow-up planning'),
  evidenceReview('Evidence review'),
  ownerConfirmation('Owner confirmation');

  final String label;

  const IncomingTalentRiskCouncilReadinessChecklistCategory(this.label);
}

enum IncomingTalentRiskCouncilReadinessChecklistStatus {
  ready('Ready'),
  needsPrep('Needs prep'),
  blocked('Blocked'),
  overdue('Overdue');

  final String label;

  const IncomingTalentRiskCouncilReadinessChecklistStatus(this.label);
}

class IncomingTalentRiskCouncilReadinessChecklistItem {
  final String id;
  final IncomingTalentRiskCouncilReadinessChecklistCategory category;
  final IncomingTalentRiskCouncilReadinessChecklistStatus status;
  final String title;
  final String detail;
  final String ownerName;
  final DateTime dueDate;
  final int sourceCount;

  const IncomingTalentRiskCouncilReadinessChecklistItem({
    required this.id,
    required this.category,
    required this.status,
    required this.title,
    required this.detail,
    required this.ownerName,
    required this.dueDate,
    required this.sourceCount,
  });

  bool get isReady {
    return status == IncomingTalentRiskCouncilReadinessChecklistStatus.ready;
  }

  bool get needsAttention => !isReady;

  int get urgencyRank {
    return switch (status) {
      IncomingTalentRiskCouncilReadinessChecklistStatus.blocked => 0,
      IncomingTalentRiskCouncilReadinessChecklistStatus.overdue => 1,
      IncomingTalentRiskCouncilReadinessChecklistStatus.needsPrep => 2,
      IncomingTalentRiskCouncilReadinessChecklistStatus.ready => 3,
    };
  }
}
