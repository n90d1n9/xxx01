import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_stabilization_action.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';
import 'incoming_talent_mobility_stabilization_outcome_policy.dart';

class IncomingTalentMobilityStabilizationOutcomeDraft {
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
  final IncomingTalentMobilityStabilizationActionType? actionType;
  final IncomingTalentMobilityStabilizationStatus? actionStatus;
  final String actionOwnerName;
  final String actionSummary;
  final IncomingTalentMobilityFirstReviewOutcome? reviewOutcomeBefore;
  final IncomingTalentMobilityFirstReviewRetentionRisk? retentionRiskBefore;
  final int hostConfidenceBefore;
  final String reviewerName;
  final DateTime? outcomeDate;
  final IncomingTalentMobilityStabilizationOutcomeDecision? decision;
  final IncomingTalentMobilityStabilizationResidualRisk? residualRisk;
  final int hostConfidenceAfter;
  final String evidenceSummary;
  final String learningSummary;
  final String nextCadenceAction;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentMobilityStabilizationOutcomeDraft({
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
    required this.asOfDate,
  });

  factory IncomingTalentMobilityStabilizationOutcomeDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentMobilityStabilizationOutcomeDraft(
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
      actionType: null,
      actionStatus: null,
      actionOwnerName: '',
      actionSummary: '',
      reviewOutcomeBefore: null,
      retentionRiskBefore: null,
      hostConfidenceBefore: 0,
      reviewerName: '',
      outcomeDate: null,
      decision: null,
      residualRisk: null,
      hostConfidenceAfter: 0,
      evidenceSummary: '',
      learningSummary: '',
      nextCadenceAction: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityStabilizationOutcomeDraft.fromAction({
    required IncomingTalentMobilityStabilizationAction action,
    required DateTime asOfDate,
  }) {
    final decision = defaultIncomingTalentMobilityStabilizationOutcomeDecision(
      action,
    );

    return IncomingTalentMobilityStabilizationOutcomeDraft(
      actionId: action.id,
      reviewId: action.reviewId,
      checklistId: action.checklistId,
      matchId: action.matchId,
      decisionId: action.decisionId,
      candidateId: action.candidateId,
      candidateName: action.candidateName,
      currentRole: action.currentRole,
      department: action.department,
      targetRole: action.targetRole,
      opportunityTitle: action.opportunityTitle,
      hostDepartment: action.hostDepartment,
      actionType: action.actionType,
      actionStatus: action.status,
      actionOwnerName: action.ownerName,
      actionSummary: action.actionSummary,
      reviewOutcomeBefore: action.reviewOutcome,
      retentionRiskBefore: action.retentionRisk,
      hostConfidenceBefore: action.hostConfidenceScore,
      reviewerName: action.ownerName,
      outcomeDate: asOfDate,
      decision: decision,
      residualRisk: defaultIncomingTalentMobilityStabilizationResidualRisk(
        action,
      ),
      hostConfidenceAfter:
          defaultIncomingTalentMobilityStabilizationConfidenceAfter(action),
      evidenceSummary:
          defaultIncomingTalentMobilityStabilizationOutcomeEvidence(action),
      learningSummary:
          defaultIncomingTalentMobilityStabilizationOutcomeLearning(action),
      nextCadenceAction:
          defaultIncomingTalentMobilityStabilizationOutcomeNextAction(decision),
      nextReviewDate:
          defaultIncomingTalentMobilityStabilizationOutcomeNextReviewDate(
            decision: decision,
            asOfDate: asOfDate,
          ),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityStabilizationOutcomeDraft copyWith({
    String? actionId,
    String? reviewId,
    String? checklistId,
    String? matchId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? currentRole,
    String? department,
    String? targetRole,
    String? opportunityTitle,
    String? hostDepartment,
    IncomingTalentMobilityStabilizationActionType? actionType,
    IncomingTalentMobilityStabilizationStatus? actionStatus,
    String? actionOwnerName,
    String? actionSummary,
    IncomingTalentMobilityFirstReviewOutcome? reviewOutcomeBefore,
    IncomingTalentMobilityFirstReviewRetentionRisk? retentionRiskBefore,
    int? hostConfidenceBefore,
    String? reviewerName,
    DateTime? outcomeDate,
    IncomingTalentMobilityStabilizationOutcomeDecision? decision,
    IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
    int? hostConfidenceAfter,
    String? evidenceSummary,
    String? learningSummary,
    String? nextCadenceAction,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityStabilizationOutcomeDraft(
      actionId: actionId ?? this.actionId,
      reviewId: reviewId ?? this.reviewId,
      checklistId: checklistId ?? this.checklistId,
      matchId: matchId ?? this.matchId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      currentRole: currentRole ?? this.currentRole,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      hostDepartment: hostDepartment ?? this.hostDepartment,
      actionType: actionType ?? this.actionType,
      actionStatus: actionStatus ?? this.actionStatus,
      actionOwnerName: actionOwnerName ?? this.actionOwnerName,
      actionSummary: actionSummary ?? this.actionSummary,
      reviewOutcomeBefore: reviewOutcomeBefore ?? this.reviewOutcomeBefore,
      retentionRiskBefore: retentionRiskBefore ?? this.retentionRiskBefore,
      hostConfidenceBefore: hostConfidenceBefore ?? this.hostConfidenceBefore,
      reviewerName: reviewerName ?? this.reviewerName,
      outcomeDate: outcomeDate ?? this.outcomeDate,
      decision: decision ?? this.decision,
      residualRisk: residualRisk ?? this.residualRisk,
      hostConfidenceAfter: hostConfidenceAfter ?? this.hostConfidenceAfter,
      evidenceSummary: evidenceSummary ?? this.evidenceSummary,
      learningSummary: learningSummary ?? this.learningSummary,
      nextCadenceAction: nextCadenceAction ?? this.nextCadenceAction,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityStabilizationOutcomeRequired(
      value,
      fieldName,
    );
  }

  static String? validateActionStatus(
    IncomingTalentMobilityStabilizationStatus? value,
  ) {
    return validateIncomingTalentMobilityStabilizationOutcomeActionStatus(
      value,
    );
  }

  static String? validateDecision(
    IncomingTalentMobilityStabilizationOutcomeDecision? value,
  ) {
    return validateIncomingTalentMobilityStabilizationOutcomeDecision(value);
  }

  static String? validateResidualRisk(
    IncomingTalentMobilityStabilizationResidualRisk? value,
  ) {
    return validateIncomingTalentMobilityStabilizationOutcomeResidualRisk(
      value,
    );
  }

  static String? validateHostConfidenceAfter(int value) {
    return validateIncomingTalentMobilityStabilizationOutcomeConfidence(value);
  }

  static String? validateOutcomeDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityStabilizationOutcomeDate(
      value,
      asOfDate,
    );
  }

  static String? validateNextReviewDate(
    DateTime? outcomeDate,
    DateTime? nextReviewDate,
  ) {
    return validateIncomingTalentMobilityStabilizationOutcomeNextReviewDate(
      outcomeDate,
      nextReviewDate,
    );
  }

  static String? validateEvidenceSummary(String? value) {
    return validateIncomingTalentMobilityStabilizationOutcomeEvidence(value);
  }

  static String? validateLearningSummary(String? value) {
    return validateIncomingTalentMobilityStabilizationOutcomeLearning(value);
  }

  static String? validateNextCadenceAction(String? value) {
    return validateIncomingTalentMobilityStabilizationOutcomeNextAction(value);
  }
}
