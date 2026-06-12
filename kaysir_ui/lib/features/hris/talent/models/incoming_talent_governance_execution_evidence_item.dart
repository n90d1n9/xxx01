/// Audit status for governance execution evidence.
enum IncomingTalentGovernanceExecutionEvidenceStatus {
  missing('Missing'),
  accepted('Accepted'),
  monitor('Monitor'),
  reopened('Reopened'),
  escalated('Escalated');

  final String label;

  const IncomingTalentGovernanceExecutionEvidenceStatus(this.label);
}

/// Evidence register item for a governance execution action or closure.
class IncomingTalentGovernanceExecutionEvidenceItem {
  final String id;
  final String actionId;
  final String trackId;
  final IncomingTalentGovernanceExecutionEvidenceStatus status;
  final String title;
  final String evidenceRequirement;
  final String evidenceSummary;
  final String ownerConfirmationNote;
  final String ownerName;
  final String reviewerName;
  final DateTime dueDate;
  final DateTime? closureDate;
  final DateTime? nextReviewDate;
  final int residualRiskCount;
  final int signalCount;
  final int decisionCount;
  final double readinessRatio;

  const IncomingTalentGovernanceExecutionEvidenceItem({
    required this.id,
    required this.actionId,
    required this.trackId,
    required this.status,
    required this.title,
    required this.evidenceRequirement,
    required this.evidenceSummary,
    required this.ownerConfirmationNote,
    required this.ownerName,
    required this.reviewerName,
    required this.dueDate,
    required this.closureDate,
    required this.nextReviewDate,
    required this.residualRiskCount,
    required this.signalCount,
    required this.decisionCount,
    required this.readinessRatio,
  });

  bool get hasEvidence {
    return status != IncomingTalentGovernanceExecutionEvidenceStatus.missing;
  }

  bool get needsAttention {
    return !hasEvidence ||
        status == IncomingTalentGovernanceExecutionEvidenceStatus.monitor ||
        status == IncomingTalentGovernanceExecutionEvidenceStatus.reopened ||
        status == IncomingTalentGovernanceExecutionEvidenceStatus.escalated ||
        residualRiskCount > 0;
  }

  double get normalizedReadinessRatio {
    if (readinessRatio < 0) return 0;
    if (readinessRatio > 1) return 1;
    return readinessRatio;
  }

  int get urgencyRank {
    return switch (status) {
      IncomingTalentGovernanceExecutionEvidenceStatus.escalated => 0,
      IncomingTalentGovernanceExecutionEvidenceStatus.reopened => 1,
      IncomingTalentGovernanceExecutionEvidenceStatus.missing => 2,
      IncomingTalentGovernanceExecutionEvidenceStatus.monitor => 3,
      IncomingTalentGovernanceExecutionEvidenceStatus.accepted => 4,
    };
  }
}
