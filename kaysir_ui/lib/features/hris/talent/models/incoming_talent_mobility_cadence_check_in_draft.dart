import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_check_in_policy.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

class IncomingTalentMobilityCadenceCheckInDraft {
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
  final IncomingTalentMobilityStabilizationOutcomeDecision? outcomeDecision;
  final IncomingTalentMobilityStabilizationResidualRisk? previousResidualRisk;
  final int previousHostConfidence;
  final String reviewerName;
  final DateTime? checkInDate;
  final IncomingTalentMobilityCadenceStatus? status;
  final IncomingTalentMobilityStabilizationResidualRisk? residualRisk;
  final int hostConfidenceScore;
  final String pulseSummary;
  final String supportPlan;
  final DateTime? nextReviewDate;
  final DateTime asOfDate;

  const IncomingTalentMobilityCadenceCheckInDraft({
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
    required this.outcomeDecision,
    required this.previousResidualRisk,
    required this.previousHostConfidence,
    required this.reviewerName,
    required this.checkInDate,
    required this.status,
    required this.residualRisk,
    required this.hostConfidenceScore,
    required this.pulseSummary,
    required this.supportPlan,
    required this.nextReviewDate,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityCadenceCheckInDraft.empty(DateTime asOfDate) {
    return IncomingTalentMobilityCadenceCheckInDraft(
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
      outcomeDecision: null,
      previousResidualRisk: null,
      previousHostConfidence: 0,
      reviewerName: '',
      checkInDate: null,
      status: null,
      residualRisk: null,
      hostConfidenceScore: 0,
      pulseSummary: '',
      supportPlan: '',
      nextReviewDate: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityCadenceCheckInDraft.fromOutcome({
    required IncomingTalentMobilityStabilizationOutcome outcome,
    required DateTime asOfDate,
  }) {
    final status = defaultIncomingTalentMobilityCadenceStatus(outcome);

    return IncomingTalentMobilityCadenceCheckInDraft(
      outcomeId: outcome.id,
      actionId: outcome.actionId,
      reviewId: outcome.reviewId,
      checklistId: outcome.checklistId,
      matchId: outcome.matchId,
      decisionId: outcome.decisionId,
      candidateId: outcome.candidateId,
      candidateName: outcome.candidateName,
      currentRole: outcome.currentRole,
      department: outcome.department,
      targetRole: outcome.targetRole,
      opportunityTitle: outcome.opportunityTitle,
      hostDepartment: outcome.hostDepartment,
      outcomeDecision: outcome.decision,
      previousResidualRisk: outcome.residualRisk,
      previousHostConfidence: outcome.hostConfidenceAfter,
      reviewerName: outcome.reviewerName,
      checkInDate: asOfDate,
      status: status,
      residualRisk: outcome.residualRisk,
      hostConfidenceScore: outcome.hostConfidenceAfter,
      pulseSummary: defaultIncomingTalentMobilityCadencePulseSummary(outcome),
      supportPlan: defaultIncomingTalentMobilityCadenceSupportPlan(outcome),
      nextReviewDate: defaultIncomingTalentMobilityCadenceNextReviewDate(
        status: status,
        checkInDate: asOfDate,
      ),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityCadenceCheckInDraft copyWith({
    String? outcomeId,
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
    IncomingTalentMobilityStabilizationOutcomeDecision? outcomeDecision,
    IncomingTalentMobilityStabilizationResidualRisk? previousResidualRisk,
    int? previousHostConfidence,
    String? reviewerName,
    DateTime? checkInDate,
    IncomingTalentMobilityCadenceStatus? status,
    IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
    int? hostConfidenceScore,
    String? pulseSummary,
    String? supportPlan,
    DateTime? nextReviewDate,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityCadenceCheckInDraft(
      outcomeId: outcomeId ?? this.outcomeId,
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
      outcomeDecision: outcomeDecision ?? this.outcomeDecision,
      previousResidualRisk: previousResidualRisk ?? this.previousResidualRisk,
      previousHostConfidence:
          previousHostConfidence ?? this.previousHostConfidence,
      reviewerName: reviewerName ?? this.reviewerName,
      checkInDate: checkInDate ?? this.checkInDate,
      status: status ?? this.status,
      residualRisk: residualRisk ?? this.residualRisk,
      hostConfidenceScore: hostConfidenceScore ?? this.hostConfidenceScore,
      pulseSummary: pulseSummary ?? this.pulseSummary,
      supportPlan: supportPlan ?? this.supportPlan,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityCadenceRequired(value, fieldName);
  }

  static String? validateCheckInDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityCadenceCheckInDate(value, asOfDate);
  }

  static String? validateStatus(IncomingTalentMobilityCadenceStatus? value) {
    return validateIncomingTalentMobilityCadenceStatus(value);
  }

  static String? validateResidualRisk(
    IncomingTalentMobilityStabilizationResidualRisk? value,
  ) {
    return validateIncomingTalentMobilityCadenceResidualRisk(value);
  }

  static String? validateHostConfidence(int value) {
    return validateIncomingTalentMobilityCadenceConfidence(value);
  }

  static String? validatePulseSummary(String? value) {
    return validateIncomingTalentMobilityCadencePulse(value);
  }

  static String? validateSupportPlan(String? value) {
    return validateIncomingTalentMobilityCadenceSupportPlan(value);
  }

  static String? validateNextReviewDate(
    DateTime? checkInDate,
    DateTime? nextReviewDate,
  ) {
    return validateIncomingTalentMobilityCadenceNextReviewDate(
      checkInDate,
      nextReviewDate,
    );
  }
}
