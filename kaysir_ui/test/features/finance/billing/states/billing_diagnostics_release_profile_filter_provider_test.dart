import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';

void main() {
  test(
    'billing diagnostics release profile filter controller persists state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final scope = BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: 'tenant-a',
        businessDomain: 'commerce',
      );
      final filterProvider = billingDiagnosticsReleaseProfileFilterProvider(
        scope,
      );

      final controller = container.read(filterProvider.notifier);

      expect(
        container.read(filterProvider),
        const BillingDiagnosticsReleaseProfileFilterState(),
      );

      controller.selectStatusOption(
        BillingReleaseProfileStatusFilterOption.standard,
      );
      controller.selectDomain(
        BillingReleaseProfileDomainFilterSelection.domain('retail'),
      );

      final selectedState = container.read(filterProvider);
      expect(
        selectedState.statusOption,
        BillingReleaseProfileStatusFilterOption.standard,
      );
      expect(
        selectedState.domainSelection,
        BillingReleaseProfileDomainFilterSelection.domain('retail'),
      );
      expect(selectedState.hasActiveFilters, isTrue);

      controller.clearFilters();

      expect(
        container.read(filterProvider),
        const BillingDiagnosticsReleaseProfileFilterState(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter state serializes query parameters',
    () {
      final state = BillingDiagnosticsReleaseProfileFilterState(
        statusOption: BillingReleaseProfileStatusFilterOption.standard,
        domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
          'Retail',
        ),
      );

      final queryParameters = state.toQueryParameters();

      expect(queryParameters, {
        billingDiagnosticsReleaseProfileStatusQueryKey: 'standard',
        billingDiagnosticsReleaseProfileDomainQueryKey: 'retail',
      });
      expect(
        BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters(
          queryParameters,
        ),
        state,
      );
      expect(
        const BillingDiagnosticsReleaseProfileFilterState().toQueryParameters(),
        isEmpty,
      );
      expect(
        BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters({}),
        const BillingDiagnosticsReleaseProfileFilterState(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter state supports custom query keys',
    () {
      final state = BillingDiagnosticsReleaseProfileFilterState(
        statusOption: BillingReleaseProfileStatusFilterOption.tailored,
        domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
          'digital-saas',
        ),
      );

      final queryParameters = state.toQueryParameters(
        statusQueryKey: 'status',
        domainQueryKey: 'domain',
      );

      expect(queryParameters, {'status': 'tailored', 'domain': 'digital-saas'});
      expect(
        BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters(
          queryParameters,
          statusQueryKey: 'status',
          domainQueryKey: 'domain',
        ),
        state,
      );
    },
  );

  test(
    'billing diagnostics release profile filter state tolerates query noise',
    () {
      final noisyState =
          BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters({
            billingDiagnosticsReleaseProfileStatusQueryKey: ' missing ',
            billingDiagnosticsReleaseProfileDomainQueryKey: '  Retail Store  ',
          });

      expect(
        noisyState.statusOption,
        BillingReleaseProfileStatusFilterOption.all,
      );
      expect(
        noisyState.domainSelection,
        BillingReleaseProfileDomainFilterSelection.domain('retail store'),
      );

      final uppercaseState =
          BillingDiagnosticsReleaseProfileFilterState.fromQueryParameters({
            billingDiagnosticsReleaseProfileStatusQueryKey: 'STANDARD',
          });

      expect(
        uppercaseState.statusOption,
        BillingReleaseProfileStatusFilterOption.standard,
      );
      expect(
        uppercaseState.domainSelection,
        const BillingReleaseProfileDomainFilterSelection.all(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter controller isolates scopes',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final commerceScope = BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: 'tenant-a',
        businessDomain: 'Commerce',
      );
      final normalizedCommerceScope =
          BillingDiagnosticsReleaseProfileFilterScope(
            tenantId: 'tenant-a',
            businessDomain: 'commerce',
          );
      final constructionScope = BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: 'tenant-a',
        businessDomain: 'construction',
      );

      container
          .read(
            billingDiagnosticsReleaseProfileFilterProvider(
              commerceScope,
            ).notifier,
          )
          .selectDomain(
            BillingReleaseProfileDomainFilterSelection.domain('retail'),
          );

      expect(commerceScope, normalizedCommerceScope);
      expect(
        container
            .read(
              billingDiagnosticsReleaseProfileFilterProvider(
                normalizedCommerceScope,
              ),
            )
            .domainSelection,
        BillingReleaseProfileDomainFilterSelection.domain('retail'),
      );
      expect(
        container.read(
          billingDiagnosticsReleaseProfileFilterProvider(constructionScope),
        ),
        const BillingDiagnosticsReleaseProfileFilterState(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter controller hydrates query state',
    () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final scope = BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: 'tenant-a',
        businessDomain: 'commerce',
      );
      final filterProvider = billingDiagnosticsReleaseProfileFilterProvider(
        scope,
      );

      final controller = container.read(filterProvider.notifier);

      controller.hydrateFromQueryParameters({
        billingDiagnosticsReleaseProfileStatusQueryKey: 'extended',
        billingDiagnosticsReleaseProfileDomainQueryKey: 'construction',
      });

      expect(
        container.read(filterProvider),
        BillingDiagnosticsReleaseProfileFilterState(
          statusOption: BillingReleaseProfileStatusFilterOption.extended,
          domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
            'construction',
          ),
        ),
      );

      controller.hydrateFromQueryParameters({});

      expect(
        container.read(filterProvider),
        const BillingDiagnosticsReleaseProfileFilterState(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter binding forwards actions',
    () {
      final scope = BillingDiagnosticsReleaseProfileFilterScope(
        tenantId: 'tenant-a',
        businessDomain: 'commerce',
      );
      final container = ProviderContainer(
        overrides: [
          billingDiagnosticsReleaseProfileFilterScopeProvider.overrideWithValue(
            scope,
          ),
        ],
      );
      addTearDown(container.dispose);

      final binding = container.read(
        billingDiagnosticsReleaseProfileFilterBindingProvider,
      );
      binding.selectStatusOption(
        BillingReleaseProfileStatusFilterOption.standard,
      );
      binding.selectDomainSelection(
        BillingReleaseProfileDomainFilterSelection.domain('retail'),
      );

      final selectedBinding = container.read(
        billingDiagnosticsReleaseProfileFilterBindingProvider,
      );
      expect(selectedBinding.scope, scope);
      expect(
        selectedBinding.state.statusOption,
        BillingReleaseProfileStatusFilterOption.standard,
      );
      expect(
        selectedBinding.state.domainSelection,
        BillingReleaseProfileDomainFilterSelection.domain('retail'),
      );
      expect(selectedBinding.hasActiveFilters, isTrue);

      selectedBinding.clearFilters();

      expect(
        container
            .read(billingDiagnosticsReleaseProfileFilterBindingProvider)
            .state,
        const BillingDiagnosticsReleaseProfileFilterState(),
      );
    },
  );

  test(
    'billing diagnostics release profile filter snapshot labels filters',
    () {
      final snapshot = BillingDiagnosticsReleaseProfileFilterSnapshot(
        scope: BillingDiagnosticsReleaseProfileFilterScope(
          tenantId: 'tenant-a',
          businessDomain: 'commerce',
        ),
        state: BillingDiagnosticsReleaseProfileFilterState(
          statusOption: BillingReleaseProfileStatusFilterOption.standard,
          domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
            'retail',
          ),
        ),
      );

      expect(snapshot.hasActiveFilters, isTrue);
      expect(snapshot.activeFilterCount, 2);
      expect(snapshot.countLabel, '2 filters');
      expect(snapshot.statusLabel, 'Standard');
      expect(snapshot.domainLabel, 'Retail');
      expect(snapshot.activeFilterLabels, [
        'Status: Standard',
        'Domain: Retail',
      ]);
      expect(snapshot.summaryLabel, 'Standard · Retail');
      expect(
        snapshot.detailLabel,
        '2 filters active: Status: Standard; Domain: Retail.',
      );

      final inactiveSnapshot = BillingDiagnosticsReleaseProfileFilterSnapshot(
        scope: snapshot.scope,
        state: const BillingDiagnosticsReleaseProfileFilterState(),
      );

      expect(inactiveSnapshot.hasActiveFilters, isFalse);
      expect(inactiveSnapshot.activeFilterCount, 0);
      expect(inactiveSnapshot.summaryLabel, 'All release profiles');
      expect(
        inactiveSnapshot.detailLabel,
        'No release profile filters active.',
      );
    },
  );
}
