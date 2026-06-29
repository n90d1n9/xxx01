import 'incoming_talent_mobility_cadence_intervention_outcome.dart';

class IncomingTalentMobilityCadenceInterventionOutcomeSummary {
  final int totalCount;
  final int recoveredCount;
  final int stabilizedCount;
  final int monitorCount;
  final int escalateCount;
  final int attentionCount;
  final double averageHostConfidence;
  final String nextAction;

  const IncomingTalentMobilityCadenceInterventionOutcomeSummary({
    required this.totalCount,
    required this.recoveredCount,
    required this.stabilizedCount,
    required this.monitorCount,
    required this.escalateCount,
    required this.attentionCount,
    required this.averageHostConfidence,
    required this.nextAction,
  });

  factory IncomingTalentMobilityCadenceInterventionOutcomeSummary.fromOutcomes(
    List<IncomingTalentMobilityCadenceInterventionOutcome> outcomes,
  ) {
    final recoveredCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityCadenceInterventionOutcomeDecision.recovered,
    );
    final stabilizedCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityCadenceInterventionOutcomeDecision.stabilized,
    );
    final monitorCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityCadenceInterventionOutcomeDecision.monitor,
    );
    final escalateCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityCadenceInterventionOutcomeDecision.escalate,
    );
    final attentionCount = outcomes.where((item) => item.needsAttention).length;
    final averageHostConfidence =
        outcomes.isEmpty
            ? 0.0
            : outcomes.fold<int>(
                  0,
                  (total, item) => total + item.hostConfidenceAfter,
                ) /
                outcomes.length;

    return IncomingTalentMobilityCadenceInterventionOutcomeSummary(
      totalCount: outcomes.length,
      recoveredCount: recoveredCount,
      stabilizedCount: stabilizedCount,
      monitorCount: monitorCount,
      escalateCount: escalateCount,
      attentionCount: attentionCount,
      averageHostConfidence: averageHostConfidence,
      nextAction: _nextAction(
        totalCount: outcomes.length,
        monitorCount: monitorCount,
        escalateCount: escalateCount,
        attentionCount: attentionCount,
        recoveredCount: recoveredCount,
        stabilizedCount: stabilizedCount,
      ),
    );
  }
}

int _countByDecision(
  List<IncomingTalentMobilityCadenceInterventionOutcome> outcomes,
  IncomingTalentMobilityCadenceInterventionOutcomeDecision decision,
) {
  return outcomes.where((item) => item.decision == decision).length;
}

String _nextAction({
  required int totalCount,
  required int monitorCount,
  required int escalateCount,
  required int attentionCount,
  required int recoveredCount,
  required int stabilizedCount,
}) {
  if (totalCount == 0) return 'Review resolved mobility interventions.';
  if (escalateCount > 0) {
    return 'Escalate $escalateCount intervention outcomes.';
  }
  if (monitorCount > 0) return 'Monitor $monitorCount intervention outcomes.';
  if (attentionCount > 0) {
    return 'Follow up $attentionCount fragile recoveries.';
  }
  if (stabilizedCount > 0) {
    return 'Sustain $stabilizedCount stabilized recoveries.';
  }
  if (recoveredCount > 0) return 'Archive $recoveredCount recovery wins.';
  return 'Intervention outcomes are current.';
}
