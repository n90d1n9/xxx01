import 'dart:convert';

import 'bundling_item.dart';
import 'enums.dart';
import 'promotion.dart';

class BuyAnyWithAny {
  final double withPrice;
  final Promotion promotion;
  final List<BuyAnyType> types;
  final List<BundlingItem> items;

  BuyAnyWithAny({
    required this.withPrice,
    required this.promotion,
    required this.types,
    required this.items,
  });

  BuyAnyWithAny copyWith({
    double? withPrice,
    Promotion? promotion,
    List<BuyAnyType>? types,
    List<BundlingItem>? items,
  }) {
    return BuyAnyWithAny(
      withPrice: withPrice ?? this.withPrice,
      promotion: promotion ?? this.promotion,
      types: types ?? this.types,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'withPrice': withPrice,
      'promotion': promotion.toMap(),
      'types': types.map((type) => type.toString()).toList(),
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'BuyAnyWithAny(withPrice: $withPrice, promotion: $promotion, types: $types, items: $items)';
  }
}
