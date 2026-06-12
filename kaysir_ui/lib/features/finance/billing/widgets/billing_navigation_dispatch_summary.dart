import 'billing_navigation_dispatch_plan.dart';

class BillingNavigationDispatchSummary {
  final int totalCount;
  final int actionableCount;
  final int localCount;
  final int routeCount;
  final int unavailableCount;
  final int ignoredCount;

  const BillingNavigationDispatchSummary({
    required this.totalCount,
    required this.actionableCount,
    required this.localCount,
    required this.routeCount,
    required this.unavailableCount,
    required this.ignoredCount,
  });

  factory BillingNavigationDispatchSummary.fromPlans(
    Iterable<BillingNavigationDispatchPlan> plans,
  ) {
    var totalCount = 0;
    var localCount = 0;
    var routeCount = 0;
    var unavailableCount = 0;
    var ignoredCount = 0;

    for (final plan in plans) {
      totalCount += 1;
      switch (plan.kind) {
        case BillingNavigationDispatchKind.local:
          localCount += 1;
        case BillingNavigationDispatchKind.route:
          routeCount += 1;
        case BillingNavigationDispatchKind.unavailable:
          unavailableCount += 1;
        case BillingNavigationDispatchKind.ignored:
          ignoredCount += 1;
      }
    }

    return BillingNavigationDispatchSummary(
      totalCount: totalCount,
      actionableCount: localCount + routeCount,
      localCount: localCount,
      routeCount: routeCount,
      unavailableCount: unavailableCount,
      ignoredCount: ignoredCount,
    );
  }

  int get blockedCount => unavailableCount + ignoredCount;

  bool get isEmpty => totalCount == 0;

  bool get hasActionableRoutes => actionableCount > 0;

  bool get hasBlockedRoutes => blockedCount > 0;

  bool get isFullyActionable {
    return totalCount > 0 && actionableCount == totalCount;
  }
}
