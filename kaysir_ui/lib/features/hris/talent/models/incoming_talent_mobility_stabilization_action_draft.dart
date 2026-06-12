import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_stabilization_action.dart';
import 'incoming_talent_mobility_stabilization_action_policy.dart';

class IncomingTalentMobilityStabilizationActionDraft {
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
  final IncomingTalentMobilityFirstReviewOutcome? reviewOutcome;
  final IncomingTalentMobilityFirstReviewRetentionRisk? retentionRisk;
  final int hostConfidenceScore;
  final IncomingTalentMobilityStabilizationActionType? actionType;
  final IncomingTalentMobilityStabilizationStatus? status;
  final String ownerName;
  final DateTime? dueDate;
  final String actionSummary;
  final String successMeasure;
  final String blockerNote;
  final DateTime asOfDate;

  const IncomingTalentMobilityStabilizationActionDraft({
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
    required this.reviewOutcome,
    required this.retentionRisk,
    required this.hostConfidenceScore,
    required this.actionType,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.actionSummary,
    required this.successMeasure,
    required this.blockerNote,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityStabilizationActionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentMobilityStabilizationActionDraft(
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
      reviewOutcome: null,
      retentionRisk: null,
      hostConfidenceScore: 0,
      actionType: null,
      status: null,
      ownerName: '',
      dueDate: null,
      actionSummary: '',
      successMeasure: '',
      blockerNote: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityStabilizationActionDraft.fromReview({
    required IncomingTalentMobilityFirstReview review,
    required DateTime asOfDate,
  }) {
    return IncomingTalentMobilityStabilizationActionDraft(
      reviewId: review.id,
      checklistId: review.checklistId,
      matchId: review.matchId,
      decisionId: review.decisionId,
      candidateId: review.candidateId,
      candidateName: review.candidateName,
      currentRole: review.currentRole,
      department: review.department,
      targetRole: review.targetRole,
      opportunityTitle: review.opportunityTitle,
      hostDepartment: review.hostDepartment,
      reviewOutcome: review.outcome,
      retentionRisk: review.retentionRisk,
      hostConfidenceScore: review.hostConfidenceScore,
      actionType: defaultIncomingTalentMobilityStabilizationActionType(review),
      status: defaultIncomingTalentMobilityStabilizationStatus(review),
      ownerName: review.reviewerName,
      dueDate: defaultIncomingTalentMobilityStabilizationDueDate(
        review: review,
        asOfDate: asOfDate,
      ),
      actionSummary: defaultIncomingTalentMobilityStabilizationActionSummary(
        review,
      ),
      successMeasure: defaultIncomingTalentMobilityStabilizationSuccessMeasure(
        review,
      ),
      blockerNote: review.blockerNote,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityStabilizationActionDraft copyWith({
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
    IncomingTalentMobilityFirstReviewOutcome? reviewOutcome,
    IncomingTalentMobilityFirstReviewRetentionRisk? retentionRisk,
    int? hostConfidenceScore,
    IncomingTalentMobilityStabilizationActionType? actionType,
    IncomingTalentMobilityStabilizationStatus? status,
    String? ownerName,
    DateTime? dueDate,
    String? actionSummary,
    String? successMeasure,
    String? blockerNote,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityStabilizationActionDraft(
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
      reviewOutcome: reviewOutcome ?? this.reviewOutcome,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      hostConfidenceScore: hostConfidenceScore ?? this.hostConfidenceScore,
      actionType: actionType ?? this.actionType,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      actionSummary: actionSummary ?? this.actionSummary,
      successMeasure: successMeasure ?? this.successMeasure,
      blockerNote: blockerNote ?? this.blockerNote,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityStabilizationRequired(
      value,
      fieldName,
    );
  }

  static String? validateActionType(
    IncomingTalentMobilityStabilizationActionType? value,
  ) {
    return validateIncomingTalentMobilityStabilizationActionType(value);
  }

  static String? validateStatus(
    IncomingTalentMobilityStabilizationStatus? value,
  ) {
    return validateIncomingTalentMobilityStabilizationStatus(value);
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityStabilizationDueDate(value, asOfDate);
  }

  static String? validateActionSummary(String? value) {
    return validateIncomingTalentMobilityStabilizationActionSummary(value);
  }

  static String? validateSuccessMeasure(String? value) {
    return validateIncomingTalentMobilityStabilizationSuccessMeasure(value);
  }

  static String? validateBlockerNote(
    String? value,
    IncomingTalentMobilityStabilizationStatus? status,
  ) {
    return validateIncomingTalentMobilityStabilizationBlockerNote(
      value,
      status,
    );
  }
}
