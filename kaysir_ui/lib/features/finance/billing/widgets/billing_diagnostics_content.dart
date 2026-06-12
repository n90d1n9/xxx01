import 'package:flutter/material.dart';

import '../states/billing_diagnostics_screen_context_provider.dart';
import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import '../utils/billing_route_contract.dart';
import '../utils/billing_route_contract_remediation.dart';
import '../utils/billing_route_definition_registry.dart';
import '../utils/billing_route_execution_contract.dart';
import '../utils/billing_route_extension_manifest.dart';
import '../utils/billing_route_extension_manifest_remediation.dart';
import '../utils/billing_release_gate.dart';
import 'billing_diagnostics_section_registry.dart';
import 'billing_navigation_destination.dart';
import 'billing_release_gate_lane_target.dart';
import 'billing_release_workspace_profile.dart';
import 'diagnostics_release_profile_saved_view_registry.dart';

/// Renders the ordered diagnostics sections for a resolved billing context.
class BillingDiagnosticsContent extends StatelessWidget {
  final BillingDiagnosticsScreenContext diagnosticsContext;
  final ValueChanged<BillingNavigationDestinationId>? onDestinationSelected;
  final bool includeSafeArea;
  final Iterable<BillingDiagnosticsSectionDescriptor>? sectionRegistry;
  final BillingDiagnosticsSectionRegistry? diagnosticsSectionRegistry;
  final BillingReleaseWorkspaceProfileCatalog? releaseWorkspaceProfileCatalog;
  final BillingDiagnosticsReleaseProfileSavedViewRegistry
  releaseProfileSavedViewRegistry;
  final BillingDiagnosticsReleaseProfileFilterBinding?
  releaseProfileFilterBinding;
  final BillingRouteContractReport? routeContractReport;
  final BillingRouteContractRemediationPlan? routeContractRemediationPlan;
  final BillingRouteExecutionReport? routeExecutionReport;
  final BillingRouteExtensionManifestReport? routeExtensionManifestReport;
  final BillingRouteExtensionManifestRemediationPlan?
  routeExtensionManifestRemediationPlan;
  final BillingReleaseGateReport? releaseGateReport;
  final BillingReleaseGateLaneTargetRegistry? releaseGateLaneTargetRegistry;

  const BillingDiagnosticsContent({
    super.key,
    required this.diagnosticsContext,
    this.onDestinationSelected,
    this.includeSafeArea = true,
    this.sectionRegistry,
    this.diagnosticsSectionRegistry,
    this.releaseWorkspaceProfileCatalog,
    this.releaseProfileSavedViewRegistry =
        standardBillingDiagnosticsReleaseProfileSavedViewRegistry,
    this.releaseProfileFilterBinding,
    this.routeContractReport,
    this.routeContractRemediationPlan,
    this.routeExecutionReport,
    this.routeExtensionManifestReport,
    this.routeExtensionManifestRemediationPlan,
    this.releaseGateReport,
    this.releaseGateLaneTargetRegistry,
  }) : assert(
         sectionRegistry == null || diagnosticsSectionRegistry == null,
         'Use either sectionRegistry or diagnosticsSectionRegistry.',
       );

  @override
  Widget build(BuildContext context) {
    final destinationHandler = onDestinationSelected ?? _ignoreDestination;
    final sectionKeys = <String, GlobalKey>{};
    final resolvedRouteContractReport =
        routeContractReport ?? BillingRouteContractReport.forRouteRegistry();
    final resolvedRouteExtensionManifestReport =
        routeExtensionManifestReport ??
        BillingRouteExtensionManifestReport.forManifests(const []);
    final resolvedRouteContractRemediationPlan =
        routeContractRemediationPlan ??
        BillingRouteContractRemediationPlan.forReport(
          resolvedRouteContractReport,
        );
    final resolvedRouteExecutionReport =
        routeExecutionReport ??
        BillingRouteExecutionReport.forRegistry(
          routeDefinitionRegistry: BillingRouteDefinitionRegistry(
            baseDefinitions: resolvedRouteContractReport.routeDefinitions,
          ),
        );
    final resolvedRouteExtensionManifestRemediationPlan =
        routeExtensionManifestRemediationPlan ??
        BillingRouteExtensionManifestRemediationPlan.forReport(
          resolvedRouteExtensionManifestReport,
        );
    final resolvedReleaseGateReport =
        releaseGateReport ??
        BillingReleaseGateReport.forRouting(
          routeContractReport: resolvedRouteContractReport,
          routeContractRemediationPlan: resolvedRouteContractRemediationPlan,
          routeExecutionReport: resolvedRouteExecutionReport,
          routeExtensionManifestReport: resolvedRouteExtensionManifestReport,
          routeExtensionManifestRemediationPlan:
              resolvedRouteExtensionManifestRemediationPlan,
        );
    final sectionContext = BillingDiagnosticsSectionBuildContext(
      diagnosticsContext: diagnosticsContext,
      onDestinationSelected: destinationHandler,
      releaseWorkspaceProfileCatalog: releaseWorkspaceProfileCatalog,
      releaseProfileSavedViewRegistry: releaseProfileSavedViewRegistry,
      releaseProfileFilterBinding: releaseProfileFilterBinding,
      routeContractReport: resolvedRouteContractReport,
      routeContractRemediationPlan: resolvedRouteContractRemediationPlan,
      routeExecutionReport: resolvedRouteExecutionReport,
      routeExtensionManifestReport: resolvedRouteExtensionManifestReport,
      routeExtensionManifestRemediationPlan:
          resolvedRouteExtensionManifestRemediationPlan,
      releaseGateReport: resolvedReleaseGateReport,
      releaseGateLaneTargetRegistry:
          releaseGateLaneTargetRegistry ??
          standardBillingReleaseGateLaneTargetRegistry(),
      onSectionSelected:
          (sectionId) => _scrollToDiagnosticsSection(sectionKeys, sectionId),
    );
    final registry =
        diagnosticsSectionRegistry ??
        BillingDiagnosticsSectionRegistry(
          sections:
              sectionRegistry ?? standardBillingDiagnosticsSectionRegistry(),
        );
    final sections = registry.resolve(sectionContext);
    final content = CustomScrollView(
      key: const ValueKey('billing-diagnostics-scroll'),
      slivers: [
        for (final section in sections)
          SliverToBoxAdapter(
            key: ValueKey('billing-diagnostics-section-${section.id}'),
            child: KeyedSubtree(
              key: _diagnosticsSectionScrollKey(sectionKeys, section.id),
              child: section.build(sectionContext),
            ),
          ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ],
    );

    if (!includeSafeArea) return content;

    return SafeArea(child: content);
  }

  static void _ignoreDestination(BillingNavigationDestinationId destination) {}

  static GlobalKey _diagnosticsSectionScrollKey(
    Map<String, GlobalKey> sectionKeys,
    String sectionId,
  ) {
    return sectionKeys.putIfAbsent(
      sectionId,
      () => GlobalKey(debugLabel: 'billing-diagnostics-section-$sectionId'),
    );
  }

  static void _scrollToDiagnosticsSection(
    Map<String, GlobalKey> sectionKeys,
    String sectionId,
  ) {
    final targetContext = sectionKeys[sectionId]?.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }
}
