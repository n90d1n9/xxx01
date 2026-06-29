class CostEstimate {
  final double estimatedCost;
  final String currency;
  final Map<String, dynamic> breakdown;

  CostEstimate({
    required this.estimatedCost,
    this.currency = 'USD',
    this.breakdown = const {},
  });

  factory CostEstimate.free() => CostEstimate(estimatedCost: 0.0);
}
