import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_stabilization_action.dart';

enum IncomingTalentMobilityStabilizationOutcomeDecision {
  resolved('Resolved'),
  improved('Improved'),
  monitor('Monitor'),
  escalate('Escalate');

  final String label;

  const IncomingTalentMobilityStabilizationOutcomeDecision(this.label);
}

enum IncomingTalentMobilityStabilizationResidualRisk {
  low('Low'),
  moderate('Moderate'),
  high('High');

  final String label;

  const IncomingTalentMobilityStabilizationResidualRisk(this.label);
}

class IncomingTalentMobilityStabilizationOutcome {
  final String id;
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
  final IncomingTalentMobilityStabilizationActionType actionType;
  final IncomingTalentMobilityStabilizationStatus actionStatus;
  final String actionOwnerName;
  final String actionSummary;
  final IncomingTalentMobilityFirstReviewOutcome reviewOutcomeBefore;
  final IncomingTalentMobilityFirstReviewRetentionRisk retentionRiskBefore;
  final int hostConfidenceBefore;
  final String reviewerName;
  final DateTime outcomeDate;
  final IncomingTalentMobilityStabilizationOutcomeDecision decision;
  final IncomingTalentMobilityStabilizationResidualRisk residualRisk;
  final int hostConfidenceAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCadenceAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentMobilityStabilizationOutcome({
    required this.id,
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
    required this.actionType,
    required this.actionStatus,
    required this.actionOwnerName,
    required this.actionSummary,
    required this.reviewOutcomeBefore,
    required this.retentionRiskBefore,
    required this.hostConfidenceBefore,
    required this.reviewerName,
    required this.outcomeDate,
    required this.decision,
    required this.residualRisk,
    required this.hostConfidenceAfter,
    required this.evidenceSummary,
    required this.learningSummary,
    required this.nextCadenceAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision ==
            IncomingTalentMobilityStabilizationOutcomeDecision.monitor ||
        decision ==
            IncomingTalentMobilityStabilizationOutcomeDecision.escalate ||
        residualRisk != IncomingTalentMobilityStabilizationResidualRisk.low ||
        hostConfidenceAfter <= 3;
  }

  int get confidenceImprovement => hostConfidenceAfter - hostConfidenceBefore;

  double get confidenceRatio => hostConfidenceAfter / 5;
}
