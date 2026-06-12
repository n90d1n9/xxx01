import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/states/billing_diagnostics_release_profile_filter_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_diagnostics_release_profile_filter_hydrator.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_domain_filter.dart';
import 'package:kaysir/features/finance/billing/widgets/release_profile_status_filter.dart';

void main() {
  testWidgets(
    'BillingDiagnosticsReleaseProfileFilterHydrator restores route filter state',
    (tester) async {
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
      final initialState = BillingDiagnosticsReleaseProfileFilterState(
        statusOption: BillingReleaseProfileStatusFilterOption.standard,
        domainSelection: BillingReleaseProfileDomainFilterSelection.domain(
          'retail',
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: BillingDiagnosticsReleaseProfileFilterHydrator(
            initialState: initialState,
            child: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(
        container.read(billingDiagnosticsReleaseProfileFilterProvider(scope)),
        initialState,
      );
    },
  );

  testWidgets(
    'BillingDiagnosticsReleaseProfileFilterHydrator can leave inactive filters untouched',
    (tester) async {
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
      final filterProvider = billingDiagnosticsReleaseProfileFilterProvider(
        scope,
      );
      container
          .read(filterProvider.notifier)
          .selectStatusOption(BillingReleaseProfileStatusFilterOption.extended);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BillingDiagnosticsReleaseProfileFilterHydrator(
            clearWhenInactive: false,
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(
        container.read(filterProvider).statusOption,
        BillingReleaseProfileStatusFilterOption.extended,
      );
    },
  );
}
