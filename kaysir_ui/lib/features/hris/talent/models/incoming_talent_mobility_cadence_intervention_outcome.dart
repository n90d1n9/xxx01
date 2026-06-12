import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

enum IncomingTalentMobilityCadenceInterventionOutcomeDecision {
  recovered('Recovered'),
  stabilized('Stabilized'),
  monitor('Monitor'),
  escalate('Escalate');

  final String label;

  const IncomingTalentMobilityCadenceInterventionOutcomeDecision(this.label);
}

enum IncomingTalentMobilityCadenceInterventionSustainability {
  strong('Strong'),
  moderate('Moderate'),
  fragile('Fragile');

  final String label;

  const IncomingTalentMobilityCadenceInterventionSustainability(this.label);
}

class IncomingTalentMobilityCadenceInterventionOutcome {
  final String id;
  final String interventionId;
  final String checkInId;
  final String outcomeId;
  final String actionId;
  final String reviewId;
  final String checklistId;
  final String matchId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String currentRole;
  final String department;
  final String targetRole;
  final String opportunityTitle;
  final String hostDepartment;
  final IncomingTalentMobilityCadenceStatus cadenceStatusBefore;
  final IncomingTalentMobilityStabilizationResidualRisk residualRiskBefore;
  final int hostConfidenceBefore;
  final IncomingTalentMobilityCadenceInterventionType interventionType;
  final IncomingTalentMobilityCadenceInterventionPriority priority;
  final IncomingTalentMobilityCadenceInterventionStatus interventionStatus;
  final String interventionOwnerName;
  final String interventionSummary;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentMobilityCadenceInterventionOutcomeDecision decision;
  final IncomingTalentMobilityCadenceInterventionSustainability sustainability;
  final IncomingTalentMobilityStabilizationResidualRisk residualRiskAfter;
  final int hostConfidenceAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCadenceAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentMobilityCadenceInterventionOutcome({
    required this.id,
    required this.interventionId,
    required this.checkInId,
    required this.outcomeId,
    required this.actionId,
    required this.reviewId,
    required this.checklistId,
    required this.matchId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.currentRole,
    required this.department,
    required this.targetRole,
    required this.opportunityTitle,
    required this.hostDepartment,
    required this.cadenceStatusBefore,
    required this.residualRiskBefore,
    required this.hostConfidenceBefore,
    required this.interventionType,
    required this.priority,
    required this.interventionStatus,
    required this.interventionOwnerName,
    required this.interventionSummary,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.sustainability,
    required this.residualRiskAfter,
    required this.hostConfidenceAfter,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextCadenceAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision ==
            IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor ||
        decision ==
            IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate ||
        sustainability ==
            IncomingTalentMobilityCadenceInterventionSustainability.fragile ||
        residualRiskAfter !=
            IncomingTalentMobilityStabilizationResidualRisk.low ||
        hostConfidenceAfter <= 3;
  }

  int get confidenceRecovery => hostConfidenceAfter - hostConfidenceBefore;

  double get confidenceRatio => hostConfidenceAfter / 5;
}
