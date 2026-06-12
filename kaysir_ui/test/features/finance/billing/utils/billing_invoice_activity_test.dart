import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_activity.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_activity.dart';

void main() {
  test('buildBillingInvoiceActivityTimeline marks due soon invoices', () {
    final entries = buildBillingInvoiceActivityTimeline(
      _invoice(date: DateTime(2026, 5, 20)),
      preferences: const BillingTenantPreferences(
        currencySymbol: 'Rp ',
        decimalDigits: 0,
        paymentTermsDays: 14,
      ),
      now: DateTime(2026, 5, 31),
    );

    expect(entries, hasLength(3));
    expect(entries[0].title, 'Invoice issued');
    expect(entries[0].description, 'Created for Rp 2,000.');
    expect(entries[1].title, 'Payment due soon');
    expect(entries[1].state, BillingInvoiceActivityState.current);
    expect(entries[1].description, 'Payment is due in 3 days.');
    expect(entries[2].title, 'Prioritize collection');
    expect(entries[2].state, BillingInvoiceActivityState.upcoming);
  });

  test(
    'buildBillingInvoiceActivityTimeline adds reminder for overdue invoices',
    () {
      final entries = buildBillingInvoiceActivityTimeline(
        _invoice(
          date: DateTime(2026, 5, 1),
          status: BillingInvoiceStatus.overdue,
        ),
        preferences: const BillingTenantPreferences(paymentTermsDays: 14),
        now: DateTime(2026, 5, 31),
      );

      expect(
        entries.map((entry) => entry.type),
        containsAll([
          BillingInvoiceActivityType.overdueNotice,
          BillingInvoiceActivityType.reminder,
        ]),
      );
      expect(entries[1].description, 'Payment is 16 days overdue.');
    },
  );

  test('buildBillingInvoiceActivityTimeline keeps closed invoices stable', () {
    final entries = buildBillingInvoiceActivityTimeline(
      _invoice(status: BillingInvoiceStatus.paid),
      now: DateTime(2026, 5, 31),
    );

    expect(entries, hasLength(2));
    expect(entries.last.type, BillingInvoiceActivityType.paymentReceived);
    expect(entries.last.state, BillingInvoiceActivityState.completed);
  });
}

BillingInvoice _invoice({
  DateTime? date,
  BillingInvoiceStatus status = BillingInvoiceStatus.pending,
}) {
  return BillingInvoice(
    id: 'inv-activity',
    tenantId: 'tenant-test',
    amount: 2000,
    date: date ?? DateTime(2026, 5, 10),
    status: status,
  );
}
