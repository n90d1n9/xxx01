import 'incoming_talent_mobility_cadence_check_in.dart';
import 'incoming_talent_mobility_cadence_intervention.dart';
import 'incoming_talent_mobility_cadence_intervention_policy.dart';
import 'incoming_talent_mobility_stabilization_outcome.dart';

class IncomingTalentMobilityCadenceInterventionDraft {
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
  final IncomingTalentMobilityCadenceStatus? cadenceStatus;
  final IncomingTalentMobilityStabilizationResidualRisk? residualRisk;
  final int hostConfidenceScore;
  final IncomingTalentMobilityCadenceInterventionType? interventionType;
  final IncomingTalentMobilityCadenceInterventionPriority? priority;
  final IncomingTalentMobilityCadenceInterventionStatus? status;
  final String ownerName;
  final DateTime? dueDate;
  final String interventionSummary;
  final String successMeasure;
  final String blockerNote;
  final DateTime asOfDate;

  const IncomingTalentMobilityCadenceInterventionDraft({
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
    required this.cadenceStatus,
    required this.residualRisk,
    required this.hostConfidenceScore,
    required this.interventionType,
    required this.priority,
    required this.status,
    required this.ownerName,
    required this.dueDate,
    required this.interventionSummary,
    required this.successMeasure,
    required this.blockerNote,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityCadenceInterventionDraft.empty(
    DateTime asOfDate,
  ) {
    return IncomingTalentMobilityCadenceInterventionDraft(
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
      cadenceStatus: null,
      residualRisk: null,
      hostConfidenceScore: 0,
      interventionType: null,
      priority: null,
      status: null,
      ownerName: '',
      dueDate: null,
      interventionSummary: '',
      successMeasure: '',
      blockerNote: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityCadenceInterventionDraft.fromCheckIn({
    required IncomingTalentMobilityCadenceCheckIn checkIn,
    required DateTime asOfDate,
  }) {
    final priority = defaultIncomingTalentMobilityCadenceInterventionPriority(
      checkIn,
    );

    return IncomingTalentMobilityCadenceInterventionDraft(
      checkInId: checkIn.id,
      outcomeId: checkIn.outcomeId,
      actionId: checkIn.actionId,
      reviewId: checkIn.reviewId,
      checklistId: checkIn.checklistId,
      matchId: checkIn.matchId,
      decisionId: checkIn.decisionId,
      candidateId: checkIn.candidateId,
      candidateName: checkIn.candidateName,
      currentRole: checkIn.currentRole,
      department: checkIn.department,
      targetRole: checkIn.targetRole,
      opportunityTitle: checkIn.opportunityTitle,
      hostDepartment: checkIn.hostDepartment,
      cadenceStatus: checkIn.status,
      residualRisk: checkIn.residualRisk,
      hostConfidenceScore: checkIn.hostConfidenceScore,
      interventionType: defaultIncomingTalentMobilityCadenceInterventionType(
        checkIn,
      ),
      priority: priority,
      status: defaultIncomingTalentMobilityCadenceInterventionStatus(checkIn),
      ownerName: checkIn.reviewerName,
      dueDate: defaultIncomingTalentMobilityCadenceInterventionDueDate(
        priority: priority,
        asOfDate: asOfDate,
      ),
      interventionSummary:
          defaultIncomingTalentMobilityCadenceInterventionSummary(checkIn),
      successMeasure:
          defaultIncomingTalentMobilityCadenceInterventionSuccessMeasure(
            checkIn,
          ),
      blockerNote: '',
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityCadenceInterventionDraft copyWith({
    String? checkInId,
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
    IncomingTalentMobilityCadenceStatus? cadenceStatus,
    IncomingTalentMobilityStabilizationResidualRisk? residualRisk,
    int? hostConfidenceScore,
    IncomingTalentMobilityCadenceInterventionType? interventionType,
    IncomingTalentMobilityCadenceInterventionPriority? priority,
    IncomingTalentMobilityCadenceInterventionStatus? status,
    String? ownerName,
    DateTime? dueDate,
    String? interventionSummary,
    String? successMeasure,
    String? blockerNote,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityCadenceInterventionDraft(
      checkInId: checkInId ?? this.checkInId,
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
      cadenceStatus: cadenceStatus ?? this.cadenceStatus,
      residualRisk: residualRisk ?? this.residualRisk,
      hostConfidenceScore: hostConfidenceScore ?? this.hostConfidenceScore,
      interventionType: interventionType ?? this.interventionType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      ownerName: ownerName ?? this.ownerName,
      dueDate: dueDate ?? this.dueDate,
      interventionSummary: interventionSummary ?? this.interventionSummary,
      successMeasure: successMeasure ?? this.successMeasure,
      blockerNote: blockerNote ?? this.blockerNote,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityCadenceInterventionRequired(
      value,
      fieldName,
    );
  }

  static String? validateInterventionType(
    IncomingTalentMobilityCadenceInterventionType? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionType(value);
  }

  static String? validatePriority(
    IncomingTalentMobilityCadenceInterventionPriority? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionPriority(value);
  }

  static String? validateStatus(
    IncomingTalentMobilityCadenceInterventionStatus? value,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionStatus(value);
  }

  static String? validateDueDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityCadenceInterventionDueDate(
      value,
      asOfDate,
    );
  }

  static String? validateInterventionSummary(String? value) {
    return validateIncomingTalentMobilityCadenceInterventionSummary(value);
  }

  static String? validateSuccessMeasure(String? value) {
    return validateIncomingTalentMobilityCadenceInterventionSuccessMeasure(
      value,
    );
  }

  static String? validateBlockerNote(
    String? value,
    IncomingTalentMobilityCadenceInterventionStatus? status,
  ) {
    return validateIncomingTalentMobilityCadenceInterventionBlockerNote(
      value,
      status,
    );
  }
}
