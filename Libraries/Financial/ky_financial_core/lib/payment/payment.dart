class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime date;
  final String method; // 'credit_card', 'bank_transfer', 'cash', etc.

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.date,
    required this.method,
  });
}
