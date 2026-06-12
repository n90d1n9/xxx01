import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_tenant_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_tenant_selection_screen.dart';

void main() {
  testWidgets('TenantSelectionScreen selects the tapped tenant', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        billingProductTenantRepositoryProvider.overrideWithValue(
          const _FakeBillingProductTenantRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TenantSelectionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acme Corp'));
    await tester.pump();

    expect(container.read(currentTenantProvider)?.name, 'Acme Corp');
  });

  testWidgets('TenantSelectionScreen applies initial business domain', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        billingProductTenantRepositoryProvider.overrideWithValue(
          const _FakeBillingProductTenantRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: TenantSelectionScreen(initialBusinessDomain: 'construction'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Acme Corp'));
    await tester.pump();

    expect(
      container.read(currentTenantProvider)?.preferences.businessDomain,
      'construction',
    );
  });

  testWidgets('TenantSelectionScreen blocks tenant-scoped navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 1040);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        billingProductTenantRepositoryProvider.overrideWithValue(
          const _FakeBillingProductTenantRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: TenantSelectionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(find.text('Select a tenant first'), findsWidgets);
  });
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
