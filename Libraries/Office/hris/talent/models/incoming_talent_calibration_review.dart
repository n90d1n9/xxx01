import 'incoming_talent_calibration_packet.dart';

enum IncomingTalentCalibrationDecision {
  accelerateGrowth('Accelerate growth'),
  maintainTrack('Maintain track'),
  coachingPlan('Coaching plan'),
  retentionEscalation('Retention escalation');

  final String label;

  const IncomingTalentCalibrationDecision(this.label);
}

class IncomingTalentCalibrationReview {
  final String id;
  final String packetId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime reviewDate;
  final IncomingTalentCalibrationDecision decision;
  final IncomingTalentCalibrationPotential potential;
  final String talentTrack;
  final String evidenceSummary;
  final String decisionNote;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentCalibrationReview({
    required this.id,
    required this.packetId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.reviewDate,
    required this.decision,
    required this.potential,
    required this.talentTrack,
    required this.evidenceSummary,
    required this.decisionNote,
    required this.nextReviewDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return decision == IncomingTalentCalibrationDecision.coachingPlan ||
        decision == IncomingTalentCalibrationDecision.retentionEscalation ||
        potential == IncomingTalentCalibrationPotential.watch;
  }
}
