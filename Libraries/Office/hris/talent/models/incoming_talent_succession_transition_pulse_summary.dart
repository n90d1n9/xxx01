import 'incoming_talent_succession_transition_pulse.dart';

class IncomingTalentSuccessionTransitionPulseSummary {
  final int totalPulses;
  final int thrivingCount;
  final int stableCount;
  final int watchCount;
  final int interventionCount;
  final int highRiskCount;
  final int attentionCount;
  final double averageAdoptionScore;
  final double averageManagerConfidence;
  final String nextAction;

  const IncomingTalentSuccessionTransitionPulseSummary({
    required this.totalPulses,
    required this.thrivingCount,
    required this.stableCount,
    required this.watchCount,
    required this.interventionCount,
    required this.highRiskCount,
    required this.attentionCount,
    required this.averageAdoptionScore,
    required this.averageManagerConfidence,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionTransitionPulseSummary.fromPulses(
    List<IncomingTalentSuccessionTransitionPulse> pulses,
  ) {
    final thrivingCount =
        pulses
            .where(
              (pulse) =>
                  pulse.health ==
                  IncomingTalentSuccessionTransitionPulseHealth.thriving,
            )
            .length;
    final stableCount =
        pulses
            .where(
              (pulse) =>
                  pulse.health ==
                  IncomingTalentSuccessionTransitionPulseHealth.stable,
            )
            .length;
    final watchCount =
        pulses
            .where(
              (pulse) =>
                  pulse.health ==
                  IncomingTalentSuccessionTransitionPulseHealth.watch,
            )
            .length;
    final interventionCount =
        pulses
            .where(
              (pulse) =>
                  pulse.health ==
                  IncomingTalentSuccessionTransitionPulseHealth.intervention,
            )
            .length;
    final highRiskCount =
        pulses
            .where(
              (pulse) =>
                  pulse.retentionRisk ==
                  IncomingTalentSuccessionTransitionRetentionRisk.high,
            )
            .length;
    final attentionCount = pulses.where((pulse) => pulse.needsAttention).length;
    final adoptionTotal = pulses.fold<int>(
      0,
      (total, pulse) => total + pulse.adoptionScore,
    );
    final confidenceTotal = pulses.fold<int>(
      0,
      (total, pulse) => total + pulse.managerConfidenceScore,
    );

    return IncomingTalentSuccessionTransitionPulseSummary(
      totalPulses: pulses.length,
      thrivingCount: thrivingCount,
      stableCount: stableCount,
      watchCount: watchCount,
      interventionCount: interventionCount,
      highRiskCount: highRiskCount,
      attentionCount: attentionCount,
      averageAdoptionScore:
          pulses.isEmpty ? 0.0 : adoptionTotal / pulses.length,
      averageManagerConfidence:
          pulses.isEmpty ? 0.0 : confidenceTotal / pulses.length,
      nextAction: _nextAction(
        totalPulses: pulses.length,
        thrivingCount: thrivingCount,
        stableCount: stableCount,
        watchCount: watchCount,
        interventionCount: interventionCount,
        highRiskCount: highRiskCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

String _nextAction({
  required int totalPulses,
  required int thrivingCount,
  required int stableCount,
  required int watchCount,
  required int interventionCount,
  required int highRiskCount,
  required int attentionCount,
}) {
  if (totalPulses == 0) {
    return 'Capture 30/60/90-day pulses for completed transitions.';
  }
  if (interventionCount > 0) {
    return 'Create interventions for $interventionCount transition pulses.';
  }
  if (highRiskCount > 0) return 'Review $highRiskCount high-risk pulses.';
  if (attentionCount > 0) {
    return 'Monitor $attentionCount transition pulses with attention.';
  }
  if (watchCount > 0) return 'Keep $watchCount transition pulses on watch.';
  return '${thrivingCount + stableCount} transitions are stabilizing.';
}
