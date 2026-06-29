import 'incoming_talent_succession_bench_replenishment.dart';

enum IncomingTalentSuccessionBenchCheckInHealth {
  onTrack('On track'),
  watch('Watch'),
  atRisk('At risk'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionBenchCheckInHealth(this.label);
}

class IncomingTalentSuccessionBenchCheckIn {
  final String id;
  final String benchReplenishmentId;
  final String outcomeReviewId;
  final String interventionId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionBenchReplenishmentPriority priority;
  final IncomingTalentSuccessionBenchReplenishmentStatus planStatus;
  final DateTime checkInDate;
  final IncomingTalentSuccessionBenchCheckInHealth health;
  final int successorSlateCount;
  final int readyNowCount;
  final int readinessScore;
  final String blockerSummary;
  final String leadershipSupport;
  final String nextAction;
  final DateTime nextCheckInDate;
  final DateTime createdAt;

  const IncomingTalentSuccessionBenchCheckIn({
    required this.id,
    required this.benchReplenishmentId,
    required this.outcomeReviewId,
    required this.interventionId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.priority,
    required this.planStatus,
    required this.checkInDate,
    required this.health,
    required this.successorSlateCount,
    required this.readyNowCount,
    required this.readinessScore,
    required this.blockerSummary,
    required this.leadershipSupport,
    required this.nextAction,
    required this.nextCheckInDate,
    required this.createdAt,
  });

  bool get needsAttention {
    return health != IncomingTalentSuccessionBenchCheckInHealth.onTrack ||
        readyNowCount == 0 ||
        readinessScore <= 3 ||
        planStatus == IncomingTalentSuccessionBenchReplenishmentStatus.blocked;
  }

  double get readinessRatio => readinessScore / 5;

  double get readyNowRatio {
    if (successorSlateCount == 0) return 0;
    return readyNowCount / successorSlateCount;
  }
}
