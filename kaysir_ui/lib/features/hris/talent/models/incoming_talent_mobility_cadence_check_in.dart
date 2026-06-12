import 'incoming_talent_mobility_stabilization_outcome.dart';

enum IncomingTalentMobilityCadenceStatus {
  onTrack('On track'),
  watch('Watch'),
  intervene('Intervene'),
  closed('Closed');

  final String label;

  const IncomingTalentMobilityCadenceStatus(this.label);
}

class IncomingTalentMobilityCadenceCheckIn {
  final String id;
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
  final IncomingTalentMobilityStabilizationOutcomeDecision outcomeDecision;
  final IncomingTalentMobilityStabilizationResidualRisk previousResidualRisk;
  final int previousHostConfidence;
  final String reviewerName;
  final DateTime checkInDate;
  final IncomingTalentMobilityCadenceStatus status;
  final IncomingTalentMobilityStabilizationResidualRisk residualRisk;
  final int hostConfidenceScore;
  final String pulseSummary;
  final String supportPlan;
  final DateTime nextReviewDate;
  final DateTime createdAt;

  const IncomingTalentMobilityCadenceCheckIn({
    required this.id,
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
    required this.createdAt,
  });

  bool get isClosed => status == IncomingTalentMobilityCadenceStatus.closed;

  bool get needsAttention {
    return status == IncomingTalentMobilityCadenceStatus.watch ||
        status == IncomingTalentMobilityCadenceStatus.intervene ||
        residualRisk != IncomingTalentMobilityStabilizationResidualRisk.low ||
        hostConfidenceScore <= 3;
  }

  int get confidenceDelta => hostConfidenceScore - previousHostConfidence;

  double get confidenceRatio => hostConfidenceScore / 5;

  int daysUntilNextReview(DateTime asOfDate) {
    final today = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final review = DateTime(
      nextReviewDate.year,
      nextReviewDate.month,
      nextReviewDate.day,
    );
    return review.difference(today).inDays;
  }
}
