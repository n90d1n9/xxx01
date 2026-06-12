import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_draft.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/models/billing_tenant_preferences.dart';
import 'package:kaysir/features/finance/billing/utils/billing_invoice_terms.dart';

void main() {
  test('billingInvoiceDueDate applies tenant payment terms', () {
    final invoice = BillingInvoice(
      id: 'inv-1',
      tenantId: 'tenant-a',
      amount: 100,
      date: DateTime(2026, 6, 10),
      status: BillingInvoiceStatus.pending,
    );

    expect(
      billingInvoiceDueDate(
        invoice,
        preferences: const BillingTenantPreferences(paymentTermsDays: 14),
      ),
      DateTime(2026, 6, 24),
    );
  });

  test('billingInvoiceDraftDueDate applies tenant payment terms', () {
    final draft = BillingInvoiceDraft(
      tenantId: 'tenant-a',
      amount: 100,
      issueDate: DateTime(2026, 6, 10),
    );

    expect(
      billingInvoiceDraftDueDate(
        draft,
        preferences: const BillingTenantPreferences(paymentTermsDays: 7),
      ),
      DateTime(2026, 6, 17),
    );
  });

  test('billingIssueDueDate calculates from a raw issue date', () {
    expect(
      billingIssueDueDate(
        DateTime(2026, 6, 10),
        preferences: const BillingTenantPreferences(paymentTermsDays: 45),
      ),
      DateTime(2026, 7, 25),
    );
  });
}
