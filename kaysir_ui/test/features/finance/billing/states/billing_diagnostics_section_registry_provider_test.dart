import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/states/billing_business_domain_pack_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_section_registry_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_lane_target.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_billing_diagnostics_section_profiles.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test(
    'billingDiagnosticsSectionRegistryForBusinessDomain keeps commerce standard',
    () {
      final registry = billingDiagnosticsSectionRegistryForBusinessDomain(
        'commerce',
      );

      expect(registry.sections.map((section) => section.id), [
        billingDiagnosticsOverviewSectionId,
        billingDiagnosticsDomainSectionId,
        billingDiagnosticsReleaseProfileCoverageSectionId,
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsReleaseGateSectionId,
        billingDiagnosticsRouteExtensionManifestSectionId,
        billingDiagnosticsRouteContractSectionId,
        billingDiagnosticsNavigationSectionId,
      ]);
    },
  );

  test(
    'billingDiagnosticsSectionRegistryForBusinessDomain adds construction signal',
    () {
      final registry = billingDiagnosticsSectionRegistryForBusinessDomain(
        'construction',
      );

      expect(registry.sections.map((section) => section.id), [
        billingDiagnosticsOverviewSectionId,
        billingDiagnosticsConstructionSignalSectionId,
        billingDiagnosticsDomainSectionId,
        billingDiagnosticsReleaseProfileCoverageSectionId,
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsReleaseGateSectionId,
        billingDiagnosticsRouteExtensionManifestSectionId,
        billingDiagnosticsRouteContractSectionId,
        billingDiagnosticsNavigationSectionId,
      ]);
    },
  );

  test(
    'billingDiagnosticsSectionRegistryForBusinessDomain adds subscription signal',
    () {
      final registry = billingDiagnosticsSectionRegistryForBusinessDomain(
        'SaaS',
      );

      expect(
        registry.sections.map((section) => section.id),
        contains(billingDiagnosticsSubscriptionSignalSectionId),
      );
    },
  );

  test(
    'billingDiagnosticsSectionRegistryProvider exposes standard sections',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsSectionRegistryProvider,
      );

      expect(registry.sections.map((section) => section.id), [
        billingDiagnosticsOverviewSectionId,
        billingDiagnosticsDomainSectionId,
        billingDiagnosticsReleaseProfileCoverageSectionId,
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsReleaseGateSectionId,
        billingDiagnosticsRouteExtensionManifestSectionId,
        billingDiagnosticsRouteContractSectionId,
        billingDiagnosticsNavigationSectionId,
      ]);
    },
  );

  test(
    'billingDiagnosticsSectionRegistryProvider derives pack diagnostics',
    () {
      final container = ProviderContainer(
        overrides: [
          billingBusinessDomainPackRegistryProvider.overrideWithValue(
            BillingBusinessDomainPackRegistry(
              packs: [
                commerceBillingDomainPack(
                  diagnosticsProfile: BillingDiagnosticsSectionProfile(
                    id: 'commerce-pack',
                    businessDomains: const ['commerce'],
                    extensions: [
                      BillingDiagnosticsSectionDescriptor(
                        id: 'commerce-pack-signal',
                        priority: 150,
                        builder: (_) => throw StateError('not rendered'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsSectionRegistryProvider,
      );

      expect(registry.sections.map((section) => section.id), [
        billingDiagnosticsOverviewSectionId,
        'commerce-pack-signal',
        billingDiagnosticsDomainSectionId,
        billingDiagnosticsReleaseProfileCoverageSectionId,
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsReleaseGateSectionId,
        billingDiagnosticsRouteExtensionManifestSectionId,
        billingDiagnosticsRouteContractSectionId,
        billingDiagnosticsNavigationSectionId,
      ]);
    },
  );

  test(
    'billingReleaseGateLaneTargetRegistryProvider derives pack lane targets',
    () {
      final container = ProviderContainer(
        overrides: [
          billingBusinessDomainPackRegistryProvider.overrideWithValue(
            BillingBusinessDomainPackRegistry(
              packs: [
                commerceBillingDomainPack(
                  releaseGateLanes: const [
                    BillingReleaseGateLane(
                      id: 'commerce-risk',
                      title: 'Commerce risk',
                      status: BillingReleaseGateStatus.hardening,
                      summaryLabel: 'Commerce risk has 1 warning.',
                      blockerCount: 0,
                      warningCount: 1,
                      actionCount: 1,
                      priority: 450,
                    ),
                  ],
                  releaseGateLaneTargets: const [
                    BillingReleaseGateLaneTarget(
                      laneId: 'commerce-risk',
                      sectionId: 'commerce-pack-signal',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final registry = container.read(
        billingReleaseGateLaneTargetRegistryProvider,
      );

      expect(
        registry.targetForLaneId('commerce-risk')?.sectionId,
        'commerce-pack-signal',
      );
      expect(
        registry
            .targetForLaneId(billingReleaseGateRouteExecutionLaneId)
            ?.sectionId,
        billingDiagnosticsRouteContractSectionId,
      );
    },
  );

  test(
    'billingDiagnosticsReleaseGateReportProvider derives pack release lanes',
    () {
      final container = ProviderContainer(
        overrides: [
          billingBusinessDomainPackRegistryProvider.overrideWithValue(
            BillingBusinessDomainPackRegistry(
              packs: [
                commerceBillingDomainPack(
                  releaseGateLanes: const [
                    BillingReleaseGateLane(
                      id: 'commerce-risk',
                      title: 'Commerce risk',
                      status: BillingReleaseGateStatus.hardening,
                      summaryLabel: 'Commerce risk has 1 warning.',
                      blockerCount: 0,
                      warningCount: 1,
                      actionCount: 1,
                      priority: 450,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final report = container.read(
        billingDiagnosticsReleaseGateReportProvider,
      );

      expect(report.laneForId('commerce-risk')?.title, 'Commerce risk');
      expect(report.warningCount, 1);
      expect(report.hardeningLanes.map((lane) => lane.id), ['commerce-risk']);
    },
  );

  test(
    'billingDiagnosticsSectionRegistryProvider accepts profile catalog overrides',
    () {
      final container = ProviderContainer(
        overrides: [
          billingDiagnosticsSectionProfileCatalogProvider.overrideWithValue(
            BillingDiagnosticsSectionProfileCatalog(
              profiles: [
                BillingDiagnosticsSectionProfile(
                  id: 'commerce-addon',
                  businessDomains: const ['commerce'],
                  extensions: [
                    BillingDiagnosticsSectionDescriptor(
                      id: 'commerce-signal',
                      priority: 150,
                      builder: (_) => throw StateError('not rendered'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsSectionRegistryProvider,
      );

      expect(registry.sections.map((section) => section.id), [
        billingDiagnosticsOverviewSectionId,
        'commerce-signal',
        billingDiagnosticsDomainSectionId,
        billingDiagnosticsReleaseProfileCoverageSectionId,
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsReleaseGateSectionId,
        billingDiagnosticsRouteExtensionManifestSectionId,
        billingDiagnosticsRouteContractSectionId,
        billingDiagnosticsNavigationSectionId,
      ]);
    },
  );

  test(
    'billingReleaseWorkspaceProfileCatalogProvider derives pack profiles',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final catalog = container.read(
        billingReleaseWorkspaceProfileCatalogProvider,
      );

      expect(
        catalog.registryForBusinessDomain('construction').deckIds,
        contains(billingReleaseWorkspaceConstructionFocusDeckId),
      );
      expect(
        catalog.savedViewsForBusinessDomain('digital').map((view) => view.id),
        contains(billingReleaseWorkspaceSubscriptionFocusSavedViewId),
      );
    },
  );
}
