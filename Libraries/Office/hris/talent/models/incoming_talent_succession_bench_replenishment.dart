import 'incoming_talent_succession_transition_outcome_review.dart';

enum IncomingTalentSuccessionBenchReplenishmentPriority {
  routine('Routine'),
  accelerated('Accelerated'),
  critical('Critical');

  final String label;

  const IncomingTalentSuccessionBenchReplenishmentPriority(this.label);
}

enum IncomingTalentSuccessionBenchReplenishmentStatus {
  planned('Planned'),
  active('Active'),
  completed('Completed'),
  blocked('Blocked');

  final String label;

  const IncomingTalentSuccessionBenchReplenishmentStatus(this.label);
}

class IncomingTalentSuccessionBenchReplenishment {
  final String id;
  final String outcomeReviewId;
  final String interventionId;
  final String pulseId;
  final String closureId;
  final String activationPlanId;
  final String decisionId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final String targetRole;
  final String ownerName;
  final IncomingTalentSuccessionTransitionOutcomeDecision outcomeDecision;
  final IncomingTalentSuccessionTransitionOutcomeResidualRisk residualRisk;
  final IncomingTalentSuccessionBenchReplenishmentPriority priority;
  final IncomingTalentSuccessionBenchReplenishmentStatus status;
  final DateTime targetReadyDate;
  final String benchGap;
  final String sourcingStrategy;
  final String developmentTrack;
  final String reviewCadence;
  final DateTime createdAt;

  const IncomingTalentSuccessionBenchReplenishment({
    required this.id,
    required this.outcomeReviewId,
    required this.interventionId,
    required this.pulseId,
    required this.closureId,
    required this.activationPlanId,
    required this.decisionId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.targetRole,
    required this.ownerName,
    required this.outcomeDecision,
    required this.residualRisk,
    required this.priority,
    required this.status,
    required this.targetReadyDate,
    required this.benchGap,
    required this.sourcingStrategy,
    required this.developmentTrack,
    required this.reviewCadence,
    required this.createdAt,
  });

  bool get isOpen {
    return status != IncomingTalentSuccessionBenchReplenishmentStatus.completed;
  }

  bool get needsAttention {
    return status == IncomingTalentSuccessionBenchReplenishmentStatus.blocked ||
        (isOpen &&
            (priority ==
                    IncomingTalentSuccessionBenchReplenishmentPriority
                        .critical ||
                outcomeDecision !=
                    IncomingTalentSuccessionTransitionOutcomeDecision
                        .stabilized ||
                residualRisk ==
                    IncomingTalentSuccessionTransitionOutcomeResidualRisk
                        .high));
  }

  int daysUntilReady(DateTime asOfDate) {
    final start = DateTime(asOfDate.year, asOfDate.month, asOfDate.day);
    final ready = DateTime(
      targetReadyDate.year,
      targetReadyDate.month,
      targetReadyDate.day,
    );
    return ready.difference(start).inDays;
  }

  bool isDueSoon(DateTime asOfDate) {
    final days = daysUntilReady(asOfDate);
    return isOpen && days >= 0 && days <= 14;
  }

  bool isOverdue(DateTime asOfDate) {
    return isOpen && daysUntilReady(asOfDate) < 0;
  }

  IncomingTalentSuccessionBenchReplenishment copyWith({
    IncomingTalentSuccessionBenchReplenishmentStatus? status,
  }) {
    return IncomingTalentSuccessionBenchReplenishment(
      id: id,
      outcomeReviewId: outcomeReviewId,
      interventionId: interventionId,
      pulseId: pulseId,
      closureId: closureId,
      activationPlanId: activationPlanId,
      decisionId: decisionId,
      candidateId: candidateId,
      candidateName: candidateName,
      role: role,
      department: department,
      targetRole: targetRole,
      ownerName: ownerName,
      outcomeDecision: outcomeDecision,
      residualRisk: residualRisk,
      priority: priority,
      status: status ?? this.status,
      targetReadyDate: targetReadyDate,
      benchGap: benchGap,
      sourcingStrategy: sourcingStrategy,
      developmentTrack: developmentTrack,
      reviewCadence: reviewCadence,
      createdAt: createdAt,
    );
  }
}
