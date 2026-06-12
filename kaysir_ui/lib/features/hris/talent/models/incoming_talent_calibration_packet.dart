import 'incoming_talent_activation_outcome_models.dart';
import 'incoming_talent_development_check_in_models.dart';
import 'incoming_talent_development_intervention_models.dart';
import 'incoming_talent_development_roadmap_models.dart';

enum IncomingTalentCalibrationRecommendation {
  accelerate('Accelerate'),
  maintainCadence('Maintain cadence'),
  coach('Coach'),
  escalate('Escalate');

  final String label;

  const IncomingTalentCalibrationRecommendation(this.label);
}

enum IncomingTalentCalibrationPotential {
  high('High potential'),
  solid('Solid performer'),
  emerging('Emerging'),
  watch('Watch');

  final String label;

  const IncomingTalentCalibrationPotential(this.label);
}

class IncomingTalentCalibrationPacket {
  final String id;
  final String outcomeReviewId;
  final String? roadmapId;
  final String? latestCheckInId;
  final String candidateId;
  final String candidateName;
  final String role;
  final String department;
  final IncomingTalentActivationOutcomeDecision outcomeDecision;
  final IncomingTalentActivationRetentionRisk retentionRisk;
  final IncomingTalentDevelopmentRoadmapStatus? roadmapStatus;
  final IncomingTalentDevelopmentCheckInTrend? latestTrend;
  final int readinessScore;
  final int confidenceScore;
  final int openInterventionCount;
  final int criticalInterventionCount;
  final IncomingTalentCalibrationRecommendation recommendation;
  final IncomingTalentCalibrationPotential potential;
  final DateTime reviewDueDate;
  final String evidenceSummary;

  const IncomingTalentCalibrationPacket({
    required this.id,
    required this.outcomeReviewId,
    required this.roadmapId,
    required this.latestCheckInId,
    required this.candidateId,
    required this.candidateName,
    required this.role,
    required this.department,
    required this.outcomeDecision,
    required this.retentionRisk,
    required this.roadmapStatus,
    required this.latestTrend,
    required this.readinessScore,
    required this.confidenceScore,
    required this.openInterventionCount,
    required this.criticalInterventionCount,
    required this.recommendation,
    required this.potential,
    required this.reviewDueDate,
    required this.evidenceSummary,
  });

  factory IncomingTalentCalibrationPacket.fromSignals({
    required IncomingTalentActivationOutcomeReview outcome,
    required List<IncomingTalentDevelopmentRoadmap> roadmaps,
    required List<IncomingTalentDevelopmentCheckIn> checkIns,
    required List<IncomingTalentDevelopmentInterventionAction> interventions,
  }) {
    final roadmap = _matchingRoadmap(outcome, roadmaps);
    final latestCheckIn = _latestCheckIn(outcome, roadmap, checkIns);
    final relatedInterventions = _relatedInterventions(
      outcome,
      roadmap,
      interventions,
    );
    final openInterventionCount =
        relatedInterventions.where(_isOpenIntervention).length;
    final criticalInterventionCount =
        relatedInterventions
            .where(
              (action) =>
                  _isOpenIntervention(action) &&
                  action.priority ==
                      IncomingTalentDevelopmentInterventionPriority.critical,
            )
            .length;
    final confidenceScore =
        latestCheckIn?.confidenceScore ?? _confidenceFromReadiness(outcome);
    final recommendation = _recommendation(
      outcome: outcome,
      roadmap: roadmap,
      latestCheckIn: latestCheckIn,
      openInterventionCount: openInterventionCount,
      criticalInterventionCount: criticalInterventionCount,
      confidenceScore: confidenceScore,
    );
    final potential = _potential(recommendation);

    return IncomingTalentCalibrationPacket(
      id: outcome.id,
      outcomeReviewId: outcome.id,
      roadmapId: roadmap?.id,
      latestCheckInId: latestCheckIn?.id,
      candidateId: outcome.candidateId,
      candidateName: outcome.candidateName,
      role: outcome.role,
      department: outcome.department,
      outcomeDecision: outcome.decision,
      retentionRisk: outcome.retentionRisk,
      roadmapStatus: roadmap?.status,
      latestTrend: latestCheckIn?.trend,
      readinessScore: outcome.readinessScore,
      confidenceScore: confidenceScore,
      openInterventionCount: openInterventionCount,
      criticalInterventionCount: criticalInterventionCount,
      recommendation: recommendation,
      potential: potential,
      reviewDueDate:
          latestCheckIn?.nextReviewDate ??
          roadmap?.targetCompletionDate ??
          outcome.reviewDate.add(const Duration(days: 30)),
      evidenceSummary: _evidenceSummary(
        outcome: outcome,
        roadmap: roadmap,
        latestCheckIn: latestCheckIn,
        openInterventionCount: openInterventionCount,
      ),
    );
  }

  bool get needsAttention {
    return recommendation == IncomingTalentCalibrationRecommendation.coach ||
        recommendation == IncomingTalentCalibrationRecommendation.escalate ||
        retentionRisk == IncomingTalentActivationRetentionRisk.high ||
        criticalInterventionCount > 0 ||
        confidenceScore <= 3;
  }

  double get readinessRatio => readinessScore / 100;
}

IncomingTalentDevelopmentRoadmap? _matchingRoadmap(
  IncomingTalentActivationOutcomeReview outcome,
  List<IncomingTalentDevelopmentRoadmap> roadmaps,
) {
  for (final roadmap in roadmaps) {
    if (roadmap.outcomeReviewId == outcome.id) return roadmap;
  }
  for (final roadmap in roadmaps) {
    if (roadmap.candidateId == outcome.candidateId) return roadmap;
  }
  return null;
}

IncomingTalentDevelopmentCheckIn? _latestCheckIn(
  IncomingTalentActivationOutcomeReview outcome,
  IncomingTalentDevelopmentRoadmap? roadmap,
  List<IncomingTalentDevelopmentCheckIn> checkIns,
) {
  final matches =
      checkIns
          .where(
            (checkIn) =>
                checkIn.outcomeReviewId == outcome.id ||
                checkIn.roadmapId == roadmap?.id ||
                checkIn.candidateId == outcome.candidateId,
          )
          .toList()
        ..sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
  return matches.isEmpty ? null : matches.first;
}

List<IncomingTalentDevelopmentInterventionAction> _relatedInterventions(
  IncomingTalentActivationOutcomeReview outcome,
  IncomingTalentDevelopmentRoadmap? roadmap,
  List<IncomingTalentDevelopmentInterventionAction> interventions,
) {
  return interventions
      .where(
        (action) =>
            action.outcomeReviewId == outcome.id ||
            action.roadmapId == roadmap?.id ||
            action.candidateId == outcome.candidateId,
      )
      .toList();
}

bool _isOpenIntervention(IncomingTalentDevelopmentInterventionAction action) {
  return action.status !=
          IncomingTalentDevelopmentInterventionStatus.resolved &&
      action.status != IncomingTalentDevelopmentInterventionStatus.cancelled;
}

int _confidenceFromReadiness(IncomingTalentActivationOutcomeReview outcome) {
  return (outcome.readinessScore / 20).round().clamp(1, 5);
}

IncomingTalentCalibrationRecommendation _recommendation({
  required IncomingTalentActivationOutcomeReview outcome,
  required IncomingTalentDevelopmentRoadmap? roadmap,
  required IncomingTalentDevelopmentCheckIn? latestCheckIn,
  required int openInterventionCount,
  required int criticalInterventionCount,
  required int confidenceScore,
}) {
  if (outcome.decision ==
          IncomingTalentActivationOutcomeDecision.escalateRisk ||
      outcome.retentionRisk == IncomingTalentActivationRetentionRisk.high ||
      roadmap?.status == IncomingTalentDevelopmentRoadmapStatus.atRisk ||
      latestCheckIn?.trend == IncomingTalentDevelopmentCheckInTrend.blocked ||
      criticalInterventionCount > 0) {
    return IncomingTalentCalibrationRecommendation.escalate;
  }
  if (outcome.decision ==
          IncomingTalentActivationOutcomeDecision.extendSupport ||
      latestCheckIn?.trend == IncomingTalentDevelopmentCheckInTrend.watch ||
      confidenceScore <= 3 ||
      openInterventionCount > 0) {
    return IncomingTalentCalibrationRecommendation.coach;
  }
  if (outcome.decision == IncomingTalentActivationOutcomeDecision.stabilized &&
      outcome.readinessScore >= 85 &&
      confidenceScore >= 4) {
    return IncomingTalentCalibrationRecommendation.accelerate;
  }
  return IncomingTalentCalibrationRecommendation.maintainCadence;
}

IncomingTalentCalibrationPotential _potential(
  IncomingTalentCalibrationRecommendation recommendation,
) {
  return switch (recommendation) {
    IncomingTalentCalibrationRecommendation.accelerate =>
      IncomingTalentCalibrationPotential.high,
    IncomingTalentCalibrationRecommendation.maintainCadence =>
      IncomingTalentCalibrationPotential.solid,
    IncomingTalentCalibrationRecommendation.coach =>
      IncomingTalentCalibrationPotential.emerging,
    IncomingTalentCalibrationRecommendation.escalate =>
      IncomingTalentCalibrationPotential.watch,
  };
}

String _evidenceSummary({
  required IncomingTalentActivationOutcomeReview outcome,
  required IncomingTalentDevelopmentRoadmap? roadmap,
  required IncomingTalentDevelopmentCheckIn? latestCheckIn,
  required int openInterventionCount,
}) {
  final roadmapLabel =
      roadmap == null ? 'no roadmap' : '${roadmap.status.label} roadmap';
  final trendLabel =
      latestCheckIn == null
          ? 'no check-in'
          : '${latestCheckIn.trend.label} check-in';
  return '${outcome.decision.label} outcome, $roadmapLabel, $trendLabel, $openInterventionCount open interventions.';
}
