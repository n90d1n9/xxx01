import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

enum TransactionType { debit, credit }

class LedgerTransaction {
  final String id;
  final DateTime date;
  final String account;
  final String description;
  final TransactionType type;
  final double amount;
  final String reference;
  final String category;

  LedgerTransaction({
    String? id,
    required this.date,
    required this.account,
    required this.description,
    required this.type,
    required this.amount,
    required this.reference,
    required this.category,
  }) : id = id ?? const Uuid().v4();

  String get formattedDate => DateFormat('yyyy-MM-dd').format(date);

  String get formattedAmount =>
      NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);

  LedgerTransaction copyWith({
    String? id,
    DateTime? date,
    String? account,
    String? description,
    TransactionType? type,
    double? amount,
    String? reference,
    String? category,
  }) {
    return LedgerTransaction(
      id: id ?? this.id,
      date: date ?? this.date,
      account: account ?? this.account,
      description: description ?? this.description,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      reference: reference ?? this.reference,
      category: category ?? this.category,
    );
  }
}
