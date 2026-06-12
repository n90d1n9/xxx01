import 'incoming_talent_mobility_launch_checklist.dart';
import 'incoming_talent_mobility_launch_checklist_policy.dart';
import 'incoming_talent_mobility_match.dart';

class IncomingTalentMobilityLaunchChecklistDraft {
  final String matchId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String currentRole;
  final String department;
  final String targetRole;
  final String opportunityTitle;
  final String hostDepartment;
  final String sponsorName;
  final String mobilityOwnerName;
  final IncomingTalentMobilityMoveType? moveType;
  final IncomingTalentMobilityMatchStatus? matchStatus;
  final IncomingTalentMobilityLaunchStatus? status;
  final int fitScore;
  final String ownerName;
  final DateTime? launchDate;
  final DateTime? firstReviewDate;
  final bool sponsorSignedOff;
  final bool hostManagerReady;
  final bool accessReady;
  final bool communicationReady;
  final bool backfillReady;
  final bool firstReviewScheduled;
  final String riskNote;
  final String launchNotes;
  final DateTime asOfDate;

  const IncomingTalentMobilityLaunchChecklistDraft({
    required this.matchId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.currentRole,
    required this.department,
    required this.targetRole,
    required this.opportunityTitle,
    required this.hostDepartment,
    required this.sponsorName,
    required this.mobilityOwnerName,
    required this.moveType,
    required this.matchStatus,
    required this.status,
    required this.fitScore,
    required this.ownerName,
    required this.launchDate,
    required this.firstReviewDate,
    required this.sponsorSignedOff,
    required this.hostManagerReady,
    required this.accessReady,
    required this.communicationReady,
    required this.backfillReady,
    required this.firstReviewScheduled,
    required this.riskNote,
    required this.launchNotes,
    required this.asOfDate,
  });

  factory IncomingTalentMobilityLaunchChecklistDraft.empty(DateTime asOfDate) {
    return IncomingTalentMobilityLaunchChecklistDraft(
      matchId: '',
      decisionId: '',
      candidateId: '',
      candidateName: '',
      currentRole: '',
      department: '',
      targetRole: '',
      opportunityTitle: '',
      hostDepartment: '',
      sponsorName: '',
      mobilityOwnerName: '',
      moveType: null,
      matchStatus: null,
      status: null,
      fitScore: 0,
      ownerName: '',
      launchDate: null,
      firstReviewDate: null,
      sponsorSignedOff: false,
      hostManagerReady: false,
      accessReady: false,
      communicationReady: false,
      backfillReady: false,
      firstReviewScheduled: false,
      riskNote: '',
      launchNotes: '',
      asOfDate: asOfDate,
    );
  }

  factory IncomingTalentMobilityLaunchChecklistDraft.fromMatch({
    required IncomingTalentMobilityMatch match,
    required DateTime asOfDate,
  }) {
    final launchDate = defaultIncomingTalentMobilityLaunchDate(
      match: match,
      asOfDate: asOfDate,
    );

    return IncomingTalentMobilityLaunchChecklistDraft(
      matchId: match.id,
      decisionId: match.decisionId,
      candidateId: match.candidateId,
      candidateName: match.candidateName,
      currentRole: match.currentRole,
      department: match.department,
      targetRole: match.targetRole,
      opportunityTitle: match.opportunityTitle,
      hostDepartment: match.hostDepartment,
      sponsorName: match.sponsorName,
      mobilityOwnerName: match.mobilityOwnerName,
      moveType: match.moveType,
      matchStatus: match.status,
      status: defaultIncomingTalentMobilityLaunchStatus(match.status),
      fitScore: match.fitScore,
      ownerName: match.mobilityOwnerName,
      launchDate: launchDate,
      firstReviewDate: defaultIncomingTalentMobilityFirstReviewDate(
        match: match,
        launchDate: launchDate,
      ),
      sponsorSignedOff: defaultIncomingTalentMobilityLaunchSponsorSignoff(
        match.status,
      ),
      hostManagerReady: match.fitScore >= 75,
      accessReady: match.status == IncomingTalentMobilityMatchStatus.activated,
      communicationReady:
          match.status == IncomingTalentMobilityMatchStatus.activated,
      backfillReady: defaultIncomingTalentMobilityLaunchBackfillReady(
        match.moveType,
      ),
      firstReviewScheduled: true,
      riskNote: defaultIncomingTalentMobilityLaunchRiskNote(match),
      launchNotes: defaultIncomingTalentMobilityLaunchNotes(match),
      asOfDate: asOfDate,
    );
  }

  IncomingTalentMobilityLaunchChecklistDraft copyWith({
    String? matchId,
    String? decisionId,
    String? candidateId,
    String? candidateName,
    String? currentRole,
    String? department,
    String? targetRole,
    String? opportunityTitle,
    String? hostDepartment,
    String? sponsorName,
    String? mobilityOwnerName,
    IncomingTalentMobilityMoveType? moveType,
    IncomingTalentMobilityMatchStatus? matchStatus,
    IncomingTalentMobilityLaunchStatus? status,
    int? fitScore,
    String? ownerName,
    DateTime? launchDate,
    DateTime? firstReviewDate,
    bool? sponsorSignedOff,
    bool? hostManagerReady,
    bool? accessReady,
    bool? communicationReady,
    bool? backfillReady,
    bool? firstReviewScheduled,
    String? riskNote,
    String? launchNotes,
    DateTime? asOfDate,
  }) {
    return IncomingTalentMobilityLaunchChecklistDraft(
      matchId: matchId ?? this.matchId,
      decisionId: decisionId ?? this.decisionId,
      candidateId: candidateId ?? this.candidateId,
      candidateName: candidateName ?? this.candidateName,
      currentRole: currentRole ?? this.currentRole,
      department: department ?? this.department,
      targetRole: targetRole ?? this.targetRole,
      opportunityTitle: opportunityTitle ?? this.opportunityTitle,
      hostDepartment: hostDepartment ?? this.hostDepartment,
      sponsorName: sponsorName ?? this.sponsorName,
      mobilityOwnerName: mobilityOwnerName ?? this.mobilityOwnerName,
      moveType: moveType ?? this.moveType,
      matchStatus: matchStatus ?? this.matchStatus,
      status: status ?? this.status,
      fitScore: fitScore ?? this.fitScore,
      ownerName: ownerName ?? this.ownerName,
      launchDate: launchDate ?? this.launchDate,
      firstReviewDate: firstReviewDate ?? this.firstReviewDate,
      sponsorSignedOff: sponsorSignedOff ?? this.sponsorSignedOff,
      hostManagerReady: hostManagerReady ?? this.hostManagerReady,
      accessReady: accessReady ?? this.accessReady,
      communicationReady: communicationReady ?? this.communicationReady,
      backfillReady: backfillReady ?? this.backfillReady,
      firstReviewScheduled: firstReviewScheduled ?? this.firstReviewScheduled,
      riskNote: riskNote ?? this.riskNote,
      launchNotes: launchNotes ?? this.launchNotes,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }

  static String? validateRequired(String? value, String fieldName) {
    return validateIncomingTalentMobilityLaunchRequired(value, fieldName);
  }

  static String? validateStatus(IncomingTalentMobilityLaunchStatus? value) {
    return validateIncomingTalentMobilityLaunchStatus(value);
  }

  static String? validateMoveType(IncomingTalentMobilityMoveType? value) {
    return validateIncomingTalentMobilityLaunchMoveType(value);
  }

  static String? validateMatchStatus(IncomingTalentMobilityMatchStatus? value) {
    return validateIncomingTalentMobilityLaunchMatchStatus(value);
  }

  static String? validateLaunchDate(DateTime? value, DateTime asOfDate) {
    return validateIncomingTalentMobilityLaunchDate(value, asOfDate);
  }

  static String? validateFirstReviewDate(
    DateTime? launchDate,
    DateTime? firstReviewDate,
  ) {
    return validateIncomingTalentMobilityLaunchFirstReviewDate(
      launchDate,
      firstReviewDate,
    );
  }

  static String? validateLaunchNotes(String? value) {
    return validateIncomingTalentMobilityLaunchNotes(value);
  }

  static String? validateRiskNote(String? value) {
    return validateIncomingTalentMobilityLaunchRiskNote(value);
  }
}
