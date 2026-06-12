import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  test('diagnostics overview resolves default module health', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        const BillingDiagnosticsOverviewRequest(),
      ),
    );

    expect(overview.isDefaultScoped, isTrue);
    expect(overview.isTenantScoped, isFalse);
    expect(overview.businessDomain, 'commerce');
    expect(overview.scopeLabel, 'Default diagnostics');
    expect(overview.moduleCount, 3);
    expect(overview.packCount, 3);
    expect(overview.blockerCount, 3);
    expect(overview.warningCount, 2);
    expect(overview.packBlockerCount, 3);
    expect(overview.packWarningCount, 4);
    expect(overview.packContractOpenRequirementCount, 5);
    expect(overview.packContractBlockedRequirementCount, 3);
    expect(overview.packContractWarningRequirementCount, 2);
    expect(
      overview.packContractSummaryLabel,
      '3 of 3 billing domain-pack contracts need contract attention.',
    );
    expect(overview.remediationActionCount, 7);
    expect(overview.remediationBlockerActionCount, 3);
    expect(overview.remediationWarningActionCount, 4);
    expect(
      overview.remediationSummaryLabel,
      '3 blocker actions should be cleared before pack release.',
    );
    expect(
      overview.packReadinessSummaryLabel,
      '3 of 3 billing packs need attention.',
    );
    expect(overview.registryReadiness.blockedDomainKeys, [
      'commerce',
      'construction',
      'digital',
    ]);
    expect(overview.hasNavigationGaps, isTrue);
    expect(overview.coverageSummary.isComplete, isFalse);
    expect(overview.readyLaunchTaskCount, 0);
    expect(overview.blockedLaunchTaskCount, 14);
    expect(overview.hasLaunchBlockers, isTrue);
    expect(
      overview.destinationLaunchSnapshot.selectedDestinationIdFor(
        BillingNavigationDestinationId.cartCheckout,
      ),
      BillingNavigationDestinationId.dashboard,
    );
  });

  test('diagnostics overview resolves commerce tenant health', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: const BillingTenantPreferences(),
          tenantId: 'tenant-a',
        ),
      ),
    );

    expect(overview.isTenantScoped, isTrue);
    expect(overview.businessDomain, 'commerce');
    expect(overview.scopeLabel, 'Tenant commerce diagnostics');
    expect(overview.moduleCount, 3);
    expect(overview.packCount, 3);
    expect(overview.warningCount, 2);
    expect(overview.packWarningCount, 4);
    expect(overview.packContractOpenRequirementCount, 4);
    expect(overview.packContractBlockedRequirementCount, 0);
    expect(overview.packContractWarningRequirementCount, 4);
    expect(
      overview.packContractSummaryLabel,
      '3 billing domain-pack contracts are release-ready with '
      '4 hardening requirements.',
    );
    expect(overview.remediationActionCount, 4);
    expect(overview.remediationBlockerActionCount, 0);
    expect(overview.remediationWarningActionCount, 4);
    expect(
      overview.remediationSummaryLabel,
      '4 hardening actions can improve billing pack release quality.',
    );
    expect(
      overview.packReadinessSummaryLabel,
      '3 billing packs are release-ready with 4 warnings.',
    );
    expect(overview.coverageSummary.isComplete, isTrue);
    expect(overview.navigationGapCount, 0);
    expect(overview.readyLaunchTaskCount, 2);
    expect(overview.blockedLaunchTaskCount, 12);
    expect(
      overview.releaseSummaryLabel,
      '2 launch tasks ready now; 12 need release or routing work.',
    );
    expect(
      overview.destinationLaunchSnapshot.destinationIds,
      contains(BillingNavigationDestinationId.cartCheckout),
    );
  });

  test('diagnostics overview resolves construction tenant health', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final overview = container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest.fromTenant(
          preferences: const BillingTenantPreferences(
            businessDomain: 'construction',
          ),
          tenantId: 'tenant-a',
        ),
      ),
    );

    expect(overview.isTenantScoped, isTrue);
    expect(overview.businessDomain, 'construction');
    expect(overview.coverageSummary.isComplete, isTrue);
    expect(overview.readyLaunchTaskCount, 5);
    expect(overview.blockedLaunchTaskCount, 9);
    expect(
      overview.destinationLaunchSnapshot.destinationIds,
      isNot(contains(BillingNavigationDestinationId.cartCheckout)),
    );
    expect(
      overview.releaseSummaryLabel,
      '5 launch tasks ready now; 9 need release or routing work.',
    );
  });
}
