import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_domain_context_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_overview_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_saved_view_registry_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_screen_context_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_business_domain_packs.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view.dart';
import 'package:kaysir/features/finance/billing/widgets/diagnostics_release_profile_saved_view_registry.dart';

void main() {
  test(
    'billing diagnostics release profile saved-view registry provider exposes defaults',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsReleaseProfileSavedViewRegistryProvider,
      );

      expect(
        registry,
        standardBillingDiagnosticsReleaseProfileSavedViewRegistry,
      );
      expect(
        registry.views.map((view) => view.id),
        contains(billingDiagnosticsReleaseProfileCurrentDomainSavedViewId),
      );
    },
  );

  test(
    'billing diagnostics release profile saved-view registry provider derives pack profiles',
    () {
      final source = ProviderContainer();
      addTearDown(source.dispose);
      final container = ProviderContainer(
        overrides: [
          billingDiagnosticsScreenContextProvider.overrideWithValue(
            _diagnosticsContext(source, 'construction'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsReleaseProfileSavedViewRegistryProvider,
      );

      expect(
        registry.views.map((view) => view.id),
        contains(billingDiagnosticsConstructionReleaseProfileSavedViewId),
      );
    },
  );

  test(
    'billing diagnostics release profile saved-view registry provider resolves domain aliases',
    () {
      final source = ProviderContainer();
      addTearDown(source.dispose);
      final container = ProviderContainer(
        overrides: [
          billingDiagnosticsScreenContextProvider.overrideWithValue(
            _diagnosticsContext(source, 'SaaS'),
          ),
        ],
      );
      addTearDown(container.dispose);

      final registry = container.read(
        billingDiagnosticsReleaseProfileSavedViewRegistryProvider,
      );

      expect(
        registry.views.map((view) => view.id),
        contains(billingDiagnosticsSubscriptionReleaseProfileSavedViewId),
      );
    },
  );
}

BillingDiagnosticsScreenContext _diagnosticsContext(
  ProviderContainer container,
  String businessDomain,
) {
  final preferences = BillingTenantPreferences(businessDomain: businessDomain);

  return BillingDiagnosticsScreenContext(
    selectedTenant: null,
    overview: container.read(
      billingDiagnosticsOverviewProvider(
        BillingDiagnosticsOverviewRequest(preferences: preferences),
      ),
    ),
    domainContext: container.read(
      billingDiagnosticsDomainContextProvider(false),
    ),
  );
}
