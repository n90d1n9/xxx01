import 'dart:convert';

import 'bundling_item.dart';
import 'enums.dart';
import 'promotion.dart';

class Bundling {
  final Unit unit;
  final double bundlingPrice;
  final List<BundlingItem> items;
  final Promotion promotion;

  Bundling({
    required this.unit,
    required this.bundlingPrice,
    required this.items,
    required this.promotion,
  });

  Bundling copyWith({
    Unit? unit,
    double? bundlingPrice,
    List<BundlingItem>? items,
    Promotion? promotion,
  }) {
    return Bundling(
      unit: unit ?? this.unit,
      bundlingPrice: bundlingPrice ?? this.bundlingPrice,
      items: items ?? this.items,
      promotion: promotion ?? this.promotion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'unit': unit,
      'bundlingPrice': bundlingPrice,
      'items': items.map((item) => item.toMap()).toList(),
      'promotion': promotion.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Bundling(unit: $unit, bundlingPrice: $bundlingPrice, items: $items, promotion: $promotion)';
  }
}
