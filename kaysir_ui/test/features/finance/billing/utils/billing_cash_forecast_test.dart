import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_cash_forecast.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_cash_forecast.dart';

void main() {
  test('summarizeBillingCashForecast buckets open invoices by timing', () {
    final summary = summarizeBillingCashForecast(
      [
        _invoice(id: 'paid', amount: 900, status: BillingInvoiceStatus.paid),
        _invoice(id: 'overdue', amount: 1000, date: DateTime(2026, 6, 1)),
        _invoice(id: 'next-7', amount: 800, date: DateTime(2026, 6, 20)),
        _invoice(id: 'next-30', amount: 500, date: DateTime(2026, 7, 5)),
        _invoice(id: 'later', amount: 700, date: DateTime(2026, 8, 1)),
      ],
      preferences: const BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        paymentTermsDays: 14,
      ),
      now: DateTime(2026, 6, 30),
    );

    expect(summary.openCount, 4);
    expect(summary.openAmount, 3000);
    expect(summary.projectedAmount, 1865);
    expect(summary.projectedAmountText, 'Rp 1,865');
    expect(summary.headline, 'Rp 1,865 projected from open invoices');

    final overdue = summary.buckets.byKind(
      BillingCashForecastBucketKind.overdueRecovery,
    );
    final next7 = summary.buckets.byKind(
      BillingCashForecastBucketKind.next7Days,
    );
    final next30 = summary.buckets.byKind(
      BillingCashForecastBucketKind.next30Days,
    );
    final later = summary.buckets.byKind(BillingCashForecastBucketKind.later);

    expect(overdue.projectedAmountText, 'Rp 450');
    expect(next7.confidence, BillingCashForecastConfidence.high);
    expect(next30.projectedAmount, 350);
    expect(later.projectedAmountText, 'Rp 385');
  });

  test('summarizeBillingCashForecast ignores closed invoices', () {
    final summary = summarizeBillingCashForecast([
      _invoice(id: 'paid', status: BillingInvoiceStatus.paid),
      _invoice(id: 'voided', status: BillingInvoiceStatus.voided),
    ], now: DateTime(2026, 6, 30));

    expect(summary.hasOpenReceivables, isFalse);
    expect(summary.projectedAmount, 0);
    expect(summary.headline, 'No forecastable receivables');
    expect(summary.buckets.every((bucket) => bucket.count == 0), isTrue);
  });
}

BillingInvoice _invoice({
  required String id,
  double amount = 1000,
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: date ?? DateTime(2026, 6, 1),
    status: status,
  );
}
