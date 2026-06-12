import 'incoming_talent_career_path_support_outcome.dart';

class IncomingTalentCareerPathSupportOutcomeSummary {
  final int totalCount;
  final int resolvedCount;
  final int improvedCount;
  final int monitorCount;
  final int escalateCount;
  final int attentionCount;
  final double averageVerifiedLevel;
  final String nextAction;

  const IncomingTalentCareerPathSupportOutcomeSummary({
    required this.totalCount,
    required this.resolvedCount,
    required this.improvedCount,
    required this.monitorCount,
    required this.escalateCount,
    required this.attentionCount,
    required this.averageVerifiedLevel,
    required this.nextAction,
  });

  factory IncomingTalentCareerPathSupportOutcomeSummary.fromOutcomes(
    List<IncomingTalentCareerPathSupportOutcome> outcomes,
  ) {
    final resolvedCount = _countByDecision(
      outcomes,
      IncomingTalentCareerPathSupportOutcomeDecision.resolved,
    );
    final improvedCount = _countByDecision(
      outcomes,
      IncomingTalentCareerPathSupportOutcomeDecision.improved,
    );
    final monitorCount = _countByDecision(
      outcomes,
      IncomingTalentCareerPathSupportOutcomeDecision.monitor,
    );
    final escalateCount = _countByDecision(
      outcomes,
      IncomingTalentCareerPathSupportOutcomeDecision.escalate,
    );
    final attentionCount =
        outcomes.where((outcome) => outcome.needsAttention).length;
    final averageVerifiedLevel =
        outcomes.isEmpty
            ? 0.0
            : outcomes.fold<int>(
                  0,
                  (total, outcome) => total + outcome.verifiedLevel,
                ) /
                outcomes.length;

    return IncomingTalentCareerPathSupportOutcomeSummary(
      totalCount: outcomes.length,
      resolvedCount: resolvedCount,
      improvedCount: improvedCount,
      monitorCount: monitorCount,
      escalateCount: escalateCount,
      attentionCount: attentionCount,
      averageVerifiedLevel: averageVerifiedLevel,
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
  List<IncomingTalentCareerPathSupportOutcome> outcomes,
  IncomingTalentCareerPathSupportOutcomeDecision decision,
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
  if (totalCount == 0) return 'Validate resolved career support actions.';
  if (escalateCount > 0) {
    return 'Escalate $escalateCount career support outcomes.';
  }
  if (monitorCount > 0) {
    return 'Monitor $monitorCount career support outcomes.';
  }
  if (attentionCount > 0) {
    return 'Follow up $attentionCount residual career risks.';
  }
  if (improvedCount > 0) {
    return 'Track $improvedCount improving career outcomes.';
  }
  if (resolvedCount > 0) {
    return 'Keep $resolvedCount career paths on cadence.';
  }
  return 'Career support outcomes are current.';
}
