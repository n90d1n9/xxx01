class FinancialEntry {
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final String type; // "income" or "expense" or "asset" or "liability"
  final String? sourceCategory;

  FinancialEntry({
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,
    this.sourceCategory,
  });
}
