import 'incoming_talent_activation_checkpoint_models.dart';
import 'incoming_talent_activation_follow_up_models.dart';
import 'incoming_talent_activation_models.dart';
import 'incoming_talent_activation_outcome.dart';

class IncomingTalentActivationOutcomeDefaults {
  final IncomingTalentActivationOutcomeDecision decision;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final int readinessScore;
  final String nextDevelopmentTrack;
  final String evidenceNote;
  final String decisionNote;

  const IncomingTalentActivationOutcomeDefaults({
    required this.decision,
    required this.retentionRisk,
    required this.readinessScore,
    required this.nextDevelopmentTrack,
    required this.evidenceNote,
    required this.decisionNote,
  });

  factory IncomingTalentActivationOutcomeDefaults.fromEvidence({
    required IncomingTalentActivationPlan plan,
    required List<IncomingTalentActivationCheckpoint> checkpoints,
    required List<IncomingTalentActivationFollowUpAction> followUps,
  }) {
    final latestCheckpoint = _latestCheckpoint(plan.id, checkpoints);
    final planFollowUps =
        followUps
            .where((action) => action.activationPlanId == plan.id)
            .toList();
    final decision = _defaultDecision(
      plan: plan,
      latestCheckpoint: latestCheckpoint,
      followUps: planFollowUps,
    );

    return IncomingTalentActivationOutcomeDefaults(
      decision: decision,
      retentionRisk: _defaultRisk(decision),
      readinessScore: _defaultReadinessScore(decision, latestCheckpoint),
      nextDevelopmentTrack: _defaultTrack(plan, decision),
      evidenceNote: _defaultEvidence(plan, latestCheckpoint, planFollowUps),
      decisionNote: _defaultDecisionNote(decision),
    );
  }
}

IncomingTalentActivationCheckpoint? _latestCheckpoint(
  String activationPlanId,
  List<IncomingTalentActivationCheckpoint> checkpoints,
) {
  final planCheckpoints =
      checkpoints
          .where(
            (checkpoint) => checkpoint.activationPlanId == activationPlanId,
          )
          .toList()
        ..sort((a, b) => b.reviewDate.compareTo(a.reviewDate));
  if (planCheckpoints.isEmpty) return null;
  return planCheckpoints.first;
}

IncomingTalentActivationOutcomeDecision _defaultDecision({
  required IncomingTalentActivationPlan plan,
  required IncomingTalentActivationCheckpoint? latestCheckpoint,
  required List<IncomingTalentActivationFollowUpAction> followUps,
}) {
  final hasBlockedFollowUp = followUps.any(
    (action) => action.status == IncomingTalentActivationFollowUpStatus.blocked,
  );
  final hasOpenFollowUp = followUps.any((action) => action.isOpen);

  if (plan.status == IncomingTalentActivationStatus.blocked ||
      latestCheckpoint?.isBlocked == true ||
      hasBlockedFollowUp) {
    return IncomingTalentActivationOutcomeDecision.escalateRisk;
  }
  if (hasOpenFollowUp ||
      latestCheckpoint?.health ==
          IncomingTalentActivationCheckpointHealth.watch ||
      (latestCheckpoint?.confidenceScore ?? 5) <= 3) {
    return IncomingTalentActivationOutcomeDecision.extendSupport;
  }
  if (plan.status == IncomingTalentActivationStatus.completed &&
      latestCheckpoint?.health ==
          IncomingTalentActivationCheckpointHealth.onTrack &&
      (latestCheckpoint?.confidenceScore ?? 0) >= 4) {
    return IncomingTalentActivationOutcomeDecision.stabilized;
  }
  return IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack;
}

IncomingTalentActivationRetentionRisk _defaultRisk(
  IncomingTalentActivationOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      IncomingTalentActivationRetentionRisk.low,
    IncomingTalentActivationOutcomeDecision.extendSupport ||
    IncomingTalentActivationOutcomeDecision
        .assignDevelopmentTrack => IncomingTalentActivationRetentionRisk.medium,
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      IncomingTalentActivationRetentionRisk.high,
  };
}

int _defaultReadinessScore(
  IncomingTalentActivationOutcomeDecision decision,
  IncomingTalentActivationCheckpoint? latestCheckpoint,
) {
  final checkpointScore = (latestCheckpoint?.confidenceScore ?? 4) * 20;
  final decisionScore = switch (decision) {
    IncomingTalentActivationOutcomeDecision.stabilized => 90,
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack => 76,
    IncomingTalentActivationOutcomeDecision.extendSupport => 68,
    IncomingTalentActivationOutcomeDecision.escalateRisk => 48,
  };
  return ((checkpointScore + decisionScore) / 2).round().clamp(1, 100);
}

String _defaultTrack(
  IncomingTalentActivationPlan plan,
  IncomingTalentActivationOutcomeDecision decision,
) {
  return switch (decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      '${plan.role} excellence track',
    IncomingTalentActivationOutcomeDecision.extendSupport =>
      '${plan.role} extended ramp support',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      '${plan.role} growth development track',
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      '${plan.role} risk recovery track',
  };
}

String _defaultEvidence(
  IncomingTalentActivationPlan plan,
  IncomingTalentActivationCheckpoint? latestCheckpoint,
  List<IncomingTalentActivationFollowUpAction> followUps,
) {
  final checkpointEvidence =
      latestCheckpoint == null
          ? 'No checkpoint submitted'
          : '${latestCheckpoint.health.label} checkpoint with '
              '${latestCheckpoint.confidenceScore}/5 confidence';
  final completedFollowUps =
      followUps
          .where(
            (action) =>
                action.status ==
                IncomingTalentActivationFollowUpStatus.completed,
          )
          .length;
  return '$checkpointEvidence; $completedFollowUps/${followUps.length} '
      'follow-up actions completed for ${plan.candidateName}.';
}

String _defaultDecisionNote(IncomingTalentActivationOutcomeDecision decision) {
  return switch (decision) {
    IncomingTalentActivationOutcomeDecision.stabilized =>
      'Close activation and move into standard talent development cadence.',
    IncomingTalentActivationOutcomeDecision.extendSupport =>
      'Extend activation support and monitor the next checkpoint closely.',
    IncomingTalentActivationOutcomeDecision.assignDevelopmentTrack =>
      'Assign a targeted development track for the next growth cycle.',
    IncomingTalentActivationOutcomeDecision.escalateRisk =>
      'Escalate retention and role-fit risk to HR leadership.',
  };
}
