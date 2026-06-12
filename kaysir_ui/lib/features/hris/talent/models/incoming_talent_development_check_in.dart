import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_roadmap_models.dart';

enum IncomingTalentDevelopmentCheckInTrend {
  improving('Improving'),
  steady('Steady'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const IncomingTalentDevelopmentCheckInTrend(this.label);
}

class IncomingTalentDevelopmentCheckIn {
  final String id;
  final String roadmapId;
  final String outcomeReviewId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String reviewerName;
  final DateTime checkInDate;
  final IncomingTalentDevelopmentCheckInTrend trend;
  final int confidenceScore;
  final String blockerNote;
  final String nextAction;
  final String managerCommitment;
  final DateTime nextReviewDate;
  final IncomingTalentDevelopmentRoadmapStatus roadmapStatus;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final DateTime createdAt;

  const IncomingTalentDevelopmentCheckIn({
    required this.id,
    required this.roadmapId,
    required this.outcomeReviewId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.reviewerName,
    required this.checkInDate,
    required this.trend,
    required this.confidenceScore,
    required this.blockerNote,
    required this.nextAction,
    required this.managerCommitment,
    required this.nextReviewDate,
    required this.roadmapStatus,
    required this.retentionRisk,
    required this.createdAt,
  });

  bool get needsAttention {
    return trend == IncomingTalentDevelopmentCheckInTrend.watch ||
        trend == IncomingTalentDevelopmentCheckInTrend.blocked ||
        confidenceScore <= 3 ||
        retentionRisk == IncomingTalentActivationRetentionRisk.high;
  }

  double get confidenceRatio => confidenceScore / 5;
}
