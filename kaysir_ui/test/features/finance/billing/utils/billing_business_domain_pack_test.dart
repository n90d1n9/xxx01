import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_module.dart';
import 'package:kaysir/features/finance/billing/models/billing_business_domain_profile.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_context_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_pack.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/utils/billing_release_gate.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_gate_lane_target.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_release_workspace_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_billing_diagnostics_section_profiles.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('standardBillingDomainPackRegistry exposes reusable pack contracts', () {
    final registry = standardBillingDomainPackRegistry();

    expect(registry.domainKeys, ['commerce', 'construction', 'digital']);
    expect(registry.moduleRegistry.domainKeys, registry.domainKeys);
    expect(
      registry.profileRegistry.requireProfile('digital').domain,
      'digital',
    );
    expect(
      registry
          .requirePack('commerce')
          .screenRegistry
          ?.contains(BillingNavigationDestinationId.cartCheckout),
      isTrue,
    );
    expect(
      registry.diagnosticsProfileCatalog
          .registryForBusinessDomain('construction')
          .sections
          .map((section) => section.id),
      contains(billingDiagnosticsConstructionSignalSectionId),
    );
    expect(
      registry.releaseWorkspaceProfileCatalog
          .registryForBusinessDomain('construction')
          .deckIds,
      contains(billingReleaseWorkspaceConstructionFocusDeckId),
    );
    expect(
      registry.releaseWorkspaceProfileCatalog
          .savedViewsForBusinessDomain('digital')
          .map((view) => view.id),
      contains(billingReleaseWorkspaceSubscriptionFocusSavedViewId),
    );
    expect(
      registry.releaseProfileSavedViewProfileCatalog
          .registryForBusinessDomain('construction')
          .views
          .map((view) => view.id),
      contains(billingDiagnosticsConstructionReleaseProfileSavedViewId),
    );
    expect(
      registry.releaseProfileSavedViewProfileCatalog
          .registryForBusinessDomain('saas')
          .views
          .map((view) => view.id),
      contains(billingDiagnosticsSubscriptionReleaseProfileSavedViewId),
    );
  });

  test('BillingBusinessDomainPackRegistry composes custom packs immutably', () {
    final registry = standardBillingDomainPackRegistry();
    final servicePack = BillingBusinessDomainPack(
      module: BillingBusinessDomainModule(profile: _serviceProfile()),
      diagnosticsProfile: BillingDiagnosticsSectionProfile(
        id: 'service-diagnostics',
        businessDomains: const ['service'],
        extensions: [
          BillingDiagnosticsSectionDescriptor(
            id: 'service-signal',
            priority: 150,
            builder: (_) => throw StateError('not rendered'),
          ),
        ],
      ),
      releaseWorkspaceProfile: BillingReleaseWorkspaceProfile(
        id: 'service-release',
        businessDomains: const ['service'],
        extensions: const [_serviceReleaseDeckDescriptor],
        savedViews: const [_serviceReleaseSavedView],
      ),
      releaseProfileSavedViewProfile:
          BillingDiagnosticsReleaseProfileSavedViewProfile(
            id: 'service-release-profile-saved-views',
            businessDomains: const ['service'],
            extensions: const [_serviceReleaseProfileSavedView],
          ),
      releaseGateLanes: const [
        BillingReleaseGateLane(
          id: 'service-handoff',
          title: 'Service handoff',
          status: BillingReleaseGateStatus.hardening,
          summaryLabel: 'Service handoff has 1 warning.',
          blockerCount: 0,
          warningCount: 1,
          actionCount: 1,
          priority: 450,
        ),
      ],
      releaseGateLaneTargets: const [
        BillingReleaseGateLaneTarget(
          laneId: 'service-handoff',
          sectionId: 'service-signal',
        ),
      ],
    );

    final extended = registry.register(servicePack);

    expect(registry.domainKeys, ['commerce', 'construction', 'digital']);
    expect(extended.domainKeys, [
      'commerce',
      'construction',
      'digital',
      'service',
    ]);
    expect(extended.requirePack('SERVICE'), servicePack);
    expect(
      extended.moduleRegistry.requireModule('service').profile.label,
      'Service operations',
    );
    expect(
      extended.diagnosticsProfileCatalog
          .registryForBusinessDomain('service')
          .sections
          .map((section) => section.id),
      contains('service-signal'),
    );
    expect(
      extended.releaseWorkspaceProfileCatalog
          .registryForBusinessDomain('service')
          .deckIds,
      contains(_serviceReleaseDeckId),
    );
    expect(
      extended.releaseWorkspaceProfileCatalog
          .savedViewsForBusinessDomain('service')
          .map((view) => view.id),
      contains(_serviceReleaseSavedViewId),
    );
    expect(
      extended.releaseProfileSavedViewProfileCatalog
          .registryForBusinessDomain('service')
          .views
          .map((view) => view.id),
      contains(_serviceReleaseProfileSavedViewId),
    );
    expect(
      extended
          .releaseGateLaneTargetsForBusinessDomain('service')
          .map((target) => target.laneId),
      contains('service-handoff'),
    );
    expect(
      extended
          .releaseGateLanesForBusinessDomain('service')
          .map((lane) => lane.id),
      contains('service-handoff'),
    );
  });

  test('BillingBusinessDomainPackRegistry rejects invalid packs', () {
    final servicePack = BillingBusinessDomainPack(
      module: BillingBusinessDomainModule(profile: _serviceProfile()),
    );

    expect(
      () => BillingBusinessDomainPackRegistry(
        packs: [servicePack, servicePack.copyWith(id: 'service-copy')],
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        diagnosticsProfile: BillingDiagnosticsSectionProfile(
          id: 'construction-only',
          businessDomains: const ['construction'],
        ),
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        releaseWorkspaceProfile: BillingReleaseWorkspaceProfile(
          id: 'construction-release-only',
          businessDomains: const ['construction'],
        ),
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        releaseProfileSavedViewProfile:
            BillingDiagnosticsReleaseProfileSavedViewProfile(
              id: 'construction-release-profile-saved-views',
              businessDomains: const ['construction'],
            ),
      ),
      throwsStateError,
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        releaseGateLanes: const [
          BillingReleaseGateLane(
            id: 'duplicate',
            title: 'Duplicate',
            status: BillingReleaseGateStatus.ready,
            summaryLabel: 'Ready.',
            blockerCount: 0,
            warningCount: 0,
            actionCount: 0,
            priority: 10,
          ),
          BillingReleaseGateLane(
            id: 'duplicate',
            title: 'Duplicate again',
            status: BillingReleaseGateStatus.ready,
            summaryLabel: 'Ready again.',
            blockerCount: 0,
            warningCount: 0,
            actionCount: 0,
            priority: 20,
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        releaseGateLaneTargets: const [
          BillingReleaseGateLaneTarget(laneId: 'missing', sectionId: 'one'),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => BillingBusinessDomainPack(
        module: BillingBusinessDomainModule(profile: _serviceProfile()),
        releaseGateLanes: const [
          BillingReleaseGateLane(
            id: 'duplicate',
            title: 'Duplicate',
            status: BillingReleaseGateStatus.ready,
            summaryLabel: 'Ready.',
            blockerCount: 0,
            warningCount: 0,
            actionCount: 0,
            priority: 10,
          ),
        ],
        releaseGateLaneTargets: const [
          BillingReleaseGateLaneTarget(laneId: 'duplicate', sectionId: 'one'),
          BillingReleaseGateLaneTarget(laneId: 'duplicate', sectionId: 'two'),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}

const _serviceReleaseDeckId = 'billing-release-workspace.service.deck';
const _serviceReleaseSavedViewId = 'service-focus';
const _serviceReleaseProfileSavedViewId = 'service-release-profile';

const _serviceReleaseDeckDescriptor = BillingReleaseWorkspaceDeckDescriptor(
  id: _serviceReleaseDeckId,
  priority: 75,
  builder: _throwIfRendered,
);

const _serviceReleaseSavedView = BillingReleaseWorkspaceSavedView(
  id: _serviceReleaseSavedViewId,
  label: 'Service focus',
  description: 'Service release readiness',
  deckIds: {_serviceReleaseDeckId},
);

const _serviceReleaseProfileSavedView =
    BillingDiagnosticsReleaseProfileSavedView(
      id: _serviceReleaseProfileSavedViewId,
      label: 'Service profile',
      description: 'Show service release profile coverage',
      statusOption: BillingReleaseProfileStatusFilterOption.extended,
      icon: Icons.home_repair_service_outlined,
    );

Widget _throwIfRendered({
  required BillingDiagnosticsReleaseContext releaseContext,
  required ValueChanged<BillingNavigationDestinationId> onDestinationSelected,
}) {
  throw StateError('not rendered');
}

BillingBusinessDomainProfile _serviceProfile() {
  return BillingBusinessDomainProfile(
    domain: 'service',
    label: 'Service operations',
    defaultSourceType: 'work_order',
    capabilities: const {BillingBusinessDomainCapability.servicePeriods},
  );
}
