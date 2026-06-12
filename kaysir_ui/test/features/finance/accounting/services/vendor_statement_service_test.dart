import 'package:flutter_test/flutter_test.dart';
import 'package:kaysir/features/finance/accounting/models/invoice.dart';
import 'package:kaysir/features/finance/accounting/models/payment.dart';
import 'package:kaysir/features/finance/accounting/models/vendor.dart';
import 'package:kaysir/features/finance/accounting/models/vendor_statement.dart';
import 'package:kaysir/features/finance/accounting/services/vendor_statement_service.dart';

void main() {
  group('VendorStatementService', () {
    const service = VendorStatementService();
    final asOf = DateTime(2026, 5, 30);
    final vendor = Vendor(
      id: 'vendor-1',
      name: 'Vendor One',
      email: 'ap@vendor.test',
    );

    test('builds a running vendor statement from bills and payments', () {
      final statement = service.build(
        vendor: vendor,
        asOf: asOf,
        bills: [
          _bill(
            id: 'bill-1',
            invoiceNumber: 'BILL-001',
            invoiceDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 5, 15),
            amount: 1000,
            payments: [
              Payment(
                id: 'payment-1',
                invoiceId: 'bill-1',
                amount: 250,
                paymentDate: DateTime(2026, 5, 5),
                reference: 'PAY-001',
              ),
            ],
          ),
          _bill(
            id: 'bill-2',
            invoiceNumber: 'BILL-002',
            invoiceDate: DateTime(2026, 5, 20),
            dueDate: DateTime(2026, 6, 15),
            amount: 400,
          ),
        ],
        payments: [
          Payment(
            id: 'payment-1',
            invoiceId: 'bill-1',
            amount: 250,
            paymentDate: DateTime(2026, 5, 5),
            reference: 'PAY-001',
          ),
        ],
      );

      expect(statement.totalBilled, 1400);
      expect(statement.totalPaid, 250);
      expect(statement.outstandingAmount, 1150);
      expect(statement.overdueAmount, 750);
      expect(statement.openBillCount, 2);
      expect(statement.lines.map((line) => line.type), [
        VendorStatementLineType.bill,
        VendorStatementLineType.payment,
        VendorStatementLineType.bill,
      ]);
      expect(statement.lines.map((line) => line.balance), [1000, 750, 1150]);
    });

    test('ignores bills and payments for other vendors', () {
      final statement = service.build(
        vendor: vendor,
        asOf: asOf,
        bills: [
          _bill(
            id: 'bill-1',
            invoiceNumber: 'BILL-001',
            invoiceDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 6, 1),
            amount: 100,
          ),
          _bill(
            id: 'other-bill',
            vendorId: 'vendor-2',
            invoiceNumber: 'BILL-OTHER',
            invoiceDate: DateTime(2026, 5, 1),
            dueDate: DateTime(2026, 6, 1),
            amount: 900,
          ),
        ],
        payments: [
          Payment(
            id: 'other-payment',
            invoiceId: 'other-bill',
            amount: 900,
            paymentDate: DateTime(2026, 5, 2),
          ),
        ],
      );

      expect(statement.totalBilled, 100);
      expect(statement.totalPaid, 0);
      expect(statement.lines, hasLength(1));
      expect(statement.lines.single.reference, 'BILL-001');
    });
  });
}

Invoice _bill({
  required String id,
  required String invoiceNumber,
  required DateTime invoiceDate,
  required DateTime dueDate,
  required double amount,
  String vendorId = 'vendor-1',
  List<Payment>? payments,
}) {
  return Invoice(
    id: id,
    vendorId: vendorId,
    vendorName: 'Vendor One',
    invoiceNumber: invoiceNumber,
    invoiceDate: invoiceDate,
    dueDate: dueDate,
    amount: amount,
    description: 'Statement test bill',
    payments: payments,
  );
}
