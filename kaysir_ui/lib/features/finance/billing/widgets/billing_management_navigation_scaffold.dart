import 'package:flutter/material.dart';

import '../states/billing_management_navigation_context_provider.dart';
import 'billing_navigation_drawer.dart';
import 'billing_navigation_scaffold.dart';

class BillingManagementNavigationScaffold extends StatelessWidget {
  final BillingManagementNavigationContext navigationContext;
  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final String? tenantName;
  final String? tenantSubtitle;

  const BillingManagementNavigationScaffold({
    super.key,
    required this.navigationContext,
    required this.selectedDestination,
    required this.onDestinationSelected,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.tenantName,
    this.tenantSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return BillingNavigationScaffold(
      backgroundColor: backgroundColor,
      selectedDestination: selectedDestination,
      tenantName: tenantName,
      tenantSubtitle: tenantSubtitle,
      hasTenant: navigationContext.hasTenant,
      launchSnapshot: navigationContext.destinationLaunchSnapshot,
      dispatchSnapshot: navigationContext.destinationDispatchSnapshot,
      routeLinkNavigationModel: navigationContext.routeLinkNavigationModel,
      coverageSummary: navigationContext.coverageSummary,
      onDestinationSelected: onDestinationSelected,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
