import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_contract_coverage.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/standard_release_workspace_profiles.dart';

void main() {
  test('release profile saved-view registry composes standard presets', () {
    final registry = BillingDiagnosticsReleaseProfileSavedViewRegistry.standard(
      hiddenViewIds: {billingDiagnosticsReleaseProfileExtendedSavedViewId},
      replacements: const [
        BillingDiagnosticsReleaseProfileSavedView(
          id: billingDiagnosticsReleaseProfileStandardSavedViewId,
          label: 'Baseline profiles',
          description: 'Show baseline release profile coverage',
          statusOption: BillingReleaseProfileStatusFilterOption.standard,
          icon: Icons.verified_user_outlined,
        ),
      ],
      extensions: const [
        BillingDiagnosticsReleaseProfileSavedView(
          id: 'focused-domain-standard',
          label: 'Focused baseline',
          description: 'Show standard profiles for the focused domain',
          statusOption: BillingReleaseProfileStatusFilterOption.standard,
          domainScope:
              BillingDiagnosticsReleaseProfileSavedViewDomainScope
                  .focusedBusinessDomain,
          icon: Icons.center_focus_strong_outlined,
        ),
      ],
    );

    expect(registry.viewForId('standard-profiles')?.label, 'Baseline profiles');
    expect(registry.views.map((view) => view.id), [
      billingDiagnosticsReleaseProfileAllSavedViewId,
      billingDiagnosticsReleaseProfileCurrentDomainSavedViewId,
      billingDiagnosticsReleaseProfileStandardSavedViewId,
      billingDiagnosticsReleaseProfileConstrainedSavedViewId,
      billingDiagnosticsReleaseProfileTailoredSavedViewId,
      'focused-domain-standard',
    ]);
  });

  test('release profile saved-view registry resolves available presets', () {
    final coverage = BillingReleaseWorkspaceProfileContractCoverage(
      contracts: standardBillingReleaseWorkspaceProfileCatalog.buildContracts(),
    );
    final registry = BillingDiagnosticsReleaseProfileSavedViewRegistry.standard(
      hiddenViewIds: {billingDiagnosticsReleaseProfileCurrentDomainSavedViewId},
    );

    expect(
      registry
          .availableViews(
            coverage: coverage,
            focusedBusinessDomain: 'construction',
          )
          .map((view) => view.id),
      [
        billingDiagnosticsReleaseProfileAllSavedViewId,
        billingDiagnosticsReleaseProfileStandardSavedViewId,
        billingDiagnosticsReleaseProfileExtendedSavedViewId,
      ],
    );
  });

  test('release profile saved-view registry validates ids', () {
    expect(
      () => BillingDiagnosticsReleaseProfileSavedViewRegistry(
        views: const [
          billingDiagnosticsReleaseProfileAllSavedView,
          billingDiagnosticsReleaseProfileAllSavedView,
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => BillingDiagnosticsReleaseProfileSavedViewRegistry(
        views: const [
          BillingDiagnosticsReleaseProfileSavedView(
            id: ' ',
            label: 'Blank',
            description: 'Invalid blank id',
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('release profile saved-view profile catalog resolves domains', () {
    final profile = BillingDiagnosticsReleaseProfileSavedViewProfile(
      id: 'service-release-profile-saved-views',
      businessDomains: const ['Service', 'work-orders'],
      extensions: const [
        BillingDiagnosticsReleaseProfileSavedView(
          id: 'service-release-profile',
          label: 'Service profile',
          description: 'Show service release profile coverage',
          icon: Icons.home_repair_service_outlined,
        ),
      ],
    );
    final catalog = BillingDiagnosticsReleaseProfileSavedViewProfileCatalog(
      profiles: [profile],
    );

    expect(catalog.profileForBusinessDomain('work-orders'), profile);
    expect(
      catalog.registryForBusinessDomain('service').views.map((view) => view.id),
      contains('service-release-profile'),
    );
    expect(
      catalog.registryForBusinessDomain('commerce'),
      standardBillingDiagnosticsReleaseProfileSavedViewRegistry,
    );
  });

  test('release profile saved-view profile catalog validates ownership', () {
    final profile = BillingDiagnosticsReleaseProfileSavedViewProfile(
      id: 'service-release-profile-saved-views',
      businessDomains: const ['service'],
    );

    expect(
      () => BillingDiagnosticsReleaseProfileSavedViewProfileCatalog(
        profiles: [profile, profile],
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => BillingDiagnosticsReleaseProfileSavedViewProfileCatalog(
        profiles: [
          profile,
          BillingDiagnosticsReleaseProfileSavedViewProfile(
            id: 'service-duplicate',
            businessDomains: const ['SERVICE'],
          ),
        ],
      ),
      throwsA(isA<ArgumentError>()),
    );
  });
}
