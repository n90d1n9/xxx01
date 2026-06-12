import '../../../ecommerce/cart/models/item.dart';

class Transaction {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final String cashierId;
  final DateTime timestamp;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.cashierId,
    required this.timestamp,
    required this.status,
  });
}

enum PaymentMethod { cash, card, qris, other }

enum TransactionStatus { completed, voided, refunded }
