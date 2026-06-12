import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_domain_context_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_screen_context_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_contract_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_execution_contract.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_extension_manifest_remediation.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_lane_target.dart';

void main() {
  test('standardBillingDiagnosticsSectionRegistry keeps default order', () {
    final ids =
        standardBillingDiagnosticsSectionRegistry()
            .map((section) => section.id)
            .toList();

    expect(ids, [
      billingDiagnosticsOverviewSectionId,
      billingDiagnosticsDomainSectionId,
      billingDiagnosticsReleaseProfileCoverageSectionId,
      billingDiagnosticsReleaseSectionId,
      billingDiagnosticsReleaseGateSectionId,
      billingDiagnosticsRouteExtensionManifestSectionId,
      billingDiagnosticsRouteContractSectionId,
      billingDiagnosticsNavigationSectionId,
    ]);
  });

  test('BillingDiagnosticsSectionRegistry hides and extends defaults', () {
    final registry = BillingDiagnosticsSectionRegistry.standard(
      hiddenSectionIds: {billingDiagnosticsReleaseSectionId},
      extensions: [
        BillingDiagnosticsSectionDescriptor(
          id: 'subscription-health',
          priority: 250,
          builder: (_) => const Text('Subscription health'),
        ),
      ],
    );

    expect(registry.sections.map((section) => section.id), [
      billingDiagnosticsOverviewSectionId,
      billingDiagnosticsDomainSectionId,
      'subscription-health',
      billingDiagnosticsReleaseProfileCoverageSectionId,
      billingDiagnosticsReleaseGateSectionId,
      billingDiagnosticsRouteExtensionManifestSectionId,
      billingDiagnosticsRouteContractSectionId,
      billingDiagnosticsNavigationSectionId,
    ]);
  });

  test('BillingDiagnosticsSectionRegistry rejects duplicate section ids', () {
    expect(
      () => BillingDiagnosticsSectionRegistry(
        sections: [
          BillingDiagnosticsSectionDescriptor(
            id: 'duplicate',
            priority: 10,
            builder: (_) => const Text('First duplicate'),
          ),
          BillingDiagnosticsSectionDescriptor(
            id: 'duplicate',
            priority: 20,
            builder: (_) => const Text('Second duplicate'),
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('BillingDiagnosticsSectionRegistry rejects blank section ids', () {
    expect(
      () => BillingDiagnosticsSectionRegistry(
        sections: [
          BillingDiagnosticsSectionDescriptor(
            id: ' ',
            priority: 10,
            builder: (_) => const Text('Blank id'),
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('standardBillingReleaseGateLaneTargetRegistry resolves extensions', () {
    final registry = standardBillingReleaseGateLaneTargetRegistry(
      extensions: const [
        BillingReleaseGateLaneTarget(
          laneId: 'construction-handover',
          sectionId: 'construction-signal',
        ),
      ],
    );

    expect(
      registry
          .targetForLaneId(billingReleaseGateRouteExecutionLaneId)
          ?.sectionId,
      billingDiagnosticsRouteContractSectionId,
    );
    expect(
      registry.targetForLaneId('construction-handover')?.sectionId,
      'construction-signal',
    );
  });

  test('BillingReleaseGateLaneTargetRegistry rejects duplicate lanes', () {
    expect(
      () => BillingReleaseGateLaneTargetRegistry(
        targets: const [
          BillingReleaseGateLaneTarget(
            laneId: 'route-execution',
            sectionId: 'route-contract',
          ),
          BillingReleaseGateLaneTarget(
            laneId: 'route-execution',
            sectionId: 'navigation',
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('resolveBillingDiagnosticsSections filters and sorts sections', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final context = BillingDiagnosticsSectionBuildContext(
      diagnosticsContext: _diagnosticsContext(container),
      onDestinationSelected: (_) {},
      routeContractReport: BillingRouteContractReport.forRouteRegistry(),
      routeContractRemediationPlan:
          BillingRouteContractRemediationPlan.forReport(
            BillingRouteContractReport.forRouteRegistry(),
          ),
      routeExecutionReport: BillingRouteExecutionReport.forRegistry(),
      routeExtensionManifestReport:
          BillingRouteExtensionManifestReport.forManifests(const []),
      routeExtensionManifestRemediationPlan:
          BillingRouteExtensionManifestRemediationPlan.forReport(
            BillingRouteExtensionManifestReport.forManifests(const []),
          ),
      releaseGateReport: BillingReleaseGateReport.forRouting(
        routeContractReport: BillingRouteContractReport.forRouteRegistry(),
        routeExecutionReport: BillingRouteExecutionReport.forRegistry(),
        routeExtensionManifestReport:
            BillingRouteExtensionManifestReport.forManifests(const []),
      ),
    );

    final sections = resolveBillingDiagnosticsSections(
      sections: [
        BillingDiagnosticsSectionDescriptor(
          id: 'late',
          priority: 30,
          builder: (_) => const Text('Late section'),
        ),
        BillingDiagnosticsSectionDescriptor(
          id: 'hidden',
          priority: 5,
          builder: (_) => const Text('Hidden section'),
          isEnabled: (_) => false,
        ),
        BillingDiagnosticsSectionDescriptor(
          id: 'early',
          priority: 10,
          builder: (_) => const Text('Early section'),
        ),
      ],
      context: context,
    );

    expect(sections.map((section) => section.id), ['early', 'late']);
  });
}

BillingDiagnosticsScreenContext _diagnosticsContext(
  ProviderContainer container,
) {
  const preferences = BillingTenantPreferences();
  return BillingDiagnosticsScreenContext(
    selectedTenant: BillingTenantAccount(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      planName: 'Enterprise',
      currentBalance: 1200,
      preferences: preferences,
    ),
    overview: container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: preferences,
          tenantId: 'tenant-a',
        ),
      ),
    ),
    domainContext: container.read(
      billingDiagnosticsDomainContextProvider(true),
    ),
  );
}
