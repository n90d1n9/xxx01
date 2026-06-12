import '../models/invoice.dart';
import '../models/payable_payment_run.dart';
import '../models/payment.dart';

class PayablePaymentRunService {
  const PayablePaymentRunService();

  List<Invoice> openBills(Iterable<Invoice> bills) {
    return bills.where((bill) => bill.remainingAmount > 0).toList()
      ..sort(_compareByDueDateThenReference);
  }

  PayablePaymentRunPlan plan({
    required Iterable<Invoice> bills,
    required Set<String> selectedBillIds,
  }) {
    final selectedBills =
        openBills(
          bills,
        ).where((bill) => selectedBillIds.contains(bill.id)).toList();

    return PayablePaymentRunPlan(
      items: [
        for (final bill in selectedBills) PayablePaymentRunItem(bill: bill),
      ],
    );
  }

  Set<String> dueOnOrBefore({
    required Iterable<Invoice> bills,
    required DateTime date,
  }) {
    final cutoff = _dateOnly(date);
    return {
      for (final bill in openBills(bills))
        if (bill.dueDate != null && !_dateOnly(bill.dueDate!).isAfter(cutoff))
          bill.id,
    };
  }

  PayablePaymentRunRecord record({
    required String id,
    required String reference,
    required DateTime paymentDate,
    required DateTime createdAt,
    required String method,
    required PayablePaymentRunPlan plan,
    required Iterable<Payment> payments,
  }) {
    final paymentByInvoiceId = payments.byInvoiceId;

    return PayablePaymentRunRecord(
      id: id,
      reference: reference,
      paymentDate: paymentDate,
      createdAt: createdAt,
      method: method,
      items: [
        for (final item in plan.items)
          PayablePaymentRunRecordItem(
            billId: item.billId,
            billReference: item.billReference,
            vendorName: item.vendorName,
            dueDate: item.dueDate,
            paymentId: paymentByInvoiceId[item.billId]?.id ?? '',
            amount: paymentByInvoiceId[item.billId]?.amount ?? item.amount,
          ),
      ],
    );
  }

  int _compareByDueDateThenReference(Invoice a, Invoice b) {
    final aDueDate = a.dueDate ?? DateTime(9999);
    final bDueDate = b.dueDate ?? DateTime(9999);
    final dueDateComparison = aDueDate.compareTo(bDueDate);
    if (dueDateComparison != 0) {
      return dueDateComparison;
    }

    return (a.invoiceNumber ?? a.id).compareTo(b.invoiceNumber ?? b.id);
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
