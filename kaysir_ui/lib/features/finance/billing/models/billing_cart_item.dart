import 'billing_product.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String tenantId;

  const CartItem({
    required this.product,
    this.quantity = 1,
    required this.tenantId,
  });

  double get total => product.price * quantity;
}
