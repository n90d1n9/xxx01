import 'dart:convert';

import 'enums.dart';
import 'promotion.dart';

class Discount {
  final int id;
  final String name;
  final DiscountType type;
  final DateTime startDate;
  final DateTime endDate;
  final String? description;
  final double value;
  final Promotion? promotion;

  Discount({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.endDate,
    this.description,
    required this.value,
    this.promotion,
  });

  Discount copyWith({
    int? id,
    String? name,
    DiscountType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    double? value,
    Promotion? promotion,
  }) {
    return Discount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      value: value ?? this.value,
      promotion: promotion ?? this.promotion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'description': description,
      'value': value,
      'promotion': promotion?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Discount(id: $id, name: $name, type: $type, startDate: $startDate, endDate: $endDate, description: $description, value: $value, promotion: $promotion)';
  }
}
