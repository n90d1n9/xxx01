import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';

enum IncomingTalentSuccessionPanelOutcome {
  approvePromotion('Approve promotion'),
  approveSuccessionBench('Approve bench'),
  conditionalApproval('Conditional approval'),
  defer('Defer'),
  decline('Decline');

  final String label;

  const IncomingTalentSuccessionPanelOutcome(this.label);
}

class IncomingTalentSuccessionPanelDecision {
  final String id;
  final String nominationId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String panelLeadName;
  final String followUpOwner;
  final IncomingTalentSuccessionNominationType nominationType;
  final IncomingTalentSuccessionReadiness readiness;
  final IncomingTalentSuccessionRisk risk;
  final IncomingTalentSuccessionPanelOutcome outcome;
  final DateTime decisionDate;
  final DateTime activationDate;
  final DateTime nextReviewDate;
  final String decisionSummary;
  final String conditions;
  final String sponsorCommitment;
  final DateTime createdAt;

  const IncomingTalentSuccessionPanelDecision({
    required this.id,
    required this.nominationId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.panelLeadName,
    required this.followUpOwner,
    required this.nominationType,
    required this.readiness,
    required this.risk,
    required this.outcome,
    required this.decisionDate,
    required this.activationDate,
    required this.nextReviewDate,
    required this.decisionSummary,
    required this.conditions,
    required this.sponsorCommitment,
    required this.createdAt,
  });

  bool get isApproved {
    return outcome == IncomingTalentSuccessionPanelOutcome.approvePromotion ||
        outcome ==
            IncomingTalentSuccessionPanelOutcome.approveSuccessionBench ||
        outcome == IncomingTalentSuccessionPanelOutcome.conditionalApproval;
  }

  bool get needsAttention {
    return outcome ==
            IncomingTalentSuccessionPanelOutcome.conditionalApproval ||
        outcome == IncomingTalentSuccessionPanelOutcome.defer ||
        outcome == IncomingTalentSuccessionPanelOutcome.decline ||
        risk != IncomingTalentSuccessionRisk.low;
  }
}
