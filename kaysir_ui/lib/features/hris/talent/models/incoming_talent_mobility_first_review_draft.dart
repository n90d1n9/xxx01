import 'incoming_talent_mobility_first_review.dart';
import 'incoming_talent_mobility_first_review_policy.dart';
import 'incoming_talent_mobility_launch_checklist.dart';

class IncomingTalentMobilityFirstReviewDraft {
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
  final String reviewerName;
  final DateTime? reviewDate;
  final IncomingTalentMobilityFirstReviewOutcome? outcome;
  final int hostConfidenceScore;
  final String deliverySignal;
  final String blockerNote;
  final IncomingTalentMobilityFirstReviewRetentionRisk? retentionRisk;
  final String nextAction;
  final DateTime? followUpDate;
  final IncomingTalentMobilityLaunchStatus? launchStatus;
  final DateTime asOfDate;

  const IncomingTalentMobilityFirstReviewDraft({
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
    required this.reviewerName,
    required this.reviewDate,
    required this.outcome,
    required this.hostConfidenceScore,
    required this.deliverySignal,
    required this.blockerNote,
    required this.retentionRisk,
    required this.nextAction,
    required this.followUpDate,
    required this.launchStatus,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityFirstReviewDraft.empty(DateTime asOfDate) {
    return IncomingTalentMobilityFirstReviewDraft(
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
      reviewerName: '',
      reviewDate: null,
      outcome: null,
      hostConfidenceScore: 0,
      deliverySignal: '',
      blockerNote: '',
      retentionRisk: null,
      nextAction: '',
      followUpDate: null,
      launchStatus: null,
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityFirstReviewDraft.fromChecklist({
    required IncomingTalentMobilityLaunchChecklist checklist,
    required DateTime asOfDate,
  }) {
    final reviewDate = defaultIncomingTalentMobilityFirstReviewCaptureDate(
      checklist: checklist,
      asOfDate: asOfDate,
    );

    return IncomingTalentMobilityFirstReviewDraft(
      checklistId: checklist.id,
      matchId: checklist.matchId,
      decisionId: checklist.decisionId,
      candidateId: checklist.candidateId,
      candidateName: checklist.candidateName,
      currentRole: checklist.currentRole,
      department: checklist.department,
      targetRole: checklist.targetRole,
      opportunityTitle: checklist.opportunityTitle,
      hostDepartment: checklist.hostDepartment,
      reviewerName: checklist.ownerName,
      reviewDate: reviewDate,
      outcome: defaultIncomingTalentMobilityFirstReviewOutcome(checklist),
      hostConfidenceScore: defaultIncomingTalentMobilityFirstReviewConfidence(
        checklist,
      ),
      deliverySignal: defaultIncomingTalentMobilityFirstReviewDeliverySignal(
        checklist,
      ),
      blockerNote: checklist.riskNote,
      retentionRisk: defaultIncomingTalentMobilityFirstReviewRetentionRisk(
        checklist,
      ),
      nextAction: defaultIncomingTalentMobilityFirstReviewNextAction(checklist),
      followUpDate: reviewDate.add(const Duration(days: 30)),
      launchStatus: checklist.status,
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityFirstReviewDraft copyWith({
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
    String? reviewerName,
    DateTime? reviewDate,
    IncomingTalentMobilityFirstReviewOutcome? outcome,
    int? hostConfidenceScore,
    String? deliverySignal,
    String? blockerNote,
    IncomingTalentMobilityFirstReviewRetentionRisk? retentionRisk,
    String? nextAction,
    DateTime? followUpDate,
    IncomingTalentMobilityLaunchStatus? launchStatus,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityFirstReviewDraft(
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
      reviewerName: reviewerName ?? this.reviewerName,
      reviewDate: reviewDate ?? this.reviewDate,
      outcome: outcome ?? this.outcome,
      hostConfidenceScore: hostConfidenceScore ?? this.hostConfidenceScore,
      deliverySignal: deliverySignal ?? this.deliverySignal,
      blockerNote: blockerNote ?? this.blockerNote,
      retentionRisk: retentionRisk ?? this.retentionRisk,
      nextAction: nextAction ?? this.nextAction,
      followUpDate: followUpDate ?? this.followUpDate,
      launchStatus: launchStatus ?? this.launchStatus,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityFirstReviewRequired(value, fieldName);
  }

  static String? validateOutcome(
    IncomingTalentMobilityFirstReviewOutcome? value,
  ) {
    return validateIncomingTalentMobilityFirstReviewOutcome(value);
  }

  static String? validateRetentionRisk(
    IncomingTalentMobilityFirstReviewRetentionRisk? value,
  ) {
    return validateIncomingTalentMobilityFirstReviewRetentionRisk(value);
  }

  static String? validateLaunchStatus(
    IncomingTalentMobilityLaunchStatus? value,
  ) {
    return validateIncomingTalentMobilityFirstReviewLaunchStatus(value);
  }

  static String? validateHostConfidenceScore(int value) {
    return validateIncomingTalentMobilityFirstReviewConfidenceScore(value);
  }

  static String? validateReviewDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityFirstReviewDate(value, asOfDate);
  }

  static String? validateFollowUpDate(
    DateTime? reviewDate,
    DateTime? followUpDate,
  ) {
    return validateIncomingTalentMobilityFirstReviewFollowUpDate(
      reviewDate,
      followUpDate,
    );
  }

  static String? validateDeliverySignal(String? value) {
    return validateIncomingTalentMobilityFirstReviewDeliverySignal(value);
  }

  static String? validateBlockerNote(
    String? value,
    IncomingTalentMobilityFirstReviewOutcome? outcome,
  ) {
    return validateIncomingTalentMobilityFirstReviewBlockerNote(value, outcome);
  }

  static String? validateNextAction(String? value) {
    return validateIncomingTalentMobilityFirstReviewNextAction(value);
  }
}
