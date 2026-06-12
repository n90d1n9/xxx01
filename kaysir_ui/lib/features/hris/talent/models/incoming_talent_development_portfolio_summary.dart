import 'incoming_talent_development_portfolio.dart';

class IncomingTalentDevelopmentPortfolioSummary {
  final int totalCount;
  final int designingCount;
  final int activeCount;
  final int watchCount;
  final int graduatedCount;
  final int recoveryPriorityCount;
  final int dueSoonCount;
  final double averageReadinessScore;
  final String nextAction;

  const IncomingTalentDevelopmentPortfolioSummary({
    required this.totalCount,
    required this.designingCount,
    required this.activeCount,
    required this.watchCount,
    required this.graduatedCount,
    required this.recoveryPriorityCount,
    required this.dueSoonCount,
    required this.averageReadinessScore,
    required this.nextAction,
  });

  factory IncomingTalentDevelopmentPortfolioSummary.fromPortfolios({
    required List<IncomingTalentDevelopmentPortfolio> portfolios,
    required DateTime asOfDate,
  }) {
    final dueThreshold = asOfDate.add(const Duration(days: 14));
    final designingCount = _countStage(
      portfolios,
      IncomingTalentDevelopmentPortfolioStage.designing,
    );
    final activeCount = _countStage(
      portfolios,
      IncomingTalentDevelopmentPortfolioStage.active,
    );
    final watchCount = _countStage(
      portfolios,
      IncomingTalentDevelopmentPortfolioStage.watch,
    );
    final graduatedCount = _countStage(
      portfolios,
      IncomingTalentDevelopmentPortfolioStage.graduated,
    );
    final recoveryPriorityCount =
        portfolios
            .where(
              (portfolio) =>
                  portfolio.priority ==
                  IncomingTalentDevelopmentPortfolioPriority.recovery,
            )
            .length;
    final dueSoonCount =
        portfolios
            .where(
              (portfolio) =>
                  portfolio.stage !=
                      IncomingTalentDevelopmentPortfolioStage.graduated &&
                  !portfolio.nextReviewDate.isAfter(dueThreshold),
            )
            .length;
    final readinessTotal = portfolios.fold<int>(
      0,
      (total, portfolio) => total + portfolio.sourceReadinessScore,
    );

    return IncomingTalentDevelopmentPortfolioSummary(
      totalCount: portfolios.length,
      designingCount: designingCount,
      activeCount: activeCount,
      watchCount: watchCount,
      graduatedCount: graduatedCount,
      recoveryPriorityCount: recoveryPriorityCount,
      dueSoonCount: dueSoonCount,
      averageReadinessScore:
          portfolios.isEmpty ? 0 : readinessTotal / portfolios.length,
      nextAction: _nextAction(
        totalCount: portfolios.length,
        designingCount: designingCount,
        activeCount: activeCount,
        watchCount: watchCount,
        recoveryPriorityCount: recoveryPriorityCount,
        dueSoonCount: dueSoonCount,
      ),
    );
  }
}

int _countStage(
  List<IncomingTalentDevelopmentPortfolio> portfolios,
  IncomingTalentDevelopmentPortfolioStage stage,
) {
  return portfolios.where((portfolio) => portfolio.stage == stage).length;
}

String _nextAction({
  required int totalCount,
  required int designingCount,
  required int activeCount,
  required int watchCount,
  required int recoveryPriorityCount,
  required int dueSoonCount,
}) {
  if (totalCount == 0) return 'Create IDP portfolios from roadmaps.';
  if (watchCount > 0 || recoveryPriorityCount > 0) {
    return 'Stabilize $watchCount watch portfolios.';
  }
  if (dueSoonCount > 0) {
    return 'Review $dueSoonCount IDP portfolios due soon.';
  }
  if (designingCount > 0) {
    return 'Activate $designingCount drafted IDP portfolios.';
  }
  return 'Keep $activeCount active IDP portfolios on cadence.';
}
