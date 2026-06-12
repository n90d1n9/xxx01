import 'payment.dart';

enum InvoiceStatus {
  pending,
  partiallyPaid,
  paid,
  overdue,
  outstanding,
  disputed,
}

class Invoice {
  final String id;
  final String? vendorId;
  final String? invoiceNumber;
  final DateTime? invoiceDate;
  final DateTime? dueDate;
  final double amount;
  final String description;
  final InvoiceStatus status;
  final String? vendorName;
  final bool isPaid;
  final String? customerId;
  final DateTime? issueDate;
  final String? reference;
  final List<Payment>? payments;
  final String? expenseAccountId;

  Invoice({
    required this.id,
    this.vendorId,
    this.invoiceNumber,
    this.invoiceDate,
    this.dueDate,
    this.amount = 0,
    this.description = '',
    this.customerId,
    this.issueDate,
    this.reference,
    this.status = InvoiceStatus.pending,
    this.vendorName,
    this.isPaid = false,
    this.payments,
    this.expenseAccountId,
  });

  double get paidAmount {
    if (payments == null || payments!.isEmpty) {
      return status == InvoiceStatus.paid ? amount : 0;
    }
    return payments!.fold(0, (sum, payment) => sum + payment.amount);
  }

  double get remainingAmount => amount - paidAmount;
  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      remainingAmount > 0;
  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate!).inDays : 0;

  Invoice copyWith({
    String? id,
    String? vendorId,

    String? customerId,
    DateTime? issueDate,
    String? invoiceNumber,
    DateTime? invoiceDate,
    DateTime? dueDate,
    double? amount,
    String? description,
    String? reference,
    InvoiceStatus? status,
    String? vendorName,
    bool? isPaid,
    double? remainingAmount,
    List<Payment>? payments,
    String? expenseAccountId,
  }) {
    return Invoice(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      issueDate: issueDate ?? this.issueDate,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      status: status ?? this.status,
      vendorName: vendorName ?? this.vendorName,
      isPaid: isPaid ?? this.isPaid,
      payments: payments ?? this.payments,
      expenseAccountId: expenseAccountId ?? this.expenseAccountId,
    );
  }
}
