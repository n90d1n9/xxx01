import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_metric.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_dashboard_metrics.dart';

void main() {
  test('billingDashboardMetrics builds display-ready dashboard metrics', () {
    final metrics = billingDashboardMetrics(_stats());

    expect(metrics.map((metric) => metric.kind), [
      BillingDashboardMetricKind.totalBilled,
      BillingDashboardMetricKind.pending,
      BillingDashboardMetricKind.overdue,
      BillingDashboardMetricKind.nextBilling,
    ]);
    expect(metrics.map((metric) => metric.title), [
      'Total Billed',
      'Pending',
      'Overdue',
      'Next Billing',
    ]);
    expect(metrics.map((metric) => metric.value), [
      r'$5,750.50',
      r'$2,000.00',
      r'$90.00',
      'Jun 10, 2026',
    ]);
  });

  test(
    'billingDashboardMetrics supports alternate currency and date format',
    () {
      final metrics = billingDashboardMetrics(
        _stats(),
        currencySymbol: 'Rp ',
        datePattern: 'yyyy-MM-dd',
      );

      expect(metrics.first.value, 'Rp 5,750.50');
      expect(metrics.last.value, '2026-06-10');
    },
  );

  test('billingDashboardMetrics supports tenant billing preferences', () {
    final metrics = billingDashboardMetrics(
      _stats(),
      preferences: const BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        datePattern: 'yyyy-MM-dd',
      ),
    );

    expect(metrics.first.value, 'Rp 5,751');
    expect(metrics.last.value, '2026-06-10');
  });
}

BillingDashboardStats _stats() {
  return BillingDashboardStats(
    totalBilled: 5750.50,
    pendingAmount: 2000,
    overdueAmount: 90,
    nextBillingDate: DateTime(2026, 6, 10),
  );
}
