import 'incoming_talent_promotion_stabilization_follow_up_resolution.dart';

/// Aggregates promotion follow-up resolution reviews into closure signals.
class IncomingTalentPromotionStabilizationFollowUpResolutionSummary {
  final int totalCount;
  final int stabilizedCount;
  final int monitorCount;
  final int reopenedCount;
  final int escalatedCount;
  final int attentionCount;
  final double averageConfidenceAfter;
  final double averageConfidenceDelta;
  final String nextAction;

  const IncomingTalentPromotionStabilizationFollowUpResolutionSummary({
    required this.totalCount,
    required this.stabilizedCount,
    required this.monitorCount,
    required this.reopenedCount,
    required this.escalatedCount,
    required this.attentionCount,
    required this.averageConfidenceAfter,
    required this.averageConfidenceDelta,
    required this.nextAction,
  });

  factory IncomingTalentPromotionStabilizationFollowUpResolutionSummary.fromResolutions(
    List<IncomingTalentPromotionStabilizationFollowUpResolution> resolutions,
  ) {
    final stabilizedCount = _countByOutcome(
      resolutions,
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.stabilized,
    );
    final monitorCount = _countByOutcome(
      resolutions,
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome.monitor,
    );
    final reopenedCount = _countByOutcome(
      resolutions,
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
          .reopenFollowUp,
    );
    final escalatedCount = _countByOutcome(
      resolutions,
      IncomingTalentPromotionStabilizationFollowUpResolutionOutcome
          .peoplePanelEscalation,
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

    return IncomingTalentPromotionStabilizationFollowUpResolutionSummary(
      totalCount: resolutions.length,
      stabilizedCount: stabilizedCount,
      monitorCount: monitorCount,
      reopenedCount: reopenedCount,
      escalatedCount: escalatedCount,
      attentionCount: attentionCount,
      averageConfidenceAfter:
          resolutions.isEmpty ? 0 : confidenceTotal / resolutions.length,
      averageConfidenceDelta:
          resolutions.isEmpty ? 0 : deltaTotal / resolutions.length,
      nextAction: _nextAction(
        totalCount: resolutions.length,
        stabilizedCount: stabilizedCount,
        monitorCount: monitorCount,
        reopenedCount: reopenedCount,
        escalatedCount: escalatedCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

const emptyIncomingTalentPromotionStabilizationFollowUpResolutionSummary =
    IncomingTalentPromotionStabilizationFollowUpResolutionSummary(
      totalCount: 0,
      stabilizedCount: 0,
      monitorCount: 0,
      reopenedCount: 0,
      escalatedCount: 0,
      attentionCount: 0,
      averageConfidenceAfter: 0,
      averageConfidenceDelta: 0,
      nextAction: 'Review resolved promotion follow-up actions.',
    );

int _countByOutcome(
  List<IncomingTalentPromotionStabilizationFollowUpResolution> resolutions,
  IncomingTalentPromotionStabilizationFollowUpResolutionOutcome outcome,
) {
  return resolutions
      .where((resolution) => resolution.outcome == outcome)
      .length;
}

String _nextAction({
  required int totalCount,
  required int stabilizedCount,
  required int monitorCount,
  required int reopenedCount,
  required int escalatedCount,
  required int attentionCount,
}) {
  if (totalCount == 0) {
    return 'Review resolved promotion follow-up actions.';
  }
  if (escalatedCount > 0) {
    return 'Escalate $escalatedCount promotion resolutions to people panel.';
  }
  if (reopenedCount > 0) {
    return 'Reopen $reopenedCount promotion follow-up actions.';
  }
  if (monitorCount > 0 || attentionCount > 0) {
    return 'Monitor $attentionCount promotion resolutions with residual risk.';
  }
  return '$stabilizedCount promotion follow-up resolutions are stable.';
}
