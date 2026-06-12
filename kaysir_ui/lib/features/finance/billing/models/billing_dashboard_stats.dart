class BillingUsagePoint {
  final String label;
  final double amount;

  const BillingUsagePoint({required this.label, required this.amount});
}

class BillingDashboardStats {
  final double totalBilled;
  final double pendingAmount;
  final double overdueAmount;
  final DateTime nextBillingDate;
  final List<BillingUsagePoint> usageData;

  BillingDashboardStats({
    required this.totalBilled,
    required this.pendingAmount,
    required this.overdueAmount,
    required this.nextBillingDate,
    Iterable<BillingUsagePoint> usageData = const [],
  }) : usageData = List.unmodifiable(usageData);
}
