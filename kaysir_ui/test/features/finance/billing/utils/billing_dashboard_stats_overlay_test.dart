import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/billing/models/billing_dashboard_stats.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice.dart';
import 'package:kaysir/features/finance/billing/models/billing_invoice_status.dart';
import 'package:kaysir/features/finance/billing/utils/billing_dashboard_stats_overlay.dart';

void main() {
  test('overlayBillingDashboardStats adds open local invoice amounts', () {
    final stats = overlayBillingDashboardStats(
      BillingDashboardStats(
        totalBilled: 1000,
        pendingAmount: 200,
        overdueAmount: 50,
        nextBillingDate: DateTime(2026, 6, 10),
      ),
      invoices: [
        _invoice(
          id: 'inv-pending',
          amount: 300,
          status: BillingInvoiceStatus.pending,
        ),
        _invoice(
          id: 'inv-overdue',
          amount: 90,
          status: BillingInvoiceStatus.overdue,
        ),
        _invoice(
          id: 'inv-voided',
          amount: 1000,
          status: BillingInvoiceStatus.voided,
        ),
      ],
    );

    expect(stats.totalBilled, 1390);
    expect(stats.pendingAmount, 500);
    expect(stats.overdueAmount, 140);
    expect(stats.nextBillingDate, DateTime(2026, 6, 10));
  });
}

BillingInvoice _invoice({
  required String id,
  required double amount,
  required BillingInvoiceStatus status,
}) {
  return BillingInvoice(
    id: id,
    tenantId: 'tenant-test',
    amount: amount,
    date: DateTime(2026, 5, 31),
    status: status,
  );
}
