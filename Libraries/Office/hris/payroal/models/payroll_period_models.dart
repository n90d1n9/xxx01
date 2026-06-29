class PayrollRunPeriod {
  final String id;
  final String label;
  final DateTime asOfDate;
  final DateTime payDate;
  final String statusLabel;
  final bool isCurrent;

  const PayrollRunPeriod({
    required this.id,
    required this.label,
    required this.asOfDate,
    required this.payDate,
    required this.statusLabel,
    required this.isCurrent,
  });
}
