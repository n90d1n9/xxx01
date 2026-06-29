import 'incoming_talent_succession_coverage_action_outcome.dart';

class IncomingTalentSuccessionCoverageActionOutcomeSummary {
  final int totalOutcomes;
  final int validatedCount;
  final int monitorCount;
  final int reworkCount;
  final int executiveReviewCount;
  final int attentionCount;
  final double averageCoverageAfter;
  final double averageCoverageImprovement;
  final String nextAction;

  const IncomingTalentSuccessionCoverageActionOutcomeSummary({
    required this.totalOutcomes,
    required this.validatedCount,
    required this.monitorCount,
    required this.reworkCount,
    required this.executiveReviewCount,
    required this.attentionCount,
    required this.averageCoverageAfter,
    required this.averageCoverageImprovement,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageActionOutcomeSummary.fromOutcomes(
    List<IncomingTalentSuccessionCoverageActionOutcome> outcomes,
  ) {
    final validatedCount =
        outcomes
            .where(
              (outcome) =>
                  outcome.decision ==
                  IncomingTalentSuccessionCoverageActionOutcomeDecision
                      .validated,
            )
            .length;
    final monitorCount =
        outcomes
            .where(
              (outcome) =>
                  outcome.decision ==
                  IncomingTalentSuccessionCoverageActionOutcomeDecision.monitor,
            )
            .length;
    final reworkCount =
        outcomes
            .where(
              (outcome) =>
                  outcome.decision ==
                  IncomingTalentSuccessionCoverageActionOutcomeDecision
                      .reworkCoverage,
            )
            .length;
    final executiveReviewCount =
        outcomes
            .where(
              (outcome) =>
                  outcome.decision ==
                  IncomingTalentSuccessionCoverageActionOutcomeDecision
                      .executiveReview,
            )
            .length;
    final attentionCount =
        outcomes.where((outcome) => outcome.needsAttention).length;
    final coverageAfterTotal = outcomes.fold<int>(
      0,
      (total, outcome) => total + outcome.coverageScoreAfter,
    );
    final coverageImprovementTotal = outcomes.fold<int>(
      0,
      (total, outcome) => total + outcome.coverageImprovement,
    );

    return IncomingTalentSuccessionCoverageActionOutcomeSummary(
      totalOutcomes: outcomes.length,
      validatedCount: validatedCount,
      monitorCount: monitorCount,
      reworkCount: reworkCount,
      executiveReviewCount: executiveReviewCount,
      attentionCount: attentionCount,
      averageCoverageAfter:
          outcomes.isEmpty ? 0.0 : coverageAfterTotal / outcomes.length,
      averageCoverageImprovement:
          outcomes.isEmpty ? 0.0 : coverageImprovementTotal / outcomes.length,
      nextAction: _nextAction(
        totalOutcomes: outcomes.length,
        validatedCount: validatedCount,
        monitorCount: monitorCount,
        reworkCount: reworkCount,
        executiveReviewCount: executiveReviewCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

String _nextAction({
  required int totalOutcomes,
  required int validatedCount,
  required int monitorCount,
  required int reworkCount,
  required int executiveReviewCount,
  required int attentionCount,
}) {
  if (totalOutcomes == 0) {
    return 'Review resolved coverage actions before closing risk.';
  }
  if (executiveReviewCount > 0) {
    return 'Route $executiveReviewCount coverage outcomes to executives.';
  }
  if (reworkCount > 0) {
    return 'Rework $reworkCount coverage outcomes with unresolved risk.';
  }
  if (attentionCount > 0) {
    return 'Keep $attentionCount coverage outcomes on watch.';
  }
  if (monitorCount > 0) {
    return 'Confirm $monitorCount monitored outcomes in the next council.';
  }
  return '$validatedCount coverage outcomes validated.';
}
