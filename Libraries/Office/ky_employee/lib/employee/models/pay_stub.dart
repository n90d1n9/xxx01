class PayStub {
  final String id;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final DateTime payDate;
  final double grossAmount;
  final double netAmount;

  PayStub({
    required this.id,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.payDate,
    required this.grossAmount,
    required this.netAmount,
  });

  double get totalDeductions {
    final value = grossAmount - netAmount;
    return value < 0 ? 0 : value;
  }

  double get netRate => grossAmount == 0 ? 0 : netAmount / grossAmount;
}
