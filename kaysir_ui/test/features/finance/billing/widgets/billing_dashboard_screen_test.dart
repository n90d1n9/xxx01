import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_filter.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_product.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_product_catalog_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/billing_product_catalog_provider.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_dashboard_screen.dart';
import 'package:kaysir/features/finance/billing/widgets/billing_navigation_destination.dart';

void main() {
  testWidgets('BillingDashboardScreen honors an initial invoice destination', (
    tester,
  ) async {
    final container = _container(tester);

    container.read(selectedBillingTenantIdProvider.notifier).state =
        'tenant-test';
    container
        .read(billingInvoiceFilterProvider('tenant-test').notifier)
        .state = const BillingInvoiceFilter(
      status: BillingInvoiceStatus.overdue,
      sort: BillingInvoiceSortOption.amountLowToHigh,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: BillingDashboardScreen(
            initialDestination: BillingNavigationDestinationId.invoices,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final filter = container.read(billingInvoiceFilterProvider('tenant-test'));
    expect(filter.status, isNull);
    expect(filter.sort, BillingInvoiceSortOption.newestFirst);
    expect(_tileColor(tester, 'invoices'), const Color(0xFFEFF6FF));
  });

  testWidgets('BillingDashboardScreen resets filters from invoice navigation', (
    tester,
  ) async {
    final container = _container(tester);

    container.read(selectedBillingTenantIdProvider.notifier).state =
        'tenant-test';
    container
        .read(billingInvoiceFilterProvider('tenant-test').notifier)
        .state = const BillingInvoiceFilter(
      status: BillingInvoiceStatus.pending,
      sort: BillingInvoiceSortOption.amountHighToLow,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(_tileColor(tester, 'dashboard'), const Color(0xFFEFF6FF));
    expect(_tileColor(tester, 'invoices'), Colors.transparent);

    await tester.tap(find.text('Browse and filter receivables'));
    await tester.pumpAndSettle();

    final filter = container.read(billingInvoiceFilterProvider('tenant-test'));
    expect(filter.status, isNull);
    expect(filter.sort, BillingInvoiceSortOption.newestFirst);
    expect(_tileColor(tester, 'dashboard'), Colors.transparent);
    expect(_tileColor(tester, 'invoices'), const Color(0xFFEFF6FF));
  });

  testWidgets(
    'BillingDashboardScreen routes quick actions through navigation',
    (tester) async {
      final container = _container(tester);

      container.read(selectedBillingTenantIdProvider.notifier).state =
          'tenant-test';
      container
          .read(billingInvoiceFilterProvider('tenant-test').notifier)
          .state = const BillingInvoiceFilter(
        status: BillingInvoiceStatus.overdue,
        sort: BillingInvoiceSortOption.amountLowToHigh,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('billing-quick-action-invoices')),
      );
      await tester.pumpAndSettle();

      final filter = container.read(
        billingInvoiceFilterProvider('tenant-test'),
      );
      expect(filter.status, isNull);
      expect(filter.sort, BillingInvoiceSortOption.newestFirst);
      expect(_tileColor(tester, 'invoices'), const Color(0xFFEFF6FF));
    },
  );

  testWidgets('BillingDashboardScreen opens cart checkout from navigation', (
    tester,
  ) async {
    final container = _container(tester);

    container.read(selectedBillingTenantIdProvider.notifier).state =
        'tenant-test';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cart & checkout'));
    await tester.pumpAndSettle();

    expect(container.read(currentTenantProvider)?.id, 'tenant-test');
    expect(find.text('Products & Services'), findsOneWidget);
    expect(_tileColor(tester, 'cartCheckout'), const Color(0xFFEFF6FF));
  });

  testWidgets('BillingDashboardScreen blocks tenant-scoped navigation', (
    tester,
  ) async {
    final container = _container(
      tester,
      repository: const _EmptyBillingDashboardRepository(),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Products & checkout'));
    await tester.pump();

    expect(find.text('Select a tenant first'), findsWidgets);
  });

  testWidgets('BillingDashboardScreen filters navigation by tenant domain', (
    tester,
  ) async {
    final container = _container(
      tester,
      repository: const _FakeBillingDashboardRepository(
        preferences: BillingTenantPreferences(businessDomain: 'construction'),
      ),
    );

    container.read(selectedBillingTenantIdProvider.notifier).state =
        'tenant-test';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingDashboardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Invoices'), findsOneWidget);
    expect(find.text('Create invoice'), findsOneWidget);
    expect(find.text('Products & checkout'), findsNothing);
    expect(find.text('Cart & checkout'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('billing-quick-action-menu')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('billing-quick-action-invoices')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('billing-quick-action-productWorkspace')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('billing-quick-action-cartCheckout')),
      findsNothing,
    );
  });

  testWidgets(
    'BillingDashboardScreen syncs active navigation while scrolling',
    (tester) async {
      final container = _container(tester);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: BillingDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(_tileColor(tester, 'dashboard'), const Color(0xFFEFF6FF));

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      await tester.pumpAndSettle();

      expect(_tileColor(tester, 'dashboard'), Colors.transparent);
      expect(_tileColor(tester, 'invoices'), const Color(0xFFEFF6FF));
    },
  );
}

ProviderContainer _container(
  WidgetTester tester, {
  BillingDashboardRepository repository =
      const _FakeBillingDashboardRepository(),
}) {
  tester.view.physicalSize = const Size(1280, 1040);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      billingDashboardRepositoryProvider.overrideWithValue(repository),
      billingProductCatalogRepositoryProvider.overrideWithValue(
        const _FakeBillingProductCatalogRepository(),
      ),
    ],
  );
  addTearDown(container.dispose);

  return container;
}

Color? _tileColor(WidgetTester tester, String destinationName) {
  final tile = tester.widget<Material>(
    find.byKey(ValueKey('billing-navigation-tile-$destinationName')),
  );

  return tile.color;
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final BillingTenantPreferences preferences;

  const _FakeBillingDashboardRepository({
    this.preferences = const BillingTenantPreferences(),
  });

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return [
      BillingTenantAccount(
        id: 'tenant-test',
        name: 'Test Tenant',
        logoUrl: '',
        planName: 'Enterprise',
        currentBalance: 4750,
        preferences: preferences,
      ),
    ];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return [
      BillingInvoice(
        id: 'inv-paid',
        tenantId: tenantId,
        amount: 1500,
        date: DateTime(2026, 5, 31),
        status: BillingInvoiceStatus.paid,
      ),
      BillingInvoice(
        id: 'inv-pending',
        tenantId: tenantId,
        amount: 2000,
        date: DateTime(2026, 6, 10),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 3500,
      pendingAmount: 2000,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 10),
    );
  }
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
    ];
  }
}

class _EmptyBillingDashboardRepository implements BillingDashboardRepository {
  const _EmptyBillingDashboardRepository();

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return const [];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 0,
      pendingAmount: 0,
      overdueAmount: 0,
      nextBillingDate: DateTime(2026, 6, 1),
    );
  }
}
