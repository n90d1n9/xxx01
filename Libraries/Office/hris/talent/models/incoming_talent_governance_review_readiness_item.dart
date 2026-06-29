/// Preparation category for an executive talent governance review item.
enum IncomingTalentGovernanceReviewReadinessCategory {
  decisionBrief('Decision brief'),
  escalationPrep('Escalation prep'),
  capacityPlan('Capacity plan'),
  ownerConfirmation('Owner confirmation'),
  evidencePack('Evidence pack'),
  facilitationPlan('Facilitation plan');

  final String label;

  const IncomingTalentGovernanceReviewReadinessCategory(this.label);
}

/// Preparation status for an executive talent governance review task.
enum IncomingTalentGovernanceReviewReadinessStatus {
  ready('Ready'),
  needsPrep('Needs prep'),
  blocked('Blocked');

  final String label;

  const IncomingTalentGovernanceReviewReadinessStatus(this.label);
}

/// Checklist task required before the talent governance review can run.
class IncomingTalentGovernanceReviewReadinessItem {
  final String id;
  final String sourceReviewItemId;
  final IncomingTalentGovernanceReviewReadinessCategory category;
  final IncomingTalentGovernanceReviewReadinessStatus status;
  final String title;
  final String detail;
  final String ownerName;
  final String evidencePrompt;
  final DateTime dueDate;
  final int signalCount;
  final int decisionCount;
  final int timeboxMinutes;

  const IncomingTalentGovernanceReviewReadinessItem({
    required this.id,
    required this.sourceReviewItemId,
    required this.category,
    required this.status,
    required this.title,
    required this.detail,
    required this.ownerName,
    required this.evidencePrompt,
    required this.dueDate,
    required this.signalCount,
    required this.decisionCount,
    required this.timeboxMinutes,
  });

  bool get isReady {
    return status == IncomingTalentGovernanceReviewReadinessStatus.ready;
  }

  bool get needsAttention => !isReady;

  int get urgencyRank {
    return switch (status) {
      IncomingTalentGovernanceReviewReadinessStatus.blocked => 0,
      IncomingTalentGovernanceReviewReadinessStatus.needsPrep => 1,
      IncomingTalentGovernanceReviewReadinessStatus.ready => 2,
    };
  }
}
