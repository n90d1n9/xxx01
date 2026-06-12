import 'incoming_talent_succession_coverage_action.dart';

class IncomingTalentSuccessionCoverageActionSummary {
  final int totalActions;
  final int plannedCount;
  final int inProgressCount;
  final int resolvedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionCoverageActionSummary({
    required this.totalActions,
    required this.plannedCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionCoverageActionSummary.fromActions({
    required List<IncomingTalentSuccessionCoverageAction> actions,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionCoverageActionStatus.planned,
            )
            .length;
    final inProgressCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionCoverageActionStatus.inProgress,
            )
            .length;
    final resolvedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionCoverageActionStatus.resolved,
            )
            .length;
    final blockedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionCoverageActionStatus.blocked,
            )
            .length;
    final dueSoonCount =
        actions.where((action) => action.isDueSoon(asOfDate)).length;
    final overdueCount =
        actions.where((action) => action.isOverdue(asOfDate)).length;

    return IncomingTalentSuccessionCoverageActionSummary(
      totalActions: actions.length,
      plannedCount: plannedCount,
      inProgressCount: inProgressCount,
      resolvedCount: resolvedCount,
      blockedCount: blockedCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalActions: actions.length,
        plannedCount: plannedCount,
        inProgressCount: inProgressCount,
        resolvedCount: resolvedCount,
        blockedCount: blockedCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalActions,
  required int plannedCount,
  required int inProgressCount,
  required int resolvedCount,
  required int blockedCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalActions == 0) {
    return 'Create actions from coverage reviews.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount coverage actions.';
  }
  if (overdueCount > 0) {
    return 'Resolve $overdueCount overdue coverage actions.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount coverage actions due soon.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned coverage actions.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount coverage actions in progress.';
  }
  return '$resolvedCount coverage actions resolved.';
}
