import '../../../product/models/product.dart';

class OrderItem {
  final String id;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double discount;

  OrderItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });

  double get total => unitPrice * quantity - discount;
}
