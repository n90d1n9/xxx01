import 'incoming_talent_development_intervention_outcome.dart';

class IncomingTalentDevelopmentInterventionOutcomeSummary {
  final int totalCount;
  final int improvedCount;
  final int stabilizedCount;
  final int monitorCount;
  final int escalateCount;
  final int attentionCount;
  final int releaseRiskCount;
  final double averageConfidenceAfter;
  final String nextAction;

  const IncomingTalentDevelopmentInterventionOutcomeSummary({
    required this.totalCount,
    required this.improvedCount,
    required this.stabilizedCount,
    required this.monitorCount,
    required this.escalateCount,
    required this.attentionCount,
    required this.releaseRiskCount,
    required this.averageConfidenceAfter,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeSummary.fromOutcomes(
    List<IncomingTalentDevelopmentInterventionOutcome> outcomes,
  ) {
    final improvedCount = _countByDecision(
      outcomes,
      IncomingTalentDevelopmentInterventionOutcomeDecision.improved,
    );
    final stabilizedCount = _countByDecision(
      outcomes,
      IncomingTalentDevelopmentInterventionOutcomeDecision.stabilized,
    );
    final monitorCount = _countByDecision(
      outcomes,
      IncomingTalentDevelopmentInterventionOutcomeDecision.monitor,
    );
    final escalateCount = _countByDecision(
      outcomes,
      IncomingTalentDevelopmentInterventionOutcomeDecision.escalate,
    );
    final attentionCount = outcomes.where((item) => item.needsAttention).length;
    final releaseRiskCount =
        outcomes.where((item) => item.remainingReleaseRiskCount > 0).length;
    final averageConfidenceAfter =
        outcomes.isEmpty
            ? 0.0
            : outcomes.fold<int>(
                  0,
                  (total, item) => total + item.confidenceAfter,
                ) /
                outcomes.length;

    return IncomingTalentDevelopmentInterventionOutcomeSummary(
      totalCount: outcomes.length,
      improvedCount: improvedCount,
      stabilizedCount: stabilizedCount,
      monitorCount: monitorCount,
      escalateCount: escalateCount,
      attentionCount: attentionCount,
      releaseRiskCount: releaseRiskCount,
      averageConfidenceAfter: averageConfidenceAfter,
      nextAction: _nextAction(
        totalCount: outcomes.length,
        escalateCount: escalateCount,
        monitorCount: monitorCount,
        releaseRiskCount: releaseRiskCount,
        attentionCount: attentionCount,
        improvedCount: improvedCount,
        stabilizedCount: stabilizedCount,
      ),
    );
  }
}

int _countByDecision(
  List<IncomingTalentDevelopmentInterventionOutcome> outcomes,
  IncomingTalentDevelopmentInterventionOutcomeDecision decision,
) {
  return outcomes.where((item) => item.decision == decision).length;
}

String _nextAction({
  required int totalCount,
  required int escalateCount,
  required int monitorCount,
  required int releaseRiskCount,
  required int attentionCount,
  required int improvedCount,
  required int stabilizedCount,
}) {
  if (totalCount == 0) return 'Review resolved development interventions.';
  if (escalateCount > 0) {
    return 'Escalate $escalateCount development intervention outcomes.';
  }
  if (releaseRiskCount > 0) {
    return 'Close $releaseRiskCount outcome release evidence risks.';
  }
  if (monitorCount > 0) {
    return 'Monitor $monitorCount development intervention outcomes.';
  }
  if (attentionCount > 0) {
    return 'Follow up $attentionCount fragile development outcomes.';
  }
  if (stabilizedCount > 0) {
    return 'Sustain $stabilizedCount stabilized development outcomes.';
  }
  if (improvedCount > 0) return 'Archive $improvedCount development wins.';
  return 'Development intervention outcomes are current.';
}
