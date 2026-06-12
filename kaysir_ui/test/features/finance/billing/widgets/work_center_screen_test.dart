import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_navigation_destination_id.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_account.dart';
import 'package:kaysir/features/finance/billing/models/follow_up_work_item.dart';
import 'package:kaysir/features/finance/billing/repositories/billing_dashboard_repository.dart';
import 'package:kaysir/features/finance/billing/states/billing_dashboard_provider.dart';
import 'package:kaysir/features/finance/billing/states/work_center_provider.dart';
import 'package:kaysir/features/finance/billing/utils/follow_up_work_action_registry.dart';
import 'package:kaysir/features/finance/billing/widgets/work_center_screen.dart';

void main() {
  testWidgets('BillingWorkCenterScreen renders tenant follow-up queue', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        billingDashboardRepositoryProvider.overrideWithValue(
          _FakeBillingDashboardRepository(
            invoices: [
              BillingInvoice(
                id: 'inv-overdue',
                tenantId: 'tenant-test',
                amount: 1200,
                date: DateTime.now().subtract(const Duration(days: 45)),
                status: BillingInvoiceStatus.overdue,
              ),
            ],
          ),
        ),
        billingWorkCenterActionRegistryProvider.overrideWithValue(
          BillingFollowUpWorkActionRegistry.standard().withOverrides([
            BillingFollowUpWorkActionDefinition(
              source: BillingFollowUpWorkSource.collections,
              destination: BillingNavigationDestinationId.invoices,
              label: 'Open receivables desk',
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(selectedBillingTenantIdProvider.notifier).state =
        'tenant-test';

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: BillingWorkCenterScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Billing Work Center'), findsOneWidget);
    expect(find.text('Billing work center'), findsOneWidget);
    expect(find.text('Test Tenant'), findsWidgets);
    expect(find.text('Collect invoice #inv-overdue'), findsOneWidget);
    expect(find.text('Open receivables desk'), findsOneWidget);
    expect(_tileColor(tester, 'workCenter'), const Color(0xFFEFF6FF));
  });
}

Color? _tileColor(WidgetTester tester, String destinationName) {
  final tile = tester.widget<Material>(
    find.byKey(ValueKey('billing-navigation-tile-$destinationName')),
  );

  return tile.color;
}

class _FakeBillingDashboardRepository implements BillingDashboardRepository {
  final List<BillingInvoice> invoices;

  const _FakeBillingDashboardRepository({required this.invoices});

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    return invoices;
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    return BillingDashboardStats(
      totalBilled: 0,
      pendingAmount: 0,
      overdueAmount: 0,
      nextBillingDate: DateTime.utc(2026),
    );
  }

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    return const [
      BillingTenantAccount(
        id: 'tenant-test',
        name: 'Test Tenant',
        logoUrl: '',
        planName: 'Growth',
        currentBalance: 0,
      ),
    ];
  }
}
