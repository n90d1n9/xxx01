import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/billing_business_domain_pack_provider.dart';
import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import '../states/billing_diagnostics_release_profile_saved_view_registry_provider.dart';
import '../states/billing_diagnostics_screen_context_provider.dart';
import '../states/billing_diagnostics_section_registry_provider.dart';
import '../states/billing_route_contract_provider.dart';
import 'billing_diagnostics_content.dart';
import 'billing_navigation_destination.dart';
import 'billing_navigation_scaffold.dart';
import 'diagnostics_link_action.dart';
import 'diagnostics_release_profile_filter_badge.dart';

/// Displays tenant billing diagnostics inside the shared billing navigation shell.
class BillingDiagnosticsScreen extends ConsumerWidget {
  const BillingDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenContext = ref.watch(billingDiagnosticsScreenContextProvider);
    final diagnosticsSectionRegistry = ref.watch(
      billingDiagnosticsSectionRegistryProvider,
    );
    final releaseGateLaneTargetRegistry = ref.watch(
      billingReleaseGateLaneTargetRegistryProvider,
    );
    final releaseWorkspaceProfileCatalog = ref.watch(
      billingReleaseWorkspaceProfileCatalogProvider,
    );
    final releaseProfileSavedViewRegistry = ref.watch(
      billingDiagnosticsReleaseProfileSavedViewRegistryProvider,
    );
    final overview = screenContext.overview;
    final releaseProfileFilterBinding = ref.watch(
      billingDiagnosticsReleaseProfileFilterBindingProvider,
    );
    final releaseProfileFilterSnapshot = ref.watch(
      billingDiagnosticsReleaseProfileFilterSnapshotProvider,
    );
    final routeContractReport = ref.watch(billingRouteContractReportProvider);
    final routeContractRemediationPlan = ref.watch(
      billingRouteContractRemediationPlanProvider,
    );
    final routeExecutionReport = ref.watch(billingRouteExecutionReportProvider);
    final routeExtensionManifestReport = ref.watch(
      billingRouteExtensionManifestReportProvider,
    );
    final routeExtensionManifestRemediationPlan = ref.watch(
      billingRouteExtensionManifestRemediationPlanProvider,
    );
    final releaseGateReport = ref.watch(
      billingDiagnosticsReleaseGateReportProvider,
    );

    return BillingNavigationScaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      selectedDestination: BillingNavigationDestinationId.diagnostics,
      tenantName: screenContext.tenantName,
      tenantSubtitle: screenContext.tenantSubtitle,
      hasTenant: screenContext.hasTenant,
      launchSnapshot: overview.destinationLaunchSnapshot,
      dispatchSnapshot: overview.destinationDispatchSnapshot,
      coverageSummary: overview.coverageSummary,
      onDestinationSelected:
          (destination) => _handleNavigationDestination(context, destination),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Billing Diagnostics',
          style: TextStyle(color: Color(0xFF0F172A)),
        ),
        actions: [
          BillingDiagnosticsLinkAction(
            tenantId: screenContext.selectedTenant?.id,
            businessDomain: overview.businessDomain,
            releaseProfileFilterState: releaseProfileFilterBinding.state,
          ),
          BillingDiagnosticsReleaseProfileFilterBadge(
            snapshot: releaseProfileFilterSnapshot,
            onClear: releaseProfileFilterBinding.clearFilters,
          ),
        ],
      ),
      body: BillingDiagnosticsContent(
        diagnosticsContext: screenContext,
        diagnosticsSectionRegistry: diagnosticsSectionRegistry,
        releaseWorkspaceProfileCatalog: releaseWorkspaceProfileCatalog,
        releaseProfileSavedViewRegistry: releaseProfileSavedViewRegistry,
        releaseProfileFilterBinding: releaseProfileFilterBinding,
        routeContractReport: routeContractReport,
        routeContractRemediationPlan: routeContractRemediationPlan,
        routeExecutionReport: routeExecutionReport,
        routeExtensionManifestReport: routeExtensionManifestReport,
        routeExtensionManifestRemediationPlan:
            routeExtensionManifestRemediationPlan,
        releaseGateReport: releaseGateReport,
        releaseGateLaneTargetRegistry: releaseGateLaneTargetRegistry,
        onDestinationSelected:
            (destination) => _handleNavigationDestination(context, destination),
      ),
    );
  }

  void _handleNavigationDestination(
    BuildContext context,
    BillingNavigationDestinationId destination,
  ) {
    if (destination == BillingNavigationDestinationId.diagnostics) return;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Return to billing workspace to open that destination.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
