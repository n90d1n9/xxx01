import 'incoming_talent_risk_council_queue_item.dart';

/// Aggregated talent risk council queue health and next-step guidance.
class IncomingTalentRiskCouncilQueueSummary {
  final int totalItems;
  final int criticalCount;
  final int watchCount;
  final int candidateCount;
  final int departmentCount;
  final int resolutionReviewCount;
  final int promotionResolutionReviewCount;
  final int openActionCount;
  final String nextAction;

  const IncomingTalentRiskCouncilQueueSummary({
    required this.totalItems,
    required this.criticalCount,
    required this.watchCount,
    required this.candidateCount,
    required this.departmentCount,
    required this.resolutionReviewCount,
    required this.promotionResolutionReviewCount,
    required this.openActionCount,
    required this.nextAction,
  });

  factory IncomingTalentRiskCouncilQueueSummary.fromItems(
    List<IncomingTalentRiskCouncilQueueItem> items,
  ) {
    final criticalCount = items.where((item) => item.isCritical).length;
    final watchCount = items.length - criticalCount;
    final candidateCount = items.map((item) => item.candidateId).toSet().length;
    final departmentCount = items.map((item) => item.department).toSet().length;
    final resolutionReviewCount =
        items.where((item) {
          return item.category ==
              IncomingTalentRiskCouncilQueueCategory.resolutionReview;
        }).length;
    final promotionResolutionReviewCount =
        items.where((item) => item.isPromotionResolutionReview).length;
    final openActionCount =
        items
            .where(
              (item) =>
                  item.category ==
                      IncomingTalentRiskCouncilQueueCategory.intervention ||
                  item.category ==
                      IncomingTalentRiskCouncilQueueCategory.careerSupport,
            )
            .length;

    return IncomingTalentRiskCouncilQueueSummary(
      totalItems: items.length,
      criticalCount: criticalCount,
      watchCount: watchCount,
      candidateCount: candidateCount,
      departmentCount: departmentCount,
      resolutionReviewCount: resolutionReviewCount,
      promotionResolutionReviewCount: promotionResolutionReviewCount,
      openActionCount: openActionCount,
      nextAction: _nextAction(
        totalItems: items.length,
        criticalCount: criticalCount,
        resolutionReviewCount: resolutionReviewCount,
        promotionResolutionReviewCount: promotionResolutionReviewCount,
        watchCount: watchCount,
      ),
    );
  }
}

String _nextAction({
  required int totalItems,
  required int criticalCount,
  required int resolutionReviewCount,
  required int promotionResolutionReviewCount,
  required int watchCount,
}) {
  if (totalItems == 0) return 'No talent risks queued for council.';
  if (criticalCount > 0) {
    return 'Prepare $criticalCount critical talent risks for council.';
  }
  if (promotionResolutionReviewCount > 0) {
    return 'Review $promotionResolutionReviewCount promotion resolution risks.';
  }
  if (resolutionReviewCount > 0) {
    return 'Review $resolutionReviewCount follow-up resolution risks.';
  }
  return 'Monitor $watchCount watch talent risks.';
}
