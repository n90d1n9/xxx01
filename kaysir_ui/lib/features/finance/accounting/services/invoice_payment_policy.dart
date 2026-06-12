import '../models/invoice.dart';
import '../models/payment.dart';

class InvoicePaymentPolicy {
  final double tolerance;

  const InvoicePaymentPolicy({this.tolerance = 0.01});

  double totalPaid(Iterable<Payment> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  InvoiceStatus statusFor({
    required Invoice invoice,
    required Iterable<Payment> payments,
    DateTime? asOf,
  }) {
    final paidAmount = totalPaid(payments);
    if (paidAmount + tolerance >= invoice.amount) {
      return InvoiceStatus.paid;
    }
    if (paidAmount > tolerance) {
      return InvoiceStatus.partiallyPaid;
    }

    final dueDate = invoice.dueDate;
    final today = asOf ?? DateTime.now();
    if (dueDate != null && dueDate.isBefore(today)) {
      return InvoiceStatus.overdue;
    }

    if (invoice.status == InvoiceStatus.outstanding ||
        invoice.status == InvoiceStatus.disputed) {
      return invoice.status;
    }

    return InvoiceStatus.pending;
  }
}
