import 'billing_navigation_dispatch_plan.dart';

enum BillingProductReleaseChannelLaunchDispatchStatus {
  blockedByRelease,
  notExposed,
  unavailable,
  route,
  local,
  ignored,
}

extension BillingProductReleaseChannelLaunchDispatchStatusX
    on BillingProductReleaseChannelLaunchDispatchStatus {
  bool get isActionable {
    return this == BillingProductReleaseChannelLaunchDispatchStatus.route ||
        this == BillingProductReleaseChannelLaunchDispatchStatus.local;
  }

  bool get isBlockedByRelease {
    return this ==
        BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease;
  }

  bool get needsRoutingWork {
    return !isActionable && !isBlockedByRelease;
  }

  String get label {
    return switch (this) {
      BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease =>
        'Blocked',
      BillingProductReleaseChannelLaunchDispatchStatus.notExposed =>
        'Not exposed',
      BillingProductReleaseChannelLaunchDispatchStatus.unavailable =>
        'Unavailable',
      BillingProductReleaseChannelLaunchDispatchStatus.route => 'Route',
      BillingProductReleaseChannelLaunchDispatchStatus.local => 'Local',
      BillingProductReleaseChannelLaunchDispatchStatus.ignored => 'Ignored',
    };
  }
}

BillingProductReleaseChannelLaunchDispatchStatus
billingProductReleaseChannelLaunchDispatchStatusFor({
  required bool isBlockedByRelease,
  required BillingNavigationDispatchPlan? navigationPlan,
}) {
  if (isBlockedByRelease) {
    return BillingProductReleaseChannelLaunchDispatchStatus.blockedByRelease;
  }

  final plan = navigationPlan;
  if (plan == null) {
    return BillingProductReleaseChannelLaunchDispatchStatus.notExposed;
  }
  if (plan.isUnavailable) {
    return BillingProductReleaseChannelLaunchDispatchStatus.unavailable;
  }
  if (plan.opensRoute) {
    return BillingProductReleaseChannelLaunchDispatchStatus.route;
  }
  if (plan.isLocal) {
    return BillingProductReleaseChannelLaunchDispatchStatus.local;
  }

  return BillingProductReleaseChannelLaunchDispatchStatus.ignored;
}
