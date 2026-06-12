import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_context_provider.dart';
import 'billing_navigation_destination.dart';
import 'billing_release_workspace_composition.dart';
import 'billing_release_workspace_controller.dart';
import 'release_profile_contract.dart';
import 'release_profile_contract_banner.dart';
import 'billing_release_workspace_registry.dart';
import 'billing_release_workspace_saved_view.dart';
import 'billing_release_workspace_snapshot.dart';

class BillingReleaseWorkspaceView extends StatefulWidget {
  final BillingDiagnosticsReleaseContext releaseContext;
  final BillingReleaseWorkspaceRegistry registry;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final List<BillingReleaseWorkspaceSavedView> savedViews;
  final BillingReleaseWorkspaceSavedView? selectedSavedView;
  final BillingReleaseWorkspaceController? controller;
  final BillingReleaseWorkspaceProfileContract? profileContract;
  final ValueChanged<BillingReleaseWorkspaceSavedView>? onSavedViewSelected;
  final bool showSavedViewBar;
  final bool showProfileContractBanner;
  final bool showSnapshotBanner;

  const BillingReleaseWorkspaceView({
    super.key,
    required this.releaseContext,
    required this.registry,
    required this.onDestinationSelected,
    this.savedViews = billingReleaseWorkspaceDefaultSavedViews,
    this.selectedSavedView,
    this.controller,
    this.profileContract,
    this.onSavedViewSelected,
    this.showSavedViewBar = true,
    this.showProfileContractBanner = true,
    this.showSnapshotBanner = true,
  }) : assert(
         selectedSavedView == null || controller == null,
         'Use either selectedSavedView or controller, not both.',
       );

  @override
  State<BillingReleaseWorkspaceView> createState() =>
      _BillingReleaseWorkspaceViewState();
}

class _BillingReleaseWorkspaceViewState
    extends State<BillingReleaseWorkspaceView> {
  BillingReleaseWorkspaceSavedView? _localSavedView;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(covariant BillingReleaseWorkspaceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;

    oldWidget.controller?.removeListener(_handleControllerChanged);
    widget.controller?.addListener(_handleControllerChanged);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controllerSelection = widget.controller?.selectedSavedView;
    final composition = BillingReleaseWorkspaceComposition(
      businessDomain: widget.releaseContext.businessDomain,
      registry: widget.registry,
      savedViews: widget.savedViews,
      selectedSavedView:
          widget.selectedSavedView ?? controllerSelection ?? _localSavedView,
      allowExternalSelectedView:
          widget.selectedSavedView != null || controllerSelection != null,
      profileContract: widget.profileContract,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showSavedViewBar && composition.hasSavedViews) ...[
          BillingReleaseWorkspaceSavedViewBar(
            registry: composition.baseRegistry,
            selectedView: composition.activeSavedView,
            views: composition.savedViews,
            onSelected: _selectSavedView,
          ),
          const SizedBox(height: 6),
        ],
        if (widget.showProfileContractBanner &&
            composition.profileContract != null) ...[
          BillingReleaseWorkspaceProfileContractBanner(
            contract: composition.profileContract!,
          ),
        ],
        if (widget.showSnapshotBanner) ...[
          BillingReleaseWorkspaceSnapshotBanner(snapshot: composition.snapshot),
        ],
        ...composition.visibleRegistry.buildDecks(
          releaseContext: widget.releaseContext,
          onDestinationSelected: widget.onDestinationSelected,
        ),
      ],
    );
  }

  void _selectSavedView(BillingReleaseWorkspaceSavedView view) {
    if (widget.selectedSavedView == null && widget.controller != null) {
      widget.controller?.select(view);
    } else if (widget.selectedSavedView == null) {
      setState(() {
        _localSavedView = view;
      });
    }

    widget.onSavedViewSelected?.call(view);
  }

  void _handleControllerChanged() {
    if (!mounted) return;

    setState(() {});
  }
}
