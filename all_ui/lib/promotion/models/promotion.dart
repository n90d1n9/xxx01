import 'dart:convert';

import '../../cashier/models/product.dart';
import 'enums.dart';

class Promotion {
  final int id;
  final PromotionType type;
  final double originPrice;
  final double promoPrice;
  final bool isActive;
  final bool isRequirement;
  final bool? isRedeem;
  final String? uri;
  final Product? product;

  Promotion({
    required this.id,
    required this.type,
    required this.originPrice,
    required this.promoPrice,
    this.isActive = false,
    this.isRequirement = false,
    this.isRedeem,
    this.uri,
    this.product,
  });

  Promotion copyWith({
    int? id,
    PromotionType? type,
    double? originPrice,
    double? promoPrice,
    bool? isActive,
    bool? isRequirement,
    bool? isRedeem,
    String? uri,
    Product? product,
  }) {
    return Promotion(
      id: id ?? this.id,
      type: type ?? this.type,
      originPrice: originPrice ?? this.originPrice,
      promoPrice: promoPrice ?? this.promoPrice,
      isActive: isActive ?? this.isActive,
      isRequirement: isRequirement ?? this.isRequirement,
      isRedeem: isRedeem ?? this.isRedeem,
      uri: uri ?? this.uri,
      product: product ?? this.product,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'originPrice': originPrice,
      'promoPrice': promoPrice,
      'isActive': isActive,
      'isRequirement': isRequirement,
      'isRedeem': isRedeem,
      'uri': uri,
      'product': product?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Promotion(id: $id, type: $type, originPrice: $originPrice, promoPrice: $promoPrice, isActive: $isActive, isRequirement: $isRequirement, isRedeem: $isRedeem, uri: $uri, product: $product)';
  }
}
