import 'package:flutter/material.dart';

import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_drawer.dart';
import 'billing_navigation_launch_planner.dart';
import 'billing_navigation_launch_snapshot.dart';

class BillingDashboardDrawer extends StatelessWidget {
  final String? tenantName;
  final String? tenantSubtitle;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final bool hasTenant;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingNavigationCoverageSummary? coverageSummary;

  const BillingDashboardDrawer({
    super.key,
    this.tenantName,
    this.tenantSubtitle,
    this.onDestinationSelected,
    this.hasTenant = true,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return BillingNavigationDrawer(
      selectedDestination: BillingNavigationDestinationId.dashboard,
      tenantName: tenantName,
      tenantSubtitle: tenantSubtitle,
      hasTenant: hasTenant,
      navigationSet: navigationSet,
      launchPlanner: launchPlanner,
      launchSnapshot: launchSnapshot,
      dispatchSnapshot: dispatchSnapshot,
      coverageSummary: coverageSummary,
      onDestinationSelected: onDestinationSelected ?? (_) {},
    );
  }
}
