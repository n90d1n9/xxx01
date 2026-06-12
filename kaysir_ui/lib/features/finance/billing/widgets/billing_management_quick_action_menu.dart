import 'package:flutter/material.dart';

import '../states/billing_management_navigation_context_provider.dart';
import 'billing_navigation_drawer.dart';
import 'billing_quick_action_menu.dart';

class BillingManagementQuickActionMenu extends StatelessWidget {
  final BillingManagementNavigationContext navigationContext;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;

  const BillingManagementQuickActionMenu({
    super.key,
    required this.navigationContext,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BillingQuickActionMenu(
      hasTenant: navigationContext.hasTenant,
      launchSnapshot: navigationContext.quickActionLaunchSnapshot,
      dispatchSnapshot: navigationContext.quickActionDispatchSnapshot,
      onDestinationSelected: onDestinationSelected,
    );
  }
}
