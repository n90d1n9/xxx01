import 'incoming_talent_mobility_stabilization_outcome.dart';

class IncomingTalentMobilityStabilizationOutcomeSummary {
  final int totalCount;
  final int resolvedCount;
  final int improvedCount;
  final int monitorCount;
  final int escalateCount;
  final int attentionCount;
  final double averageConfidenceAfter;
  final String nextAction;

  const IncomingTalentMobilityStabilizationOutcomeSummary({
    required this.totalCount,
    required this.resolvedCount,
    required this.improvedCount,
    required this.monitorCount,
    required this.escalateCount,
    required this.attentionCount,
    required this.averageConfidenceAfter,
    required this.nextAction,
  });

  factory IncomingTalentMobilityStabilizationOutcomeSummary.fromOutcomes(
    List<IncomingTalentMobilityStabilizationOutcome> outcomes,
  ) {
    final resolvedCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityStabilizationOutcomeDecision.resolved,
    );
    final improvedCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityStabilizationOutcomeDecision.improved,
    );
    final monitorCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityStabilizationOutcomeDecision.monitor,
    );
    final escalateCount = _countByDecision(
      outcomes,
      IncomingTalentMobilityStabilizationOutcomeDecision.escalate,
    );
    final attentionCount =
        outcomes.where((outcome) => outcome.needsAttention).length;
    final averageConfidenceAfter =
        outcomes.isEmpty
            ? 0.0
            : outcomes.fold<int>(
                  0,
                  (total, outcome) => total + outcome.hostConfidenceAfter,
                ) /
                outcomes.length;

    return IncomingTalentMobilityStabilizationOutcomeSummary(
      totalCount: outcomes.length,
      resolvedCount: resolvedCount,
      improvedCount: improvedCount,
      monitorCount: monitorCount,
      escalateCount: escalateCount,
      attentionCount: attentionCount,
      averageConfidenceAfter: averageConfidenceAfter,
      nextAction: _nextAction(
        totalCount: outcomes.length,
        resolvedCount: resolvedCount,
        improvedCount: improvedCount,
        monitorCount: monitorCount,
        escalateCount: escalateCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByDecision(
  List<IncomingTalentMobilityStabilizationOutcome> outcomes,
  IncomingTalentMobilityStabilizationOutcomeDecision decision,
) {
  return outcomes.where((outcome) => outcome.decision == decision).length;
}

String _nextAction({
  required int totalCount,
  required int resolvedCount,
  required int improvedCount,
  required int monitorCount,
  required int escalateCount,
  required int attentionCount,
}) {
  if (totalCount == 0) return 'Validate completed mobility actions.';
  if (escalateCount > 0) {
    return 'Escalate $escalateCount mobility outcomes.';
  }
  if (monitorCount > 0) return 'Monitor $monitorCount mobility outcomes.';
  if (attentionCount > 0) return 'Follow up $attentionCount residual risks.';
  if (improvedCount > 0) return 'Sustain $improvedCount improved moves.';
  if (resolvedCount > 0) return 'Keep $resolvedCount moves on cadence.';
  return 'Mobility outcomes are current.';
}
