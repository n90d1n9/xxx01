import 'dart:convert';

import 'enums.dart';
import 'promotion.dart';

class Customer {
  final String id;
  final String name;
  final String email;

  Customer({required this.id, required this.name, required this.email});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class Loyalty {
  final int value;
  final DateTime startDate;
  final DateTime endDate;
  final DiscountType type;
  final Promotion? promotion;
  final Customer? customer;

  Loyalty({
    required this.value,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.promotion,
    this.customer,
  });

  Loyalty copyWith({
    int? value,
    DateTime? startDate,
    DateTime? endDate,
    DiscountType? type,
    Promotion? promotion,
    Customer? customer,
  }) {
    return Loyalty(
      value: value ?? this.value,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      promotion: promotion ?? this.promotion,
      customer: customer ?? this.customer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type.toString(),
      'promotion': promotion?.toMap(),
      'customer': customer?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Loyalty(value: $value, startDate: $startDate, endDate: $endDate, type: $type, promotion: $promotion, customer: $customer)';
  }
}
