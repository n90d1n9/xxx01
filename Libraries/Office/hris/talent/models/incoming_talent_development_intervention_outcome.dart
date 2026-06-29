import 'incoming_talent_development_intervention_models.dart';

enum IncomingTalentDevelopmentInterventionOutcomeDecision {
  improved('Improved'),
  stabilized('Stabilized'),
  monitor('Monitor'),
  escalate('Escalate');

  final String label;

  const IncomingTalentDevelopmentInterventionOutcomeDecision(this.label);
}

class IncomingTalentDevelopmentInterventionOutcome {
  final String id;
  final String interventionId;
  final String checkInId;
  final String activationFollowUpId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentDevelopmentInterventionSource source;
  final IncomingTalentDevelopmentInterventionType interventionType;
  final IncomingTalentDevelopmentInterventionPriority priority;
  final int confidenceBefore;
  final int confidenceAfter;
  final int releaseEvidenceCount;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeDecision decision;
  final String evidenceSummary;
  final String learningSummary;
  final String nextAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentDevelopmentInterventionOutcome({
    required this.id,
    required this.interventionId,
    required this.checkInId,
    required this.activationFollowUpId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.reviewDate,
    required this.source,
    required this.interventionType,
    required this.priority,
    required this.confidenceBefore,
    required this.confidenceAfter,
    required this.releaseEvidenceCount,
    required this.remainingReleaseRiskCount,
    required this.decision,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision ==
            IncomingTalentDevelopmentInterventionOutcomeDecision.monitor ||
        decision ==
            IncomingTalentDevelopmentInterventionOutcomeDecision.escalate ||
        confidenceAfter <= 3 ||
        remainingReleaseRiskCount > 0;
  }

  int get confidenceDelta => confidenceAfter - confidenceBefore;

  double get confidenceRatio => confidenceAfter / 5;
}
