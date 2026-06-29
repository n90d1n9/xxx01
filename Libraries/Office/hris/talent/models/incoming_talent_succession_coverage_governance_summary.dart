import 'incoming_talent_succession_coverage_governance_record.dart';

class IncomingTalentSuccessionCoverageGovernanceSummary {
  final int totalRecords;
  final int openRecords;
  final int actionRequiredCount;
  final int actionOpenCount;
  final int outcomeReviewCount;
  final int outcomeWatchCount;
  final int closedCount;
  final int criticalCount;
  final int dueSoonCount;
  final int overdueCount;
  final double averageCoverageScore;
  final String nextAction;

  const IncomingTalentSuccessionCoverageGovernanceSummary({
    required this.totalRecords,
    required this.openRecords,
    required this.actionRequiredCount,
    required this.actionOpenCount,
    required this.outcomeReviewCount,
    required this.outcomeWatchCount,
    required this.closedCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.averageCoverageScore,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageGovernanceSummary.fromRecords({
    required List<IncomingTalentSuccessionCoverageGovernanceRecord> records,
    required DateTime asOfDate,
  }) {
    final actionRequiredCount = _countStage(
      records,
      IncomingTalentSuccessionCoverageGovernanceStage.actionRequired,
    );
    final actionOpenCount = _countStage(
      records,
      IncomingTalentSuccessionCoverageGovernanceStage.actionOpen,
    );
    final outcomeReviewCount = _countStage(
      records,
      IncomingTalentSuccessionCoverageGovernanceStage.outcomeReview,
    );
    final outcomeWatchCount = _countStage(
      records,
      IncomingTalentSuccessionCoverageGovernanceStage.outcomeWatch,
    );
    final closedCount = _countStage(
      records,
      IncomingTalentSuccessionCoverageGovernanceStage.closed,
    );
    final criticalCount =
        records
            .where(
              (record) =>
                  record.riskLevel ==
                  IncomingTalentSuccessionCoverageGovernanceRiskLevel.critical,
            )
            .length;
    final dueSoonCount =
        records.where((record) => record.isDueSoon(asOfDate)).length;
    final overdueCount =
        records.where((record) => record.isOverdue(asOfDate)).length;
    final coverageScoreTotal = records.fold<int>(
      0,
      (total, record) => total + record.coverageScore,
    );

    return IncomingTalentSuccessionCoverageGovernanceSummary(
      totalRecords: records.length,
      openRecords: records.where((record) => !record.isClosed).length,
      actionRequiredCount: actionRequiredCount,
      actionOpenCount: actionOpenCount,
      outcomeReviewCount: outcomeReviewCount,
      outcomeWatchCount: outcomeWatchCount,
      closedCount: closedCount,
      criticalCount: criticalCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      averageCoverageScore:
          records.isEmpty ? 0 : coverageScoreTotal / records.length,
      nextAction: _nextAction(
        totalRecords: records.length,
        actionRequiredCount: actionRequiredCount,
        actionOpenCount: actionOpenCount,
        outcomeReviewCount: outcomeReviewCount,
        outcomeWatchCount: outcomeWatchCount,
        closedCount: closedCount,
        criticalCount: criticalCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

int _countStage(
  List<IncomingTalentSuccessionCoverageGovernanceRecord> records,
  IncomingTalentSuccessionCoverageGovernanceStage stage,
) {
  return records.where((record) => record.stage == stage).length;
}

String _nextAction({
  required int totalRecords,
  required int actionRequiredCount,
  required int actionOpenCount,
  required int outcomeReviewCount,
  required int outcomeWatchCount,
  required int closedCount,
  required int criticalCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalRecords == 0) {
    return 'Create coverage reviews to populate governance.';
  }
  if (criticalCount > 0) {
    return 'Resolve $criticalCount critical coverage governance records.';
  }
  if (overdueCount > 0) {
    return 'Escalate $overdueCount overdue coverage governance records.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount governance records due soon.';
  }
  if (actionRequiredCount > 0) {
    return 'Create $actionRequiredCount coverage actions.';
  }
  if (actionOpenCount > 0) {
    return 'Track $actionOpenCount open coverage actions.';
  }
  if (outcomeReviewCount > 0) {
    return 'Review $outcomeReviewCount resolved coverage actions.';
  }
  if (outcomeWatchCount > 0) {
    return 'Monitor $outcomeWatchCount coverage outcomes.';
  }
  return '$closedCount coverage governance records closed.';
}
