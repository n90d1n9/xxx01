import '../models/billing_dashboard_metric.dart';
import '../models/billing_dashboard_stats.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';

List<BillingDashboardMetric> billingDashboardMetrics(
  BillingDashboardStats stats, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  String? currencySymbol,
  int? decimalDigits,
  String? datePattern,
}) {
  return List.unmodifiable([
    BillingDashboardMetric(
      kind: BillingDashboardMetricKind.totalBilled,
      title: 'Total Billed',
      value: formatBillingCurrency(
        stats.totalBilled,
        preferences: preferences,
        symbol: currencySymbol,
        decimalDigits: decimalDigits,
      ),
    ),
    BillingDashboardMetric(
      kind: BillingDashboardMetricKind.pending,
      title: 'Pending',
      value: formatBillingCurrency(
        stats.pendingAmount,
        preferences: preferences,
        symbol: currencySymbol,
        decimalDigits: decimalDigits,
      ),
    ),
    BillingDashboardMetric(
      kind: BillingDashboardMetricKind.overdue,
      title: 'Overdue',
      value: formatBillingCurrency(
        stats.overdueAmount,
        preferences: preferences,
        symbol: currencySymbol,
        decimalDigits: decimalDigits,
      ),
    ),
    BillingDashboardMetric(
      kind: BillingDashboardMetricKind.nextBilling,
      title: 'Next Billing',
      value: formatBillingDate(
        stats.nextBillingDate,
        preferences: preferences,
        pattern: datePattern,
      ),
    ),
  ]);
}
