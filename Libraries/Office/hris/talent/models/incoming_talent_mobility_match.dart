import 'incoming_talent_succession_candidate.dart';
import 'incoming_talent_succession_nomination.dart';

enum IncomingTalentMobilityMoveType {
  promotion('Promotion'),
  lateralMove('Lateral move'),
  stretchAssignment('Stretch assignment'),
  projectRotation('Project rotation'),
  successionCoverage('Succession coverage');

  final String label;

  const IncomingTalentMobilityMoveType(this.label);
}

enum IncomingTalentMobilityMatchStatus {
  proposed('Proposed'),
  sponsorReview('Sponsor review'),
  accepted('Accepted'),
  blocked('Blocked'),
  activated('Activated');

  final String label;

  const IncomingTalentMobilityMatchStatus(this.label);
}

class IncomingTalentMobilityMatch {
  final String id;
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
  final IncomingTalentSuccessionNominationType nominationType;
  final IncomingTalentSuccessionReadiness readiness;
  final IncomingTalentSuccessionRisk risk;
  final IncomingTalentMobilityMoveType moveType;
  final IncomingTalentMobilityMatchStatus status;
  final int fitScore;
  final DateTime startDate;
  final DateTime reviewDate;
  final String businessRationale;
  final String successMeasure;
  final String supportPlan;
  final DateTime createdAt;

  const IncomingTalentMobilityMatch({
    required this.id,
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
    required this.createdAt,
  });

  bool get isOpen => status != IncomingTalentMobilityMatchStatus.activated;

  bool get needsAttention {
    return status == IncomingTalentMobilityMatchStatus.blocked ||
        status == IncomingTalentMobilityMatchStatus.sponsorReview ||
        risk != IncomingTalentSuccessionRisk.low ||
        fitScore < 75;
  }

  double get fitRatio => fitScore / 100;

  int daysUntilStart(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final startTarget = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    return startTarget.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilStart(asOfDate);
    return isOpen && days >= 0 && days <= 14;
  }

  IncomingTalentMobilityMatch copyWith({
    IncomingTalentMobilityMatchStatus? status,
  }) {
    return IncomingTalentMobilityMatch(
      id: id,
      decisionId: decisionId,
      nominationId: nominationId,
      candidateId: candidateId,
      candidateName: candidateName,
      currentRole: currentRole,
      department: department,
      targetRole: targetRole,
      opportunityTitle: opportunityTitle,
      hostDepartment: hostDepartment,
      sponsorName: sponsorName,
      mobilityOwnerName: mobilityOwnerName,
      nominationType: nominationType,
      readiness: readiness,
      risk: risk,
      moveType: moveType,
      status: status ?? this.status,
      fitScore: fitScore,
      startDate: startDate,
      reviewDate: reviewDate,
      businessRationale: businessRationale,
      successMeasure: successMeasure,
      supportPlan: supportPlan,
      createdAt: createdAt,
    );
  }
}
