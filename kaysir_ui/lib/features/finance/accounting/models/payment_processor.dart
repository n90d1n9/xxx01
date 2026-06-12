class PaymentProcessor {
  final String id;
  final String name;
  final double processingFee;
  final int processingTime; // in days

  PaymentProcessor({
    required this.id,
    required this.name,
    required this.processingFee,
    required this.processingTime,
  });
}
