class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime? paymentDate;
  final String? referenceNumber;
  final String? processorId;
  final String notes;
  final String? reference;

  final String? method;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    this.paymentDate,
    this.referenceNumber,
    this.processorId,
    this.notes = '',
    this.reference,
    this.method,
  });
}
