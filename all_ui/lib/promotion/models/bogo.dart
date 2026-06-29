import 'dart:convert';

import '../../cashier/models/product.dart';
import 'bogo_variant.dart';
import 'promotion.dart';

class Bogo {
  final int quantity;
  final bool isAllVariant;
  final Promotion promotion;
  final Product product;
  final List<BogoVariant> variants;

  Bogo({
    this.quantity = 1,
    this.isAllVariant = false,
    required this.promotion,
    required this.product,
    required this.variants,
  });

  Bogo copyWith({
    int? quantity,
    bool? isAllVariant,
    Promotion? promotion,
    Product? product,
    List<BogoVariant>? variants,
  }) {
    return Bogo(
      quantity: quantity ?? this.quantity,
      isAllVariant: isAllVariant ?? this.isAllVariant,
      promotion: promotion ?? this.promotion,
      product: product ?? this.product,
      variants: variants ?? this.variants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'quantity': quantity,
      'isAllVariant': isAllVariant,
      'promotion': promotion.toMap(),
      'product': product.toMap(),
      'variants': variants.map((variant) => variant.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Bogo(quantity: $quantity, isAllVariant: $isAllVariant, promotion: $promotion, product: $product, variants: $variants)';
  }
}
