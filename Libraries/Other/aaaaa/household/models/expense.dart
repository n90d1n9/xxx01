import 'payment.dart';

// Expense model (if not already defined)
class Expense {
  final String id;
  final String category;
  final double amount;
  final String description;
  final PaymentMethod paymentMethod;
  final DateTime date;

  Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.description,
    required this.paymentMethod,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'category': category,
    'date': date.toIso8601String(),
    'paymentMethod': paymentMethod.index,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    id: json['id'],
    description: json['description'],
    amount: json['amount'],
    category: json['category'],
    date: DateTime.parse(json['date']),
    paymentMethod: PaymentMethod.values[json['paymentMethod']],
  );
}
