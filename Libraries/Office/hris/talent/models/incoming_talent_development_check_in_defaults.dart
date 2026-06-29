import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_check_in.dart';
import 'incoming_talent_development_roadmap_models.dart';

class IncomingTalentDevelopmentCheckInDefaults {
  final IncomingTalentDevelopmentCheckInTrend trend;
  final int confidenceScore;
  final String blockerNote;
  final String nextAction;
  final String managerCommitment;
  final Duration nextReviewInterval;

  const IncomingTalentDevelopmentCheckInDefaults({
    required this.trend,
    required this.confidenceScore,
    required this.blockerNote,
    required this.nextAction,
    required this.managerCommitment,
    required this.nextReviewInterval,
  });

  factory IncomingTalentDevelopmentCheckInDefaults.fromRoadmap(
    IncomingTalentDevelopmentRoadmap roadmap,
  ) {
    final trend = _trendFromRoadmap(roadmap);

    return IncomingTalentDevelopmentCheckInDefaults(
      trend: trend,
      confidenceScore: _confidenceFromRoadmap(roadmap),
      blockerNote: _blockerNoteFromRoadmap(roadmap, trend),
      nextAction: _nextActionFromRoadmap(roadmap, trend),
      managerCommitment: _managerCommitmentFromRoadmap(roadmap),
      nextReviewInterval: _intervalFromCadence(roadmap.cadence),
    );
  }
}

IncomingTalentDevelopmentCheckInTrend _trendFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
) {
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.atRisk ||
      roadmap.retentionRisk == IncomingTalentActivationRetentionRisk.high) {
    return roadmap.readinessScore < 50
        ? IncomingTalentDevelopmentCheckInTrend.blocked
        : IncomingTalentDevelopmentCheckInTrend.watch;
  }
  if (roadmap.status == IncomingTalentDevelopmentRoadmapStatus.completed) {
    return IncomingTalentDevelopmentCheckInTrend.improving;
  }
  return IncomingTalentDevelopmentCheckInTrend.steady;
}

int _confidenceFromRoadmap(IncomingTalentDevelopmentRoadmap roadmap) {
  final score = (roadmap.readinessScore / 20).round();
  return score.clamp(1, 5);
}

String _blockerNoteFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
  IncomingTalentDevelopmentCheckInTrend trend,
) {
  return switch (trend) {
    IncomingTalentDevelopmentCheckInTrend.blocked =>
      'Roadmap blockers need manager and people partner escalation.',
    IncomingTalentDevelopmentCheckInTrend.watch =>
      'Watch signals require tighter manager follow-through this cycle.',
    IncomingTalentDevelopmentCheckInTrend.improving ||
    IncomingTalentDevelopmentCheckInTrend.steady => '',
  };
}

String _nextActionFromRoadmap(
  IncomingTalentDevelopmentRoadmap roadmap,
  IncomingTalentDevelopmentCheckInTrend trend,
) {
  return switch (trend) {
    IncomingTalentDevelopmentCheckInTrend.blocked =>
      'Escalate ${roadmap.focusArea} blockers and reset weekly ownership.',
    IncomingTalentDevelopmentCheckInTrend.watch =>
      'Review ${roadmap.focusArea} progress with mentor before next check-in.',
    IncomingTalentDevelopmentCheckInTrend.improving =>
      'Capture evidence from ${roadmap.firstMilestone} for calibration.',
    IncomingTalentDevelopmentCheckInTrend.steady =>
      'Keep ${roadmap.focusArea} milestones moving on the current cadence.',
  };
}

String _managerCommitmentFromRoadmap(IncomingTalentDevelopmentRoadmap roadmap) {
  return '${roadmap.ownerName} will confirm ${roadmap.successMetric.toLowerCase()}';
}

Duration _intervalFromCadence(IncomingTalentDevelopmentRoadmapCadence cadence) {
  return switch (cadence) {
    IncomingTalentDevelopmentRoadmapCadence.weekly => const Duration(days: 7),
    IncomingTalentDevelopmentRoadmapCadence.biweekly => const Duration(
      days: 14,
    ),
    IncomingTalentDevelopmentRoadmapCadence.monthly => const Duration(days: 30),
  };
}
