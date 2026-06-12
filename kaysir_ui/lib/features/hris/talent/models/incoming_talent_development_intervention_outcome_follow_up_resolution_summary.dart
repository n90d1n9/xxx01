import 'incoming_talent_development_intervention_outcome_follow_up_resolution.dart';

class IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary {
  final int totalCount;
  final int closedCount;
  final int sustainedCount;
  final int monitorCount;
  final int escalateCount;
  final int attentionCount;
  final double averageConfidenceAfter;
  final double averageConfidenceDelta;
  final String nextAction;

  const IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary({
    required this.totalCount,
    required this.closedCount,
    required this.sustainedCount,
    required this.monitorCount,
    required this.escalateCount,
    required this.attentionCount,
    required this.averageConfidenceAfter,
    required this.averageConfidenceDelta,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary.fromResolutions(
    List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
    resolutions,
  ) {
    final closedCount = _countByDecision(
      resolutions,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
          .closed,
    );
    final sustainedCount = _countByDecision(
      resolutions,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
          .sustained,
    );
    final monitorCount = _countByDecision(
      resolutions,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
          .monitor,
    );
    final escalateCount = _countByDecision(
      resolutions,
      IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
          .escalate,
    );
    final attentionCount =
        resolutions.where((resolution) => resolution.needsAttention).length;
    final confidenceTotal = resolutions.fold<int>(
      0,
      (total, resolution) => total + resolution.confidenceAfter,
    );
    final deltaTotal = resolutions.fold<int>(
      0,
      (total, resolution) => total + resolution.confidenceDelta,
    );
    final averageConfidenceAfter =
        resolutions.isEmpty ? 0.0 : confidenceTotal / resolutions.length;
    final averageConfidenceDelta =
        resolutions.isEmpty ? 0.0 : deltaTotal / resolutions.length;

    return IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionSummary(
      totalCount: resolutions.length,
      closedCount: closedCount,
      sustainedCount: sustainedCount,
      monitorCount: monitorCount,
      escalateCount: escalateCount,
      attentionCount: attentionCount,
      averageConfidenceAfter: averageConfidenceAfter,
      averageConfidenceDelta: averageConfidenceDelta,
      nextAction: _nextAction(
        totalCount: resolutions.length,
        closedCount: closedCount,
        sustainedCount: sustainedCount,
        monitorCount: monitorCount,
        escalateCount: escalateCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

int _countByDecision(
  List<IncomingTalentDevelopmentInterventionOutcomeFollowUpResolution>
  resolutions,
  IncomingTalentDevelopmentInterventionOutcomeFollowUpResolutionDecision
  decision,
) {
  return resolutions
      .where((resolution) => resolution.decision == decision)
      .length;
}

String _nextAction({
  required int totalCount,
  required int closedCount,
  required int sustainedCount,
  required int monitorCount,
  required int escalateCount,
  required int attentionCount,
}) {
  if (totalCount == 0) {
    return 'Review completed intervention outcome follow-ups.';
  }
  if (escalateCount > 0) {
    return 'Escalate $escalateCount follow-up resolutions to HR council.';
  }
  if (monitorCount > 0 || attentionCount > 0) {
    return 'Monitor $attentionCount follow-up resolutions with residual risk.';
  }
  if (sustainedCount > 0) {
    return 'Keep $sustainedCount sustained follow-up resolutions on watch.';
  }
  return '$closedCount intervention follow-up resolutions are closed.';
}
