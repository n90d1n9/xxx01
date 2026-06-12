class Promotion {
  final String id;
  final String name;
  final String code;
  final double discountPercentage;
  final double discountAmount;
  final bool isActive;
  final DateTime validUntil;

  Promotion({
    required this.id,
    required this.name,
    required this.code,
    required this.discountPercentage,
    required this.discountAmount,
    required this.isActive,
    required this.validUntil,
  });
}
