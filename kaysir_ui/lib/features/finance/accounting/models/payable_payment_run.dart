import 'invoice.dart';
import 'payment.dart';

class PayablePaymentRunItem {
  final Invoice bill;

  const PayablePaymentRunItem({required this.bill});

  String get billId => bill.id;
  String get billReference => bill.invoiceNumber ?? bill.id;
  String get vendorName => bill.vendorName ?? 'Unknown Vendor';
  DateTime? get dueDate => bill.dueDate;
  double get amount => bill.remainingAmount;
}

class PayablePaymentRunPlan {
  final List<PayablePaymentRunItem> items;

  const PayablePaymentRunPlan({required this.items});

  double get totalAmount => items.fold(0, (total, item) => total + item.amount);

  int get billCount => items.length;

  bool get isEmpty => items.isEmpty;
}

class PayablePaymentRunRecordItem {
  final String billId;
  final String billReference;
  final String vendorName;
  final DateTime? dueDate;
  final String paymentId;
  final double amount;

  const PayablePaymentRunRecordItem({
    required this.billId,
    required this.billReference,
    required this.vendorName,
    required this.paymentId,
    required this.amount,
    this.dueDate,
  });
}

class PayablePaymentRunRecord {
  final String id;
  final String reference;
  final DateTime paymentDate;
  final DateTime createdAt;
  final String method;
  final List<PayablePaymentRunRecordItem> items;

  const PayablePaymentRunRecord({
    required this.id,
    required this.reference,
    required this.paymentDate,
    required this.createdAt,
    required this.method,
    required this.items,
  });

  double get totalAmount => items.fold(0, (total, item) => total + item.amount);

  int get billCount => items.length;
}

extension PayablePaymentRunRecordPaymentLookup on Iterable<Payment> {
  Map<String, Payment> get byInvoiceId {
    return {for (final payment in this) payment.invoiceId: payment};
  }
}
