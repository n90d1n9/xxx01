import 'incoming_talent_succession_bench_replenishment.dart';

class IncomingTalentSuccessionBenchReplenishmentSummary {
  final int totalPlans;
  final int plannedCount;
  final int activeCount;
  final int completedCount;
  final int blockedCount;
  final int criticalCount;
  final int dueSoonCount;
  final int overdueCount;
  final String nextAction;

  const IncomingTalentSuccessionBenchReplenishmentSummary({
    required this.totalPlans,
    required this.plannedCount,
    required this.activeCount,
    required this.completedCount,
    required this.blockedCount,
    required this.criticalCount,
    required this.dueSoonCount,
    required this.overdueCount,
    required this.nextAction,
  });

  factory IncomingTalentSuccessionBenchReplenishmentSummary.fromPlans({
    required List<IncomingTalentSuccessionBenchReplenishment> plans,
    required DateTime asOfDate,
  }) {
    final plannedCount =
        plans
            .where(
              (plan) =>
                  plan.status ==
                  IncomingTalentSuccessionBenchReplenishmentStatus.planned,
            )
            .length;
    final activeCount =
        plans
            .where(
              (plan) =>
                  plan.status ==
                  IncomingTalentSuccessionBenchReplenishmentStatus.active,
            )
            .length;
    final completedCount =
        plans
            .where(
              (plan) =>
                  plan.status ==
                  IncomingTalentSuccessionBenchReplenishmentStatus.completed,
            )
            .length;
    final blockedCount =
        plans
            .where(
              (plan) =>
                  plan.status ==
                  IncomingTalentSuccessionBenchReplenishmentStatus.blocked,
            )
            .length;
    final criticalCount =
        plans
            .where(
              (plan) =>
                  plan.isOpen &&
                  plan.priority ==
                      IncomingTalentSuccessionBenchReplenishmentPriority
                          .critical,
            )
            .length;
    final dueSoonCount = plans.where((plan) => plan.isDueSoon(asOfDate)).length;
    final overdueCount = plans.where((plan) => plan.isOverdue(asOfDate)).length;

    return IncomingTalentSuccessionBenchReplenishmentSummary(
      totalPlans: plans.length,
      plannedCount: plannedCount,
      activeCount: activeCount,
      completedCount: completedCount,
      blockedCount: blockedCount,
      criticalCount: criticalCount,
      dueSoonCount: dueSoonCount,
      overdueCount: overdueCount,
      nextAction: _nextAction(
        totalPlans: plans.length,
        plannedCount: plannedCount,
        activeCount: activeCount,
        completedCount: completedCount,
        blockedCount: blockedCount,
        criticalCount: criticalCount,
        dueSoonCount: dueSoonCount,
        overdueCount: overdueCount,
      ),
    );
  }
}

String _nextAction({
  required int totalPlans,
  required int plannedCount,
  required int activeCount,
  required int completedCount,
  required int blockedCount,
  required int criticalCount,
  required int dueSoonCount,
  required int overdueCount,
}) {
  if (totalPlans == 0) {
    return 'Create bench replenishment from transition outcomes.';
  }
  if (blockedCount > 0) {
    return 'Unblock $blockedCount bench replenishments.';
  }
  if (overdueCount > 0) {
    return 'Restore $overdueCount overdue bench replenishments.';
  }
  if (criticalCount > 0) {
    return 'Start $criticalCount critical bench replenishments.';
  }
  if (dueSoonCount > 0) {
    return 'Complete $dueSoonCount bench replenishments due soon.';
  }
  if (plannedCount > 0) {
    return 'Start $plannedCount planned bench replenishments.';
  }
  if (activeCount > 0) {
    return 'Track $activeCount active bench replenishments.';
  }
  return '$completedCount bench replenishments complete.';
}
