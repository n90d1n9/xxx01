import 'cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime dateTime;
  final PaymentMethod paymentMethod;
  final OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.dateTime,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
  });
}

enum PaymentMethod { cash, card, mobilePay }

enum OrderStatus { pending, completed, cancelled }
