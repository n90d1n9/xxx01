class Payment {
  final String id;
  final double amount;
  final String method;
  final DateTime timestamp;
  final String reference;
  final bool isComplete;

  Payment({
    required this.id,
    required this.amount,
    required this.method,
    required this.timestamp,
    required this.reference,
    required this.isComplete,
  });
}
