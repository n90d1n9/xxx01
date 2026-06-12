enum TransactionType { income, expense }

enum TransactionCategory {
  sales,
  services,
  investments,
  otherIncome,
  costOfGoodsSold,
  wages,
  rent,
  utilities,
  marketing,
  supplies,
  maintenance,
  insurance,
  taxes,
  otherExpense,
}

class Transaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final TransactionType type;
  final TransactionCategory category;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  Transaction copyWith({
    String? id,
    String? description,
    double? amount,
    DateTime? date,
    TransactionType? type,
    TransactionCategory? category,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      type: type ?? this.type,
      category: category ?? this.category,
    );
  }
}
