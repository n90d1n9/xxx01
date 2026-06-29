import 'incoming_talent_development_intervention_outcome_follow_up.dart';
import 'incoming_talent_development_intervention_outcome_models.dart';

enum IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision {
  closed('Closed'),
  sustained('Sustained'),
  monitor('Monitor'),
  escalate('Escalate');

  final String label;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision(
    this.label,
  );
}

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution {
  final String id;
  final String followUpId;
  final String outcomeId;
  final String interventionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String ownerName;
  final String reviewerName;
  final DateTime followUpDueDate;
  final DateTime reviewDate;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpStatus sourceStatus;
  final IncomingTalentDevelopmentInterventionOutcomeDecision sourceDecision;
  final int confidenceBefore;
  final int confidenceAfter;
  final int remainingReleaseRiskCount;
  final IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  decision;
  final String evidenceSummary;
  final String managerNote;
  final String nextAction;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution({
    required this.id,
    required this.followUpId,
    required this.outcomeId,
    required this.interventionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.ownerName,
    required this.reviewerName,
    required this.followUpDueDate,
    required this.reviewDate,
    required this.sourceStatus,
    required this.sourceDecision,
    required this.confidenceBefore,
    required this.confidenceAfter,
    required this.remainingReleaseRiskCount,
    required this.decision,
    required this.evidenceSummary,
    required this.managerNote,
    required this.nextAction,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
                .monitor ||
        decision ==
            IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
                .escalate ||
        confidenceAfter <= 3 ||
        remainingReleaseRiskCount > 0;
  }

  int get confidenceDelta => confidenceAfter - confidenceBefore;

  double get confidenceRatio => confidenceAfter / 5;
}
