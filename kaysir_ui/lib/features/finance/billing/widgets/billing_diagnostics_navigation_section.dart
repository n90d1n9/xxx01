import 'package:flutter/material.dart';

import '../states/billing_diagnostics_overview_provider.dart';
import 'billing_diagnostics_navigation_coverage_panel.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_launch_center.dart';

class BillingDiagnosticsNavigationSection extends StatelessWidget {
  final BillingDiagnosticsOverview overview;
  final BillingNavigationDestinationId selectedDestination;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;

  const BillingDiagnosticsNavigationSection({
    super.key,
    required this.overview,
    this.selectedDestination = BillingNavigationDestinationId.diagnostics,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BillingNavigationLaunchCenter(
          launchSnapshot: overview.destinationLaunchSnapshot,
          dispatchSnapshot: overview.destinationDispatchSnapshot,
          coverageSummary: overview.coverageSummary,
          selectedDestination: selectedDestination,
          onDestinationSelected: onDestinationSelected,
        ),
        BillingDiagnosticsNavigationCoveragePanel(overview: overview),
      ],
    );
  }
}
