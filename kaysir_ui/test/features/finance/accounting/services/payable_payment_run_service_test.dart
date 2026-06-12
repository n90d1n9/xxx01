import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/services/payable_payment_run_service.dart';

void main() {
  group('PayablePaymentRunService', () {
    const service = PayablePaymentRunService();

    test('builds a due-date sorted plan for selected open bills', () {
      final laterBill = _bill(
        id: 'later',
        dueDate: DateTime(2026, 6, 20),
        amount: 700,
      );
      final partialBill = _bill(
        id: 'partial',
        dueDate: DateTime(2026, 6, 5),
        amount: 500,
        payments: [Payment(id: 'p1', invoiceId: 'partial', amount: 125)],
      );
      final unselectedBill = _bill(
        id: 'unselected',
        dueDate: DateTime(2026, 6, 1),
        amount: 300,
      );

      final plan = service.plan(
        bills: [laterBill, partialBill, unselectedBill],
        selectedBillIds: {'later', 'partial'},
      );

      expect(plan.billCount, 2);
      expect(plan.items.map((item) => item.billId), ['partial', 'later']);
      expect(plan.totalAmount, 1075);
    });

    test('excludes settled bills from open bills and plans', () {
      final paidBill = _bill(
        id: 'paid',
        dueDate: DateTime(2026, 6, 1),
        amount: 300,
        status: InvoiceStatus.paid,
      );
      final openBill = _bill(
        id: 'open',
        dueDate: DateTime(2026, 6, 2),
        amount: 400,
      );

      expect(service.openBills([paidBill, openBill]).map((bill) => bill.id), [
        'open',
      ]);

      final plan = service.plan(
        bills: [paidBill, openBill],
        selectedBillIds: {'paid', 'open'},
      );

      expect(plan.billCount, 1);
      expect(plan.totalAmount, 400);
    });

    test('selects open bills due on or before the cutoff date', () {
      final selectedIds = service.dueOnOrBefore(
        date: DateTime(2026, 6, 7),
        bills: [
          _bill(id: 'overdue', dueDate: DateTime(2026, 5, 31), amount: 100),
          _bill(id: 'today', dueDate: DateTime(2026, 6, 7), amount: 200),
          _bill(id: 'later', dueDate: DateTime(2026, 6, 8), amount: 300),
        ],
      );

      expect(selectedIds, {'overdue', 'today'});
    });

    test('creates an audit record from a posted payment run', () {
      final bill = _bill(
        id: 'bill-1',
        dueDate: DateTime(2026, 6, 1),
        amount: 800,
      );
      final plan = service.plan(bills: [bill], selectedBillIds: {'bill-1'});

      final record = service.record(
        id: 'run-1',
        reference: 'RUN-001',
        paymentDate: DateTime(2026, 6, 2),
        createdAt: DateTime(2026, 6, 2, 10),
        method: 'bank_transfer',
        plan: plan,
        payments: [
          Payment(
            id: 'payment-1',
            invoiceId: 'bill-1',
            amount: 800,
            paymentDate: DateTime(2026, 6, 2),
          ),
        ],
      );

      expect(record.id, 'run-1');
      expect(record.reference, 'RUN-001');
      expect(record.method, 'bank_transfer');
      expect(record.billCount, 1);
      expect(record.totalAmount, 800);
      expect(record.items.single.paymentId, 'payment-1');
      expect(record.items.single.billReference, 'BILL-bill-1');
    });
  });
}

Invoice _bill({
  required String id,
  required DateTime dueDate,
  required double amount,
  InvoiceStatus status = InvoiceStatus.pending,
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: 'vendor-1',
    vendorName: 'Vendor One',
    invoiceNumber: 'BILL-$id',
    invoiceDate: DateTime(2026, 1, 1),
    dueDate: dueDate,
    amount: amount,
    status: status,
    payments: payments,
  );
}
