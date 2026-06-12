import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_tenant_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/utils/billing_route_context.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_route_context_hydrator.dart';

void main() {
  testWidgets(
    'BillingRouteContextHydrator restores selected tenant from route',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BillingRouteContextHydrator(
            tenantId: ' tenant-a ',
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(container.read(selectedBillingTenantIdProvider), 'tenant-a');
    },
  );

  testWidgets(
    'BillingRouteContextHydrator applies route domain to product tenant',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BillingRouteContextHydrator(
            tenantId: 'tenant-a',
            businessDomain: ' Construction ',
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final tenant = container.read(currentTenantProvider);
      expect(tenant?.id, 'tenant-a');
      expect(tenant?.preferences.businessDomain, 'construction');
    },
  );

  testWidgets('BillingRouteContextHydrator restores context object', (
    tester,
  ) async {
    final container = _container();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: BillingRouteContextHydrator(
          routeContext: BillingRouteContext(
            tenantId: ' tenant-b ',
            businessDomain: 'Digital',
          ),
          child: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(container.read(selectedBillingTenantIdProvider), 'tenant-b');
    final tenant = container.read(currentTenantProvider);
    expect(tenant?.id, 'tenant-b');
    expect(tenant?.preferences.businessDomain, 'digital');
  });

  testWidgets(
    'BillingRouteContextHydrator applies route domain to current tenant',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);
      container.read(currentTenantProvider.notifier).state = const Tenant(
        id: 'tenant-a',
        name: 'Acme Corp',
        logoUrl: '',
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BillingRouteContextHydrator(
            businessDomain: 'digital',
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      final tenant = container.read(currentTenantProvider);
      expect(tenant?.id, 'tenant-a');
      expect(tenant?.preferences.businessDomain, 'digital');
    },
  );

  testWidgets(
    'BillingRouteContextHydrator ignores blank tenant route context',
    (tester) async {
      final container = _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const BillingRouteContextHydrator(
            tenantId: '   ',
            child: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      expect(container.read(selectedBillingTenantIdProvider), isEmpty);
    },
  );
}

ProviderContainer _container() {
  return ProviderContainer(
    overrides: [
      billingProductTenantRepositoryProvider.overrideWithValue(
        const _FakeBillingProductTenantRepository(),
      ),
    ],
  );
}

class _FakeBillingProductTenantRepository
    implements BillingProductTenantRepository {
  const _FakeBillingProductTenantRepository();

  @override
  Future<List<Tenant>> fetchTenants() async {
    return const [
      Tenant(id: 'tenant-a', name: 'Acme Corp', logoUrl: ''),
      Tenant(id: 'tenant-b', name: 'TechStart Inc', logoUrl: ''),
    ];
  }
}
