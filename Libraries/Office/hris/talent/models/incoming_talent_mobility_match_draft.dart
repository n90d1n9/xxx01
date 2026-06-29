import 'incoming_talent_mobility_match.dart';
import 'incoming_talent_mobility_match_policy.dart';
import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';
import 'incoming_talent_succession_panel_decision.dart';

class IncomingTalentMobilityMatchDraft {
  final String decisionId;
  final String nominationId;
  final String candidateId;
  final String candidateName;
  final String currentRole;
  final String department;
  final String targetRole;
  final String opportunityTitle;
  final String hostDepartment;
  final String sponsorName;
  final String mobilityOwnerName;
  final IncomingTalentSuccessionNominationType? nominationType;
  final IncomingTalentSuccessionReadiness? readiness;
  final IncomingTalentSuccessionRisk? risk;
  final IncomingTalentMobilityMoveType? moveType;
  final IncomingTalentMobilityMatchStatus? status;
  final int fitScore;
  final DateTime? startDate;
  final DateTime? reviewDate;
  final String businessRationale;
  final String successMeasure;
  final String supportPlan;
  final DateTime asOfDate;

  const IncomingTalentMobilityMatchDraft({
    required this.decisionId,
    required this.nominationId,
    required this.candidateId,
    required this.candidateName,
    required this.currentRole,
    required this.department,
    required this.targetRole,
    required this.opportunityTitle,
    required this.hostDepartment,
    required this.sponsorName,
    required this.mobilityOwnerName,
    required this.nominationType,
    required this.readiness,
    required this.risk,
    required this.moveType,
    required this.status,
    required this.fitScore,
    required this.startDate,
    required this.reviewDate,
    required this.businessRationale,
    required this.successMeasure,
    required this.supportPlan,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityMatchDraft.empty(DateTime asOfDate) {
    return IncomingTalentMobilityMatchDraft(
      decisionId: '',
      nominationId: '',
      candidateId: '',
      candidateName: '',
      currentRole: '',
      department: '',
      targetRole: '',
      opportunityTitle: '',
      hostDepartment: '',
      sponsorName: '',
      mobilityOwnerName: '',
      nominationType: null,
      readiness: null,
      risk: null,
      moveType: null,
      status: null,
      fitScore: 0,
      startDate: null,
      reviewDate: null,
      businessRationale: '',
      successMeasure: '',
      supportPlan: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityMatchDraft.fromDecision({
    required IncomingTalentSuccessionPanelDecision decision,
    required DateTime asOfDate,
  }) {
    final moveType = defaultIncomingTalentMobilityMoveType(decision);
    final startDate =
        decision.activationDate.isBefore(asOfDate)
            ? asOfDate
            : decision.activationDate;

    return IncomingTalentMobilityMatchDraft(
      decisionId: decision.id,
      nominationId: decision.nominationId,
      candidateId: decision.candidateId,
      candidateName: decision.candidateName,
      currentRole: decision.role,
      department: decision.department,
      targetRole: decision.targetRole,
      opportunityTitle: defaultIncomingTalentMobilityOpportunityTitle(decision),
      hostDepartment: decision.department,
      sponsorName: decision.followUpOwner,
      mobilityOwnerName: decision.panelLeadName,
      nominationType: decision.nominationType,
      readiness: decision.readiness,
      risk: decision.risk,
      moveType: moveType,
      status: IncomingTalentMobilityMatchStatus.proposed,
      fitScore: defaultIncomingTalentMobilityFitScore(decision),
      startDate: startDate,
      reviewDate: startDate.add(const Duration(days: 45)),
      businessRationale: defaultIncomingTalentMobilityBusinessRationale(
        decision,
      ),
      successMeasure: defaultIncomingTalentMobilitySuccessMeasure(decision),
      supportPlan: defaultIncomingTalentMobilitySupportPlan(decision),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityMatchDraft copyWith({
    String? decisionId,
    String? nominationId,
    String? candidateId,
    String? candidateName,
    String? currentRole,
    String? department,
    String? targetRole,
    String? opportunityTitle,
    String? hostDepartment,
    String? sponsorName,
    String? mobilityOwnerName,
    IncomingTalentSuccessionNominationType? nominationType,
    IncomingTalentSuccessionReadiness? readiness,
    IncomingTalentSuccessionRisk? risk,
    IncomingTalentMobilityMoveType? moveType,
    IncomingTalentMobilityMatchStatus? status,
    int? fitScore,
    DateTime? startDate,
    DateTime? reviewDate,
    String? businessRationale,
    String? successMeasure,
    String? supportPlan,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityMatchDraft(
      decisionId: decisionId ?? this.decisionId,
      nominationId: nominationId ?? this.nominationId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      currentRole: currentRole ?? this.currentRole,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      hostDepartment: hostDepartment ?? this.hostDepartment,
      sponsorName: sponsorName ?? this.sponsorName,
      mobilityOwnerName: mobilityOwnerName ?? this.mobilityOwnerName,
      nominationType: nominationType ?? this.nominationType,
      readiness: readiness ?? this.readiness,
      risk: risk ?? this.risk,
      moveType: moveType ?? this.moveType,
      status: status ?? this.status,
      fitScore: fitScore ?? this.fitScore,
      startDate: startDate ?? this.startDate,
      reviewDate: reviewDate ?? this.reviewDate,
      businessRationale: businessRationale ?? this.businessRationale,
      successMeasure: successMeasure ?? this.successMeasure,
      supportPlan: supportPlan ?? this.supportPlan,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  double get completionRatio {
    final completed =
        [
          decisionId.trim().isNotEmpty,
          opportunityTitle.trim().isNotEmpty,
          hostDepartment.trim().isNotEmpty,
          sponsorName.trim().isNotEmpty,
          mobilityOwnerName.trim().isNotEmpty,
          moveType != null,
          status != null,
          startDate != null,
          reviewDate != null,
          businessRationale.trim().length >= 12,
          successMeasure.trim().length >= 12,
          supportPlan.trim().length >= 12,
        ].where((item) => item).length;

    return completed / 12;
  }

  List<String> get validationErrors {
    return [
      if (validateIncomingTalentMobilityRequired(decisionId, 'a panel decision')
          case final error?)
        error,
      if (validateIncomingTalentMobilityRequired(
            opportunityTitle,
            'an opportunity title',
          )
          case final error?)
        error,
      if (validateIncomingTalentMobilityRequired(
            hostDepartment,
            'a host department',
          )
          case final error?)
        error,
      if (validateIncomingTalentMobilityRequired(sponsorName, 'a sponsor')
          case final error?)
        error,
      if (validateIncomingTalentMobilityRequired(
            mobilityOwnerName,
            'a mobility owner',
          )
          case final error?)
        error,
      if (validateIncomingTalentMobilityMoveType(moveType) case final error?)
        error,
      if (validateIncomingTalentMobilityStatus(status) case final error?) error,
      if (validateIncomingTalentMobilityFitScore(fitScore) case final error?)
        error,
      if (validateIncomingTalentMobilityStartDate(startDate, asOfDate)
          case final error?)
        error,
      if (validateIncomingTalentMobilityReviewDate(startDate, reviewDate)
          case final error?)
        error,
      if (incomingTalentMobilityLongTextError(
            businessRationale,
            'business rationale',
          )
          case final error?)
        error,
      if (incomingTalentMobilityLongTextError(successMeasure, 'success measure')
          case final error?)
        error,
      if (incomingTalentMobilityLongTextError(supportPlan, 'support plan')
          case final error?)
        error,
    ];
  }

  bool get isReadyToSubmit => validationErrors.isEmpty;

  IncomingTalentMobilityMatch toMatch({
    required String id,
    required DateTime createdAt,
  }) {
    return IncomingTalentMobilityMatch(
      id: id,
      decisionId: decisionId,
      nominationId: nominationId,
      candidateId: candidateId,
      candidateName: candidateName.trim(),
      currentRole: currentRole.trim(),
      department: department.trim(),
      targetRole: targetRole.trim(),
      opportunityTitle: opportunityTitle.trim(),
      hostDepartment: hostDepartment.trim(),
      sponsorName: sponsorName.trim(),
      mobilityOwnerName: mobilityOwnerName.trim(),
      nominationType: nominationType!,
      readiness: readiness!,
      risk: risk!,
      moveType: moveType!,
      status: status!,
      fitScore: fitScore,
      startDate: startDate!,
      reviewDate: reviewDate!,
      businessRationale: businessRationale.trim(),
      successMeasure: successMeasure.trim(),
      supportPlan: supportPlan.trim(),
      createdAt: createdAt,
    );
  }
}
