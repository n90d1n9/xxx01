import 'incoming_talent_succession_activation_resolution_review.dart';

class IncomingTalentSuccessionActivationResolutionReviewSummary {
  final int totalReviews;
  final int clearedCount;
  final int monitorCount;
  final int reopenCount;
  final int panelReviewCount;
  final int attentionCount;
  final double averageFinalConfidence;
  final String nextAction;

  const IncomingTalentSuccessionActivationResolutionReviewSummary({
    required this.totalReviews,
    required this.clearedCount,
    required this.monitorCount,
    required this.reopenCount,
    required this.panelReviewCount,
    required this.attentionCount,
    required this.averageFinalConfidence,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionActivationResolutionReviewSummary.fromReviews(
    List<IncomingTalentSuccessionActivationResolutionReview> reviews,
  ) {
    final clearedCount =
        reviews
            .where(
              (review) =>
                  review.outcome ==
                  IncomingTalentSuccessionActivationResolutionOutcome
                      .transitionCleared,
            )
            .length;
    final monitorCount =
        reviews
            .where(
              (review) =>
                  review.outcome ==
                  IncomingTalentSuccessionActivationResolutionOutcome.monitor,
            )
            .length;
    final reopenCount =
        reviews
            .where(
              (review) =>
                  review.outcome ==
                  IncomingTalentSuccessionActivationResolutionOutcome
                      .reopenEscalation,
            )
            .length;
    final panelReviewCount =
        reviews
            .where(
              (review) =>
                  review.outcome ==
                  IncomingTalentSuccessionActivationResolutionOutcome
                      .panelReview,
            )
            .length;
    final attentionCount =
        reviews.where((review) => review.needsAttention).length;
    final confidenceTotal = reviews.fold<int>(
      0,
      (total, review) => total + review.finalConfidenceScore,
    );
    final averageFinalConfidence =
        reviews.isEmpty ? 0.0 : confidenceTotal / reviews.length;

    return IncomingTalentSuccessionActivationResolutionReviewSummary(
      totalReviews: reviews.length,
      clearedCount: clearedCount,
      monitorCount: monitorCount,
      reopenCount: reopenCount,
      panelReviewCount: panelReviewCount,
      attentionCount: attentionCount,
      averageFinalConfidence: averageFinalConfidence,
      nextAction: _nextAction(
        totalReviews: reviews.length,
        clearedCount: clearedCount,
        monitorCount: monitorCount,
        reopenCount: reopenCount,
        panelReviewCount: panelReviewCount,
        attentionCount: attentionCount,
      ),
    );
  }
}

String _nextAction({
  required int totalReviews,
  required int clearedCount,
  required int monitorCount,
  required int reopenCount,
  required int panelReviewCount,
  required int attentionCount,
}) {
  if (totalReviews == 0) {
    return 'Review resolved succession escalations before closure.';
  }
  if (panelReviewCount > 0) {
    return 'Route $panelReviewCount resolution reviews to panel.';
  }
  if (reopenCount > 0) return 'Reopen $reopenCount succession escalations.';
  if (attentionCount > 0) {
    return 'Monitor $attentionCount resolution reviews with residual risk.';
  }
  if (monitorCount > 0) return 'Keep $monitorCount transitions on watch.';
  return '$clearedCount succession transitions are cleared.';
}
