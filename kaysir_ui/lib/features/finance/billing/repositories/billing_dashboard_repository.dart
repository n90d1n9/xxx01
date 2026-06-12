import '../models/billing_dashboard_stats.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_account.dart';
import '../models/billing_tenant_preferences.dart';

abstract class BillingDashboardRepository {
  Future<List<BillingTenantAccount>> fetchTenants();

  Future<List<BillingInvoice>> fetchInvoices(String tenantId);

  Future<BillingDashboardStats> fetchStats(String tenantId);
}

class DemoBillingDashboardRepository implements BillingDashboardRepository {
  final Duration latency;
  final DateTime Function() clock;

  const DemoBillingDashboardRepository({
    this.latency = const Duration(seconds: 1),
    DateTime Function()? clock,
  }) : clock = clock ?? DateTime.now;

  @override
  Future<List<BillingTenantAccount>> fetchTenants() async {
    await _wait();
    return const [
      BillingTenantAccount(
        id: 'tenant-001',
        name: 'Acme Corporation',
        logoUrl: '',
        planName: 'Enterprise',
        currentBalance: 4750.50,
      ),
      BillingTenantAccount(
        id: 'tenant-002',
        name: 'Globex Industries',
        logoUrl: '',
        planName: 'Professional',
        currentBalance: 2300.75,
        preferences: BillingTenantPreferences(
          currencySymbol: 'Rp ',
          decimalDigits: 0,
          datePattern: 'dd MMM yyyy',
          paymentTermsDays: 14,
          taxMode: BillingTaxMode.inclusive,
        ),
      ),
      BillingTenantAccount(
        id: 'tenant-003',
        name: 'Stark Enterprises',
        logoUrl: '',
        planName: 'Standard',
        currentBalance: 950.25,
        preferences: BillingTenantPreferences(
          currencySymbol: 'EUR ',
          datePattern: 'yyyy-MM-dd',
          paymentTermsDays: 45,
        ),
      ),
    ];
  }

  @override
  Future<List<BillingInvoice>> fetchInvoices(String tenantId) async {
    await _wait();
    final now = clock();

    return [
      BillingInvoice(
        id: 'inv-101',
        tenantId: tenantId,
        amount: 1500.00,
        date: now.subtract(const Duration(days: 5)),
        status: BillingInvoiceStatus.paid,
      ),
      BillingInvoice(
        id: 'inv-102',
        tenantId: tenantId,
        amount: 1250.50,
        date: now.subtract(const Duration(days: 35)),
        status: BillingInvoiceStatus.paid,
      ),
      BillingInvoice(
        id: 'inv-103',
        tenantId: tenantId,
        amount: 2000.00,
        date: now.add(const Duration(days: 10)),
        status: BillingInvoiceStatus.pending,
      ),
    ];
  }

  @override
  Future<BillingDashboardStats> fetchStats(String tenantId) async {
    await _wait();

    return BillingDashboardStats(
      totalBilled: 5750.50,
      pendingAmount: 2000.00,
      overdueAmount: 0.00,
      nextBillingDate: clock().add(const Duration(days: 10)),
      usageData: const [
        BillingUsagePoint(label: 'Jan', amount: 800),
        BillingUsagePoint(label: 'Feb', amount: 1200),
        BillingUsagePoint(label: 'Mar', amount: 1000),
        BillingUsagePoint(label: 'Apr', amount: 1500),
        BillingUsagePoint(label: 'May', amount: 1750),
      ],
    );
  }

  Future<void> _wait() {
    if (latency == Duration.zero) return Future<void>.value();
    return Future<void>.delayed(latency);
  }
}
