import 'dart:convert';

import 'promotion.dart';

class Cashback {
  final double amount;
  final double minPurchase;
  final Promotion promotion;

  Cashback({
    required this.amount,
    required this.minPurchase,
    required this.promotion,
  });

  Cashback copyWith({
    double? amount,
    double? minPurchase,
    Promotion? promotion,
  }) {
    return Cashback(
      amount: amount ?? this.amount,
      minPurchase: minPurchase ?? this.minPurchase,
      promotion: promotion ?? this.promotion,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'minPurchase': minPurchase,
      'promotion': promotion.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Cashback(amount: $amount, minPurchase: $minPurchase, promotion: $promotion)';
  }
}
