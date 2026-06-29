import 'incoming_talent_succession_bench_action.dart';

class IncomingTalentSuccessionBenchActionSummary {
  final int totalActions;
  final int plannedCount;
  final int inProgressCount;
  final int resolvedCount;
  final int blockedCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionBenchActionSummary({
    required this.totalActions,
    required this.plannedCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.blockedCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionBenchActionSummary.fromActions({
    required List<IncomingTalentSuccessionBenchAction> actions,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionBenchActionStatus.planned,
            )
            .length;
    final inProgressCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionBenchActionStatus.inProgress,
            )
            .length;
    final resolvedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionBenchActionStatus.resolved,
            )
            .length;
    final blockedCount =
        actions
            .where(
              (action) =>
                  action.status ==
                  IncomingTalentSuccessionBenchActionStatus.blocked,
            )
            .length;
    final dueSoonCount =
        actions.where((action) => action.isDueSoon(asOfDate)).length;
    final overdueCount =
        actions.where((action) => action.isOverdue(asOfDate)).length;

    return IncomingTalentSuccessionBenchActionSummary(
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
    return 'Create actions from risky bench check-ins.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount bench actions.';
  }
  if (overdueCount > 0) {
    return 'Resolve $overdueCount overdue bench actions.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount bench actions due soon.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned bench actions.';
  }
  if (inProgressCount > 0) {
    return 'Track $inProgressCount bench actions in progress.';
  }
  return '$resolvedCount bench actions resolved.';
}
