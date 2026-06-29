class Invoice {
  final String id;
  final String customerId;
  final double amount;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<Payment> payments;
  final String status;

  final String? invoiceNumber; // 'paid', 'partial', 'overdue', 'pending'

  Invoice({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.issueDate,
    required this.dueDate,
    required this.payments,
    required this.status,
    this.invoiceNumber,
  });

  double get paidAmount =>
      payments.fold(0, (sum, payment) => sum + payment.amount);
  double get remainingAmount => amount - paidAmount;
  bool get isOverdue => dueDate.isBefore(DateTime.now()) && remainingAmount > 0;
  int get daysOverdue =>
      isOverdue ? DateTime.now().difference(dueDate).inDays : 0;
}

class Invoice {
  final String id;
  final String vendorName;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final String status; // 'pending', 'overdue', 'paid'

  Invoice({
    required this.id,
    required this.vendorName,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.status,
  });
}
