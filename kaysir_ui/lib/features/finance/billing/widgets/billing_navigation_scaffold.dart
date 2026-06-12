import 'package:flutter/material.dart';

import '../models/billing_route_link_navigation_model.dart';
import '../utils/billing_route_link.dart';
import 'billing_domain_navigation_policy.dart';
import 'billing_navigation_coverage_summary.dart';
import 'billing_navigation_dispatch_snapshot.dart';
import 'billing_navigation_drawer.dart';
import 'billing_navigation_launch_planner.dart';
import 'billing_navigation_launch_snapshot.dart';

class BillingNavigationScaffold extends StatelessWidget {
  static const double persistentSidebarBreakpoint = 1080;
  static const double persistentSidebarWidth = 292;

  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final String? tenantName;
  final String? tenantSubtitle;
  final bool hasTenant;
  final List<BillingNavigationDestination>? destinations;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingRouteLinkNavigationModel? routeLinkNavigationModel;
  final List<BillingRouteLink>? routeLinks;
  final BillingNavigationCoverageSummary? coverageSummary;

  const BillingNavigationScaffold({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.tenantName,
    this.tenantSubtitle,
    this.hasTenant = true,
    this.destinations,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
    this.routeLinkNavigationModel,
    this.routeLinks,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showPersistentSidebar =
            constraints.maxWidth >= persistentSidebarBreakpoint;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: appBar,
          drawer:
              showPersistentSidebar
                  ? null
                  : BillingNavigationDrawer(
                    selectedDestination: selectedDestination,
                    tenantName: tenantName,
                    tenantSubtitle: tenantSubtitle,
                    hasTenant: hasTenant,
                    destinations: destinations,
                    navigationSet: navigationSet,
                    launchPlanner: launchPlanner,
                    launchSnapshot: launchSnapshot,
                    dispatchSnapshot: dispatchSnapshot,
                    routeLinkNavigationModel: routeLinkNavigationModel,
                    routeLinks: routeLinks,
                    coverageSummary: coverageSummary,
                    onDestinationSelected: onDestinationSelected,
                  ),
          body:
              showPersistentSidebar
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _BillingPersistentSidebar(
                        selectedDestination: selectedDestination,
                        tenantName: tenantName,
                        tenantSubtitle: tenantSubtitle,
                        hasTenant: hasTenant,
                        destinations: destinations,
                        navigationSet: navigationSet,
                        launchPlanner: launchPlanner,
                        launchSnapshot: launchSnapshot,
                        dispatchSnapshot: dispatchSnapshot,
                        routeLinkNavigationModel: routeLinkNavigationModel,
                        routeLinks: routeLinks,
                        coverageSummary: coverageSummary,
                        onDestinationSelected: onDestinationSelected,
                      ),
                      Expanded(child: body),
                    ],
                  )
                  : body,
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
        );
      },
    );
  }
}

class _BillingPersistentSidebar extends StatelessWidget {
  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final String? tenantName;
  final String? tenantSubtitle;
  final bool hasTenant;
  final List<BillingNavigationDestination>? destinations;
  final BillingDomainNavigationSet? navigationSet;
  final BillingNavigationLaunchPlanner? launchPlanner;
  final BillingNavigationLaunchSnapshot? launchSnapshot;
  final BillingNavigationDispatchSnapshot? dispatchSnapshot;
  final BillingRouteLinkNavigationModel? routeLinkNavigationModel;
  final List<BillingRouteLink>? routeLinks;
  final BillingNavigationCoverageSummary? coverageSummary;

  const _BillingPersistentSidebar({
    required this.selectedDestination,
    required this.onDestinationSelected,
    this.tenantName,
    this.tenantSubtitle,
    required this.hasTenant,
    this.destinations,
    this.navigationSet,
    this.launchPlanner,
    this.launchSnapshot,
    this.dispatchSnapshot,
    this.routeLinkNavigationModel,
    this.routeLinks,
    this.coverageSummary,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SizedBox(
        width: BillingNavigationScaffold.persistentSidebarWidth,
        child: BillingNavigationPanel(
          selectedDestination: selectedDestination,
          tenantName: tenantName,
          tenantSubtitle: tenantSubtitle,
          hasTenant: hasTenant,
          destinations: destinations,
          navigationSet: navigationSet,
          launchPlanner: launchPlanner,
          launchSnapshot: launchSnapshot,
          dispatchSnapshot: dispatchSnapshot,
          routeLinkNavigationModel: routeLinkNavigationModel,
          routeLinks: routeLinks,
          coverageSummary: coverageSummary,
          onDestinationSelected: onDestinationSelected,
        ),
      ),
    );
  }
}
