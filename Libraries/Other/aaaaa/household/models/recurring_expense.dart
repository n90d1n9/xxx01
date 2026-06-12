class RecurringExpense {
  final String id;
  final String name;
  final double amount;
  final String category;
  final RecurrenceType recurrence;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;

  RecurringExpense({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'amount': amount,
    'category': category,
    'recurrence': recurrence.index,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'isActive': isActive,
  };

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      RecurringExpense(
        id: json['id'],
        name: json['name'],
        amount: json['amount'],
        category: json['category'],
        recurrence: RecurrenceType.values[json['recurrence']],
        startDate: DateTime.parse(json['startDate']),
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        isActive: json['isActive'] ?? true,
      );

  RecurringExpense copyWith({
    String? name,
    double? amount,
    String? category,
    RecurrenceType? recurrence,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return RecurringExpense(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum RecurrenceType { daily, weekly, monthly, yearly }
