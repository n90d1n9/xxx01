enum BillingCashForecastBucketKind {
  overdueRecovery,
  next7Days,
  next30Days,
  later,
}

enum BillingCashForecastConfidence { low, medium, high }

class BillingCashForecastBucket {
  final BillingCashForecastBucketKind kind;
  final String label;
  final String amountText;
  final String projectedAmountText;
  final double amount;
  final double projectedAmount;
  final double share;
  final int count;
  final BillingCashForecastConfidence confidence;

  const BillingCashForecastBucket({
    required this.kind,
    required this.label,
    required this.amountText,
    required this.projectedAmountText,
    required this.amount,
    required this.projectedAmount,
    required this.share,
    required this.count,
    required this.confidence,
  });

  bool get hasInvoices => count > 0;
}

class BillingCashForecastSummary {
  final List<BillingCashForecastBucket> buckets;
  final String headline;
  final String supportingText;
  final String openAmountText;
  final String projectedAmountText;
  final double openAmount;
  final double projectedAmount;
  final int openCount;

  const BillingCashForecastSummary({
    required this.buckets,
    required this.headline,
    required this.supportingText,
    required this.openAmountText,
    required this.projectedAmountText,
    required this.openAmount,
    required this.projectedAmount,
    required this.openCount,
  });

  bool get hasOpenReceivables => openCount > 0;
}
