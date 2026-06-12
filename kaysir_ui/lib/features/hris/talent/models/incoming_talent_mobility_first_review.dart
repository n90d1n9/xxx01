import 'incoming_talent_mobility_launch_checklist.dart';

enum IncomingTalentMobilityFirstReviewOutcome {
  accelerating('Accelerating'),
  stable('Stable'),
  watch('Watch'),
  blocked('Blocked');

  final String label;

  const IncomingTalentMobilityFirstReviewOutcome(this.label);
}

enum IncomingTalentMobilityFirstReviewRetentionRisk {
  low('Low'),
  moderate('Moderate'),
  high('High');

  final String label;

  const IncomingTalentMobilityFirstReviewRetentionRisk(this.label);
}

class IncomingTalentMobilityFirstReview {
  final String id;
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
  final DateTime reviewDate;
  final IncomingTalentMobilityFirstReviewOutcome outcome;
  final int hostConfidenceScore;
  final String deliverySignal;
  final String blockerNote;
  final IncomingTalentMobilityFirstReviewRetentionRisk retentionRisk;
  final String nextAction;
  final DateTime followUpDate;
  final IncomingTalentMobilityLaunchStatus launchStatus;
  final DateTime createdAt;

  const IncomingTalentMobilityFirstReview({
    required this.id,
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
    required this.createdAt,
  });

  bool get needsAttention {
    return outcome == IncomingTalentMobilityFirstReviewOutcome.watch ||
        outcome == IncomingTalentMobilityFirstReviewOutcome.blocked ||
        hostConfidenceScore <= 3 ||
        retentionRisk != IncomingTalentMobilityFirstReviewRetentionRisk.low;
  }

  double get confidenceRatio => hostConfidenceScore / 5;
}
