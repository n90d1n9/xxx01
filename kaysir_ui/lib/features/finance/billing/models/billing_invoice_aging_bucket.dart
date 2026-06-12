enum BillingInvoiceAgingBucketKind {
  overdue31Plus,
  overdue1To30,
  dueSoon,
  futureDue,
}

enum BillingInvoiceAgingRisk { settled, low, medium, high }

class BillingInvoiceAgingBucket {
  final BillingInvoiceAgingBucketKind kind;
  final String label;
  final String amountText;
  final int count;
  final double amount;
  final double share;

  const BillingInvoiceAgingBucket({
    required this.kind,
    required this.label,
    required this.amountText,
    required this.count,
    required this.amount,
    required this.share,
  });

  bool get hasInvoices => count > 0;
}

class BillingInvoiceAgingBucketSummary {
  final List<BillingInvoiceAgingBucket> buckets;
  final BillingInvoiceAgingRisk risk;
  final String headline;
  final String supportingText;
  final double openAmount;
  final int openCount;

  const BillingInvoiceAgingBucketSummary({
    required this.buckets,
    required this.risk,
    required this.headline,
    required this.supportingText,
    required this.openAmount,
    required this.openCount,
  });

  bool get hasOpenReceivables => openCount > 0;
}
