import 'package:flutter/material.dart';

import '../states/billing_diagnostics_release_profile_filter_provider.dart';
import '../states/billing_diagnostics_screen_context_provider.dart';
import '../utils/billing_route_contract.dart';
import '../utils/billing_route_contract_remediation.dart';
import '../utils/billing_route_execution_contract.dart';
import '../utils/billing_route_extension_manifest.dart';
import '../utils/billing_route_extension_manifest_remediation.dart';
import '../utils/billing_release_gate.dart';
import 'billing_diagnostics_domain_section.dart';
import 'billing_diagnostics_navigation_section.dart';
import 'billing_diagnostics_overview_panel.dart';
import 'billing_diagnostics_release_section.dart';
import 'billing_navigation_destination.dart';
import 'billing_route_extension_manifest_panel.dart';
import 'billing_route_contract_panel.dart';
import 'billing_release_gate_lane_target.dart';
import 'billing_release_gate_panel.dart';
import 'billing_release_workspace_profile.dart';
import 'diagnostics_release_profile_saved_view_registry.dart';
import 'release_profile_contract_coverage.dart';
import 'release_profile_contract_coverage_panel.dart';
import 'standard_release_workspace_profiles.dart';

typedef BillingDiagnosticsSectionBuilder =
    Widget Function(BillingDiagnosticsSectionBuildContext context);

typedef BillingDiagnosticsSectionPredicate =
    bool Function(BillingDiagnosticsSectionBuildContext context);

/// Data and callbacks available while building a billing diagnostics section.
class BillingDiagnosticsSectionBuildContext {
  final BillingDiagnosticsScreenContext diagnosticsContext;
  final ValueChanged<BillingNavigationDestinationId> onDestinationSelected;
  final BillingReleaseWorkspaceProfileCatalog? releaseWorkspaceProfileCatalog;
  final BillingDiagnosticsReleaseProfileSavedViewRegistry
  releaseProfileSavedViewRegistry;
  final BillingDiagnosticsReleaseProfileFilterBinding?
  releaseProfileFilterBinding;
  final BillingRouteContractReport routeContractReport;
  final BillingRouteContractRemediationPlan routeContractRemediationPlan;
  final BillingRouteExecutionReport routeExecutionReport;
  final BillingRouteExtensionManifestReport routeExtensionManifestReport;
  final BillingRouteExtensionManifestRemediationPlan
  routeExtensionManifestRemediationPlan;
  final BillingReleaseGateReport releaseGateReport;
  final BillingReleaseGateLaneTargetRegistry releaseGateLaneTargetRegistry;
  final ValueChanged<String>? onSectionSelected;

  const BillingDiagnosticsSectionBuildContext({
    required this.diagnosticsContext,
    required this.onDestinationSelected,
    required this.routeContractReport,
    required this.routeContractRemediationPlan,
    required this.routeExecutionReport,
    required this.routeExtensionManifestReport,
    required this.routeExtensionManifestRemediationPlan,
    required this.releaseGateReport,
    this.releaseGateLaneTargetRegistry =
        BillingReleaseGateLaneTargetRegistry.empty,
    this.onSectionSelected,
    this.releaseWorkspaceProfileCatalog,
    this.releaseProfileSavedViewRegistry =
        standardBillingDiagnosticsReleaseProfileSavedViewRegistry,
    this.releaseProfileFilterBinding,
  });
}

/// Registry entry describing a diagnostics section and its render predicate.
class BillingDiagnosticsSectionDescriptor {
  final String id;
  final int priority;
  final BillingDiagnosticsSectionBuilder builder;
  final BillingDiagnosticsSectionPredicate isEnabled;

  const BillingDiagnosticsSectionDescriptor({
    required this.id,
    required this.priority,
    required this.builder,
    this.isEnabled = _billingDiagnosticsSectionAlwaysEnabled,
  });

  Widget build(BillingDiagnosticsSectionBuildContext context) {
    return builder(context);
  }

  bool shouldRender(BillingDiagnosticsSectionBuildContext context) {
    return isEnabled(context);
  }
}

/// Validated, ordered collection of billing diagnostics sections.
class BillingDiagnosticsSectionRegistry {
  final List<BillingDiagnosticsSectionDescriptor> sections;

  factory BillingDiagnosticsSectionRegistry({
    required Iterable<BillingDiagnosticsSectionDescriptor> sections,
  }) {
    return BillingDiagnosticsSectionRegistry._(
      _sortedDiagnosticsSections(_validatedDiagnosticsSections(sections)),
    );
  }

  factory BillingDiagnosticsSectionRegistry.standard({
    Iterable<BillingDiagnosticsSectionDescriptor> extensions = const [],
    Set<String> hiddenSectionIds = const {},
  }) {
    return BillingDiagnosticsSectionRegistry(
      sections: [
        for (final section in _standardBillingDiagnosticsSections())
          if (!hiddenSectionIds.contains(section.id)) section,
        ...extensions,
      ],
    );
  }

  const BillingDiagnosticsSectionRegistry._(this.sections);

  List<BillingDiagnosticsSectionDescriptor> resolve(
    BillingDiagnosticsSectionBuildContext context,
  ) {
    return resolveBillingDiagnosticsSections(
      sections: sections,
      context: context,
    );
  }
}

const billingDiagnosticsOverviewSectionId = 'overview';
const billingDiagnosticsDomainSectionId = 'domain';
const billingDiagnosticsReleaseProfileCoverageSectionId =
    'release-profile-coverage';
const billingDiagnosticsReleaseSectionId = 'release';
const billingDiagnosticsReleaseGateSectionId = 'release-gate';
const billingDiagnosticsRouteExtensionManifestSectionId =
    'route-extension-manifests';
const billingDiagnosticsRouteContractSectionId = 'route-contract';
const billingDiagnosticsNavigationSectionId = 'navigation';

BillingReleaseGateLaneTargetRegistry
standardBillingReleaseGateLaneTargetRegistry({
  Iterable<BillingReleaseGateLaneTarget> extensions = const [],
}) {
  return BillingReleaseGateLaneTargetRegistry(
    targets: [
      const BillingReleaseGateLaneTarget(
        laneId: billingReleaseGateRouteContractLaneId,
        sectionId: billingDiagnosticsRouteContractSectionId,
      ),
      const BillingReleaseGateLaneTarget(
        laneId: billingReleaseGateRouteExecutionLaneId,
        sectionId: billingDiagnosticsRouteContractSectionId,
      ),
      const BillingReleaseGateLaneTarget(
        laneId: billingReleaseGateRouteExtensionManifestLaneId,
        sectionId: billingDiagnosticsRouteExtensionManifestSectionId,
      ),
      ...extensions,
    ],
  );
}

List<BillingDiagnosticsSectionDescriptor>
standardBillingDiagnosticsSectionRegistry({
  Iterable<BillingDiagnosticsSectionDescriptor> extensions = const [],
}) {
  return BillingDiagnosticsSectionRegistry.standard(
    extensions: extensions,
  ).sections;
}

List<BillingDiagnosticsSectionDescriptor> resolveBillingDiagnosticsSections({
  required Iterable<BillingDiagnosticsSectionDescriptor> sections,
  required BillingDiagnosticsSectionBuildContext context,
}) {
  return _sortedDiagnosticsSections(
    _validatedDiagnosticsSections(
      sections,
    ).where((section) => section.shouldRender(context)),
  );
}

List<BillingDiagnosticsSectionDescriptor>
_standardBillingDiagnosticsSections() {
  return const [
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsOverviewSectionId,
      priority: 100,
      builder: _buildOverviewSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsDomainSectionId,
      priority: 200,
      builder: _buildDomainSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsReleaseProfileCoverageSectionId,
      priority: 280,
      builder: _buildReleaseProfileCoverageSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsReleaseSectionId,
      priority: 300,
      builder: _buildReleaseSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsReleaseGateSectionId,
      priority: 350,
      builder: _buildReleaseGateSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsRouteExtensionManifestSectionId,
      priority: 370,
      builder: _buildRouteExtensionManifestSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsRouteContractSectionId,
      priority: 390,
      builder: _buildRouteContractSection,
    ),
    BillingDiagnosticsSectionDescriptor(
      id: billingDiagnosticsNavigationSectionId,
      priority: 400,
      builder: _buildNavigationSection,
    ),
  ];
}

List<BillingDiagnosticsSectionDescriptor> _validatedDiagnosticsSections(
  Iterable<BillingDiagnosticsSectionDescriptor> sections,
) {
  final sectionList = sections.toList();
  final ids = <String>{};
  for (final section in sectionList) {
    final normalizedId = section.id.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(section.id, 'section.id', 'must not be blank');
    }
    if (normalizedId != section.id) {
      throw ArgumentError.value(
        section.id,
        'section.id',
        'must not contain leading or trailing whitespace',
      );
    }
    if (!ids.add(normalizedId)) {
      throw ArgumentError.value(
        section.id,
        'section.id',
        'must be unique in a billing diagnostics registry',
      );
    }
  }

  return sectionList;
}

List<BillingDiagnosticsSectionDescriptor> _sortedDiagnosticsSections(
  Iterable<BillingDiagnosticsSectionDescriptor> sections,
) {
  final sorted =
      sections.toList()..sort((left, right) {
        final priority = left.priority.compareTo(right.priority);
        if (priority != 0) return priority;

        return left.id.compareTo(right.id);
      });

  return List.unmodifiable(sorted);
}

Widget _buildOverviewSection(BillingDiagnosticsSectionBuildContext context) {
  return BillingDiagnosticsOverviewPanel(
    overview: context.diagnosticsContext.overview,
  );
}

Widget _buildDomainSection(BillingDiagnosticsSectionBuildContext context) {
  return BillingDiagnosticsDomainSection(
    context: context.diagnosticsContext.domainContext,
    onDestinationSelected: context.onDestinationSelected,
  );
}

Widget _buildReleaseSection(BillingDiagnosticsSectionBuildContext context) {
  return BillingDiagnosticsReleaseSection(
    releaseContext: context.diagnosticsContext.releaseContext,
    onDestinationSelected: context.onDestinationSelected,
    workspaceProfileCatalog: context.releaseWorkspaceProfileCatalog,
  );
}

Widget _buildReleaseProfileCoverageSection(
  BillingDiagnosticsSectionBuildContext context,
) {
  final catalog =
      context.releaseWorkspaceProfileCatalog ??
      standardBillingReleaseWorkspaceProfileCatalog;
  final filterBinding = context.releaseProfileFilterBinding;

  return BillingReleaseWorkspaceProfileContractCoveragePanel(
    coverage: BillingReleaseWorkspaceProfileContractCoverage(
      contracts: catalog.buildContracts(),
    ),
    focusedBusinessDomain: context.diagnosticsContext.overview.businessDomain,
    onDestinationSelected: context.onDestinationSelected,
    selectedStatusOption: filterBinding?.state.statusOption,
    onStatusOptionSelected: filterBinding?.selectStatusOption,
    selectedDomainSelection: filterBinding?.state.domainSelection,
    onDomainSelectionSelected: filterBinding?.selectDomainSelection,
    releaseProfileSavedViewRegistry: context.releaseProfileSavedViewRegistry,
  );
}

Widget _buildReleaseGateSection(BillingDiagnosticsSectionBuildContext context) {
  return BillingReleaseGatePanel(
    report: context.releaseGateReport,
    canSelectLane:
        (lane) =>
            context.releaseGateLaneTargetRegistry.targetForLane(lane) != null,
    onLaneSelected:
        context.onSectionSelected == null
            ? null
            : (lane) {
              final target = context.releaseGateLaneTargetRegistry
                  .targetForLane(lane);
              if (target == null) return;

              context.onSectionSelected?.call(target.sectionId);
            },
  );
}

Widget _buildRouteExtensionManifestSection(
  BillingDiagnosticsSectionBuildContext context,
) {
  return BillingRouteExtensionManifestPanel(
    report: context.routeExtensionManifestReport,
    remediationPlan: context.routeExtensionManifestRemediationPlan,
  );
}

Widget _buildNavigationSection(BillingDiagnosticsSectionBuildContext context) {
  return BillingDiagnosticsNavigationSection(
    overview: context.diagnosticsContext.overview,
    onDestinationSelected: context.onDestinationSelected,
  );
}

Widget _buildRouteContractSection(
  BillingDiagnosticsSectionBuildContext context,
) {
  return BillingRouteContractPanel(
    report: context.routeContractReport,
    remediationPlan: context.routeContractRemediationPlan,
    executionReport: context.routeExecutionReport,
    onDestinationSelected: context.onDestinationSelected,
  );
}

bool _billingDiagnosticsSectionAlwaysEnabled(
  BillingDiagnosticsSectionBuildContext context,
) {
  return true;
}
