import '../../../product/models/product.dart';

class Receipt {
  final String id;
  final List<Product> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double total;
  final DateTime dateTime;
  final String cashierName;
  final PaymentMethod paymentMethod;

  Receipt({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.total,
    required this.dateTime,
    required this.cashierName,
    required this.paymentMethod,
  });
}

enum PaymentMethod { cash, card, other }
