import 'dart:convert';

import '../../cashier/models/product.dart';

class BundlingItem {
  final int quantity;
  final Product product;

  BundlingItem({required this.quantity, required this.product});

  BundlingItem copyWith({int? quantity, Product? product}) {
    return BundlingItem(
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return {'quantity': quantity, 'product': product.toMap()};
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'BundlingItem(quantity: $quantity, product: $product)';
  }
}
