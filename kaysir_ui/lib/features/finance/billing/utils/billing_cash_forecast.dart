import '../models/billing_cash_forecast.dart';
import '../models/billing_invoice.dart';
import '../models/billing_invoice_status.dart';
import '../models/billing_tenant_preferences.dart';
import 'billing_formatters.dart';
import 'billing_invoice_aging.dart';
import 'billing_invoice_terms.dart';

BillingCashForecastSummary summarizeBillingCashForecast(
  Iterable<BillingInvoice> invoices, {
  BillingTenantPreferences preferences = const BillingTenantPreferences(),
  DateTime? now,
}) {
  final currentTime = now ?? DateTime.now();
  final counts = {
    for (final kind in BillingCashForecastBucketKind.values) kind: 0,
  };
  final amounts = {
    for (final kind in BillingCashForecastBucketKind.values) kind: 0.0,
  };

  for (final invoice in invoices) {
    if (!invoice.status.isCollectable) continue;

    final dueDate = billingInvoiceDueDate(invoice, preferences: preferences);
    final aging = BillingInvoiceAging(
      status: invoice.status,
      dueDate: dueDate,
      now: currentTime,
    );
    final kind = _bucketKindFor(invoice.status, aging.daysUntilDue);

    counts[kind] = (counts[kind] ?? 0) + 1;
    amounts[kind] = (amounts[kind] ?? 0) + invoice.amount;
  }

  final openAmount = amounts.values.fold<double>(0, (sum, item) => sum + item);
  final buckets = BillingCashForecastBucketKind.values
      .map((kind) {
        final amount = amounts[kind] ?? 0;
        final projectedAmount = amount * kind.recoveryWeight;
        return BillingCashForecastBucket(
          kind: kind,
          label: kind.label,
          amountText: formatBillingCurrency(amount, preferences: preferences),
          projectedAmountText: formatBillingCurrency(
            projectedAmount,
            preferences: preferences,
          ),
          amount: amount,
          projectedAmount: projectedAmount,
          share: openAmount == 0 ? 0 : amount / openAmount,
          count: counts[kind] ?? 0,
          confidence: kind.confidence,
        );
      })
      .toList(growable: false);
  final projectedAmount = buckets.fold<double>(
    0,
    (sum, bucket) => sum + bucket.projectedAmount,
  );
  final openCount = counts.values.fold<int>(0, (sum, count) => sum + count);
  final projectedAmountText = formatBillingCurrency(
    projectedAmount,
    preferences: preferences,
  );
  final openAmountText = formatBillingCurrency(
    openAmount,
    preferences: preferences,
  );

  return BillingCashForecastSummary(
    buckets: buckets,
    headline:
        openCount == 0
            ? 'No forecastable receivables'
            : '$projectedAmountText projected from open invoices',
    supportingText:
        openCount == 0
            ? 'Closed and non-collectable invoices are excluded from forecast.'
            : '$openAmountText is open across $openCount ${_invoiceNoun(openCount)}.',
    openAmountText: openAmountText,
    projectedAmountText: projectedAmountText,
    openAmount: openAmount,
    projectedAmount: projectedAmount,
    openCount: openCount,
  );
}

BillingCashForecastBucketKind _bucketKindFor(
  BillingInvoiceStatus status,
  int daysUntilDue,
) {
  if (status == BillingInvoiceStatus.overdue || daysUntilDue < 0) {
    return BillingCashForecastBucketKind.overdueRecovery;
  }
  if (daysUntilDue <= 7) return BillingCashForecastBucketKind.next7Days;
  if (daysUntilDue <= 30) return BillingCashForecastBucketKind.next30Days;
  return BillingCashForecastBucketKind.later;
}

extension BillingCashForecastBucketKindX on BillingCashForecastBucketKind {
  String get label {
    switch (this) {
      case BillingCashForecastBucketKind.overdueRecovery:
        return 'Overdue recovery';
      case BillingCashForecastBucketKind.next7Days:
        return 'Next 7 days';
      case BillingCashForecastBucketKind.next30Days:
        return '8-30 days';
      case BillingCashForecastBucketKind.later:
        return 'Later';
    }
  }

  double get recoveryWeight {
    switch (this) {
      case BillingCashForecastBucketKind.overdueRecovery:
        return 0.45;
      case BillingCashForecastBucketKind.next7Days:
        return 0.85;
      case BillingCashForecastBucketKind.next30Days:
        return 0.7;
      case BillingCashForecastBucketKind.later:
        return 0.55;
    }
  }

  BillingCashForecastConfidence get confidence {
    switch (this) {
      case BillingCashForecastBucketKind.overdueRecovery:
        return BillingCashForecastConfidence.low;
      case BillingCashForecastBucketKind.next7Days:
        return BillingCashForecastConfidence.high;
      case BillingCashForecastBucketKind.next30Days:
        return BillingCashForecastConfidence.medium;
      case BillingCashForecastBucketKind.later:
        return BillingCashForecastConfidence.medium;
    }
  }
}

extension BillingCashForecastConfidenceX on BillingCashForecastConfidence {
  String get label {
    switch (this) {
      case BillingCashForecastConfidence.low:
        return 'Low confidence';
      case BillingCashForecastConfidence.medium:
        return 'Medium confidence';
      case BillingCashForecastConfidence.high:
        return 'High confidence';
    }
  }
}

extension BillingCashForecastBucketListX on List<BillingCashForecastBucket> {
  BillingCashForecastBucket byKind(BillingCashForecastBucketKind kind) {
    return firstWhere((bucket) => bucket.kind == kind);
  }
}

String _invoiceNoun(int count) {
  return count == 1 ? 'invoice' : 'invoices';
}
