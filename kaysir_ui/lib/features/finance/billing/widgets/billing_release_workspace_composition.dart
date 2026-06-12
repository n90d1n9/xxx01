import 'billing_release_workspace_profile.dart';
import 'release_profile_contract.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';
import 'billing_release_workspace_snapshot.dart';
import 'standard_release_workspace_profiles.dart';

class BillingReleaseWorkspaceComposition {
  final String businessDomain;
  final BillingReleaseWorkspaceRegistry baseRegistry;
  final List<BillingReleaseWorkspaceSavedView> savedViews;
  final BillingReleaseWorkspaceSavedView activeSavedView;
  final BillingReleaseWorkspaceRegistry visibleRegistry;
  final BillingReleaseWorkspaceSnapshot snapshot;
  final BillingReleaseWorkspaceProfileContract? profileContract;

  factory BillingReleaseWorkspaceComposition({
    required String businessDomain,
    required BillingReleaseWorkspaceRegistry registry,
    Iterable<BillingReleaseWorkspaceSavedView> savedViews =
        billingReleaseWorkspaceDefaultSavedViews,
    BillingReleaseWorkspaceSavedView? selectedSavedView,
    bool allowExternalSelectedView = false,
    BillingReleaseWorkspaceProfileContract? profileContract,
  }) {
    final resolvedSavedViews =
        List<BillingReleaseWorkspaceSavedView>.unmodifiable(savedViews);
    final activeSavedView = _resolveActiveSavedView(
      savedViews: resolvedSavedViews,
      selectedSavedView: selectedSavedView,
      allowExternalSelectedView: allowExternalSelectedView,
    );
    final snapshot = BillingReleaseWorkspaceSnapshot.forView(
      businessDomain: businessDomain,
      savedView: activeSavedView,
      baseRegistry: registry,
    );

    return BillingReleaseWorkspaceComposition._(
      businessDomain: businessDomain.trim(),
      baseRegistry: registry,
      savedViews: resolvedSavedViews,
      activeSavedView: activeSavedView,
      visibleRegistry: snapshot.visibleRegistry,
      snapshot: snapshot,
      profileContract: profileContract,
    );
  }

  factory BillingReleaseWorkspaceComposition.forBusinessDomain({
    required String businessDomain,
    BillingReleaseWorkspaceProfileCatalog? catalog,
    BillingReleaseWorkspaceRegistry? registry,
    Iterable<BillingReleaseWorkspaceSavedView>? savedViews,
    BillingReleaseWorkspaceSavedView? selectedSavedView,
    bool allowExternalSelectedView = false,
  }) {
    final resolvedCatalog =
        catalog ?? standardBillingReleaseWorkspaceProfileCatalog;
    final profile = resolvedCatalog.profileForBusinessDomain(businessDomain);
    final canUseProfileContract = registry == null && savedViews == null;

    return BillingReleaseWorkspaceComposition(
      businessDomain: businessDomain,
      registry:
          registry ??
          profile?.buildRegistry() ??
          standardBillingReleaseWorkspaceRegistry(),
      savedViews:
          savedViews ??
          profile?.buildSavedViews() ??
          billingReleaseWorkspaceDefaultSavedViews,
      selectedSavedView: selectedSavedView,
      allowExternalSelectedView: allowExternalSelectedView,
      profileContract: canUseProfileContract ? profile?.buildContract() : null,
    );
  }

  const BillingReleaseWorkspaceComposition._({
    required this.businessDomain,
    required this.baseRegistry,
    required this.savedViews,
    required this.activeSavedView,
    required this.visibleRegistry,
    required this.snapshot,
    required this.profileContract,
  });

  bool get hasSavedViews => savedViews.isNotEmpty;
}

BillingReleaseWorkspaceSavedView _resolveActiveSavedView({
  required List<BillingReleaseWorkspaceSavedView> savedViews,
  BillingReleaseWorkspaceSavedView? selectedSavedView,
  required bool allowExternalSelectedView,
}) {
  if (selectedSavedView != null) {
    final selectedIsVisible = savedViews.any(
      (view) => view.id == selectedSavedView.id,
    );
    if (selectedIsVisible || allowExternalSelectedView) {
      return selectedSavedView;
    }
  }

  if (savedViews.isNotEmpty) return savedViews.first;

  return billingReleaseWorkspaceAllSavedView;
}
