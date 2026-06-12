import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_attention.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_attention.dart';

void main() {
  test('summarizeBillingInvoiceAttention prioritizes overdue invoices', () {
    final summary = summarizeBillingInvoiceAttention(
      [
        _invoice(
          id: 'paid',
          amount: 500,
          date: DateTime(2026, 5, 2),
          status: BillingInvoiceStatus.paid,
        ),
        _invoice(id: 'overdue', amount: 1200, date: DateTime(2026, 5, 1)),
        _invoice(id: 'due-soon', amount: 800, date: DateTime(2026, 5, 20)),
      ],
      preferences: const BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        paymentTermsDays: 14,
      ),
      now: DateTime(2026, 5, 31),
    );

    expect(summary.level, BillingInvoiceAttentionLevel.urgent);
    expect(summary.headline, '1 overdue invoice needs follow-up');
    expect(summary.overdueCount, 1);
    expect(summary.dueSoonCount, 1);
    expect(summary.openCount, 2);
    expect(summary.overdueAmount, 1200);
    expect(summary.dueSoonAmount, 800);
    expect(summary.openAmount, 2000);
    expect(summary.items.map((item) => item.title), [
      'Overdue',
      'Due soon',
      'Open balance',
    ]);
    expect(summary.items.last.value, 'Rp 2,000');
  });

  test('summarizeBillingInvoiceAttention reports settled receivables', () {
    final summary = summarizeBillingInvoiceAttention([
      _invoice(status: BillingInvoiceStatus.paid),
      _invoice(status: BillingInvoiceStatus.voided),
    ], now: DateTime(2026, 5, 31));

    expect(summary.level, BillingInvoiceAttentionLevel.settled);
    expect(summary.headline, 'Receivables are settled');
    expect(summary.hasOpenReceivables, isFalse);
    expect(summary.items.every((item) => item.count == 0), isTrue);
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
