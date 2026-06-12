import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_roadmap.dart';

class IncomingTalentDevelopmentRoadmapDefaults {
  final IncomingTalentDevelopmentRoadmapCadence cadence;
  final IncomingTalentDevelopmentRoadmapStatus status;
  final Duration duration;
  final String focusArea;
  final String learningObjective;
  final String firstMilestone;
  final String successMetric;

  const IncomingTalentDevelopmentRoadmapDefaults({
    required this.cadence,
    required this.status,
    required this.duration,
    required this.focusArea,
    required this.learningObjective,
    required this.firstMilestone,
    required this.successMetric,
  });

  factory IncomingTalentDevelopmentRoadmapDefaults.fromOutcome(
    IncomingTalentActivationOutcomeReview review,
  ) {
    return IncomingTalentDevelopmentRoadmapDefaults(
      cadence: _cadenceFromOutcome(review),
      status: _statusFromOutcome(review),
      duration: _durationFromOutcome(review),
      focusArea: _focusAreaFromOutcome(review),
      learningObjective: _learningObjectiveFromOutcome(review),
      firstMilestone: _milestoneFromOutcome(review),
      successMetric: _successMetricFromOutcome(review),
    );
  }
}

IncomingTalentDevelopmentRoadmapCadence _cadenceFromOutcome(
  IncomingTalentActivationOutcomeReview review,
) {
  if (review.retentionRisk == IncomingTalentActivationRetentionRisk.high ||
      review.decision == IncomingTalentActivationOutcomeDecision.escalateRisk) {
    return IncomingTalentDevelopmentRoadmapCadence.weekly;
  }
  if (review.retentionRisk == IncomingTalentActivationRetentionRisk.medium ||
      review.decision != IncomingTalentActivationOutcomeDecision.stabilized) {
    return IncomingTalentDevelopmentRoadmapCadence.biweekly;
  }
  return IncomingTalentDevelopmentRoadmapCadence.monthly;
}

IncomingTalentDevelopmentRoadmapStatus _statusFromOutcome(
  IncomingTalentActivationOutcomeReview review,
) {
  if (review.decision == IncomingTalentActivationOutcomeDecision.escalateRisk ||
      review.retentionRisk == IncomingTalentActivationRetentionRisk.high) {
    return IncomingTalentDevelopmentRoadmapStatus.atRisk;
  }
  if (review.decision ==
      IncomingTalentActivationOutcomeDecision.extendSupport) {
    return IncomingTalentDevelopmentRoadmapStatus.active;
  }
  return IncomingTalentDevelopmentRoadmapStatus.planned;
}

Duration _durationFromOutcome(IncomingTalentActivationOutcomeReview review) {
  return switch (review.decision) {
    IncomingTalentActivationOutcomeDecision.stabilized => const Duration(
      days: 60,
    ),
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      const Duration(days: 90),
    IncomingTalentActivationOutcomeDecision.extendSupport => const Duration(
      days: 75,
    ),
    IncomingTalentActivationOutcomeDecision.escalateRisk => const Duration(
      days: 45,
    ),
  };
}

String _focusAreaFromOutcome(IncomingTalentActivationOutcomeReview review) {
  return switch (review.decision) {
    IncomingTalentActivationOutcomeDecision.stabilized => 'Role excellence',
    IncomingTalentActivationOutcomeDecision.extendSupport => 'Extended support',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      review.nextDevelopmentTrack,
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      'Retention recovery',
  };
}

String _learningObjectiveFromOutcome(
  IncomingTalentActivationOutcomeReview review,
) {
  return switch (review.decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      'Convert activation gains into ${review.role} delivery rituals.',
    IncomingTalentActivationOutcomeDecision.extendSupport =>
      'Close support gaps while strengthening ${review.role} confidence.',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      'Build ${review.nextDevelopmentTrack} capability with manager evidence.',
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      'Recover retention confidence and remove blockers for ${review.role}.',
  };
}

String _milestoneFromOutcome(IncomingTalentActivationOutcomeReview review) {
  return switch (review.decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      'Complete first independent ${review.role} delivery review.',
    IncomingTalentActivationOutcomeDecision.extendSupport =>
      'Finish two manager-supported delivery checkpoints.',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      'Publish a manager-approved development evidence pack.',
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      'Resolve retention blockers with manager and people partner.',
  };
}

String _successMetricFromOutcome(IncomingTalentActivationOutcomeReview review) {
  return switch (review.decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      'Maintain 85% readiness or better across the next review cycle.',
    IncomingTalentActivationOutcomeDecision.extendSupport =>
      'Lift readiness above 75% with no open support blockers.',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      'Complete track milestones with manager sign-off.',
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      'Move retention risk below high and restore weekly confidence.',
  };
}
