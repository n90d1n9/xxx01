import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_aging_bucket.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_aging_buckets.dart';

void main() {
  test(
    'summarizeBillingInvoiceAgingBuckets groups open receivables by risk',
    () {
      final summary = summarizeBillingInvoiceAgingBuckets(
        [
          _invoice(id: 'paid', status: BillingInvoiceStatus.paid, amount: 900),
          _invoice(id: 'old-overdue', date: DateTime(2026, 5, 1), amount: 1000),
          _invoice(
            id: 'recent-overdue',
            date: DateTime(2026, 6, 10),
            amount: 800,
          ),
          _invoice(id: 'due-soon', date: DateTime(2026, 6, 20), amount: 500),
          _invoice(id: 'future', date: DateTime(2026, 6, 25), amount: 700),
        ],
        preferences: const BillingTenantPreferences(
          currencySymbol: 'Rp ',
          decimalDigits: 0,
          paymentTermsDays: 14,
        ),
        now: DateTime(2026, 6, 30),
      );

      expect(summary.risk, BillingInvoiceAgingRisk.high);
      expect(summary.headline, 'Collection risk is high');
      expect(summary.openCount, 4);
      expect(summary.openAmount, 3000);

      final severe = summary.buckets.byKind(
        BillingInvoiceAgingBucketKind.overdue31Plus,
      );
      final recent = summary.buckets.byKind(
        BillingInvoiceAgingBucketKind.overdue1To30,
      );
      final dueSoon = summary.buckets.byKind(
        BillingInvoiceAgingBucketKind.dueSoon,
      );
      final future = summary.buckets.byKind(
        BillingInvoiceAgingBucketKind.futureDue,
      );

      expect(severe.count, 1);
      expect(severe.amountText, 'Rp 1,000');
      expect(recent.amount, 800);
      expect(dueSoon.count, 1);
      expect(future.amountText, 'Rp 700');
    },
  );

  test('summarizeBillingInvoiceAgingBuckets ignores closed invoices', () {
    final summary = summarizeBillingInvoiceAgingBuckets([
      _invoice(status: BillingInvoiceStatus.paid),
      _invoice(status: BillingInvoiceStatus.voided),
    ], now: DateTime(2026, 6, 30));

    expect(summary.risk, BillingInvoiceAgingRisk.settled);
    expect(summary.hasOpenReceivables, isFalse);
    expect(summary.buckets.every((bucket) => bucket.count == 0), isTrue);
  });
}

BillingInvoice _invoice({
  String id = 'invoice',
  double amount = 1000,
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: date ?? DateTime(2026, 5, 1),
    status: status,
  );
}
