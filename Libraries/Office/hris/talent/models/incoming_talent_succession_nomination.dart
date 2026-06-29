import 'incoming_talent_succession_candidate.dart';

enum IncomingTalentSuccessionNominationType {
  promotion('Promotion'),
  successionBench('Succession bench'),
  stretchAssignment('Stretch assignment'),
  sponsorTrack('Sponsor track');

  final String label;

  const IncomingTalentSuccessionNominationType(this.label);
}

enum IncomingTalentSuccessionNominationStatus {
  panelReview('Panel review'),
  approved('Approved'),
  deferred('Deferred'),
  sponsorFollowUp('Sponsor follow-up');

  final String label;

  const IncomingTalentSuccessionNominationStatus(this.label);
}

class IncomingTalentSuccessionNomination {
  final String id;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String promotionTrack;
  final String sponsorName;
  final String panelName;
  final IncomingTalentSuccessionNominationType nominationType;
  final IncomingTalentSuccessionNominationStatus status;
  final IncomingTalentSuccessionReadiness readiness;
  final IncomingTalentSuccessionRisk risk;
  final DateTime nominationDate;
  final DateTime panelDate;
  final String businessCase;
  final String evidenceSummary;
  final String successPlan;
  final DateTime createdAt;

  const IncomingTalentSuccessionNomination({
    required this.id,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.promotionTrack,
    required this.sponsorName,
    required this.panelName,
    required this.nominationType,
    required this.status,
    required this.readiness,
    required this.risk,
    required this.nominationDate,
    required this.panelDate,
    required this.businessCase,
    required this.evidenceSummary,
    required this.successPlan,
    required this.createdAt,
  });

  bool get needsAttention {
    return status == IncomingTalentSuccessionNominationStatus.deferred ||
        status == IncomingTalentSuccessionNominationStatus.sponsorFollowUp ||
        risk == IncomingTalentSuccessionRisk.high;
  }

  bool get isApproved {
    return status == IncomingTalentSuccessionNominationStatus.approved;
  }
}
