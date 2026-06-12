import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_context_provider.dart';
import 'billing_navigation_destination.dart';
import 'billing_release_workspace_composition.dart';
import 'billing_release_workspace_profile.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';
import 'billing_release_workspace_view.dart';

class BillingDiagnosticsReleaseSection extends StatelessWidget {
  final BillingDiagnosticsReleaseContext releaseContext;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final BillingReleaseWorkspaceRegistry? workspaceRegistry;
  final BillingReleaseWorkspaceProfileCatalog? workspaceProfileCatalog;
  final BillingReleaseWorkspaceSavedView? selectedSavedView;
  final ValueChanged<BillingReleaseWorkspaceSavedView>? onSavedViewSelected;
  final List<BillingReleaseWorkspaceSavedView>? savedViews;
  final bool showSavedViewBar;
  final bool showProfileContractBanner;
  final bool showSnapshotBanner;

  const BillingDiagnosticsReleaseSection({
    super.key,
    required this.releaseContext,
    required this.onDestinationSelected,
    this.workspaceRegistry,
    this.workspaceProfileCatalog,
    this.selectedSavedView,
    this.onSavedViewSelected,
    this.savedViews,
    this.showSavedViewBar = true,
    this.showProfileContractBanner = true,
    this.showSnapshotBanner = true,
  });

  @override
  Widget build(BuildContext context) {
    final composition = BillingReleaseWorkspaceComposition.forBusinessDomain(
      businessDomain: releaseContext.businessDomain,
      catalog: workspaceProfileCatalog,
      registry: workspaceRegistry,
      savedViews: savedViews,
      selectedSavedView: selectedSavedView,
      allowExternalSelectedView: selectedSavedView != null,
    );

    return BillingReleaseWorkspaceView(
      releaseContext: releaseContext,
      registry: composition.baseRegistry,
      onDestinationSelected: onDestinationSelected,
      savedViews: composition.savedViews,
      selectedSavedView: selectedSavedView,
      profileContract: composition.profileContract,
      onSavedViewSelected: onSavedViewSelected,
      showSavedViewBar: showSavedViewBar,
      showProfileContractBanner: showProfileContractBanner,
      showSnapshotBanner: showSnapshotBanner,
    );
  }
}
