import 'dart:convert';

import 'enums.dart';
import 'promotion.dart';
import 'user.dart';

class Coupons {
  final String code;
  final DateTime startDate;
  final DateTime endDate;
  final double value;
  final DiscountType type;
  final String? description;
  final List<Promotion>? promotions;
  final User? referrer;

  Coupons({
    required this.code,
    required this.startDate,
    required this.endDate,
    required this.value,
    required this.type,
    this.description,
    this.promotions,
    this.referrer,
  });

  Coupons copyWith({
    String? code,
    DateTime? startDate,
    DateTime? endDate,
    double? value,
    DiscountType? type,
    String? description,
    List<Promotion>? promotions,
    User? referrer,
  }) {
    return Coupons(
      code: code ?? this.code,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      value: value ?? this.value,
      type: type ?? this.type,
      description: description ?? this.description,
      promotions: promotions ?? this.promotions,
      referrer: referrer ?? this.referrer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'value': value,
      'type': type.toString(),
      'description': description,
      'promotions': promotions?.map((promo) => promo.toMap()).toList(),
      'referrer': referrer?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Coupons(code: $code, startDate: $startDate, endDate: $endDate, value: $value, type: $type, description: $description, promotions: $promotions, referrer: $referrer)';
  }
}
