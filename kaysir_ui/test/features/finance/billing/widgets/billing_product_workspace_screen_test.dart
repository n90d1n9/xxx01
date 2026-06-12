import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_catalog_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_cart_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_product_workspace_screen.dart';

void main() {
  testWidgets('BillingScreen keeps cart visible on wide workspaces', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 820);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        billingProductCatalogRepositoryProvider.overrideWithValue(
          const _FakeBillingProductCatalogRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    const tenant = Tenant(id: 'tenant-a', name: 'Acme Corp', logoUrl: '');
    const product = Product(
      id: 'plan',
      name: 'Business Plan',
      price: 79.99,
      category: 'Subscription',
    );

    container.read(currentTenantProvider.notifier).state = tenant;
    container.read(cartProvider.notifier).addToCart(product, tenant.id);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Products & Services'), findsOneWidget);
    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Proceed to Checkout'), findsOneWidget);
    expect(find.byTooltip('Open cart'), findsNothing);
    expect(find.text('Products & checkout'), findsOneWidget);
    expect(find.text('Cart & checkout'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Issue outbox'), findsOneWidget);
  });

  testWidgets('BillingScreen opens the cart checkout destination', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 820);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        billingProductCatalogRepositoryProvider.overrideWithValue(
          const _FakeBillingProductCatalogRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    const tenant = Tenant(id: 'tenant-a', name: 'Acme Corp', logoUrl: '');
    container.read(currentTenantProvider.notifier).state = tenant;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: BillingScreen(
            initialDestination: BillingNavigationDestinationId.cartCheckout,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your Cart'), findsOneWidget);
    expect(_tileColor(tester, 'cartCheckout'), const Color(0xFFEFF6FF));
  });

  testWidgets('BillingScreen carries tenant context into invoice navigation', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 820);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        billingProductCatalogRepositoryProvider.overrideWithValue(
          const _FakeBillingProductCatalogRepository(),
        ),
        billingDashboardRepositoryProvider.overrideWithValue(
          const _FakeBillingDashboardRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    const tenant = Tenant(id: 'tenant-a', name: 'Acme Corp', logoUrl: '');
    container.read(currentTenantProvider.notifier).state = tenant;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Browse and filter receivables'));
    await tester.pumpAndSettle();

    expect(container.read(selectedBillingTenantIdProvider), 'tenant-a');
    expect(find.text('Billing Dashboard'), findsOneWidget);
    expect(_tileColor(tester, 'invoices'), const Color(0xFFEFF6FF));
  });

  testWidgets('BillingScreen filters checkout navigation by tenant domain', (
    tester,
  ) async {
    final view = tester.view;
    view.physicalSize = const Size(1200, 820);
    view.devicePixelRatio = 1;
    addTearDown(() {
      view.resetPhysicalSize();
      view.resetDevicePixelRatio();
    });

    final container = ProviderContainer(
      overrides: [
        billingProductCatalogRepositoryProvider.overrideWithValue(
          const _FakeBillingProductCatalogRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    const tenant = Tenant(
      id: 'tenant-a',
      name: 'Acme Corp',
      logoUrl: '',
      preferences: BillingTenantPreferences(businessDomain: 'construction'),
    );
    container.read(currentTenantProvider.notifier).state = tenant;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Products & Services'), findsOneWidget);
    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);
    expect(find.text('Cart & checkout'), findsNothing);
    expect(_tileColor(tester, 'dashboard'), const Color(0xFFEFF6FF));

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('billing-quick-action-invoices')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('billing-quick-action-cartCheckout')),
      findsNothing,
    );
  });
}

class _FakeBillingProductCatalogRepository
    implements BillingProductCatalogRepository {
  const _FakeBillingProductCatalogRepository();

  @override
  Future<List<Product>> fetchProducts(String tenantId) async {
    return const [
      Product(
        id: 'plan',
        name: 'Business Plan',
        price: 79.99,
        category: 'Subscription',
      ),
      Product(
        id: 'support',
        name: 'Premium Support',
        price: 29.99,
        category: 'Service',
      ),
    ];
  }
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  const _FakeBillingDashboardRepository();

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [
      BillingTenantAccount(
        id: 'tenant-a',
        name: 'Acme Corp',
        logoUrl: '',
        planName: 'Checkout',
        currentBalance: 0,
      ),
    ];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return [
      BillingInvoice(
        id: 'inv-a',
        tenantId: tenantId,
        amount: 100,
        date: DateTime(2026, 6, 1),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 100,
      pendingAmount: 100,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
    );
  }
}

Color? _tileColor(WidgetTester tester, String destinationName) {
  final tile = tester.widget<Material>(
    find.byKey(ValueKey('billing-navigation-tile-$destinationName')),
  );

  return tile.color;
}
