import 'dart:convert';

import '../../cashier/models/product.dart';

class BogoVariant {
  final String name;
  final String? description;
  final Product product;

  BogoVariant({required this.name, this.description, required this.product});

  BogoVariant copyWith({String? name, String? description, Product? product}) {
    return BogoVariant(
      name: name ?? this.name,
      description: description ?? this.description,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'product': product.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'BogoVariant(name: $name, description: $description, product: $product)';
  }
}
