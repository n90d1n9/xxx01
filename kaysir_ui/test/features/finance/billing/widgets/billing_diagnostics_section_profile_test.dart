import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_profile.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_section_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_billing_diagnostics_section_profiles.dart';

void main() {
  test('BillingDiagnosticsSectionProfile normalizes domain aliases', () {
    final profile = BillingDiagnosticsSectionProfile(
      id: 'subscription',
      businessDomains: const [' SaaS ', 'DIGITAL'],
    );

    expect(profile.id, 'subscription');
    expect(profile.matches('saas'), isTrue);
    expect(profile.matches('digital'), isTrue);
    expect(profile.matches('construction'), isFalse);
  });

  test('BillingDiagnosticsSectionProfileCatalog resolves custom profiles', () {
    final catalog = BillingDiagnosticsSectionProfileCatalog(
      profiles: [
        BillingDiagnosticsSectionProfile(
          id: 'custom',
          businessDomains: const ['custom'],
          hiddenSectionIds: const {billingDiagnosticsReleaseSectionId},
          extensions: [
            BillingDiagnosticsSectionDescriptor(
              id: 'custom-signal',
              priority: 150,
              builder: (_) => const Text('Custom diagnostics'),
            ),
          ],
        ),
      ],
    );

    final registry = billingDiagnosticsSectionRegistryForBusinessDomain(
      ' custom ',
      catalog: catalog,
    );

    expect(registry.sections.map((section) => section.id), [
      billingDiagnosticsOverviewSectionId,
      'custom-signal',
      billingDiagnosticsDomainSectionId,
      billingDiagnosticsReleaseProfileCoverageSectionId,
      billingDiagnosticsReleaseGateSectionId,
      billingDiagnosticsRouteExtensionManifestSectionId,
      billingDiagnosticsRouteContractSectionId,
      billingDiagnosticsNavigationSectionId,
    ]);
  });

  test(
    'BillingDiagnosticsSectionProfile extends reusable profile metadata',
    () {
      final profile = BillingDiagnosticsSectionProfile(
        id: 'subscription',
        businessDomains: const ['saas'],
        hiddenSectionIds: const {billingDiagnosticsReleaseSectionId},
        extensions: [
          BillingDiagnosticsSectionDescriptor(
            id: 'renewal-signal',
            priority: 150,
            builder: (_) => const Text('Renewal diagnostics'),
          ),
        ],
      ).extend(
        businessDomains: const ['digital'],
        hiddenSectionIds: const {billingDiagnosticsNavigationSectionId},
        extensions: [
          BillingDiagnosticsSectionDescriptor(
            id: 'entitlement-signal',
            priority: 160,
            builder: (_) => const Text('Entitlement diagnostics'),
          ),
        ],
      );

      expect(profile.businessDomains, {'saas', 'digital'});
      expect(profile.hiddenSectionIds, {
        billingDiagnosticsReleaseSectionId,
        billingDiagnosticsNavigationSectionId,
      });
      expect(profile.extensions.map((section) => section.id), [
        'renewal-signal',
        'entitlement-signal',
      ]);
    },
  );

  test('BillingDiagnosticsSectionProfileCatalog extends existing profiles', () {
    final catalog = standardBillingDiagnosticsSectionProfileCatalog
        .extendProfile(
          profileId: billingDiagnosticsConstructionProfileId,
          businessDomains: const ['builder'],
          hiddenSectionIds: const {billingDiagnosticsReleaseSectionId},
          extensions: [
            BillingDiagnosticsSectionDescriptor(
              id: 'retention-signal',
              priority: 160,
              builder: (_) => const Text('Retention diagnostics'),
            ),
          ],
        );

    final registry = billingDiagnosticsSectionRegistryForBusinessDomain(
      'builder',
      catalog: catalog,
    );

    expect(registry.sections.map((section) => section.id), [
      billingDiagnosticsOverviewSectionId,
      billingDiagnosticsConstructionSignalSectionId,
      'retention-signal',
      billingDiagnosticsDomainSectionId,
      billingDiagnosticsReleaseProfileCoverageSectionId,
      billingDiagnosticsReleaseGateSectionId,
      billingDiagnosticsRouteExtensionManifestSectionId,
      billingDiagnosticsRouteContractSectionId,
      billingDiagnosticsNavigationSectionId,
    ]);
  });

  test('BillingDiagnosticsSectionProfileCatalog rejects duplicate domains', () {
    expect(
      () => BillingDiagnosticsSectionProfileCatalog(
        profiles: [
          BillingDiagnosticsSectionProfile(
            id: 'one',
            businessDomains: const ['commerce'],
          ),
          BillingDiagnosticsSectionProfile(
            id: 'two',
            businessDomains: const [' Commerce '],
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test(
    'BillingDiagnosticsSectionProfileCatalog rejects conflicting extensions',
    () {
      expect(
        () => standardBillingDiagnosticsSectionProfileCatalog.extendProfile(
          profileId: billingDiagnosticsSubscriptionProfileId,
          businessDomains: const ['construction'],
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => standardBillingDiagnosticsSectionProfileCatalog.extendProfile(
          profileId: 'missing',
          extensions: [
            BillingDiagnosticsSectionDescriptor(
              id: 'missing-signal',
              priority: 150,
              builder: (_) => const Text('Missing diagnostics'),
            ),
          ],
        ),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('BillingDiagnosticsSectionProfile rejects blank profile domains', () {
    expect(
      () => BillingDiagnosticsSectionProfile(
        id: 'blank',
        businessDomains: const [' '],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
