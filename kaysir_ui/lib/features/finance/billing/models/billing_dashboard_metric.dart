enum BillingDashboardMetricKind { totalBilled, pending, overdue, nextBilling }

class BillingDashboardMetric {
  final BillingDashboardMetricKind kind;
  final String title;
  final String value;

  const BillingDashboardMetric({
    required this.kind,
    required this.title,
    required this.value,
  });
}
