import '../models/billing_invoice.dart';
import '../models/billing_invoice_aging_bucket.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';
import 'billing_invoice_aging.dart';
import 'billing_invoice_terms.dart';

BillingInvoiceAgingBucketSummary summarizeBillingInvoiceAgingBuckets(
  Iterable<BillingInvoice> invoices, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  final counts = {
    for (final kind in BillingInvoiceAgingBucketKind.values) kind: 0,
  };
  final amounts = {
    for (final kind in BillingInvoiceAgingBucketKind.values) kind: 0.0,
  };

  for (final invoice in invoices) {
    if (!invoice.status.isCollectable) continue;

    final dueDate = billingInvoiceDueDate(invoice, preferences: preferences);
    final aging = BillingInvoiceAging(
      status: invoice.status,
      dueDate: dueDate,
      now: currentTime,
    );
    final kind = _bucketKindFor(aging.daysUntilDue);

    counts[kind] = (counts[kind] ?? 0) + 1;
    amounts[kind] = (amounts[kind] ?? 0) + invoice.amount;
  }

  final openCount = counts.values.fold<int>(0, (sum, count) => sum + count);
  final openAmount = amounts.values.fold<double>(
    0,
    (sum, amount) => sum + amount,
  );
  final buckets = BillingInvoiceAgingBucketKind.values
      .map((kind) {
        final amount = amounts[kind] ?? 0;
        return BillingInvoiceAgingBucket(
          kind: kind,
          label: kind.label,
          amountText: formatBillingCurrency(amount, preferences: preferences),
          count: counts[kind] ?? 0,
          amount: amount,
          share: openAmount == 0 ? 0 : amount / openAmount,
        );
      })
      .toList(growable: false);

  final risk = _riskFor(buckets);
  return BillingInvoiceAgingBucketSummary(
    buckets: buckets,
    risk: risk,
    headline: _headlineFor(risk, openCount: openCount),
    supportingText: _supportingTextFor(
      risk,
      buckets: buckets,
      openAmount: openAmount,
      preferences: preferences,
    ),
    openAmount: openAmount,
    openCount: openCount,
  );
}

BillingInvoiceAgingBucketKind _bucketKindFor(int daysUntilDue) {
  if (daysUntilDue < -30) return BillingInvoiceAgingBucketKind.overdue31Plus;
  if (daysUntilDue < 0) return BillingInvoiceAgingBucketKind.overdue1To30;
  if (daysUntilDue <= 7) return BillingInvoiceAgingBucketKind.dueSoon;
  return BillingInvoiceAgingBucketKind.futureDue;
}

BillingInvoiceAgingRisk _riskFor(List<BillingInvoiceAgingBucket> buckets) {
  final severeOverdue = buckets.byKind(
    BillingInvoiceAgingBucketKind.overdue31Plus,
  );
  final overdue = buckets.byKind(BillingInvoiceAgingBucketKind.overdue1To30);
  final dueSoon = buckets.byKind(BillingInvoiceAgingBucketKind.dueSoon);

  if (severeOverdue.hasInvoices) return BillingInvoiceAgingRisk.high;
  if (overdue.hasInvoices) return BillingInvoiceAgingRisk.medium;
  if (dueSoon.hasInvoices) return BillingInvoiceAgingRisk.low;
  final hasOpen = buckets.any((bucket) => bucket.hasInvoices);
  return hasOpen
      ? BillingInvoiceAgingRisk.low
      : BillingInvoiceAgingRisk.settled;
}

String _headlineFor(BillingInvoiceAgingRisk risk, {required int openCount}) {
  switch (risk) {
    case BillingInvoiceAgingRisk.high:
      return 'Collection risk is high';
    case BillingInvoiceAgingRisk.medium:
      return 'Overdue invoices need follow-up';
    case BillingInvoiceAgingRisk.low:
      return openCount == 0
          ? 'No open receivables'
          : '$openCount open ${_invoiceNoun(openCount)} aging normally';
    case BillingInvoiceAgingRisk.settled:
      return 'No open receivables';
  }
}

String _supportingTextFor(
  BillingInvoiceAgingRisk risk, {
  required List<BillingInvoiceAgingBucket> buckets,
  required double openAmount,
  required BillingTenantPreferences preferences,
}) {
  final openAmountText = formatBillingCurrency(
    openAmount,
    preferences: preferences,
  );

  switch (risk) {
    case BillingInvoiceAgingRisk.high:
      final bucket = buckets.byKind(
        BillingInvoiceAgingBucketKind.overdue31Plus,
      );
      return '${bucket.amountText} is more than 30 days overdue.';
    case BillingInvoiceAgingRisk.medium:
      final bucket = buckets.byKind(BillingInvoiceAgingBucketKind.overdue1To30);
      return '${bucket.amountText} is overdue and should be prioritized.';
    case BillingInvoiceAgingRisk.low:
      if (openAmount == 0) {
        return 'Closed and settled invoices are excluded from aging.';
      }
      return '$openAmountText is open across active collection windows.';
    case BillingInvoiceAgingRisk.settled:
      return 'Closed and settled invoices are excluded from aging.';
  }
}

extension BillingInvoiceAgingBucketKindX on BillingInvoiceAgingBucketKind {
  String get label {
    switch (this) {
      case BillingInvoiceAgingBucketKind.overdue31Plus:
        return '31+ overdue';
      case BillingInvoiceAgingBucketKind.overdue1To30:
        return '1-30 overdue';
      case BillingInvoiceAgingBucketKind.dueSoon:
        return 'Due soon';
      case BillingInvoiceAgingBucketKind.futureDue:
        return 'Future due';
    }
  }
}

extension BillingInvoiceAgingBucketListX on List<BillingInvoiceAgingBucket> {
  BillingInvoiceAgingBucket byKind(BillingInvoiceAgingBucketKind kind) {
    return firstWhere((bucket) => bucket.kind == kind);
  }
}

String _invoiceNoun(int count) {
  return count == 1 ? 'invoice' : 'invoices';
}
