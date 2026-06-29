import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome.dart';
import 'incoming_talent_mobility_cadence_intervention_outcome_policy.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

class IncomingTalentMobilityCadenceInterventionOutcomeDraft {
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
  final IncomingTalentMobilityCadenceStatus? cadenceStatusBefore;
  final IncomingTalentMobilityStabilizationResidualRisk? residualRiskBefore;
  final int hostConfidenceBefore;
  final IncomingTalentMobilityCadenceInterventionType? interventionType;
  final IncomingTalentMobilityCadenceInterventionPriority? priority;
  final IncomingTalentMobilityCadenceInterventionStatus? interventionStatus;
  final String interventionOwnerName;
  final String interventionSummary;
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentMobilityCadenceInterventionOutcomeDecision? decision;
  final IncomingTalentMobilityCadenceInterventionSustainability? sustainability;
  final IncomingTalentMobilityStabilizationResidualRisk? residualRiskAfter;
  final int hostConfidenceAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCadenceAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentMobilityCadenceInterventionOutcomeDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentMobilityCadenceInterventionOutcomeDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentMobilityCadenceInterventionOutcomeDraft(
      interventionId: '',
      checkInId: '',
      outcomeId: '',
      actionId: '',
      reviewId: '',
      checklistId: '',
      matchId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      currentRole: '',
      department: '',
      targetRole: '',
      opportunityTitle: '',
      hostDepartment: '',
      cadenceStatusBefore: null,
      residualRiskBefore: null,
      hostConfidenceBefore: 0,
      interventionType: null,
      priority: null,
      interventionStatus: null,
      interventionOwnerName: '',
      interventionSummary: '',
      reviewerName: '',
      reviewDate: null,
      decision: null,
      sustainability: null,
      residualRiskAfter: null,
      hostConfidenceAfter: 0,
      evidenceSummary: '',
      learningSummary: '',
      nextCadenceAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityCadenceInterventionOutcomeDraft.fromIntervention({
    required IncomingTalentMobilityCadenceIntervention intervention,
    required DateTime asOfDate,
  }) {
    final decision =
        defaultIncomingTalentMobilityCadenceInterventionOutcomeDecision(
          intervention,
        );

    return IncomingTalentMobilityCadenceInterventionOutcomeDraft(
      interventionId: intervention.id,
      checkInId: intervention.checkInId,
      outcomeId: intervention.outcomeId,
      actionId: intervention.actionId,
      reviewId: intervention.reviewId,
      checklistId: intervention.checklistId,
      matchId: intervention.matchId,
      decisionId: intervention.decisionId,
      candidateId: intervention.candidateId,
      candidateName: intervention.candidateName,
      currentRole: intervention.currentRole,
      department: intervention.department,
      targetRole: intervention.targetRole,
      opportunityTitle: intervention.opportunityTitle,
      hostDepartment: intervention.hostDepartment,
      cadenceStatusBefore: intervention.cadenceStatus,
      residualRiskBefore: intervention.residualRisk,
      hostConfidenceBefore: intervention.hostConfidenceScore,
      interventionType: intervention.interventionType,
      priority: intervention.priority,
      interventionStatus: intervention.status,
      interventionOwnerName: intervention.ownerName,
      interventionSummary: intervention.interventionSummary,
      reviewerName: intervention.ownerName,
      reviewDate: asOfDate,
      decision: decision,
      sustainability:
          defaultIncomingTalentMobilityCadenceInterventionSustainability(
            intervention,
          ),
      residualRiskAfter:
          defaultIncomingTalentMobilityCadenceInterventionResidualRiskAfter(
            intervention,
          ),
      hostConfidenceAfter:
          defaultIncomingTalentMobilityCadenceInterventionConfidenceAfter(
            intervention,
          ),
      evidenceSummary:
          defaultIncomingTalentMobilityCadenceInterventionOutcomeEvidence(
            intervention,
          ),
      learningSummary:
          defaultIncomingTalentMobilityCadenceInterventionOutcomeLearning(
            intervention,
          ),
      nextCadenceAction:
          defaultIncomingTalentMobilityCadenceInterventionNextAction(decision),
      nextReviewDate:
          defaultIncomingTalentMobilityCadenceInterventionNextReviewDate(
            decision: decision,
            asOfDate: asOfDate,
          ),
      asOfDate: asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeRequired(
      value,
      fieldName,
    );
  }

  static String? validateInterventionStatus(
    IncomingTalentMobilityCadenceInterventionStatus? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeStatus(
      value,
    );
  }

  static String? validateDecision(
    IncomingTalentMobilityCadenceInterventionOutcomeDecision? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeDecision(
      value,
    );
  }

  static String? validateSustainability(
    IncomingTalentMobilityCadenceInterventionSustainability? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionSustainability(
      value,
    );
  }

  static String? validateResidualRisk(
    IncomingTalentMobilityStabilizationResidualRisk? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeRisk(value);
  }

  static String? validateHostConfidenceAfter(int value) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeConfidence(
      value,
    );
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeReviewDate(
      value,
      asOfDate,
    );
  }

  static String? validateNextReviewDate(
    DateTime? reviewDate,
    DateTime? nextReviewDate,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeNextReviewDate(
      reviewDate,
      nextReviewDate,
    );
  }

  static String? validateEvidenceSummary(String? value) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeEvidence(
      value,
    );
  }

  static String? validateLearningSummary(String? value) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeLearning(
      value,
    );
  }

  static String? validateNextCadenceAction(String? value) {
    return validateIncomingTalentMobilityCadenceInterventionOutcomeNextAction(
      value,
    );
  }
}
